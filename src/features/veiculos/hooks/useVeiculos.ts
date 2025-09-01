import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { veiculoRepository } from '../../../services/repositories/veiculoRepository'
import type { VeiculoInsert, VeiculoUpdate } from '../../../entities/veiculo'
import { useAuthStore } from '../../../features/auth/stores/authStore'

export function useVeiculos() {
  const queryClient = useQueryClient()
  const authStore = useAuthStore()

  const regionalId = authStore.userRegionalData?.id || authStore.userData?.regional_id

  const veiculos = useQuery({
    queryKey: ['veiculos', regionalId],
    queryFn: () => veiculoRepository.findAll(regionalId || undefined),
    // Remover a condição enabled para sempre carregar os veículos
    retry: false,
    staleTime: 5 * 60 * 1000, // 5 minutos
    refetchOnWindowFocus: false,
    initialData: []
  })

  const veiculosEmManutencao = useQuery({
    queryKey: ['veiculos', 'manutencao'],
    queryFn: () => veiculoRepository.getVeiculosEmManutencao(),
    retry: false,
    staleTime: 5 * 60 * 1000, // 5 minutos
    refetchOnWindowFocus: false,
    initialData: []
  })

  const createVeiculo = useMutation({
    mutationFn: (veiculo: VeiculoInsert) => veiculoRepository.create(veiculo),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['veiculos'] })
    },
    onError: (error) => {
      console.error('Erro ao criar veículo:', error)
    }
  })

  const updateVeiculo = useMutation({
    mutationFn: ({ id, data }: { id: string; data: VeiculoUpdate }) =>
      veiculoRepository.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['veiculos'] })
    },
    onError: (error) => {
      console.error('Erro ao atualizar veículo:', error)
    }
  })

  const deleteVeiculo = useMutation({
    mutationFn: (id: string) => veiculoRepository.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['veiculos'] })
    },
    onError: (error) => {
      console.error('Erro ao deletar veículo:', error)
    }
  })

  return {
    veiculos,
    veiculosEmManutencao,
    createVeiculo,
    updateVeiculo,
    deleteVeiculo
  }
}

export function useVeiculo(id: string) {
  const queryClient = useQueryClient()

  const veiculo = useQuery({
    queryKey: ['veiculos', id],
    queryFn: () => veiculoRepository.findById(id),
    enabled: !!id,
    retry: false,
    staleTime: 5 * 60 * 1000, // 5 minutos
    refetchOnWindowFocus: false,
    initialData: null
  })

  const updateVeiculo = useMutation({
    mutationFn: (data: VeiculoUpdate) => veiculoRepository.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['veiculos', id] })
      queryClient.invalidateQueries({ queryKey: ['veiculos'] })
    },
    onError: (error) => {
      console.error('Erro ao atualizar veículo:', error)
    }
  })

  return {
    veiculo,
    updateVeiculo
  }
}
