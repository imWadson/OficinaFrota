import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { veiculoRepository } from '../../../services/repositories/veiculoRepository'
import type { VeiculoInsert, VeiculoUpdate } from '../../../entities/veiculo'

export function useVeiculos() {
  const queryClient = useQueryClient()

  const veiculos = useQuery({
    queryKey: ['veiculos'],
    queryFn: () => veiculoRepository.findAll()
  })

  const veiculosEmManutencao = useQuery({
    queryKey: ['veiculos', 'manutencao'],
    queryFn: () => veiculoRepository.getVeiculosEmManutencao()
  })

  const createVeiculo = useMutation({
    mutationFn: (veiculo: VeiculoInsert) => veiculoRepository.create(veiculo),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['veiculos'] })
    }
  })

  const updateVeiculo = useMutation({
    mutationFn: ({ id, data }: { id: number; data: VeiculoUpdate }) => 
      veiculoRepository.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['veiculos'] })
    }
  })

  const deleteVeiculo = useMutation({
    mutationFn: (id: number) => veiculoRepository.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['veiculos'] })
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

export function useVeiculo(id: number) {
  const queryClient = useQueryClient()

  const veiculo = useQuery({
    queryKey: ['veiculos', id],
    queryFn: () => veiculoRepository.findById(id),
    enabled: !!id
  })

  const updateVeiculo = useMutation({
    mutationFn: (data: VeiculoUpdate) => veiculoRepository.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['veiculos', id] })
      queryClient.invalidateQueries({ queryKey: ['veiculos'] })
    }
  })

  return {
    veiculo,
    updateVeiculo
  }
}
