import { z } from 'zod'

export const relatorioFrotaSchema = z.object({
    periodo_inicio: z.string().min(1, 'Data de início é obrigatória'),
    periodo_fim: z.string().min(1, 'Data de fim é obrigatória'),
    regional_id: z.string().optional(),
    tipo_veiculo: z.string().optional(),
    status: z.string().optional()
})

export const relatorioOficinaSchema = z.object({
    periodo_inicio: z.string().min(1, 'Data de início é obrigatória'),
    periodo_fim: z.string().min(1, 'Data de fim é obrigatória'),
    supervisor_id: z.number().optional(),
    status: z.string().optional(),
    tipo_servico: z.string().optional()
})

export const relatorioEstoqueSchema = z.object({
    categoria: z.string().optional(),
    fornecedor: z.string().optional(),
    estoque_baixo: z.boolean().optional(),
    valor_minimo: z.number().optional(),
    valor_maximo: z.number().optional()
})

export type RelatorioFrota = z.infer<typeof relatorioFrotaSchema>
export type RelatorioOficina = z.infer<typeof relatorioOficinaSchema>
export type RelatorioEstoque = z.infer<typeof relatorioEstoqueSchema>

export interface RelatorioFrotaResult {
    total_veiculos: number
    veiculos_ativos: number
    veiculos_manutencao: number
    veiculos_oficina_externa: number
    quilometragem_media: number
    custo_medio_manutencao: number
    veiculos_por_tipo: Array<{
        tipo: string
        quantidade: number
        percentual: number
    }>
    veiculos_por_regional: Array<{
        regional: string
        quantidade: number
        percentual: number
    }>
}

export interface RelatorioOficinaResult {
    total_ordens: number
    ordens_concluidas: number
    ordens_em_andamento: number
    tempo_medio_conclusao: number
    custo_total_pecas: number
    custo_total_servicos_externos: number
    produtividade_por_supervisor: Array<{
        supervisor: string
        ordens_concluidas: number
        tempo_medio: number
        custo_medio: number
    }>
    ordens_por_periodo: Array<{
        data: string
        quantidade: number
        valor_total: number
    }>
}

export interface RelatorioEstoqueResult {
    total_pecas: number
    valor_total_estoque: number
    pecas_estoque_baixo: number
    pecas_por_categoria: Array<{
        categoria: string
        quantidade: number
        valor_total: number
    }>
    fornecedores_principais: Array<{
        fornecedor: string
        quantidade_pecas: number
        valor_total: number
    }>
    movimentacao_estoque: Array<{
        data: string
        entrada: number
        saida: number
        saldo: number
    }>
}
