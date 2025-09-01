import { z } from 'zod'

export const auditoriaSchema = z.object({
  id: z.number().optional(),
  usuario_id: z.number(),
  acao: z.string().min(1, 'Ação é obrigatória'),
  entidade: z.string().min(1, 'Entidade é obrigatória'),
  entidade_id: z.number().optional(),
  dados_anteriores: z.record(z.any()).optional(),
  dados_novos: z.record(z.any()).optional(),
  ip_address: z.string().optional(),
  user_agent: z.string().optional(),
  contexto: z.string().optional(),
  criada_em: z.string().optional()
})

export type Auditoria = z.infer<typeof auditoriaSchema>
export type AuditoriaInsert = Omit<Auditoria, 'id' | 'criada_em'>

export interface AuditoriaFiltros {
  usuario_id?: number
  acao?: string
  entidade?: string
  data_inicio?: string
  data_fim?: string
  limit?: number
  offset?: number
}

export interface AuditoriaResumo {
  total_acoes: number
  acoes_por_usuario: Array<{
    usuario: string
    acoes: number
    percentual: number
  }>
  acoes_por_entidade: Array<{
    entidade: string
    acoes: number
    percentual: number
  }>
  acoes_por_periodo: Array<{
    data: string
    acoes: number
  }>
}

export enum AcaoAuditoria {
  // CRUD básico
  CREATE = 'CREATE',
  READ = 'READ',
  UPDATE = 'UPDATE',
  DELETE = 'DELETE',
  
  // Ações específicas
  LOGIN = 'LOGIN',
  LOGOUT = 'LOGOUT',
  LOGIN_FAILED = 'LOGIN_FAILED',
  PASSWORD_CHANGE = 'PASSWORD_CHANGE',
  PASSWORD_RESET = 'PASSWORD_RESET',
  
  // Ações de negócio
  ORDEM_SERVICO_CREATE = 'ORDEM_SERVICO_CREATE',
  ORDEM_SERVICO_UPDATE = 'ORDEM_SERVICO_UPDATE',
  ORDEM_SERVICO_DELETE = 'ORDEM_SERVICO_DELETE',
  ORDEM_SERVICO_STATUS_CHANGE = 'ORDEM_SERVICO_STATUS_CHANGE',
  
  VEICULO_CREATE = 'VEICULO_CREATE',
  VEICULO_UPDATE = 'VEICULO_UPDATE',
  VEICULO_DELETE = 'VEICULO_DELETE',
  VEICULO_STATUS_CHANGE = 'VEICULO_STATUS_CHANGE',
  
  PECA_CREATE = 'PECA_CREATE',
  PECA_UPDATE = 'PECA_UPDATE',
  PECA_DELETE = 'PECA_DELETE',
  PECA_ESTOQUE_UPDATE = 'PECA_ESTOQUE_UPDATE',
  
  SUPERVISOR_CREATE = 'SUPERVISOR_CREATE',
  SUPERVISOR_UPDATE = 'SUPERVISOR_UPDATE',
  SUPERVISOR_DELETE = 'SUPERVISOR_DELETE',
  
  RELATORIO_GENERATE = 'RELATORIO_GENERATE',
  RELATORIO_EXPORT = 'RELATORIO_EXPORT',
  
  NOTIFICACAO_CREATE = 'NOTIFICACAO_CREATE',
  NOTIFICACAO_UPDATE = 'NOTIFICACAO_UPDATE',
  NOTIFICACAO_DELETE = 'NOTIFICACAO_DELETE',
  
  // Ações de sistema
  CONFIGURACAO_UPDATE = 'CONFIGURACAO_UPDATE',
  BACKUP_CREATE = 'BACKUP_CREATE',
  BACKUP_RESTORE = 'BACKUP_RESTORE',
  USUARIO_PERMISSAO_CHANGE = 'USUARIO_PERMISSAO_CHANGE'
}

export enum EntidadeAuditoria {
  USUARIO = 'usuario',
  SUPERVISOR = 'supervisor',
  VEICULO = 'veiculo',
  ORDEM_SERVICO = 'ordem_servico',
  PECA = 'peca',
  PECA_USADA = 'peca_usada',
  SERVICO_EXTERNO = 'servico_externo',
  OFICINA_EXTERNA = 'oficina_externa',
  RELATORIO = 'relatorio',
  NOTIFICACAO = 'notificacao',
  CONFIGURACAO = 'configuracao',
  SISTEMA = 'sistema'
}

export interface ContextoAuditoria {
  pagina?: string
  rota?: string
  parametros?: Record<string, any>
  sessao?: string
  timestamp?: number
}
