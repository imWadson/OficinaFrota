import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { notificacaoService } from '../../../services/notificacaoService'
import type { NotificacaoInsert } from '../../../entities/notificacao'
import { useAuthStore } from '../../auth/stores/authStore'

export function useNotificacoes() {
    const authStore = useAuthStore()
    const queryClient = useQueryClient()
    const userId = authStore.user?.id

    // Buscar notificações do usuário
    const notificacoes = useQuery({
        queryKey: ['notificacoes', userId],
        queryFn: () => notificacaoService.buscarPorUsuario(userId!),
        enabled: !!userId
    })

    // Buscar notificações não lidas
    const notificacoesNaoLidas = useQuery({
        queryKey: ['notificacoes', userId, 'nao-lidas'],
        queryFn: () => notificacaoService.buscarPorUsuario(userId!, { lidas: false }),
        enabled: !!userId
    })

    // Contador de notificações não lidas
    const contadorNaoLidas = useQuery({
        queryKey: ['notificacoes', userId, 'contador'],
        queryFn: () => notificacaoService.contarNaoLidas(userId!),
        enabled: !!userId
    })

    // Mutations essenciais
    const marcarComoLida = useMutation({
        mutationFn: (id: number) => notificacaoService.marcarComoLida(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['notificacoes', userId] })
        }
    })

    const marcarTodasComoLidas = useMutation({
        mutationFn: () => notificacaoService.marcarTodasComoLidas(userId!),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['notificacoes', userId] })
        }
    })

    const deletarNotificacao = useMutation({
        mutationFn: (id: number) => notificacaoService.deletar(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['notificacoes', userId] })
        }
    })

    const criarNotificacao = useMutation({
        mutationFn: (notificacao: NotificacaoInsert) => {
            const notificacaoComUsuario = {
                ...notificacao,
                usuario_id: notificacao.usuario_id || userId
            }
            return notificacaoService.criar(notificacaoComUsuario)
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['notificacoes', userId] })
        }
    })

    return {
        // Queries
        notificacoes,
        notificacoesNaoLidas,
        contadorNaoLidas,

        // Mutations
        marcarComoLida,
        marcarTodasComoLidas,
        deletarNotificacao,
        criarNotificacao
    }
}
