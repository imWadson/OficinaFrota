import { z } from 'zod'

export const veiculoSchema = z.object({
  id: z.string().uuid('ID deve ser um UUID válido').optional(),
  placa: z.string().min(1, 'Placa é obrigatória').max(10, 'Placa muito longa'),
  modelo: z.string().min(1, 'Modelo é obrigatório'),
  tipo: z.string().min(1, 'Tipo é obrigatório'),
  ano: z.number().min(1980, 'Ano deve ser >= 1980').max(new Date().getFullYear() + 1),
  quilometragem: z.number().min(0, 'Quilometragem deve ser >= 0').default(0),
  status: z.enum(['ativo', 'inativo', 'manutencao']).default('ativo'),
  regional_id: z.string().uuid('Regional ID deve ser um UUID válido'),
  criado_por: z.string().uuid('Criado por deve ser um UUID válido'),
  criado_em: z.string().optional()
})

export type Veiculo = z.infer<typeof veiculoSchema>
export type VeiculoInsert = Omit<Veiculo, 'id' | 'criado_em'>
export type VeiculoUpdate = Partial<VeiculoInsert>
