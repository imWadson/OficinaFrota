import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { notificacaoService } from '../../../services/notificacaoService'
import type { NotificacaoInsert, NotificacaoUpdate, ConfiguracaoNotificacao } from '../../../entities/notificacao'
import { useAuthStore } from '../../auth/stores/authStore'

export function useNotificacoes(usuarioId?: number) {
  const authStore = useAuthStore()
  const queryClient = useQueryClient()
  const userId = usuarioId || authStore.user?.id

  // Buscar notificações do usuário
  const notificacoes = useQuery({
    queryKey: ['notificacoes', userId],
    queryFn: () => notificacaoService.buscarPorUsuario(userId!),
    enabled: !!userId,
    staleTime: 30 * 1000, // 30 segundos
    gcTime: 5 * 60 * 1000 // 5 minutos
  })

  // Buscar notificações não lidas
  const notificacoesNaoLidas = useQuery({
    queryKey: ['notificacoes', userId, 'nao-lidas'],
    queryFn: () => notificacaoService.buscarPorUsuario(userId!, { lidas: false }),
    enabled: !!userId,
    staleTime: 30 * 1000,
    gcTime: 5 * 60 * 1000
  })

  // Contador de notificações não lidas
  const contadorNaoLidas = useQuery({
    queryKey: ['notificacoes', userId, 'contador'],
    queryFn: () => notificacaoService.contarNaoLidas(userId!),
    enabled: !!userId,
    staleTime: 30 * 1000,
    gcTime: 5 * 60 * 1000
  })

  // Buscar configurações de notificação
  const configuracoes = useQuery({
    queryKey: ['notificacoes', userId, 'configuracoes'],
    queryFn: () => notificacaoService.buscarConfiguracao(userId!),
    enabled: !!userId,
    staleTime: 5 * 60 * 1000, // 5 minutos
    gcTime: 10 * 60 * 1000 // 10 minutos
  })

  // Mutations
  const marcarComoLida = useMutation({
    mutationFn: (id: number) => notificacaoService.marcarComoLida(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId] })
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId, 'nao-lidas'] })
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId, 'contador'] })
    }
  })

  const marcarTodasComoLidas = useMutation({
    mutationFn: () => notificacaoService.marcarTodasComoLidas(userId!),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId] })
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId, 'contador'] })
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId, 'nao-lidas'] })
    }
  })

  const deletarNotificacao = useMutation({
    mutationFn: (id: number) => notificacaoService.deletar(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId] })
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId, 'nao-lidas'] })
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId, 'contador'] })
    }
  })

  const atualizarConfiguracao = useMutation({
    mutationFn: ({ id, configuracao }: { id: number; configuracao: Partial<ConfiguracaoNotificacao> }) =>
      notificacaoService.atualizarConfiguracao(id, configuracao),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId, 'configuracoes'] })
    }
  })

  const limparAntigas = useMutation({
    mutationFn: () => notificacaoService.limparAntigas(userId!),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId] })
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId, 'nao-lidas'] })
      queryClient.invalidateQueries({ queryKey: ['notificacoes', userId, 'contador'] })
    }
  })

  return {
    // Queries
    notificacoes,
    notificacoesNaoLidas,
    contadorNaoLidas,
    configuracoes,

    // Mutations
    marcarComoLida,
    marcarTodasComoLidas,
    deletarNotificacao,
    atualizarConfiguracao,
    limparAntigas
  }
}

export function useNotificacao(id: number) {
  const queryClient = useQueryClient()

  const notificacao = useQuery({
    queryKey: ['notificacao', id],
    queryFn: () => notificacaoService.buscarPorUsuario(id),
    enabled: !!id
  })

  const marcarComoLida = useMutation({
    mutationFn: () => notificacaoService.marcarComoLida(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notificacao', id] })
    }
  })

  return {
    notificacao,
    marcarComoLida
  }
}

export function useCriarNotificacao() {
  const queryClient = useQueryClient()
  const authStore = useAuthStore()

  const criarNotificacao = useMutation({
    mutationFn: (notificacao: NotificacaoInsert) => {
      const notificacaoComUsuario = {
        ...notificacao,
        usuario_id: notificacao.usuario_id || authStore.user?.id
      }
      return notificacaoService.criar(notificacaoComUsuario)
    },
    onSuccess: () => {
      // Invalidar queries relacionadas
      queryClient.invalidateQueries({ queryKey: ['notificacoes'] })
    }
  })

  const criarNotificacaoEstoque = useMutation({
    mutationFn: (dados: {
      peca_id: number
      peca_nome: string
      quantidade_atual: number
      quantidade_minima: number
    }) => notificacaoService.criarNotificacaoEstoque(authStore.user?.id!, dados),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notificacoes'] })
    }
  })

  const criarNotificacaoManutencao = useMutation({
    mutationFn: (dados: {
      veiculo_id: number
      veiculo_placa: string
      ordem_servico_id: number
      dias_em_andamento: number
    }) => notificacaoService.criarNotificacaoManutencao(authStore.user?.id!, dados),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notificacoes'] })
    }
  })

  const criarNotificacaoSistema = useMutation({
    mutationFn: (dados: {
      acao: string
      detalhes: string
      tipo?: 'info' | 'warning' | 'error' | 'success'
      prioridade?: 'baixa' | 'media' | 'alta' | 'critica'
    }) => notificacaoService.criarNotificacaoSistema(
      authStore.user?.id!,
      { acao: dados.acao, detalhes: dados.detalhes },
      dados.tipo,
      dados.prioridade
    ),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notificacoes'] })
    }
  })

  return {
    criarNotificacao,
    criarNotificacaoEstoque,
    criarNotificacaoManutencao,
    criarNotificacaoSistema
  }
}
