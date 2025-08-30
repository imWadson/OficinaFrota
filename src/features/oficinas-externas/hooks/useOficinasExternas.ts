import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { oficinasExternasRepository, type OficinaExternaInsert } from '../../../services/repositories/oficinasExternasRepository'

export function useOficinasExternas() {
  const queryClient = useQueryClient()

  const oficinasExternas = useQuery({
    queryKey: ['oficinas-externas'],
    queryFn: () => oficinasExternasRepository.findAll()
  })

  const createOficina = useMutation({
    mutationFn: (oficina: OficinaExternaInsert) => oficinasExternasRepository.create(oficina),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['oficinas-externas'] })
    }
  })

  const updateOficina = useMutation({
    mutationFn: ({ id, data }: { id: number; data: Partial<OficinaExternaInsert> }) => 
      oficinasExternasRepository.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['oficinas-externas'] })
    }
  })

  const deleteOficina = useMutation({
    mutationFn: (id: number) => oficinasExternasRepository.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['oficinas-externas'] })
    }
  })

  return {
    oficinasExternas,
    createOficina,
    updateOficina,
    deleteOficina
  }
}
