import { supabase } from '@/services/supabase'

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

export class DashboardService {
  /**
   * Busca estatísticas gerais do dashboard
   */
  static async getStats(): Promise<DashboardStats> {
    try {
      // Buscar estatísticas da frota
      const { data: veiculos, error: veiculosError } = await supabase
        .from('veiculos')
        .select('status')

      if (veiculosError) {
        console.error('Erro ao buscar veículos:', veiculosError)
        throw veiculosError
      }

      const frota = {
        total: veiculos?.length || 0,
        ativos: veiculos?.filter(v => v.status === 'ativo').length || 0,
        manutencao: veiculos?.filter(v => v.status === 'manutencao').length || 0,
        oficina_externa: veiculos?.filter(v => v.status === 'oficina_externa').length || 0
      }

      // Buscar estatísticas da oficina
      const { data: ordens, error: ordensError } = await supabase
        .from('ordens_servico')
        .select('status, data_entrada, prioridade, data_saida')

      if (ordensError) {
        console.error('Erro ao buscar ordens de serviço:', ordensError)
        // Continuar com valores padrão
      }

      const hoje = new Date()
      hoje.setHours(0, 0, 0, 0)

      const oficina = {
        total_ordens: ordens?.length || 0,
        em_andamento: ordens?.filter(o => o.status === 'em_andamento').length || 0,
        concluidas_hoje: ordens?.filter(o => {
          if (!o.data_saida) return false
          const dataSaida = new Date(o.data_saida)
          return o.status === 'concluida' && dataSaida >= hoje
        }).length || 0,
        urgentes: ordens?.filter(o => o.prioridade === 'urgente').length || 0
      }

      // Buscar estatísticas do estoque
      const { data: pecas, error: pecasError } = await supabase
        .from('pecas')
        .select('quantidade_estoque, quantidade_minima, custo_unitario')

      if (pecasError) {
        console.error('Erro ao buscar peças:', pecasError)
        throw pecasError
      }

      const estoque = {
        total_pecas: pecas?.length || 0,
        baixo_estoque: pecas?.filter(p => p.quantidade_estoque <= p.quantidade_minima).length || 0,
        valor_total: pecas?.reduce((total, p) => total + (p.quantidade_estoque * p.custo_unitario), 0) || 0
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
  static async getRecentOS(limit: number = 5): Promise<RecentOS[]> {
    try {
      // Buscar ordens de serviço com dados básicos
      const { data: ordens, error: ordensError } = await supabase
        .from('ordens_servico')
        .select(`
          id,
          numero_os,
          veiculo_id,
          problema_reportado,
          status,
          prioridade,
          data_entrada
        `)
        .order('data_entrada', { ascending: false })
        .limit(limit)

      if (ordensError) {
        console.error('Erro ao buscar OS recentes:', ordensError)
        throw ordensError
      }

      // Se não há ordens, retornar array vazio
      if (!ordens || ordens.length === 0) {
        return []
      }

      // Buscar dados dos veículos separadamente
      const veiculoIds = ordens.map(os => os.veiculo_id).filter(id => id)
      const { data: veiculos, error: veiculosError } = await supabase
        .from('veiculos')
        .select('id, placa, modelo')
        .in('id', veiculoIds)

      if (veiculosError) {
        console.error('Erro ao buscar veículos:', veiculosError)
        // Continuar mesmo sem dados dos veículos
      }

      // Criar mapa de veículos para lookup rápido
      const veiculosMap = new Map()
      if (veiculos) {
        veiculos.forEach(v => veiculosMap.set(v.id, v))
      }

      return ordens.map(os => ({
        id: os.id,
        numero_os: os.numero_os || `OS-${os.id}`,
        veiculo_placa: veiculosMap.get(os.veiculo_id)?.placa || 'N/A',
        veiculo_modelo: veiculosMap.get(os.veiculo_id)?.modelo || 'N/A',
        status: os.status || 'em_andamento',
        prioridade: os.prioridade || 'normal',
        data_entrada: os.data_entrada,
        problema_reportado: os.problema_reportado || 'Problema não especificado'
      }))
    } catch (error) {
      console.error('Erro ao buscar OS recentes:', error)
      throw error
    }
  }

  /**
   * Busca dados para gráficos (atividade por período)
   */
  static async getActivityData(days: number = 30) {
    try {
      const startDate = new Date()
      startDate.setDate(startDate.getDate() - days)

      const { data, error } = await supabase
        .from('ordens_servico')
        .select('status, data_entrada, data_saida')
        .gte('data_entrada', startDate.toISOString())

      if (error) {
        console.error('Erro ao buscar dados de atividade:', error)
        throw error
      }

      // Agrupar por data e status
      const activityByDate = data?.reduce((acc, os) => {
        const date = new Date(os.data_entrada).toLocaleDateString('pt-BR')
        if (!acc[date]) {
          acc[date] = { em_andamento: 0, concluida: 0, cancelada: 0 }
        }
        acc[date][os.status]++
        return acc
      }, {} as Record<string, any>) || {}

      return activityByDate
    } catch (error) {
      console.error('Erro ao buscar dados de atividade:', error)
      throw error
    }
  }

  /**
   * Busca alertas e situações críticas
   */
  static async getAlerts() {
    try {
      const alerts = []

      // Veículos em manutenção
      const { data: veiculosCriticos, error: veiculosError } = await supabase
        .from('veiculos')
        .select('placa, modelo, status')
        .eq('status', 'manutencao')

      if (veiculosError) {
        console.error('Erro ao buscar veículos críticos:', veiculosError)
      } else if (veiculosCriticos?.length) {
        alerts.push({
          type: 'warning',
          message: `${veiculosCriticos.length} veículo(s) em manutenção`,
          count: veiculosCriticos.length
        })
      }

      // Peças com estoque baixo
      const { data: pecas, error: pecasError } = await supabase
        .from('pecas')
        .select('nome, quantidade_estoque, quantidade_minima')

      if (pecasError) {
        console.error('Erro ao buscar peças:', pecasError)
      } else if (pecas) {
        const pecasBaixoEstoque = pecas.filter(p => p.quantidade_estoque <= p.quantidade_minima)
        if (pecasBaixoEstoque.length > 0) {
          alerts.push({
            type: 'critical',
            message: `${pecasBaixoEstoque.length} peça(s) com estoque baixo`,
            count: pecasBaixoEstoque.length
          })
        }
      }

      // OS urgentes
      const { data: osUrgentes, error: osError } = await supabase
        .from('ordens_servico')
        .select('numero_os, prioridade')
        .eq('prioridade', 'urgente')
        .eq('status', 'em_andamento')

      if (osError) {
        console.error('Erro ao buscar OS urgentes:', osError)
      } else if (osUrgentes?.length) {
        alerts.push({
          type: 'critical',
          message: `${osUrgentes.length} OS urgente(s) em andamento`,
          count: osUrgentes.length
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
  static async checkAuth() {
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
}
