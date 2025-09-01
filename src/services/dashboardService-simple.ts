import { supabase } from './supabase'

// =====================================================
// INTERFACES SIMPLIFICADAS - SEM OVERENGINEERING
// =====================================================

export interface DashboardStats {
    frota: {
        total: number
        ativos: number
        manutencao: number
        oficina_externa: number
    }
    oficina: {
        total_ordens: number
        em_andamento: number
        concluidas_hoje: number
        urgentes: number
    }
    estoque: {
        total_pecas: number
        baixo_estoque: number
        valor_total: number
    }
}

export interface RecentOS {
    id: string
    numero_os: string
    veiculo_placa: string
    veiculo_modelo: string
    status: string
    prioridade: string
    data_entrada: string
    problema_reportado: string
}

export interface Alert {
    type: 'warning' | 'critical'
    message: string
    count: number
}

// =====================================================
// FUNÇÕES SIMPLIFICADAS - SEM OVERENGINEERING
// =====================================================

/**
 * Busca estatísticas gerais do dashboard
 */
export async function getDashboardStats(): Promise<DashboardStats> {
    try {
        // Buscar dados em paralelo para melhor performance
        const [veiculos, ordens, pecas] = await Promise.all([
            supabase.from('veiculos').select('status'),
            supabase.from('ordens_servico').select('status, data_saida, prioridade'),
            supabase.from('pecas').select('quantidade_estoque, quantidade_minima, custo_unitario')
        ])

        // Calcular estatísticas da frota
        const frota = {
            total: veiculos.data?.length || 0,
            ativos: veiculos.data?.filter(v => v.status === 'ativo').length || 0,
            manutencao: veiculos.data?.filter(v => v.status === 'manutencao').length || 0,
            oficina_externa: veiculos.data?.filter(v => v.status === 'oficina_externa').length || 0
        }

        // Calcular estatísticas da oficina
        const hoje = new Date()
        hoje.setHours(0, 0, 0, 0)

        const oficina = {
            total_ordens: ordens.data?.length || 0,
            em_andamento: ordens.data?.filter(o => o.status === 'em_andamento').length || 0,
            concluidas_hoje: ordens.data?.filter(o => {
                if (!o.data_saida) return false
                const dataSaida = new Date(o.data_saida)
                return o.status === 'concluida' && dataSaida >= hoje
            }).length || 0,
            urgentes: ordens.data?.filter(o => o.prioridade === 'urgente').length || 0
        }

        // Calcular estatísticas do estoque
        const estoque = {
            total_pecas: pecas.data?.length || 0,
            baixo_estoque: pecas.data?.filter(p => p.quantidade_estoque <= p.quantidade_minima).length || 0,
            valor_total: pecas.data?.reduce((total, p) => total + (p.quantidade_estoque * p.custo_unitario), 0) || 0
        }

        return { frota, oficina, estoque }
    } catch (error) {
        console.error('Erro ao buscar estatísticas do dashboard:', error)
        throw error
    }
}

/**
 * Busca ordens de serviço recentes
 */
export async function getRecentOS(limit: number = 10): Promise<RecentOS[]> {
    try {
        const { data, error } = await supabase
            .from('ordens_servico')
            .select(`
        id,
        numero_os,
        status,
        prioridade,
        data_entrada,
        problema_reportado,
        veiculos!inner(
          placa,
          modelo
        )
      `)
            .order('data_entrada', { ascending: false })
            .limit(limit)

        if (error) throw error

        return (data || []).map(os => ({
            id: os.id,
            numero_os: os.numero_os,
            veiculo_placa: os.veiculos?.placa || 'N/A',
            veiculo_modelo: os.veiculos?.modelo || 'N/A',
            status: os.status,
            prioridade: os.prioridade,
            data_entrada: os.data_entrada,
            problema_reportado: os.problema_reportado
        }))
    } catch (error) {
        console.error('Erro ao buscar OS recentes:', error)
        throw error
    }
}

/**
 * Busca alertas e situações críticas
 */
export async function getDashboardAlerts(): Promise<Alert[]> {
    try {
        const alerts: Alert[] = []

        // Buscar dados em paralelo
        const [veiculosManutencao, pecas, osUrgentes] = await Promise.all([
            supabase.from('veiculos').select('status').eq('status', 'manutencao'),
            supabase.from('pecas').select('quantidade_estoque, quantidade_minima'),
            supabase.from('ordens_servico').select('prioridade').eq('prioridade', 'urgente').eq('status', 'em_andamento')
        ])

        // Veículos em manutenção
        if (veiculosManutencao.data?.length) {
            alerts.push({
                type: 'warning',
                message: `${veiculosManutencao.data.length} veículo(s) em manutenção`,
                count: veiculosManutencao.data.length
            })
        }

        // Peças com estoque baixo
        if (pecas.data) {
            const pecasBaixoEstoque = pecas.data.filter(p => p.quantidade_estoque <= p.quantidade_minima)
            if (pecasBaixoEstoque.length > 0) {
                alerts.push({
                    type: 'critical',
                    message: `${pecasBaixoEstoque.length} peça(s) com estoque baixo`,
                    count: pecasBaixoEstoque.length
                })
            }
        }

        // OS urgentes
        if (osUrgentes.data?.length) {
            alerts.push({
                type: 'critical',
                message: `${osUrgentes.data.length} OS urgente(s) em andamento`,
                count: osUrgentes.data.length
            })
        }

        return alerts
    } catch (error) {
        console.error('Erro ao buscar alertas:', error)
        throw error
    }
}

/**
 * Verifica se o usuário está autenticado
 */
export async function checkUserAuth() {
    try {
        const { data: { user }, error } = await supabase.auth.getUser()
        if (error || !user) {
            throw new Error('Usuário não autenticado')
        }
        return user
    } catch (error) {
        console.error('Erro ao verificar autenticação:', error)
        throw error
    }
}
