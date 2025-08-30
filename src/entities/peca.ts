import { z } from 'zod'

export const pecaSchema = z.object({
  id: z.number().optional(),
  nome: z.string().min(1, 'Nome é obrigatório'),
  codigo: z.string().min(1, 'Código é obrigatório'),
  fornecedor: z.string().optional(),
  custo_unitario: z.number().min(0, 'Custo deve ser >= 0'),
  quantidade_estoque: z.number().min(0, 'Quantidade deve ser >= 0').default(0)
})

export type Peca = z.infer<typeof pecaSchema>
export type PecaInsert = Omit<Peca, 'id'>
export type PecaUpdate = Partial<PecaInsert>
