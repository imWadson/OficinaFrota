import { computed } from 'vue'
import { useAuthStore } from '@/features/auth/stores/authStore'

export function useAuth() {
  const authStore = useAuthStore()

  const user = computed(() => authStore.user)
  
  const userInitials = computed(() => {
    if (!user.value?.name) return 'U'
    return user.value.name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2)
  })

  const userRole = computed(() => user.value?.role || 'Usuário')

  return {
    user,
    userInitials,
    userRole
  }
}
