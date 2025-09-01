import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { ordemServicoRepository } from '../../../services/repositories/ordemServicoRepository'
import type { OrdemServicoInsert, OrdemServicoUpdate } from '../../../entities/ordemServico'

export function useOrdensServico(ordemId?: number) {
    const queryClient = useQueryClient()

    // Queries principais
    const ordensServico = useQuery({
        queryKey: ['ordens-servico'],
        queryFn: () => ordemServicoRepository.findAll()
    })

    // Query específica para uma ordem (se ordemId fornecido)
    const ordemServico = useQuery({
        queryKey: ['ordens-servico', ordemId],
        queryFn: () => ordemServicoRepository.findById(ordemId!),
        enabled: !!ordemId
    })

    // Queries filtradas (computadas a partir da query principal)
    const ordensEmAndamento = useQuery({
        queryKey: ['ordens-servico', 'em-andamento'],
        queryFn: () => ordemServicoRepository.getOrdensEmAndamento(),
        enabled: !ordemId // Só buscar se não estiver focado em uma ordem específica
    })

    const ordensConcluidas = useQuery({
        queryKey: ['ordens-servico', 'concluidas'],
        queryFn: () => ordemServicoRepository.getOrdensConcluidas(),
        enabled: !ordemId // Só buscar se não estiver focado em uma ordem específica
    })

    // Mutations
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
            if (ordemId) {
                queryClient.invalidateQueries({ queryKey: ['ordens-servico', ordemId] })
            }
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
        // Queries principais
        ordensServico,
        ordemServico: ordemId ? ordemServico : undefined,

        // Queries filtradas (só disponíveis se não estiver focado em uma ordem)
        ordensEmAndamento: !ordemId ? ordensEmAndamento : undefined,
        ordensConcluidas: !ordemId ? ordensConcluidas : undefined,

        // Mutations
        createOrdemServico,
        updateOrdemServico,
        concluirOrdemServico
    }
}
