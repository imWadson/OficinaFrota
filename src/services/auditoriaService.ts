import { supabase } from './supabase'
import type { AuditoriaFiltros, AuditoriaResumo } from '../entities/auditoria'

export interface LogAuditoria {
  id: string
  usuario_id: string
  acao: string
  tabela: string
  registro_id: string
  dados_anteriores?: any
  dados_novos?: any
  ip_address?: string
  user_agent?: string
  timestamp: string
  detalhes?: string
}

export interface LogAuditoriaInsert {
  usuario_id: string
  acao: string
  tabela: string
  registro_id: string
  dados_anteriores?: any
  dados_novos?: any
  ip_address?: string
  user_agent?: string
  detalhes?: string
}

export type AcaoAuditoria =
  | 'CREATE'
  | 'UPDATE'
  | 'DELETE'
  | 'LOGIN'
  | 'LOGOUT'
  | 'EXPORT'
  | 'IMPORT'
  | 'STATUS_CHANGE'
  | 'PRIORITY_CHANGE'
  | 'ASSIGNMENT_CHANGE'

export type TabelaAuditoria =
  | 'veiculos'
  | 'ordens_servico'
  | 'pecas'
  | 'supervisores'
  | 'oficinas_externas'
  | 'usuarios'
  | 'notificacoes'

class AuditoriaService {
  /**
   * Registra uma ação de auditoria
   */
  async registrarAcao(log: LogAuditoriaInsert): Promise<void> {
    try {
      const { error } = await supabase
        .from('auditoria_logs')
        .insert({
          ...log,
          timestamp: new Date().toISOString(),
          ip_address: await this.getClientIP(),
          user_agent: this.getUserAgent()
        })

      if (error) {
        console.error('Erro ao registrar log de auditoria:', error)
        // Não lançar erro para não interromper o fluxo principal
      }
    } catch (error) {
      console.error('Erro ao registrar log de auditoria:', error)
    }
  }

  /**
   * Registra criação de registro
   */
  async registrarCriacao(
    usuarioId: string,
    tabela: TabelaAuditoria,
    registroId: string,
    dadosNovos: any,
    detalhes?: string
  ): Promise<void> {
    await this.registrarAcao({
      usuario_id: usuarioId,
      acao: 'CREATE',
      tabela,
      registro_id: registroId,
      dados_novos: dadosNovos,
      detalhes
    })
  }

  /**
   * Registra atualização de registro
   */
  async registrarAtualizacao(
    usuarioId: string,
    tabela: TabelaAuditoria,
    registroId: string,
    dadosAnteriores: any,
    dadosNovos: any,
    detalhes?: string
  ): Promise<void> {
    await this.registrarAcao({
      usuario_id: usuarioId,
      acao: 'UPDATE',
      tabela,
      registro_id: registroId,
      dados_anteriores: dadosAnteriores,
      dados_novos: dadosNovos,
      detalhes
    })
  }

  /**
   * Registra exclusão de registro
   */
  async registrarExclusao(
    usuarioId: string,
    tabela: TabelaAuditoria,
    registroId: string,
    dadosAnteriores: any,
    detalhes?: string
  ): Promise<void> {
    await this.registrarAcao({
      usuario_id: usuarioId,
      acao: 'DELETE',
      tabela,
      registro_id: registroId,
      dados_anteriores: dadosAnteriores,
      detalhes
    })
  }

  /**
   * Registra mudança de status
   */
  async registrarMudancaStatus(
    usuarioId: string,
    tabela: TabelaAuditoria,
    registroId: string,
    statusAnterior: string,
    statusNovo: string,
    detalhes?: string
  ): Promise<void> {
    await this.registrarAcao({
      usuario_id: usuarioId,
      acao: 'STATUS_CHANGE',
      tabela,
      registro_id: registroId,
      dados_anteriores: { status: statusAnterior },
      dados_novos: { status: statusNovo },
      detalhes: `Status alterado de "${statusAnterior}" para "${statusNovo}". ${detalhes || ''}`
    })
  }

  /**
   * Registra mudança de prioridade
   */
  async registrarMudancaPrioridade(
    usuarioId: string,
    tabela: TabelaAuditoria,
    registroId: string,
    prioridadeAnterior: string,
    prioridadeNova: string,
    detalhes?: string
  ): Promise<void> {
    await this.registrarAcao({
      usuario_id: usuarioId,
      acao: 'PRIORITY_CHANGE',
      tabela,
      registro_id: registroId,
      dados_anteriores: { prioridade: prioridadeAnterior },
      dados_novos: { prioridade: prioridadeNova },
      detalhes: `Prioridade alterada de "${prioridadeAnterior}" para "${prioridadeNova}". ${detalhes || ''}`
    })
  }

