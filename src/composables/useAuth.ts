import { computed } from 'vue'
import { useAuthStore } from '@/features/auth/stores/authStore'

export function useAuth() {
  const authStore = useAuthStore()

  const user = computed(() => authStore.user)
  
  const userInitials = computed(() => {
    if (!user.value?.user_metadata?.nome) {
      // Fallback para email se não tiver nome
      if (user.value?.email) {
        return user.value.email.split('@')[0].substring(0, 2).toUpperCase()
      }
      return 'U'
    }
    
    return user.value.user_metadata.nome
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2)
  })

  const userName = computed(() => {
    return user.value?.user_metadata?.nome || user.value?.email?.split('@')[0] || 'Usuário'
  })

  const userRole = computed(() => {
    return user.value?.user_metadata?.cargo_nome || 'Usuário'
  })

  const userEmail = computed(() => {
    return user.value?.email || ''
  })

  const userMatricula = computed(() => {
    return user.value?.user_metadata?.matricula || ''
  })

  const userRegional = computed(() => {
    return authStore.userRegional
  })

  const userCargo = computed(() => {
    return authStore.userCargo
  })

  const userEstado = computed(() => {
    return authStore.userEstado
  })

  const userRegionalDisplay = computed(() => {
    const regional = userRegional.value
    const estado = userEstado.value
    if (!regional || !estado) return ''
    return `${regional.nome} - ${estado.sigla}`
  })

  const userCargoDisplay = computed(() => {
    return userCargo.value?.nome || 'Usuário'
  })

  // Funções de autorização baseadas em roles
  const hasRole = (role: string) => {
    return userRole.value === role
  }

  const hasAnyRole = (roles: string[]) => {
    return roles.includes(userRole.value)
  }

  const isAdmin = computed(() => hasRole('admin'))
  const isSupervisor = computed(() => hasAnyRole(['admin', 'supervisor']))
  const isUsuario = computed(() => hasAnyRole(['admin', 'supervisor', 'usuario']))

  // Permissões específicas
  const canManageUsers = computed(() => isAdmin.value)
  const canManageVehicles = computed(() => isSupervisor.value)
  const canManageOrders = computed(() => isSupervisor.value)
  const canViewReports = computed(() => isSupervisor.value)
  const canManageInventory = computed(() => isSupervisor.value)

  return {
    user,
    userInitials,
    userName,
    userRole,
    userEmail,
    userMatricula,
    userRegional,
    userCargo,
    userEstado,
    userRegionalDisplay,
    userCargoDisplay,
    hasRole,
    hasAnyRole,
    isAdmin,
    isSupervisor,
    isUsuario,
    canManageUsers,
    canManageVehicles,
    canManageOrders,
    canViewReports,
    canManageInventory
  }
}
