import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { ordemServicoRepository } from '../../../services/repositories/ordemServicoRepository'
import type { OrdemServicoInsert, OrdemServicoUpdate } from '../../../entities/ordemServico'

export function useOrdensServico() {
  const queryClient = useQueryClient()

  const ordensServico = useQuery({
    queryKey: ['ordens-servico'],
    queryFn: () => ordemServicoRepository.findAll()
  })

  const ordensEmAndamento = useQuery({
    queryKey: ['ordens-servico', 'em-andamento'],
    queryFn: () => ordemServicoRepository.getOrdensEmAndamento()
  })

  const ordensConcluidas = useQuery({
    queryKey: ['ordens-servico', 'concluidas'],
    queryFn: () => ordemServicoRepository.getOrdensConcluidas()
  })

  const createOrdemServico = useMutation({
    mutationFn: (ordemServico: OrdemServicoInsert) => ordemServicoRepository.create(ordemServico),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ordens-servico'] })
      queryClient.invalidateQueries({ queryKey: ['veiculos'] })
    }
  })

  const updateOrdemServico = useMutation({
    mutationFn: ({ id, data }: { id: number; data: OrdemServicoUpdate }) => 
      ordemServicoRepository.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ordens-servico'] })
    }
  })

  const concluirOrdemServico = useMutation({
    mutationFn: ({ id, supervisorId }: { id: number; supervisorId: number }) => 
      ordemServicoRepository.concluir(id, supervisorId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ordens-servico'] })
      queryClient.invalidateQueries({ queryKey: ['veiculos'] })
    }
  })

  return {
    ordensServico,
    ordensEmAndamento,
    ordensConcluidas,
    createOrdemServico,
    updateOrdemServico,
    concluirOrdemServico
  }
}

export function useOrdemServico(id: number) {
  const queryClient = useQueryClient()

  const ordemServico = useQuery({
    queryKey: ['ordens-servico', id],
    queryFn: () => ordemServicoRepository.findById(id),
    enabled: !!id
  })

  const updateOrdemServico = useMutation({
    mutationFn: (data: OrdemServicoUpdate) => ordemServicoRepository.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ordens-servico', id] })
      queryClient.invalidateQueries({ queryKey: ['ordens-servico'] })
    }
  })

  return {
    ordemServico,
    updateOrdemServico
  }
}
