import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { pecaRepository } from '../../../services/repositories/pecaRepository'
import type { PecaInsert, PecaUpdate } from '../../../entities/peca'

export function usePecas() {
  const queryClient = useQueryClient()

  const pecas = useQuery({
    queryKey: ['pecas'],
    queryFn: () => pecaRepository.findAll()
  })

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

  return {
    pecas,
    createPeca,
    updatePeca,
    deletePeca
  }
}
