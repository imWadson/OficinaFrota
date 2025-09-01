import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { auditoriaService } from '../../../services/auditoriaService'
import type {
  AuditoriaFiltros,
  AuditoriaResumo,
  AcaoAuditoria,
  EntidadeAuditoria,
  ContextoAuditoria
} from '../../../entities/auditoria'
import { useAuthStore } from '../../auth/stores/authStore'

export function useAuditoria() {
  const queryClient = useQueryClient()
  const authStore = useAuthStore()

  // Buscar logs de auditoria
  const auditoria = useQuery({
    queryKey: ['auditoria'],
    queryFn: () => auditoriaService.buscar(),
    staleTime: 5 * 60 * 1000, // 5 minutos
    gcTime: 10 * 60 * 1000 // 10 minutos
  })

  // Buscar auditoria com filtros
  const buscarAuditoria = (filtros: AuditoriaFiltros) => {
    return useQuery({
      queryKey: ['auditoria', filtros],
      queryFn: () => auditoriaService.buscar(filtros),
      staleTime: 5 * 60 * 1000,
      gcTime: 10 * 60 * 1000
    })
  }

  // Buscar resumo de auditoria
  const resumoAuditoria = (periodo: { inicio: string; fim: string }) => {
    return useQuery({
      queryKey: ['auditoria', 'resumo', periodo],
      queryFn: () => auditoriaService.buscarResumo(periodo),
      staleTime: 5 * 60 * 1000,
      gcTime: 10 * 60 * 1000
    })
  }

  // Buscar auditoria por entidade
  const auditoriaPorEntidade = (entidade: string, entidadeId: number) => {
    return useQuery({
      queryKey: ['auditoria', 'entidade', entidade, entidadeId],
      queryFn: () => auditoriaService.buscarPorEntidade(entidade, entidadeId),
      staleTime: 5 * 60 * 1000,
      gcTime: 10 * 60 * 1000
    })
  }

  // Buscar auditoria por usuário
  const auditoriaPorUsuario = (usuarioId: number, limit: number = 100) => {
    return useQuery({
      queryKey: ['auditoria', 'usuario', usuarioId, limit],
      queryFn: () => auditoriaService.buscarPorUsuario(usuarioId, limit),
      staleTime: 5 * 60 * 1000,
      gcTime: 10 * 60 * 1000
    })
  }

  // Buscar auditoria por período
  const auditoriaPorPeriodo = (inicio: string, fim: string, limit: number = 1000) => {
    return useQuery({
      queryKey: ['auditoria', 'periodo', inicio, fim, limit],
      queryFn: () => auditoriaService.buscarPorPeriodo(inicio, fim, limit),
      staleTime: 5 * 60 * 1000,
      gcTime: 10 * 60 * 1000
    })
  }

  // Exportar auditoria
  const exportarAuditoria = useMutation({
    mutationFn: (filtros: AuditoriaFiltros) => auditoriaService.exportarCSV(filtros),
    onSuccess: (csvContent: string) => {
      // Download do arquivo CSV
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `auditoria-${new Date().toISOString().split('T')[0]}.csv`
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    }
  })

  // Limpar auditoria antiga
  const limparAuditoriaAntiga = useMutation({
    mutationFn: () => auditoriaService.limparAntiga(),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['auditoria'] })
    }
  })

  return {
    // Queries
    auditoria,
    buscarAuditoria,
    resumoAuditoria,
    auditoriaPorEntidade,
    auditoriaPorUsuario,
    auditoriaPorPeriodo,

    // Mutations
    exportarAuditoria,
    limparAuditoriaAntiga
  }
}

export function useRegistrarAuditoria() {
  const queryClient = useQueryClient()
  const authStore = useAuthStore()

  // Registrar ação genérica
  const registrarAcao = useMutation({
    mutationFn: async ({
      acao,
      entidade,
      opcoes
    }: {
      acao: AcaoAuditoria | string
      entidade: EntidadeAuditoria | string
      opcoes?: {
        entidade_id?: number
        dados_anteriores?: Record<string, any>
        dados_novos?: Record<string, any>
        contexto?: ContextoAuditoria
      }
    }) => {
      if (!authStore.user?.id) {
        throw new Error('Usuário não autenticado')
      }

      return auditoriaService.registrar(
        authStore.user.id,
        acao,
        entidade,
        opcoes || {}
      )
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['auditoria'] })
    }
  })

  // Métodos de conveniência
  const registrarLogin = useMutation({
    mutationFn: async (contexto?: ContextoAuditoria) => {
      if (!authStore.user?.id) {
        throw new Error('Usuário não autenticado')
      }

      return auditoriaService.registrarLogin(authStore.user.id, contexto)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['auditoria'] })
    }
  })

  const registrarLogout = useMutation({
    mutationFn: async (contexto?: ContextoAuditoria) => {
      if (!authStore.user?.id) {
        throw new Error('Usuário não autenticado')
      }

      return auditoriaService.registrarLogout(authStore.user.id, contexto)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['auditoria'] })
    }
  })

  const registrarCriacao = useMutation({
    mutationFn: async ({
      entidade,
      entidadeId,
      dados,
      contexto
    }: {
      entidade: EntidadeAuditoria
      entidadeId: number
      dados: Record<string, any>
      contexto?: ContextoAuditoria
    }) => {
      if (!authStore.user?.id) {
        throw new Error('Usuário não autenticado')
      }

      return auditoriaService.registrarCriacao(
        authStore.user.id,
        entidade,
        entidadeId,
        dados,
        contexto
      )
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['auditoria'] })
    }
  })

  const registrarAtualizacao = useMutation({
    mutationFn: async ({
      entidade,
      entidadeId,
      dadosAnteriores,
      dadosNovos,
      contexto
    }: {
      entidade: EntidadeAuditoria
      entidadeId: number
      dadosAnteriores: Record<string, any>
      dadosNovos: Record<string, any>
      contexto?: ContextoAuditoria
    }) => {
      if (!authStore.user?.id) {
        throw new Error('Usuário não autenticado')
      }

      return auditoriaService.registrarAtualizacao(
        authStore.user.id,
        entidade,
        entidadeId,
        dadosAnteriores,
        dadosNovos,
        contexto
      )
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['auditoria'] })
    }
  })

  const registrarExclusao = useMutation({
    mutationFn: async ({
      entidade,
      entidadeId,
      dados,
      contexto
    }: {
      entidade: EntidadeAuditoria
      entidadeId: number
      dados: Record<string, any>
      contexto?: ContextoAuditoria
    }) => {
      if (!authStore.user?.id) {
        throw new Error('Usuário não autenticado')
      }

      return auditoriaService.registrarExclusao(
        authStore.user.id,
        entidade,
        entidadeId,
        dados,
        contexto
      )
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['auditoria'] })
    }
  })

  return {
    registrarAcao,
    registrarLogin,
    registrarLogout,
    registrarCriacao,
    registrarAtualizacao,
    registrarExclusao
  }
}

export function useAuditoriaEmTempoReal() {
  const queryClient = useQueryClient()

  // Função para invalidar queries de auditoria
  const invalidarAuditoria = () => {
    queryClient.invalidateQueries({ queryKey: ['auditoria'] })
  }

  // Função para atualizar auditoria em tempo real
  const atualizarAuditoria = () => {
    // Em uma implementação real, isso seria conectado a um WebSocket
    // ou Server-Sent Events para atualizações em tempo real
    invalidarAuditoria()
  }

  return {
    invalidarAuditoria,
    atualizarAuditoria
  }
}
