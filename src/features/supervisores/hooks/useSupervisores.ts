import { useQuery } from '@tanstack/vue-query'
import { supervisorRepository } from '../../../services/repositories/supervisorRepository'

export function useSupervisores() {
  const supervisores = useQuery({
    queryKey: ['supervisores'],
    queryFn: () => supervisorRepository.findAll(),
    retry: false,
    staleTime: 5 * 60 * 1000, // 5 minutos
    refetchOnWindowFocus: false,
    initialData: []
  })

  return {
    supervisores
  }
}

export function useSupervisor(id: number) {
  const supervisor = useQuery({
    queryKey: ['supervisores', id],
    queryFn: () => supervisorRepository.findById(id),
    enabled: !!id,
    retry: false,
    staleTime: 5 * 60 * 1000, // 5 minutos
    refetchOnWindowFocus: false,
    initialData: null
  })

  return {
    supervisor
  }
}
