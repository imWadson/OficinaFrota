import { useQuery, useMutation } from '@tanstack/vue-query'
import { RelatorioService } from '../../../services/relatorioService'
import type {
    RelatorioFrota,
    RelatorioOficina,
    RelatorioEstoque,
    RelatorioFrotaResult,
    RelatorioOficinaResult,
    RelatorioEstoqueResult
} from '../../../entities/relatorio'

export function useRelatorioFrota(params: RelatorioFrota) {
    return useQuery({
        queryKey: ['relatorio-frota', params],
        queryFn: () => RelatorioService.gerarRelatorioFrota(params),
        enabled: !!params.periodo_inicio && !!params.periodo_fim,
        staleTime: 5 * 60 * 1000, // 5 minutos
        gcTime: 10 * 60 * 1000 // 10 minutos
    })
}

export function useRelatorioOficina(params: RelatorioOficina) {
    return useQuery({
        queryKey: ['relatorio-oficina', params],
        queryFn: () => RelatorioService.gerarRelatorioOficina(params),
        enabled: !!params.periodo_inicio && !!params.periodo_fim,
        staleTime: 5 * 60 * 1000,
        gcTime: 10 * 60 * 1000
    })
}

export function useRelatorioEstoque(params: RelatorioEstoque) {
    return useQuery({
        queryKey: ['relatorio-estoque', params],
        queryFn: () => RelatorioService.gerarRelatorioEstoque(params),
        staleTime: 5 * 60 * 1000,
        gcTime: 10 * 60 * 1000
    })
}

export function useGerarRelatorio() {
    return useMutation({
        mutationFn: async ({
            tipo,
            params
        }: {
            tipo: 'frota' | 'oficina' | 'estoque'
            params: RelatorioFrota | RelatorioOficina | RelatorioEstoque
        }) => {
            switch (tipo) {
                case 'frota':
                    return await RelatorioService.gerarRelatorioFrota(params as RelatorioFrota)
                case 'oficina':
                    return await RelatorioService.gerarRelatorioOficina(params as RelatorioOficina)
                case 'estoque':
                    return await RelatorioService.gerarRelatorioEstoque(params as RelatorioEstoque)
                default:
                    throw new Error('Tipo de relatório inválido')
            }
        }
    })
}

export function useExportarRelatorio() {
    return useMutation({
        mutationFn: async ({
            tipo,
            dados,
            formato
        }: {
            tipo: string
            dados: RelatorioFrotaResult | RelatorioOficinaResult | RelatorioEstoqueResult
            formato: 'pdf' | 'excel' | 'csv'
        }) => {
            // Implementar exportação baseada no formato
            switch (formato) {
                case 'csv':
                    return exportarCSV(dados, tipo)
                case 'excel':
                    return exportarExcel(dados, tipo)
                case 'pdf':
                    return exportarPDF(dados, tipo)
                default:
                    throw new Error('Formato de exportação inválido')
            }
        }
    })
}

// Funções de exportação
function exportarCSV(dados: any, tipo: string): string {
    const headers = Object.keys(dados)
    const values = Object.values(dados)

    let csv = `Relatório de ${tipo}\n`
    csv += `${headers.join(',')}\n`
    csv += `${values.join(',')}\n`

    return csv
}

function exportarExcel(dados: any, tipo: string): Blob {
    // Implementar exportação para Excel
    // Por enquanto, retornar CSV como fallback
    const csv = exportarCSV(dados, tipo)
    return new Blob([csv], { type: 'text/csv' })
}

function exportarPDF(dados: any, tipo: string): Blob {
    // Implementar exportação para PDF
    // Por enquanto, retornar CSV como fallback
    const csv = exportarCSV(dados, tipo)
    return new Blob([csv], { type: 'text/csv' })
}
