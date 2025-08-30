import { useQuery } from '@tanstack/vue-query'
import { supervisorRepository } from '../../../services/repositories/supervisorRepository'

export function useSupervisores() {
  const supervisores = useQuery({
    queryKey: ['supervisores'],
    queryFn: () => supervisorRepository.findAll()
  })

  return {
    supervisores
  }
}

export function useSupervisor(id: number) {
  const supervisor = useQuery({
    queryKey: ['supervisores', id],
    queryFn: () => supervisorRepository.findById(id),
    enabled: !!id
  })

  return {
    supervisor
  }
}
