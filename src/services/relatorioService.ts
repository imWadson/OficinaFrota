import { supabase } from './supabase'
import type {
    RelatorioFrota,
    RelatorioOficina,
    RelatorioEstoque,
    RelatorioFrotaResult,
    RelatorioOficinaResult,
    RelatorioEstoqueResult
} from '../entities/relatorio'

export class RelatorioService {
    /**
     * Gera relatório completo da frota
     */
    static async gerarRelatorioFrota(params: RelatorioFrota): Promise<RelatorioFrotaResult> {
        try {
            // Buscar veículos no período
            let query = supabase
                .from('veiculos')
                .select('*')
                .gte('criado_em', params.periodo_inicio)
                .lte('criado_em', params.periodo_fim)

            if (params.regional_id) {
                // Aqui precisaríamos de uma relação com regional_id
                // Por enquanto, vamos buscar todos
            }

            if (params.tipo_veiculo) {
                query = query.eq('tipo', params.tipo_veiculo)
            }

            if (params.status) {
                query = query.eq('status', params.status)
            }

            const { data: veiculos, error } = await query

            if (error) throw error

            if (!veiculos || veiculos.length === 0) {
                return {
                    total_veiculos: 0,
                    veiculos_ativos: 0,
                    veiculos_manutencao: 0,
                    veiculos_oficina_externa: 0,
                    quilometragem_media: 0,
                    custo_medio_manutencao: 0,
                    veiculos_por_tipo: [],
                    veiculos_por_regional: []
                }
            }

            // Calcular estatísticas básicas
            const total_veiculos = veiculos.length
            const veiculos_ativos = veiculos.filter(v => v.status === 'ativo').length
            const veiculos_manutencao = veiculos.filter(v => v.status === 'manutencao').length
            const veiculos_oficina_externa = veiculos.filter(v => v.status === 'oficina_externa').length

            // Calcular quilometragem média
            const quilometragem_media = Math.round(
                veiculos.reduce((sum, v) => sum + v.quilometragem, 0) / total_veiculos
            )

            // Calcular custo médio de manutenção (buscar OS relacionadas)
            const veiculoIds = veiculos.map(v => v.id)
            const { data: ordens } = await supabase
                .from('ordens_servico')
                .select('id, veiculo_id')
                .in('veiculo_id', veiculoIds)

            const { data: pecasUsadas } = await supabase
                .from('pecas_usadas')
                .select('quantidade, peca_id')
                .in('ordem_servico_id', ordens?.map(o => o.id) || [])

            const { data: pecas } = await supabase
                .from('pecas')
                .select('custo_unitario')
                .in('id', pecasUsadas?.map(p => p.peca_id) || [])

            const custo_total_pecas = pecasUsadas?.reduce((sum, pu) => {
                const peca = pecas?.find(p => (p as any).id === pu.peca_id)
                return sum + ((peca as any)?.custo_unitario || 0) * pu.quantidade
            }, 0) || 0

            const custo_medio_manutencao = ordens && ordens.length > 0
                ? custo_total_pecas / ordens.length
                : 0

            // Agrupar por tipo de veículo
            const veiculosPorTipo = Object.entries(
                veiculos.reduce((acc, v) => {
                    acc[v.tipo] = (acc[v.tipo] || 0) + 1
                    return acc
                }, {} as Record<string, number>)
            ).map(([tipo, quantidade]) => ({
                tipo,
                quantidade: quantidade as number,
                percentual: Math.round((quantidade as number / total_veiculos) * 100)
            }))

            // Por enquanto, regional será hardcoded (precisa implementar relação)
            const veiculosPorRegional = [{
                regional: 'Metropolitana',
                quantidade: total_veiculos,
                percentual: 100
            }]

            return {
                total_veiculos,
                veiculos_ativos,
                veiculos_manutencao,
                veiculos_oficina_externa,
                quilometragem_media,
                custo_medio_manutencao,
                veiculos_por_tipo: veiculosPorTipo,
                veiculos_por_regional: veiculosPorRegional
            }
        } catch (error) {
            console.error('Erro ao gerar relatório da frota:', error)
            throw error
        }
    }

