import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '../../../services/supabase'
import type { User } from '@supabase/supabase-js'
import { ESTADOS, CARGOS, SETORES, type Regional, type Cargo, type Setor } from '../../../entities/rbac'

export interface UserMetadata {
  nome: string
  matricula: string
  regional_id: string
  cargo_id: string
  setor: string
  estado: string
  regional_nome: string
  cargo_nome: string
  setor_nome: string
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

  // Dados reais do usuário da tabela usuarios
  const userData = ref<any>(null)

  // Dados reais do usuário carregados do Supabase
  const userRegionalData = ref<any>(null)
  const userCargoData = ref<any>(null)

  const userRegional = computed(() => {
    // Usar dados reais do Supabase se disponíveis
    if (userRegionalData.value) {
      return userRegionalData.value
    }

    // Fallback para userMetadata (se ainda existir)
    if (!userMetadata.value?.regional_id) return null
    return ESTADOS
      .flatMap(estado => estado.regionais)
      .find(regional => regional.id === userMetadata.value?.regional_id)
  })

  const userCargo = computed(() => {
    // Usar dados reais do Supabase se disponíveis
    if (userCargoData.value) {
      return userCargoData.value
    }

    // Fallback para userMetadata (se ainda existir)
    if (!userMetadata.value?.cargo_id) return null
    return CARGOS.find(cargo => cargo.id === userMetadata.value?.cargo_id)
  })

  const userSetor = computed(() => {
    if (!userMetadata.value?.setor) return null
    return SETORES.find(setor => setor.sigla === userMetadata.value?.setor)
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

  // Função para carregar dados do usuário da tabela usuarios
  async function loadUserData() {
    if (!user.value?.id) return

    try {
      // Carregar dados básicos do usuário
      const { data, error } = await supabase
        .from('usuarios')
        .select(`
          id,
          nome,
          email,
          matricula,
          cargo_id,
          regional_id,
          ativo
        `)
        .eq('auth_user_id', user.value.id)
        .single()

      if (error) {
        console.error('Erro ao carregar dados do usuário:', error)
        return
      }

      userData.value = data

      // Carregar dados da regional
      if (data.regional_id) {
        const { data: regionalData, error: regionalError } = await supabase
          .from('regionais')
          .select(`
            id,
            nome,
            sigla,
            estado_id,
            estados!inner(id, nome, sigla)
          `)
          .eq('id', data.regional_id)
          .single()

        if (regionalError) {
          console.error('Erro ao carregar dados da regional:', regionalError)
        } else {
          userRegionalData.value = regionalData
        }
      }

      // Carregar dados do cargo
      if (data.cargo_id) {
        const { data: cargoData, error: cargoError } = await supabase
          .from('cargos')
          .select(`
            id,
            nome,
            sigla,
            nivel,
            setor_id
          `)
          .eq('id', data.cargo_id)
          .single()

        if (cargoError) {
          console.error('Erro ao carregar dados do cargo:', cargoError)
        } else {
          userCargoData.value = cargoData
        }
      }

    } catch (error) {
      console.error('Erro ao carregar dados do usuário:', error)
    }
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

      // Verificar se o usuário existe na tabela usuarios
      const { data: userData, error: userError } = await supabase
        .from('usuarios')
        .select('*')
        .eq('auth_user_id', data.user.id)

      // Se não existe, criar com dados do metadata
      if ((!userData || userData.length === 0) && data.user.user_metadata) {
        const metadata = data.user.user_metadata as UserMetadata
        const { error: insertError } = await supabase
          .from('usuarios')
          .insert({
            auth_user_id: data.user.id,
            nome: metadata.nome || 'Usuário',
            email: data.user.email || '',
            matricula: metadata.matricula || 'N/A',
            cargo_id: metadata.cargo_id,
            regional_id: metadata.regional_id,
            ativo: true
          })

        if (insertError) {
          console.error('Erro ao criar usuário na tabela:', insertError)
        }
      }

      // Carregar dados do usuário da tabela usuarios
      await loadUserData()

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
      setor: string
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

    loading.value = true

    try {
      // Buscar cargo real do Supabase pelo sigla
      const { data: cargoData, error: cargoError } = await supabase
        .from('cargos')
        .select('id, nome')
        .eq('sigla', metadata.cargo_id)
        .single()

      if (cargoError || !cargoData) {
        return {
          success: false,
          error: 'Cargo selecionado é inválido'
        }
      }

      // Buscar regional real do Supabase pelo nome
      const { data: regionalData, error: regionalError } = await supabase
        .from('regionais')
        .select('id, nome')
        .eq('nome', metadata.regional_id)
        .single()

      if (regionalError || !regionalData) {
        return {
          success: false,
          error: 'Regional selecionada é inválida'
        }
      }

      // Buscar estado da regional
      const estado = ESTADOS.find(e =>
        e.regionais.some(r => r.nome === metadata.regional_id)
      )

      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            ...metadata,
            estado: estado?.nome,
            regional_nome: regionalData.nome,
            cargo_nome: cargoData.nome,
            setor_nome: metadata.setor
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

        // Criar registro na tabela usuarios
        const { error: userError } = await supabase
          .from('usuarios')
          .insert({
            auth_user_id: data.user.id,
            nome: metadata.nome,
            email: email,
            matricula: metadata.matricula,
            cargo_id: cargoData.id, // Usar UUID real do cargo
            regional_id: regionalData.id, // Usar UUID real da regional
            ativo: true
          })

        if (userError) {
          console.error('Erro ao criar usuário na tabela:', userError)
          // Não falhar o cadastro, mas logar o erro
        }

        return { success: true, message: 'Conta criada com sucesso!' }
      }

      // Se precisa confirmação, criar o registro quando confirmar
      if (data.user && !data.session) {
        // Criar registro na tabela usuarios mesmo sem sessão
        const { error: userError } = await supabase
          .from('usuarios')
          .insert({
            auth_user_id: data.user.id,
            nome: metadata.nome,
            email: email,
            matricula: metadata.matricula,
            cargo_id: cargoData.id, // Usar UUID real do cargo
            regional_id: regionalData.id, // Usar UUID real da regional
            ativo: true
          })

        if (userError) {
          console.error('Erro ao criar usuário na tabela:', userError)
        }
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
        // Carregar dados do usuário quando há sessão ativa
        await loadUserData()
      }

      // Escutar mudanças na autenticação
      supabase.auth.onAuthStateChange(async (event, session) => {
        user.value = session?.user ?? null

        // Carregar dados do usuário quando o estado de autenticação muda
        if (session?.user) {
          await loadUserData()
        } else {
          // Limpar dados quando usuário faz logout
          userData.value = null
          userRegionalData.value = null
          userCargoData.value = null
        }
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
    userSetor,
    userEstado,
    userData,
    userRegionalData,
    userCargoData,
    loadUserData,
    signIn,
    signUp,
    signOut,
    getCurrentUser,
    initializeAuth
  }
})
