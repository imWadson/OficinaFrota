import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { pecasUsadasRepository, type PecaUsadaInsert } from '../../../services/repositories/pecasUsadasRepository'

export function usePecasUsadas(ordemServicoId: number) {
  const queryClient = useQueryClient()

  const pecasUsadas = useQuery({
    queryKey: ['pecas-usadas', ordemServicoId],
    queryFn: () => pecasUsadasRepository.findByOrdemServico(ordemServicoId),
    enabled: !!ordemServicoId
  })

  const adicionarPeca = useMutation({
    mutationFn: (data: PecaUsadaInsert) => pecasUsadasRepository.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['pecas-usadas', ordemServicoId] })
      queryClient.invalidateQueries({ queryKey: ['pecas'] }) // Atualizar estoque
    }
  })

  const removerPeca = useMutation({
    mutationFn: (id: number) => pecasUsadasRepository.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['pecas-usadas', ordemServicoId] })
      queryClient.invalidateQueries({ queryKey: ['pecas'] }) // Atualizar estoque
    }
  })

  return {
    pecasUsadas,
    adicionarPeca,
    removerPeca
  }
}
