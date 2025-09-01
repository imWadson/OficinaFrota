import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { ordemServicoRepository } from '../../../services/repositories/ordemServicoRepository'
import type { OrdemServicoInsert, OrdemServicoUpdate } from '../../../entities/ordemServico'

export function useOrdensServico() {
  const queryClient = useQueryClient()

  const ordensServico = useQuery({
    queryKey: ['ordens-servico'],
    queryFn: () => ordemServicoRepository.findAll(),
    retry: false,
    staleTime: 5 * 60 * 1000, // 5 minutos
    refetchOnWindowFocus: false,
    initialData: []
  })

  const ordensEmAndamento = useQuery({
    queryKey: ['ordens-servico', 'em-andamento'],
    queryFn: () => ordemServicoRepository.getOrdensEmAndamento(),
    retry: false,
    staleTime: 5 * 60 * 1000, // 5 minutos
    refetchOnWindowFocus: false,
    initialData: []
  })

  const ordensConcluidas = useQuery({
    queryKey: ['ordens-servico', 'concluidas'],
    queryFn: () => ordemServicoRepository.getOrdensConcluidas(),
    retry: false,
    staleTime: 5 * 60 * 1000, // 5 minutos
    refetchOnWindowFocus: false,
    initialData: []
  })

  const createOrdemServico = useMutation({
    mutationFn: (ordemServico: OrdemServicoInsert) => ordemServicoRepository.create(ordemServico),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ordens-servico'] })
      queryClient.invalidateQueries({ queryKey: ['veiculos'] })
    },
    onError: (error) => {
      console.error('Erro ao criar ordem de serviço:', error)
    }
  })

  const updateOrdemServico = useMutation({
    mutationFn: ({ id, data }: { id: string; data: OrdemServicoUpdate }) =>
      ordemServicoRepository.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ordens-servico'] })
    },
    onError: (error) => {
      console.error('Erro ao atualizar ordem de serviço:', error)
    }
  })

  const concluirOrdemServico = useMutation({
    mutationFn: ({ id, supervisorId }: { id: string; supervisorId: string }) =>
      ordemServicoRepository.concluir(id, supervisorId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ordens-servico'] })
      queryClient.invalidateQueries({ queryKey: ['veiculos'] })
    },
    onError: (error) => {
      console.error('Erro ao concluir ordem de serviço:', error)
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

export function useOrdemServico(id: string) {
  const queryClient = useQueryClient()

  const ordemServico = useQuery({
    queryKey: ['ordens-servico', id],
    queryFn: () => ordemServicoRepository.findById(id),
    enabled: !!id,
    retry: false,
    staleTime: 5 * 60 * 1000, // 5 minutos
    cacheTime: 10 * 60 * 1000, // 10 minutos
    refetchOnWindowFocus: false,
    onError: (error) => {
      console.error('Erro ao buscar ordem de serviço:', error)
    },
    initialData: null
  })

  const updateOrdemServico = useMutation({
    mutationFn: (data: OrdemServicoUpdate) => ordemServicoRepository.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ordens-servico', id] })
      queryClient.invalidateQueries({ queryKey: ['ordens-servico'] })
    },
    onError: (error) => {
      console.error('Erro ao atualizar ordem de serviço:', error)
    }
  })

  return {
    ordemServico,
    updateOrdemServico
  }
}

// Hook para histórico de status
export function useStatusHistory(ordemServicoId: string) {
  const queryClient = useQueryClient()

  const statusHistory = useQuery({
    queryKey: ['ordens-servico', ordemServicoId, 'status-history'],
    queryFn: () => ordemServicoRepository.getStatusHistory(ordemServicoId),
    enabled: !!ordemServicoId,
    retry: false,
    staleTime: 2 * 60 * 1000, // 2 minutos
    refetchOnWindowFocus: false,
    onError: (error) => {
      console.error('Erro ao buscar histórico de status:', error)
    },
    initialData: []
  })

  return {
    statusHistory
  }
}

// Hook para estatísticas de tempo
export function useTempoStats(ordemServicoId: string) {
  const queryClient = useQueryClient()

  const tempoPorStatus = useQuery({
    queryKey: ['ordens-servico', ordemServicoId, 'tempo-por-status'],
    queryFn: () => ordemServicoRepository.getTempoPorStatus(ordemServicoId),
    enabled: !!ordemServicoId,
    retry: false,
    staleTime: 2 * 60 * 1000, // 2 minutos
    refetchOnWindowFocus: false,
    onError: (error) => {
      console.error('Erro ao buscar estatísticas de tempo:', error)
    },
    initialData: []
  })

  const tempoTotal = useQuery({
    queryKey: ['ordens-servico', ordemServicoId, 'tempo-total'],
    queryFn: () => ordemServicoRepository.getTempoTotal(ordemServicoId),
    enabled: !!ordemServicoId,
    retry: false,
    staleTime: 2 * 60 * 1000, // 2 minutos
    refetchOnWindowFocus: false,
    onError: (error) => {
      console.error('Erro ao buscar tempo total:', error)
    },
    initialData: '0'
  })

  return {
    tempoPorStatus,
    tempoTotal
  }
}

// Hook para mudança de status
export function useMudarStatus() {
  const queryClient = useQueryClient()

  const mudarStatus = useMutation({
    mutationFn: ({ id, novoStatus, observacao }: { id: string; novoStatus: string; observacao?: string }) =>
      ordemServicoRepository.mudarStatus(id, novoStatus, observacao),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['ordens-servico', id] })
      queryClient.invalidateQueries({ queryKey: ['ordens-servico'] })
      queryClient.invalidateQueries({ queryKey: ['ordens-servico', id, 'status-history'] })
      queryClient.invalidateQueries({ queryKey: ['ordens-servico', id, 'tempo-por-status'] })
      queryClient.invalidateQueries({ queryKey: ['ordens-servico', id, 'tempo-total'] })
    },
    onError: (error) => {
      console.error('Erro ao mudar status da ordem de serviço:', error)
    }
  })

  return {
    mudarStatus
  }
}
