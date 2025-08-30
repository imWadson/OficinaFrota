import { z } from 'zod'

export const ordemServicoSchema = z.object({
  id: z.number().optional(),
  veiculo_id: z.number().min(1, 'Veículo é obrigatório'),
  problema_reportado: z.string().min(1, 'Problema reportado é obrigatório'),
  diagnostico: z.string().optional(),
  status: z.enum(['em_andamento', 'concluida', 'cancelada']).default('em_andamento'),
  data_entrada: z.string().optional(),
  data_saida: z.string().optional(),
  supervisor_entrega_id: z.number().optional(),
  supervisor_retirada_id: z.number().optional()
})

export type OrdemServico = z.infer<typeof ordemServicoSchema>
export type OrdemServicoInsert = Omit<OrdemServico, 'id' | 'data_entrada'>
export type OrdemServicoUpdate = Partial<OrdemServico>