    /**
     * Gera relatório da oficina
     */
    static async gerarRelatorioOficina(params: RelatorioOficina): Promise<RelatorioOficinaResult> {
        try {
            // Buscar ordens de serviço no período
            let query = supabase
                .from('ordens_servico')
                .select(`
          *,
          veiculos(placa, modelo),
          supervisores!ordens_servico_supervisor_entrega_id_fkey(nome)
        `)
                .gte('data_entrada', params.periodo_inicio)
                .lte('data_entrada', params.periodo_fim)

            if (params.supervisor_id) {
                query = query.eq('supervisor_entrega_id', params.supervisor_id)
            }

            if (params.status) {
                query = query.eq('status', params.status)
            }

            const { data: ordens, error } = await query

            if (error) throw error

            if (!ordens || ordens.length === 0) {
                return {
                    total_ordens: 0,
                    ordens_concluidas: 0,
                    ordens_em_andamento: 0,
                    tempo_medio_conclusao: 0,
                    custo_total_pecas: 0,
                    custo_total_servicos_externos: 0,
                    produtividade_por_supervisor: [],
                    ordens_por_periodo: []
                }
            }

            const total_ordens = ordens.length
            const ordens_concluidas = ordens.filter(o => o.status === 'concluida').length
            const ordens_em_andamento = ordens.filter(o => o.status === 'em_andamento').length

            // Calcular tempo médio de conclusão
            const ordensCompletas = ordens.filter(o => o.status === 'concluida' && o.data_saida)
            const tempo_medio_conclusao = ordensCompletas.length > 0
                ? Math.round(
                    ordensCompletas.reduce((sum, o) => {
                        const entrada = new Date(o.data_entrada)
                        const saida = new Date(o.data_saida!)
                        return sum + (saida.getTime() - entrada.getTime()) / (1000 * 60 * 60 * 24) // dias
                    }, 0) / ordensCompletas.length
                )
                : 0

            // Calcular custo total de peças
            const { data: pecasUsadas } = await supabase
                .from('pecas_usadas')
                .select('quantidade, peca_id')
                .in('ordem_servico_id', ordens.map(o => o.id))

            const { data: pecas } = await supabase
                .from('pecas')
                .select('custo_unitario')
                .in('id', pecasUsadas?.map(p => p.peca_id) || [])

            const custo_total_pecas = pecasUsadas?.reduce((sum, pu) => {
                const peca = pecas?.find(p => (p as any).id === pu.peca_id)
                return sum + ((peca as any)?.custo_unitario || 0) * pu.quantidade
            }, 0) || 0

            // Calcular custo de serviços externos
            const { data: servicosExternos } = await supabase
                .from('servicos_externos')
                .select('valor')
                .in('ordem_servico_id', ordens.map(o => o.id))

            const custo_total_servicos_externos = servicosExternos?.reduce((sum, s) => sum + s.valor, 0) || 0

            // Produtividade por supervisor
            const produtividadePorSupervisor = Object.entries(
                ordens.reduce((acc, o) => {
                    const supervisorNome = o.supervisores?.nome || 'Não definido'
                    if (!acc[supervisorNome]) {
                        acc[supervisorNome] = { ordens: [], custos: [] }
                    }
                    acc[supervisorNome].ordens.push(o)
                    return acc
                }, {} as Record<string, { ordens: any[], custos: number[] }>)
            ).map(([supervisor, data]) => {
                const ordens_concluidas = data.ordens.filter(o => o.status === 'concluida').length
                const tempo_medio = ordens_concluidas > 0
                    ? Math.round(
                        data.ordens.filter(o => o.status === 'concluida' && o.data_saida)
                            .reduce((sum, o) => {
                                const entrada = new Date(o.data_entrada)
                                const saida = new Date(o.data_saida!)
                                return sum + (saida.getTime() - entrada.getTime()) / (1000 * 60 * 60 * 24)
                            }, 0) / ordens_concluidas
                    )
                    : 0

                // Custo médio aproximado (simplificado)
                const custo_medio = custo_total_pecas / total_ordens

                return {
                    supervisor,
                    ordens_concluidas,
                    tempo_medio,
                    custo_medio
                }
            })

            // Ordens por período (agrupadas por dia)
            const ordensPorPeriodo = Object.entries(
                ordens.reduce((acc, o) => {
                    const data = new Date(o.data_entrada).toLocaleDateString('pt-BR')
                    if (!acc[data]) {
                        acc[data] = { quantidade: 0, valor_total: 0 }
                    }
                    acc[data].quantidade++
                    // Valor aproximado baseado no custo médio
                    acc[data].valor_total += custo_total_pecas / total_ordens
                    return acc
                }, {} as Record<string, { quantidade: number, valor_total: number }>)
            ).map(([data, info]) => ({
                data,
                quantidade: info.quantidade,
                valor_total: Math.round(info.valor_total * 100) / 100
            }))

            return {
                total_ordens,
                ordens_concluidas,
                ordens_em_andamento,
                tempo_medio_conclusao,
                custo_total_pecas,
                custo_total_servicos_externos,
                produtividade_por_supervisor: produtividadePorSupervisor,
                ordens_por_periodo: ordensPorPeriodo
            }
        } catch (error) {
            console.error('Erro ao gerar relatório da oficina:', error)
            throw error
        }
    }

