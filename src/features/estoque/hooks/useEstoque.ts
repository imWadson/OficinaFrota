import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { pecaRepository } from '../../../services/repositories/pecaRepository'
import { pecasUsadasRepository, type PecaUsadaInsert } from '../../../services/repositories/pecasUsadasRepository'
import type { PecaInsert, PecaUpdate } from '../../../entities/peca'

export function useEstoque(ordemServicoId?: number) {
    const queryClient = useQueryClient()

    // Queries para peças
    const pecas = useQuery({
        queryKey: ['pecas'],
        queryFn: () => pecaRepository.findAll()
    })

    // Queries para peças usadas (se ordemServicoId fornecido)
    const pecasUsadas = useQuery({
        queryKey: ['pecas-usadas', ordemServicoId],
        queryFn: () => pecasUsadasRepository.findByOrdemServico(ordemServicoId!),
        enabled: !!ordemServicoId
    })

    // Mutations para peças
    const createPeca = useMutation({
        mutationFn: (peca: PecaInsert) => pecaRepository.create(peca),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['pecas'] })
        }
    })

    const updatePeca = useMutation({
        mutationFn: ({ id, data }: { id: number; data: PecaUpdate }) =>
            pecaRepository.update(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['pecas'] })
        }
    })

    const deletePeca = useMutation({
        mutationFn: (id: number) => pecaRepository.delete(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['pecas'] })
        }
    })

    // Mutations para peças usadas (se ordemServicoId fornecido)
    const adicionarPecaUsada = useMutation({
        mutationFn: (data: PecaUsadaInsert) => pecasUsadasRepository.create(data),
        onSuccess: () => {
            if (ordemServicoId) {
                queryClient.invalidateQueries({ queryKey: ['pecas-usadas', ordemServicoId] })
            }
            queryClient.invalidateQueries({ queryKey: ['pecas'] }) // Atualizar estoque
        }
    })

    const removerPecaUsada = useMutation({
        mutationFn: (id: number) => pecasUsadasRepository.delete(id),
        onSuccess: () => {
            if (ordemServicoId) {
                queryClient.invalidateQueries({ queryKey: ['pecas-usadas', ordemServicoId] })
            }
            queryClient.invalidateQueries({ queryKey: ['pecas'] }) // Atualizar estoque
        }
    })

    return {
        // Queries
        pecas,
        pecasUsadas: ordemServicoId ? pecasUsadas : undefined,

        // Mutations para peças
        createPeca,
        updatePeca,
        deletePeca,

        // Mutations para peças usadas (se disponível)
        adicionarPecaUsada: ordemServicoId ? adicionarPecaUsada : undefined,
        removerPecaUsada: ordemServicoId ? removerPecaUsada : undefined
    }
}