  /**
   * Registra mudança de atribuição
   */
  async registrarMudancaAtribuicao(
    usuarioId: string,
    tabela: TabelaAuditoria,
    registroId: string,
    atribuicaoAnterior: string,
    atribuicaoNova: string,
    detalhes?: string
  ): Promise<void> {
    await this.registrarAcao({
      usuario_id: usuarioId,
      acao: 'ASSIGNMENT_CHANGE',
      tabela,
      registro_id: registroId,
      dados_anteriores: { atribuicao: atribuicaoAnterior },
      dados_novos: { atribuicao: atribuicaoNova },
      detalhes: `Atribuição alterada de "${atribuicaoAnterior}" para "${atribuicaoNova}". ${detalhes || ''}`
    })
  }

  /**
   * Registra login do usuário
   */
  async registrarLogin(
    usuarioId: string,
    detalhes?: string
  ): Promise<void> {
    await this.registrarAcao({
      usuario_id: usuarioId,
      acao: 'LOGIN',
      tabela: 'usuarios',
      registro_id: usuarioId,
      detalhes: `Login realizado com sucesso. ${detalhes || ''}`
    })
  }

  /**
   * Registra logout do usuário
   */
  async registrarLogout(
    usuarioId: string,
    detalhes?: string
  ): Promise<void> {
    await this.registrarAcao({
      usuario_id: usuarioId,
      acao: 'LOGOUT',
      tabela: 'usuarios',
      registro_id: usuarioId,
      detalhes: `Logout realizado. ${detalhes || ''}`
    })
  }

  /**
   * Registra exportação de dados
   */
  async registrarExportacao(
    usuarioId: string,
    tabela: TabelaAuditoria,
    filtros?: any,
    detalhes?: string
  ): Promise<void> {
    await this.registrarAcao({
      usuario_id: usuarioId,
      acao: 'EXPORT',
      tabela,
      registro_id: 'N/A',
      dados_novos: { filtros },
      detalhes: `Dados exportados da tabela ${tabela}. ${detalhes || ''}`
    })
  }

  /**
   * Registra importação de dados
   */
  async registrarImportacao(
    usuarioId: string,
    tabela: TabelaAuditoria,
    quantidadeRegistros: number,
    detalhes?: string
  ): Promise<void> {
    await this.registrarAcao({
      usuario_id: usuarioId,
      acao: 'IMPORT',
      tabela,
      registro_id: 'N/A',
      dados_novos: { quantidade_registros: quantidadeRegistros },
      detalhes: `${quantidadeRegistros} registros importados na tabela ${tabela}. ${detalhes || ''}`
    })
  }

  /**
   * Busca logs de auditoria com filtros
   */
  async buscarLogs(filtros: {
    usuario_id?: string
    acao?: AcaoAuditoria
    tabela?: TabelaAuditoria
    data_inicio?: string
    data_fim?: string
    limit?: number
    offset?: number
  } = {}): Promise<LogAuditoria[]> {
    try {
      let query = supabase
        .from('auditoria_logs')
        .select('*')
        .order('timestamp', { ascending: false })

      if (filtros.usuario_id) {
        query = query.eq('usuario_id', filtros.usuario_id)
      }

      if (filtros.acao) {
        query = query.eq('acao', filtros.acao)
      }

      if (filtros.tabela) {
        query = query.eq('tabela', filtros.tabela)
      }

      if (filtros.data_inicio) {
        query = query.gte('timestamp', filtros.data_inicio)
      }

      if (filtros.data_fim) {
        query = query.lte('timestamp', filtros.data_fim)
      }

      if (filtros.limit) {
        query = query.limit(filtros.limit)
      }

      if (filtros.offset) {
        query = query.range(filtros.offset, filtros.offset + (filtros.limit || 50) - 1)
      }

      const { data, error } = await query

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar logs de auditoria:', error)
      throw error
    }
  }

  /**
   * Busca logs de um registro específico
   */
  async buscarLogsRegistro(
    tabela: TabelaAuditoria,
    registroId: string
  ): Promise<LogAuditoria[]> {
    try {
      const { data, error } = await supabase
        .from('auditoria_logs')
        .select('*')
        .eq('tabela', tabela)
        .eq('registro_id', registroId)
        .order('timestamp', { ascending: false })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Erro ao buscar logs do registro:', error)
      throw error
    }
  }

