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
    return user.value?.user_metadata?.role || 'usuario'
  })

  const userEmail = computed(() => {
    return user.value?.email || ''
  })

  return {
    user,
    userInitials,
    userName,
    userRole,
    userEmail
  }
}
