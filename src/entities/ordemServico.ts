import { z } from 'zod'

export const ordemServicoSchema = z.object({
  id: z.string().optional(), // UUID
  veiculo_id: z.string().min(1, 'Veículo é obrigatório'), // UUID
  problema_reportado: z.string().min(1, 'Problema reportado é obrigatório'),
  diagnostico: z.string().optional(),
  status: z.enum([
    'em_andamento', 
    'concluida', 
    'cancelada', 
    'oficina_externa', 
    'aguardando_peca', 
    'diagnostico', 
    'aguardando_aprovacao'
  ]).default('em_andamento'),
  data_entrada: z.string().optional(),
  data_saida: z.string().optional(),
  supervisor_entrega_id: z.string().optional(), // UUID
  supervisor_retirada_id: z.string().optional(), // UUID
  criado_por: z.string().optional() // UUID do usuário que criou a OS
})

// Schema para histórico de status
export const ordemServicoStatusHistorySchema = z.object({
  id: z.string().optional(), // UUID
  ordem_servico_id: z.string().min(1, 'ID da ordem de serviço é obrigatório'),
  status_anterior: z.string().optional(),
  status_novo: z.string().min(1, 'Novo status é obrigatório'),
  observacao: z.string().optional(),
  criado_por: z.string().min(1, 'Usuário que fez a mudança é obrigatório'),
  criado_em: z.string().optional()
})

// Schema para estatísticas de tempo por status
export const tempoPorStatusSchema = z.object({
  status: z.string(),
  tempo_total: z.string(), // Interval como string
  inicio_status: z.string(),
  fim_status: z.string()
})

export type OrdemServico = z.infer<typeof ordemServicoSchema>
export type OrdemServicoInsert = Omit<OrdemServico, 'id' | 'data_entrada'>
export type OrdemServicoUpdate = Partial<OrdemServico>
export type OrdemServicoStatusHistory = z.infer<typeof ordemServicoStatusHistorySchema>
export type TempoPorStatus = z.infer<typeof tempoPorStatusSchema>
