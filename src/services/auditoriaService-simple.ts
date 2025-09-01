import { supabase } from './supabase'

// =====================================================
// INTERFACES SIMPLIFICADAS - SEM OVERENGINEERING
// =====================================================

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

export interface AuditoriaFiltros {
    usuario_id?: string
    acao?: string
    tabela?: string
    data_inicio?: string
    data_fim?: string
    limit?: number
}

// =====================================================
// FUNÇÕES SIMPLIFICADAS - SEM OVERENGINEERING
// =====================================================

/**
 * Registra uma ação de auditoria
 */
export async function registrarAcao(log: LogAuditoriaInsert): Promise<void> {
    try {
        const { error } = await supabase
            .from('auditoria_logs')
            .insert({
                ...log,
                timestamp: new Date().toISOString(),
                ip_address: '127.0.0.1', // Simplificado - implementar quando necessário
                user_agent: navigator.userAgent || 'Unknown'
            })

        if (error) {
            console.error('Erro ao registrar log de auditoria:', error)
        }
    } catch (error) {
        console.error('Erro ao registrar log de auditoria:', error)
    }
}

/**
 * Registra criação de registro
 */
export async function registrarCriacao(
    usuarioId: string,
    tabela: string,
    registroId: string,
    dadosNovos: any,
    detalhes?: string
): Promise<void> {
    await registrarAcao({
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
export async function registrarAtualizacao(
    usuarioId: string,
    tabela: string,
    registroId: string,
    dadosAnteriores: any,
    dadosNovos: any,
    detalhes?: string
): Promise<void> {
    await registrarAcao({
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
export async function registrarExclusao(
    usuarioId: string,
    tabela: string,
    registroId: string,
    dadosAnteriores: any,
    detalhes?: string
): Promise<void> {
    await registrarAcao({
        usuario_id: usuarioId,
        acao: 'DELETE',
        tabela,
        registro_id: registroId,
        dados_anteriores: dadosAnteriores,
        detalhes
    })
}

/**
 * Registra login de usuário
 */
export async function registrarLogin(usuarioId: string, detalhes?: string): Promise<void> {
    await registrarAcao({
        usuario_id: usuarioId,
        acao: 'LOGIN',
        tabela: 'usuarios',
        registro_id: usuarioId,
        detalhes
    })
}

/**
 * Registra logout de usuário
 */
export async function registrarLogout(usuarioId: string, detalhes?: string): Promise<void> {
    await registrarAcao({
        usuario_id: usuarioId,
        acao: 'LOGOUT',
        tabela: 'usuarios',
        registro_id: usuarioId,
        detalhes
    })
}

/**
 * Busca logs de auditoria com filtros
 */
export async function buscarLogs(filtros: AuditoriaFiltros): Promise<LogAuditoria[]> {
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

        const { data, error } = await query
        if (error) throw error

        return data || []
    } catch (error) {
        console.error('Erro ao buscar logs de auditoria:', error)
        throw error
    }
}

/**
 * Busca auditoria por usuário
 */
export async function buscarPorUsuario(usuarioId: string, limit: number = 100): Promise<LogAuditoria[]> {
    return buscarLogs({ usuario_id: usuarioId, limit })
}

/**
 * Busca auditoria por período
 */
export async function buscarPorPeriodo(inicio: string, fim: string, limit: number = 1000): Promise<LogAuditoria[]> {
    return buscarLogs({ data_inicio: inicio, data_fim: fim, limit })
}

/**
 * Exporta auditoria para CSV
 */
export async function exportarCSV(filtros: AuditoriaFiltros): Promise<string> {
    const logs = await buscarLogs(filtros)

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
 * Limpa logs antigos (mais de X dias)
 */
export async function limparLogsAntigos(dias: number = 90): Promise<void> {
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