    /**
     * Gera relatório do estoque
     */
    static async gerarRelatorioEstoque(params: RelatorioEstoque): Promise<RelatorioEstoqueResult> {
        try {
            let query = supabase
                .from('pecas')
                .select('*')

            if (params.categoria) {
                // Implementar lógica de categoria quando disponível
            }

            if (params.fornecedor) {
                query = query.eq('fornecedor', params.fornecedor)
            }

            if (params.estoque_baixo) {
                // Por enquanto, vamos considerar estoque baixo como < 10
                query = query.lt('quantidade_estoque', 10)
            }

            const { data: pecas, error } = await query

            if (error) throw error

            if (!pecas || pecas.length === 0) {
                return {
                    total_pecas: 0,
                    valor_total_estoque: 0,
                    pecas_estoque_baixo: 0,
                    pecas_por_categoria: [],
                    fornecedores_principais: [],
                    movimentacao_estoque: []
                }
            }

            const total_pecas = pecas.length
            const valor_total_estoque = pecas.reduce((sum, p) =>
                sum + (p.quantidade_estoque * p.custo_unitario), 0
            )
            const pecas_estoque_baixo = pecas.filter(p => p.quantidade_estoque < 10).length

            // Agrupar por categoria (simplificado por tipo de peça)
            const pecasPorCategoria = Object.entries(
                pecas.reduce((acc, p) => {
                    const categoria = this.getCategoriaPeca(p.nome)
                    if (!acc[categoria]) {
                        acc[categoria] = { quantidade: 0, valor_total: 0 }
                    }
                    acc[categoria].quantidade++
                    acc[categoria].valor_total += p.quantidade_estoque * p.custo_unitario
                    return acc
                }, {} as Record<string, { quantidade: number, valor_total: number }>)
            ).map(([categoria, info]) => ({
                categoria,
                quantidade: info.quantidade,
                valor_total: Math.round(info.valor_total * 100) / 100
            }))

            // Fornecedores principais
            const fornecedoresPrincipais = Object.entries(
                pecas.reduce((acc, p) => {
                    const fornecedor = p.fornecedor || 'Não especificado'
                    if (!acc[fornecedor]) {
                        acc[fornecedor] = { quantidade_pecas: 0, valor_total: 0 }
                    }
                    acc[fornecedor].quantidade_pecas++
                    acc[fornecedor].valor_total += p.quantidade_estoque * p.custo_unitario
                    return acc
                }, {} as Record<string, { quantidade_pecas: number, valor_total: number }>)
            ).map(([fornecedor, info]) => ({
                fornecedor,
                quantidade_pecas: info.quantidade_pecas,
                valor_total: Math.round(info.valor_total * 100) / 100
            }))

            // Movimentação de estoque (simplificado - últimos 30 dias)
            const movimentacaoEstoque = await this.getMovimentacaoEstoque()

            return {
                total_pecas,
                valor_total_estoque,
                pecas_estoque_baixo,
                pecas_por_categoria,
                fornecedores_principais,
                movimentacao_estoque
            }
        } catch (error) {
            console.error('Erro ao gerar relatório do estoque:', error)
            throw error
        }
    }

    /**
     * Helper para categorizar peças
     */
    private static getCategoriaPeca(nome: string): string {
        const nomeLower = nome.toLowerCase()

        if (nomeLower.includes('filtro')) return 'Filtros'
        if (nomeLower.includes('óleo') || nomeLower.includes('oleo')) return 'Óleos e Fluidos'
        if (nomeLower.includes('motor') || nomeLower.includes('vela')) return 'Motor'
        if (nomeLower.includes('freio')) return 'Freios'
        if (nomeLower.includes('amortecedor') || nomeLower.includes('mola')) return 'Suspensão'
        if (nomeLower.includes('pneu')) return 'Pneus'
        if (nomeLower.includes('bateria') || nomeLower.includes('alternador')) return 'Elétrica'
        if (nomeLower.includes('hidráulico') || nomeLower.includes('hidraulico')) return 'Hidráulico'

        return 'Outros'
    }

    /**
     * Busca movimentação de estoque
     */
    private static async getMovimentacaoEstoque() {
        try {
            const { data: pecasUsadas, error } = await supabase
                .from('pecas_usadas')
                .select('quantidade, data_uso')
                .gte('data_uso', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())
                .order('data_uso')

            if (error) throw error

            // Agrupar por data
            const movimentacao = Object.entries(
                pecasUsadas?.reduce((acc, pu) => {
                    const data = new Date(pu.data_uso).toLocaleDateString('pt-BR')
                    if (!acc[data]) {
                        acc[data] = { entrada: 0, saida: 0, saldo: 0 }
                    }
                    acc[data].saida += pu.quantidade
                    return acc
                }, {} as Record<string, { entrada: number, saida: number, saldo: number }>) || {}
            ).map(([data, info]) => ({
                data,
                entrada: info.entrada,
                saida: info.saida,
                saldo: info.entrada - info.saida
            }))

            return movimentacao
        } catch (error) {
            console.error('Erro ao buscar movimentação de estoque:', error)
            return []
        }
    }
}
