import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '../../../services/supabase'
import type { User } from '@supabase/supabase-js'
import { ESTADOS, CARGOS, type Regional, type Cargo } from '../../../entities/regional'

export interface UserMetadata {
  nome: string
  matricula: string
  regional_id: string
  cargo_id: string
  estado: string
  regional_nome: string
  cargo_nome: string
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const loading = ref(false)
  const initialized = ref(false)
  const loginAttempts = ref(0)
  const lastLoginAttempt = ref(0)

  const isAuthenticated = computed(() => !!user.value)

  // Computed properties para dados do usuário
  const userMetadata = computed((): UserMetadata | null => {
    if (!user.value?.user_metadata) return null
    return user.value.user_metadata as UserMetadata
  })

  const userRegional = computed(() => {
    if (!userMetadata.value?.regional_id) return null
    return ESTADOS
      .flatMap(estado => estado.regionais)
      .find(regional => regional.id === userMetadata.value?.regional_id)
  })

  const userCargo = computed(() => {
    if (!userMetadata.value?.cargo_id) return null
    return CARGOS.find(cargo => cargo.id === userMetadata.value?.cargo_id)
  })

  const userEstado = computed(() => {
    if (!userMetadata.value?.estado) return null
    return ESTADOS.find(estado => estado.nome === userMetadata.value?.estado)
  })

  // Validação de senha forte
  const validatePassword = (password: string): { valid: boolean; errors: string[] } => {
    const errors: string[] = []
    
    if (password.length < 8) {
      errors.push('Senha deve ter pelo menos 8 caracteres')
    }
    if (!/[A-Z]/.test(password)) {
      errors.push('Senha deve conter pelo menos uma letra maiúscula')
    }
    if (!/[a-z]/.test(password)) {
      errors.push('Senha deve conter pelo menos uma letra minúscula')
    }
    if (!/\d/.test(password)) {
      errors.push('Senha deve conter pelo menos um número')
    }
    if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
      errors.push('Senha deve conter pelo menos um caractere especial')
    }
    
    return { valid: errors.length === 0, errors }
  }

  // Rate limiting básico
  const checkRateLimit = (): boolean => {
    const now = Date.now()
    const timeWindow = 15 * 60 * 1000 // 15 minutos
    
    if (now - lastLoginAttempt.value < timeWindow && loginAttempts.value >= 5) {
      return false // Bloqueado
    }
    
    if (now - lastLoginAttempt.value > timeWindow) {
      loginAttempts.value = 0 // Reset após 15 minutos
    }
    
    return true
  }

  async function signIn(email: string, password: string) {
    // Rate limiting
    if (!checkRateLimit()) {
      return { 
        success: false, 
        error: 'Muitas tentativas de login. Tente novamente em 15 minutos.' 
      }
    }

    loading.value = true
    loginAttempts.value++
    lastLoginAttempt.value = Date.now()

    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      })
      
      if (error) throw error
      
      user.value = data.user
      loginAttempts.value = 0 // Reset on success
      return { success: true }
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Erro ao fazer login' }
    } finally {
      loading.value = false
    }
  }

  async function signUp(
    email: string, 
    password: string, 
    metadata: {
      nome: string
      matricula: string
      regional_id: string
      cargo_id: string
    }
  ) {
    // Validação de senha
    const passwordValidation = validatePassword(password)
    if (!passwordValidation.valid) {
      return { 
        success: false, 
        error: 'Senha inválida: ' + passwordValidation.errors.join(', ') 
      }
    }

    // Validação de matrícula
    if (!metadata.matricula || metadata.matricula.length < 3) {
      return {
        success: false,
        error: 'Matrícula é obrigatória e deve ter pelo menos 3 caracteres'
      }
    }

    // Buscar dados da regional e cargo
    const regional = ESTADOS
      .flatMap(estado => estado.regionais)
      .find(r => r.id === metadata.regional_id)
    
    const cargo = CARGOS.find(c => c.id === metadata.cargo_id)

    if (!regional) {
      return {
        success: false,
        error: 'Regional selecionada é inválida'
      }
    }

    if (!cargo) {
      return {
        success: false,
        error: 'Cargo selecionado é inválido'
      }
    }

    // Buscar estado da regional
    const estado = ESTADOS.find(e => 
      e.regionais.some(r => r.id === metadata.regional_id)
    )

    loading.value = true
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            ...metadata,
            estado: estado?.nome,
            regional_nome: regional.nome,
            cargo_nome: cargo.nome
          }
        }
      })
      
      if (error) throw error
      
      // Se o usuário foi criado mas precisa confirmar email
      if (data.user && !data.session) {
        return { 
          success: true, 
          message: 'Conta criada! Verifique seu email para ativar a conta.',
          needsConfirmation: true 
        }
      }
      
      // Se foi criado e já está logado (confirmação automática)
      if (data.user && data.session) {
        user.value = data.user
        return { success: true, message: 'Conta criada com sucesso!' }
      }
      
      return { success: true, message: 'Conta criada com sucesso!' }
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Erro ao criar conta' }
    } finally {
      loading.value = false
    }
  }

  async function signOut() {
    loading.value = true
    try {
      const { error } = await supabase.auth.signOut()
      if (error) throw error
      
      user.value = null
      return { success: true }
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Erro ao fazer logout' }
    } finally {
      loading.value = false
    }
  }

  async function getCurrentUser() {
    const { data: { user: currentUser } } = await supabase.auth.getUser()
    user.value = currentUser
  }

  // Inicializar o usuário atual
  async function initializeAuth() {
    if (initialized.value) return

    try {
      // Verificar se há uma sessão ativa
      const { data: { session } } = await supabase.auth.getSession()
      if (session?.user) {
        user.value = session.user
      }

      // Escutar mudanças na autenticação
      supabase.auth.onAuthStateChange((event, session) => {
        user.value = session?.user ?? null
      })

      initialized.value = true
    } catch (error) {
      console.error('Erro ao inicializar autenticação:', error)
      initialized.value = true // Marcar como inicializado mesmo com erro
    }
  }

  return {
    user,
    loading,
    initialized,
    isAuthenticated,
    userMetadata,
    userRegional,
    userCargo,
    userEstado,
    signIn,
    signUp,
    signOut,
    getCurrentUser,
    initializeAuth
  }
})