  /**
   * Busca estatísticas de auditoria
   */
  async buscarEstatisticas(filtros: {
    data_inicio?: string
    data_fim?: string
    usuario_id?: string
  } = {}): Promise<{
    total_acoes: number
    acoes_por_tipo: Record<string, number>
    acoes_por_tabela: Record<string, number>
    acoes_por_usuario: Record<string, number>
  }> {
    try {
      let query = supabase
        .from('auditoria_logs')
        .select('*')

      if (filtros.data_inicio) {
        query = query.gte('timestamp', filtros.data_inicio)
      }

      if (filtros.data_fim) {
        query = query.lte('timestamp', filtros.data_fim)
      }

      if (filtros.usuario_id) {
        query = query.eq('usuario_id', filtros.usuario_id)
      }

      const { data, error } = await query

      if (error) throw error

      const logs = data || []
      const acoesPorTipo: Record<string, number> = {}
      const acoesPorTabela: Record<string, number> = {}
      const acoesPorUsuario: Record<string, number> = {}

      logs.forEach(log => {
        // Contar por tipo de ação
        acoesPorTipo[log.acao] = (acoesPorTipo[log.acao] || 0) + 1

        // Contar por tabela
        acoesPorTabela[log.tabela] = (acoesPorTabela[log.tabela] || 0) + 1

        // Contar por usuário
        acoesPorUsuario[log.usuario_id] = (acoesPorUsuario[log.usuario_id] || 0) + 1
      })

      return {
        total_acoes: logs.length,
        acoes_por_tipo: acoesPorTipo,
        acoes_por_tabela: acoesPorTabela,
        acoes_por_usuario: acoesPorUsuario
      }
    } catch (error) {
      console.error('Erro ao buscar estatísticas de auditoria:', error)
      throw error
    }
  }

  /**
   * Busca logs de auditoria (método principal)
   */
  async buscar(filtros?: AuditoriaFiltros): Promise<LogAuditoria[]> {
    return this.buscarLogs(filtros)
  }

  /**
   * Busca resumo de auditoria
   */
  async buscarResumo(periodo: { inicio: string; fim: string }): Promise<AuditoriaResumo> {
    const estatisticas = await this.buscarEstatisticas({
      data_inicio: periodo.inicio,
      data_fim: periodo.fim
    })

    return {
      total_acoes: estatisticas.total_acoes,
      acoes_por_usuario: Object.entries(estatisticas.acoes_por_usuario).map(([usuario, acoes]) => ({
        usuario,
        acoes,
        percentual: (acoes / estatisticas.total_acoes) * 100
      })),
      acoes_por_entidade: Object.entries(estatisticas.acoes_por_tabela).map(([entidade, acoes]) => ({
        entidade,
        acoes,
        percentual: (acoes / estatisticas.total_acoes) * 100
      })),
      acoes_por_periodo: []
    }
  }

  /**
   * Busca auditoria por entidade
   */
  async buscarPorEntidade(entidade: string, entidadeId: number): Promise<LogAuditoria[]> {
    return this.buscarLogsRegistro(entidade as TabelaAuditoria, entidadeId.toString())
  }

  /**
   * Busca auditoria por usuário
   */
  async buscarPorUsuario(usuarioId: number, limit: number = 100): Promise<LogAuditoria[]> {
    return this.buscarLogs({ usuario_id: usuarioId.toString(), limit })
  }

  /**
   * Busca auditoria por período
   */
  async buscarPorPeriodo(inicio: string, fim: string, limit: number = 1000): Promise<LogAuditoria[]> {
    return this.buscarLogs({ data_inicio: inicio, data_fim: fim, limit })
  }

  /**
   * Exporta auditoria para CSV
   */
  async exportarCSV(filtros: AuditoriaFiltros): Promise<string> {
    const logs = await this.buscar(filtros)

    const headers = ['ID', 'Usuário', 'Ação', 'Entidade', 'Registro ID', 'IP', 'Data/Hora', 'Detalhes']
    const rows = logs.map(log => [
      log.id,
      log.usuario_id,
      log.acao,
      log.tabela,
      log.registro_id,
      log.ip_address || '',
      log.timestamp,
      log.detalhes || ''
    ])

    const csvContent = [headers, ...rows]
      .map(row => row.map(cell => `"${cell}"`).join(','))
      .join('\n')

    return csvContent
  }

  /**
   * Limpa auditoria antiga
   */
  async limparAntiga(): Promise<void> {
    return this.limparLogsAntigos(90)
  }

  /**
   * Limpa logs antigos (mais de X dias)
   */
  async limparLogsAntigos(dias: number = 90): Promise<void> {
    try {
      const dataLimite = new Date()
      dataLimite.setDate(dataLimite.getDate() - dias)

      const { error } = await supabase
        .from('auditoria_logs')
        .delete()
        .lt('timestamp', dataLimite.toISOString())

      if (error) throw error
    } catch (error) {
      console.error('Erro ao limpar logs antigos:', error)
      throw error
    }
  }

  /**
   * Obtém IP do cliente (simulado)
   */
  private async getClientIP(): Promise<string> {
    // Em produção, você implementaria a lógica real para obter o IP
    return '127.0.0.1'
  }

  /**
   * Obtém User Agent do navegador
   */
  private getUserAgent(): string {
    return navigator.userAgent || 'Unknown'
  }
}

// Instância singleton
export const auditoriaService = new AuditoriaService()

// Funções de conveniência para uso direto
export const {
  registrarCriacao,
  registrarAtualizacao,
  registrarExclusao,
  registrarMudancaStatus,
  registrarMudancaPrioridade,
  registrarMudancaAtribuicao,
  registrarLogin,
  registrarLogout,
  registrarExportacao,
  registrarImportacao
} = auditoriaService
