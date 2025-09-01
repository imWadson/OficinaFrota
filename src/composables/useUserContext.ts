import { computed } from 'vue'
import { useAuth } from './useAuth'
import { useAuthStore } from '@/features/auth/stores/authStore'
import { supabase } from '@/services/supabase'

export function useUserContext() {
    const { user, userRegional, userCargo } = useAuth()
    const authStore = useAuthStore()

    // Buscar dados completos do usuário no Supabase
    const fetchUserData = async () => {
        if (!user.value) return null

        try {
            const { data, error } = await supabase
                .from('usuarios')
                .select(`
          id,
          nome,
          email,
          matricula,
          ativo,
          cargo_id,
          regional_id,
          supervisor_id,
          cargos!inner(nome, sigla, nivel),
          regionais!inner(nome, sigla)
        `)
                .eq('auth_user_id', user.value.id)
                .single()

            if (error) throw error
            return data
        } catch (error) {
            console.error('Erro ao buscar dados do usuário:', error)
            return null
        }
    }

    // Computed properties para permissões
    const isDiretor = computed(() => {
        return userCargo.value?.sigla === 'DIRETOR' ||
            userCargo.value?.nome?.includes('Diretor')
    })

    const isGerente = computed(() => {
        return userCargo.value?.sigla === 'GERENTE' ||
            userCargo.value?.nome?.includes('Gerente')
    })

    const isSupervisor = computed(() => {
        return userCargo.value?.sigla === 'SUPERVISOR' ||
            userCargo.value?.nome?.includes('Supervisor')
    })

    const isCoordenador = computed(() => {
        return userCargo.value?.sigla === 'COORDENADOR' ||
            userCargo.value?.nome?.includes('Coordenador')
    })

    const canViewAllEstados = computed(() => {
        return isDiretor.value
    })

    const canViewAllRegionais = computed(() => {
        return isDiretor.value || isGerente.value
    })

    const canViewRegional = computed(() => {
        return isDiretor.value || isGerente.value || isSupervisor.value || isCoordenador.value
    })

    // Função para aplicar filtros baseados no usuário
    const applyUserFilters = (query: any) => {
        if (!user.value) {
            return query
        }

        // Diretores podem ver tudo
        if (canViewAllEstados.value) {
            return query
        }

        // Gerentes podem ver todo o estado
        if (canViewAllRegionais.value) {
            return query
        }

        // Outros usuários só veem sua regional
        if (canViewRegional.value && userRegional.value?.id) {
            return query.eq('regional_id', userRegional.value.id)
        }

        // Verificar se userRegionalData tem regional_id
        if (authStore.userRegionalData?.id) {
            return query.eq('regional_id', authStore.userRegionalData.id)
        }

        // Fallback para userData regional_id
        if (authStore.userData?.regional_id) {
            return query.eq('regional_id', authStore.userData.regional_id)
        }

        // Usuários sem permissão não veem nada
        return query.eq('id', '00000000-0000-0000-0000-000000000000') // UUID inválido
    }

    // Função para verificar se usuário pode acessar um recurso
    const canAccessResource = (resourceRegionalId?: string) => {
        if (!user.value) return false

        // Diretores podem acessar tudo
        if (canViewAllEstados.value) return true

        // Gerentes podem acessar todo o estado
        if (canViewAllRegionais.value) return true

        // Outros usuários só podem acessar sua regional
        if (canViewRegional.value) {
            return resourceRegionalId === userRegional.value?.id
        }

        return false
    }

    // Função para obter filtros de regional baseados no usuário
    const getUserRegionalFilters = () => {
        if (!user.value) return []

        // Diretores podem ver todas as regionais
        if (canViewAllEstados.value) {
            return [] // Retorna vazio para não filtrar
        }

        // Gerentes podem ver regionais do seu estado
        if (canViewAllRegionais.value) {
            // Por enquanto, gerentes veem todas (implementar filtro por estado depois)
            return []
        }

        // Outros usuários só veem sua regional
        if (canViewRegional.value && userRegional.value?.id) {
            return [userRegional.value.id]
        }

        return []
    }

    return {
        fetchUserData,
        isDiretor,
        isGerente,
        isSupervisor,
        isCoordenador,
        canViewAllEstados,
        canViewAllRegionais,
        canViewRegional,
        applyUserFilters,
        canAccessResource,
        getUserRegionalFilters
    }
}
