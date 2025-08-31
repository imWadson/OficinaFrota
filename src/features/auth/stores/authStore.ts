import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '../../../services/supabase'
import type { User } from '@supabase/supabase-js'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const loading = ref(false)
  const initialized = ref(false)

  const isAuthenticated = computed(() => !!user.value)

  async function signIn(email: string, password: string) {
    loading.value = true
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      })
      
      if (error) throw error
      
      user.value = data.user
      return { success: true }
    } catch (error) {
      return { success: false, error: error instanceof Error ? error.message : 'Erro ao fazer login' }
    } finally {
      loading.value = false
    }
  }

  async function signUp(email: string, password: string, metadata?: { nome?: string; role?: string }) {
    loading.value = true
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: metadata
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
    signIn,
    signUp,
    signOut,
    getCurrentUser,
    initializeAuth
  }
})
