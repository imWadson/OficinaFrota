import { supabase } from './supabase'

// =====================================================
// INTERFACES SIMPLIFICADAS - SEM OVERENGINEERING
// =====================================================

export interface RelatorioFrota {
    periodo_inicio: string
    periodo_fim: string
    regional_id?: string
    tipo_veiculo?: string
    status?: string
}

export interface RelatorioFrotaResult {
    total_veiculos: number
    veiculos_ativos: number
    veiculos_manutencao: number
    veiculos_por_tipo: Array<{
        tipo: string
        quantidade: number
        percentual: number
    }>
    quilometragem_media: number
}

export interface RelatorioOficina {
    periodo_inicio: string
    periodo_fim: string
    status?: string
    prioridade?: string
}

export interface RelatorioOficinaResult {
    total_os: number
    os_concluidas: number
    os_pendentes: number
    tempo_medio_conclusao: number
    custo_total: number
    os_por_mes: Array<{
        mes: string
        quantidade: number
    }>
}

export interface RelatorioEstoque {
    categoria?: string
    fornecedor?: string
}

export interface RelatorioEstoqueResult {
    total_pecas: number
    valor_total_estoque: number
    pecas_estoque_baixo: number
    pecas_por_categoria: Array<{
        categoria: string
        quantidade: number
        valor_total: number
    }>
}

// =====================================================
// FUNÇÕES SIMPLIFICADAS - SEM OVERENGINEERING
// =====================================================

/**
 * Gera relatório básico da frota
 */
export async function gerarRelatorioFrota(params: RelatorioFrota): Promise<RelatorioFrotaResult> {
    try {
        // Query única para veículos
        let query = supabase
            .from('veiculos')
            .select('id, tipo, status, quilometragem')
            .gte('criado_em', params.periodo_inicio)
            .lte('criado_em', params.periodo_fim)

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
                veiculos_por_tipo: [],
                quilometragem_media: 0
            }
        }

        // Cálculos básicos
        const total_veiculos = veiculos.length
        const veiculos_ativos = veiculos.filter(v => v.status === 'ativo').length
        const veiculos_manutencao = veiculos.filter(v => v.status === 'manutencao').length
        const quilometragem_media = Math.round(
            veiculos.reduce((sum, v) => sum + (v.quilometragem || 0), 0) / total_veiculos
        )

        // Agrupar por tipo
        const veiculosPorTipo = Object.entries(
            veiculos.reduce((acc, v) => {
                acc[v.tipo] = (acc[v.tipo] || 0) + 1
                return acc
            }, {} as Record<string, number>)
        ).map(([tipo, quantidade]) => ({
            tipo,
            quantidade,
            percentual: Math.round((quantidade / total_veiculos) * 100)
        }))

        return {
            total_veiculos,
            veiculos_ativos,
            veiculos_manutencao,
            veiculos_por_tipo,
            quilometragem_media
        }
    } catch (error) {
        console.error('Erro ao gerar relatório da frota:', error)
        throw error
    }
}

/**
 * Gera relatório básico da oficina
 */
export async function gerarRelatorioOficina(params: RelatorioOficina): Promise<RelatorioOficinaResult> {
    try {
        // Query única para ordens de serviço
        let query = supabase
            .from('ordens_servico')
            .select('id, status, prioridade, data_entrada, data_saida, custo_total')
            .gte('data_entrada', params.periodo_inicio)
            .lte('data_entrada', params.periodo_fim)

        if (params.status) {
            query = query.eq('status', params.status)
        }

        if (params.prioridade) {
            query = query.eq('prioridade', params.prioridade)
        }

        const { data: ordens, error } = await query
        if (error) throw error

        if (!ordens || ordens.length === 0) {
            return {
                total_os: 0,
                os_concluidas: 0,
                os_pendentes: 0,
                tempo_medio_conclusao: 0,
                custo_total: 0,
                os_por_mes: []
            }
        }

        // Cálculos básicos
        const total_os = ordens.length
        const os_concluidas = ordens.filter(os => os.status === 'concluida').length
        const os_pendentes = ordens.filter(os => os.status === 'em_andamento').length
        const custo_total = ordens.reduce((sum, os) => sum + (os.custo_total || 0), 0)

        // Tempo médio de conclusão
        const osCompletas = ordens.filter(os => os.data_entrada && os.data_saida)
        const tempo_medio_conclusao = osCompletas.length > 0
            ? Math.round(osCompletas.reduce((sum, os) => {
                const entrada = new Date(os.data_entrada)
                const saida = new Date(os.data_saida)
                return sum + (saida.getTime() - entrada.getTime()) / (1000 * 60 * 60 * 24)
            }, 0) / osCompletas.length)
            : 0

        // OS por mês (simplificado)
        const os_por_mes = Object.entries(
            ordens.reduce((acc, os) => {
                const mes = new Date(os.data_entrada).toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' })
                acc[mes] = (acc[mes] || 0) + 1
                return acc
            }, {} as Record<string, number>)
        ).map(([mes, quantidade]) => ({ mes, quantidade }))

        return {
            total_os,
            os_concluidas,
            os_pendentes,
            tempo_medio_conclusao,
            custo_total,
            os_por_mes
        }
    } catch (error) {
        console.error('Erro ao gerar relatório da oficina:', error)
        throw error
    }
}

/**
 * Gera relatório básico do estoque
 */
export async function gerarRelatorioEstoque(params: RelatorioEstoque): Promise<RelatorioEstoqueResult> {
    try {
        // Query única para peças
        let query = supabase
            .from('pecas')
            .select('id, nome, categoria, fornecedor, quantidade_estoque, custo_unitario')

        if (params.categoria) {
            query = query.eq('categoria', params.categoria)
        }

        if (params.fornecedor) {
            query = query.eq('fornecedor', params.fornecedor)
        }

        const { data: pecas, error } = await query
        if (error) throw error

        if (!pecas || pecas.length === 0) {
            return {
                total_pecas: 0,
                valor_total_estoque: 0,
                pecas_estoque_baixo: 0,
                pecas_por_categoria: []
            }
        }

        // Cálculos básicos
        const total_pecas = pecas.length
        const valor_total_estoque = pecas.reduce((sum, p) =>
            sum + (p.quantidade_estoque * p.custo_unitario), 0
        )
        const pecas_estoque_baixo = pecas.filter(p => p.quantidade_estoque < 10).length

        // Agrupar por categoria
        const pecas_por_categoria = Object.entries(
            pecas.reduce((acc, p) => {
                const categoria = p.categoria || 'Sem categoria'
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

        return {
            total_pecas,
            valor_total_estoque,
            pecas_estoque_baixo,
            pecas_por_categoria
        }
    } catch (error) {
        console.error('Erro ao gerar relatório do estoque:', error)
        throw error
    }
}
