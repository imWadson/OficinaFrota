import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { servicosExternosRepository, type ServicoExternoInsert } from '../../../services/repositories/servicosExternosRepository'

export function useServicosExternos(ordemServicoId: string) {
  const queryClient = useQueryClient()

  const servicosExternos = useQuery({
    queryKey: ['servicos-externos', ordemServicoId],
    queryFn: () => servicosExternosRepository.findByOrdemServico(ordemServicoId),
    enabled: !!ordemServicoId
  })

  const enviarParaOficina = useMutation({
    mutationFn: (data: ServicoExternoInsert) => servicosExternosRepository.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['servicos-externos', ordemServicoId] })
    }
  })

  const finalizarServico = useMutation({
    mutationFn: ({ id, dataRetorno }: { id: number; dataRetorno?: string }) =>
      servicosExternosRepository.finalizarServico(id, dataRetorno),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['servicos-externos', ordemServicoId] })
    }
  })

  const cancelarServico = useMutation({
    mutationFn: (id: number) => servicosExternosRepository.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['servicos-externos', ordemServicoId] })
    }
  })

  return {
    servicosExternos,
    enviarParaOficina,
    finalizarServico,
    cancelarServico
  }
}
