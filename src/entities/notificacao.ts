import { z } from 'zod'

export const notificacaoSchema = z.object({
  id: z.number().optional(),
  tipo: z.enum(['info', 'warning', 'error', 'success']),
  titulo: z.string().min(1, 'Título é obrigatório'),
  mensagem: z.string().min(1, 'Mensagem é obrigatória'),
  categoria: z.enum(['estoque', 'manutencao', 'sistema', 'usuario']),
  prioridade: z.enum(['baixa', 'media', 'alta', 'critica']).default('media'),
  lida: z.boolean().default(false),
  usuario_id: z.number().optional(),
  dados_extras: z.record(z.any()).optional(),
  criada_em: z.string().optional(),
  lida_em: z.string().optional()
})

export type Notificacao = z.infer<typeof notificacaoSchema>
export type NotificacaoInsert = Omit<Notificacao, 'id' | 'criada_em' | 'lida_em'>
export type NotificacaoUpdate = Partial<Notificacao>

export interface NotificacaoEstoque {
  tipo: 'estoque'
  titulo: string
  mensagem: string
  prioridade: 'baixa' | 'media' | 'alta' | 'critica'
  dados_extras: {
    peca_id: number
    peca_nome: string
    quantidade_atual: number
    quantidade_minima: number
  }
}

export interface NotificacaoManutencao {
  tipo: 'manutencao'
  titulo: string
  mensagem: string
  prioridade: 'baixa' | 'media' | 'alta' | 'critica'
  dados_extras: {
    veiculo_id: number
    veiculo_placa: string
    ordem_servico_id: number
    dias_em_andamento: number
  }
}

export interface NotificacaoSistema {
  tipo: 'sistema'
  titulo: string
  mensagem: string
  prioridade: 'baixa' | 'media' | 'alta' | 'critica'
  dados_extras: {
    acao: string
    detalhes: string
  }
}

export interface NotificacaoUsuario {
  tipo: 'usuario'
  titulo: string
  mensagem: string
  prioridade: 'baixa' | 'media' | 'alta' | 'critica'
  dados_extras: {
    acao_usuario: string
    contexto: string
  }
}

export type NotificacaoTipada = 
  | NotificacaoEstoque 
  | NotificacaoManutencao 
  | NotificacaoSistema 
  | NotificacaoUsuario

export interface ConfiguracaoNotificacao {
  id: number
  usuario_id: number
  categoria: string
  ativa: boolean
  email: boolean
  push: boolean
  in_app: boolean
}
