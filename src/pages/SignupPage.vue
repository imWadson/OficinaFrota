<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-50 via-white to-amber-50/30 flex items-center justify-center p-4">
    <!-- Container Principal -->
    <div class="w-full max-w-2xl">
      <!-- Card de Cadastro -->
      <div class="bg-white rounded-2xl shadow-xl border border-slate-200/60 overflow-hidden">
        <!-- Header do Card -->
        <div class="bg-gradient-to-r from-amber-500 to-orange-600 px-8 py-6 text-center">
          <div class="flex items-center justify-center space-x-3 mb-4">
            <div class="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
              <WrenchScrewdriverIcon class="w-6 h-6 text-white" />
            </div>
            <div class="text-left">
              <h1 class="text-2xl font-bold text-white">Frota Gestor</h1>
              <p class="text-amber-100 text-sm">Sistema Corporativo</p>
            </div>
          </div>
          <p class="text-amber-100 text-sm">Crie sua conta corporativa</p>
        </div>

        <!-- Formulário -->
        <div class="px-8 py-8">
          <form @submit.prevent="handleSignup" class="space-y-6">
            <!-- Informações Pessoais -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <!-- Nome Completo -->
              <div>
                <label for="nome" class="block text-sm font-semibold text-slate-700 mb-2">
                  Nome Completo
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <svg class="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                  </div>
                  <input
                    id="nome"
                    v-model="form.nome"
                    name="nome"
                    type="text"
                    required
                    class="block w-full pl-12 pr-4 py-3 border border-slate-300 rounded-xl placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 transition-all duration-200"
                    placeholder="João Silva Santos"
                  />
                </div>
              </div>

              <!-- Matrícula -->
              <div>
                <label for="matricula" class="block text-sm font-semibold text-slate-700 mb-2">
                  Matrícula
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <svg class="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                  </div>
                  <input
                    id="matricula"
                    v-model="form.matricula"
                    name="matricula"
                    type="text"
                    required
                    class="block w-full pl-12 pr-4 py-3 border border-slate-300 rounded-xl placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 transition-all duration-200"
                    placeholder="12345"
                  />
                </div>
              </div>
            </div>

            <!-- Email -->
            <div>
              <label for="email" class="block text-sm font-semibold text-slate-700 mb-2">
                Email Corporativo
              </label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <svg class="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
                  </svg>
                </div>
                <input
                  id="email"
                  v-model="form.email"
                  name="email"
                  type="email"
                  autocomplete="email"
                  required
                  class="block w-full pl-12 pr-4 py-3 border border-slate-300 rounded-xl placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 transition-all duration-200"
                  placeholder="seu.email@empresa.com"
                />
              </div>
            </div>

            <!-- Regional e Cargo -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <!-- Estado -->
              <div>
                <label for="estado" class="block text-sm font-semibold text-slate-700 mb-2">
                  Estado
                </label>
                <select
                  id="estado"
                  v-model="form.estado"
                  @change="form.regional_id = ''"
                  required
                  class="block w-full px-4 py-3 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 transition-all duration-200"
                >
                  <option value="">Selecione o estado</option>
                  <option v-for="estado in ESTADOS" :key="estado.id" :value="estado.nome">
                    {{ estado.nome }}
                  </option>
                </select>
              </div>

              <!-- Regional -->
              <div>
                <label for="regional" class="block text-sm font-semibold text-slate-700 mb-2">
                  Regional
                </label>
                <select
                  id="regional"
                  v-model="form.regional_id"
                  required
                  :disabled="!form.estado"
                  class="block w-full px-4 py-3 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 transition-all duration-200 disabled:bg-slate-50 disabled:cursor-not-allowed"
                >
                  <option value="">Selecione a regional</option>
                  <option 
                    v-for="regional in regionaisDisponiveis" 
                    :key="regional.id" 
                    :value="regional.id"
                  >
                    {{ regional.nome }}
                  </option>
                </select>
              </div>
            </div>

            <!-- Cargo -->
            <div>
              <label for="cargo" class="block text-sm font-semibold text-slate-700 mb-2">
                Cargo
              </label>
              <select
                id="cargo"
                v-model="form.cargo_id"
                required
                class="block w-full px-4 py-3 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 transition-all duration-200"
              >
                <option value="">Selecione o cargo</option>
                <option v-for="cargo in CARGOS" :key="cargo.id" :value="cargo.id">
                  {{ cargo.nome }}
                </option>
              </select>
            </div>

            <!-- Senhas -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <!-- Senha -->
              <div>
                <label for="password" class="block text-sm font-semibold text-slate-700 mb-2">
                  Senha
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <svg class="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                    </svg>
                  </div>
                  <input
                    id="password"
                    v-model="form.password"
                    name="password"
                    :type="showPassword ? 'text' : 'password'"
                    required
                    class="block w-full pl-12 pr-12 py-3 border border-slate-300 rounded-xl placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 transition-all duration-200"
                    placeholder="••••••••"
                  />
                  <button
                    type="button"
                    @click="showPassword = !showPassword"
                    class="absolute inset-y-0 right-0 pr-4 flex items-center text-slate-400 hover:text-slate-600 transition-colors"
                  >
                    <svg v-if="showPassword" class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21" />
                    </svg>
                    <svg v-else class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                  </button>
                </div>
              </div>

              <!-- Confirmar Senha -->
              <div>
                <label for="confirmPassword" class="block text-sm font-semibold text-slate-700 mb-2">
                  Confirmar Senha
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <svg class="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                    </svg>
                  </div>
                  <input
                    id="confirmPassword"
                    v-model="form.confirmPassword"
                    name="confirmPassword"
                    type="password"
                    required
                    class="block w-full pl-12 pr-4 py-3 border border-slate-300 rounded-xl placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 transition-all duration-200"
                    placeholder="••••••••"
                  />
                </div>
              </div>
            </div>

            <!-- Requisitos da Senha -->
            <div class="bg-slate-50 rounded-xl p-4">
              <h4 class="text-sm font-semibold text-slate-700 mb-3">Requisitos da senha:</h4>
              <ul class="text-sm text-slate-600 space-y-1">
                <li class="flex items-center" :class="{ 'text-green-600': hasMinLength }">
                  <svg v-if="hasMinLength" class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                  </svg>
                  <svg v-else class="w-4 h-4 mr-2 text-slate-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z" clip-rule="evenodd" />
                  </svg>
                  Pelo menos 8 caracteres
                </li>
                <li class="flex items-center" :class="{ 'text-green-600': hasUpperCase }">
                  <svg v-if="hasUpperCase" class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                  </svg>
                  <svg v-else class="w-4 h-4 mr-2 text-slate-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z" clip-rule="evenodd" />
                  </svg>
                  Uma letra maiúscula
                </li>
                <li class="flex items-center" :class="{ 'text-green-600': hasNumber }">
                  <svg v-if="hasNumber" class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                  </svg>
                  <svg v-else class="w-4 h-4 mr-2 text-slate-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z" clip-rule="evenodd" />
                  </svg>
                  Um número
                </li>
                <li class="flex items-center" :class="{ 'text-green-600': hasSpecialChar }">
                  <svg v-if="hasSpecialChar" class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                  </svg>
                  <svg v-else class="w-4 h-4 mr-2 text-slate-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z" clip-rule="evenodd" />
                  </svg>
                  Um caractere especial
                </li>
              </ul>
            </div>

            <!-- Termos -->
            <div class="flex items-start">
              <div class="flex items-center h-5">
                <input
                  id="terms"
                  v-model="form.aceiteTermos"
                  name="terms"
                  type="checkbox"
                  required
                  class="h-4 w-4 text-amber-600 focus:ring-amber-500 border-slate-300 rounded"
                />
              </div>
              <div class="ml-3 text-sm">
                <label for="terms" class="text-slate-700">
                  Eu concordo com os 
                  <a href="#" class="font-medium text-amber-600 hover:text-amber-700">Termos de Serviço</a>
                  e 
                  <a href="#" class="font-medium text-amber-600 hover:text-amber-700">Política de Privacidade</a>
                </label>
              </div>
            </div>

            <!-- Mensagem de Status -->
            <div v-if="message" class="rounded-xl p-4" :class="messageType === 'success' ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'">
              <div class="flex">
                <div class="flex-shrink-0">
                  <svg v-if="messageType === 'success'" class="h-5 w-5 text-green-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                  </svg>
                  <svg v-else class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                  </svg>
                </div>
                <div class="ml-3">
                  <p class="text-sm" :class="messageType === 'success' ? 'text-green-800' : 'text-red-800'">
                    {{ message }}
                  </p>
                </div>
              </div>
            </div>

            <!-- Botão de Cadastro -->
            <div>
              <button
                type="submit"
                :disabled="isLoading || !isFormValid"
                class="w-full flex justify-center items-center py-3 px-4 border border-transparent rounded-xl text-sm font-semibold text-white bg-gradient-to-r from-amber-500 to-orange-600 hover:from-amber-600 hover:to-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-amber-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 transform hover:-translate-y-0.5 shadow-lg hover:shadow-xl"
              >
                <svg v-if="isLoading" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                {{ isLoading ? 'Criando conta...' : 'Criar Conta Corporativa' }}
              </button>
            </div>
          </form>

          <!-- Divisor -->
          <div class="mt-8">
            <div class="relative">
              <div class="absolute inset-0 flex items-center">
                <div class="w-full border-t border-slate-200" />
              </div>
              <div class="relative flex justify-center text-sm">
                <span class="px-4 bg-white text-slate-500 font-medium">Já tem uma conta?</span>
              </div>
            </div>

            <!-- Botão de Login -->
            <div class="mt-6">
              <router-link
                to="/login"
                class="w-full flex justify-center py-3 px-4 border border-slate-300 rounded-xl shadow-sm text-sm font-semibold text-slate-700 bg-white hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-amber-500 transition-all duration-200"
              >
                Fazer Login
              </router-link>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="mt-8 text-center">
        <p class="text-sm text-slate-500">
          © {{ new Date().getFullYear() }} Frota Gestor. Todos os direitos reservados.
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/features/auth/stores/authStore'
import { ESTADOS, CARGOS } from '@/entities/regional'
import { WrenchScrewdriverIcon } from '@heroicons/vue/24/outline'

const router = useRouter()
const authStore = useAuthStore()

const form = ref({
  nome: '',
  email: '',
  matricula: '',
  estado: '',
  regional_id: '',
  cargo_id: '',
  password: '',
  confirmPassword: '',
  aceiteTermos: false
})

const showPassword = ref(false)
const isLoading = ref(false)
const message = ref('')
const messageType = ref<'success' | 'error'>('success')

// Computed properties
const regionaisDisponiveis = computed(() => {
  if (!form.value.estado) return []
  const estado = ESTADOS.find(e => e.nome === form.value.estado)
  return estado?.regionais || []
})

const isFormValid = computed(() => {
  return form.value.nome.trim() !== '' &&
         form.value.email.trim() !== '' &&
         form.value.matricula.trim() !== '' &&
         form.value.estado !== '' &&
         form.value.regional_id !== '' &&
         form.value.cargo_id !== '' &&
         form.value.password.length >= 8 &&
         form.value.password === form.value.confirmPassword &&
         form.value.aceiteTermos
})

// Computed properties para validação de senha
const hasMinLength = computed(() => {
  return form.value.password.length >= 8
})

const hasUpperCase = computed(() => {
  return /[A-Z]/.test(form.value.password)
})

const hasNumber = computed(() => {
  return /\d/.test(form.value.password)
})

const hasSpecialChar = computed(() => {
  return /[!@#$%^&*(),.?":{}|<>]/.test(form.value.password)
})

async function handleSignup() {
  if (!isFormValid.value) {
    messageType.value = 'error'
    message.value = 'Por favor, preencha todos os campos obrigatórios corretamente.'
    return
  }

  isLoading.value = true
  message.value = ''

  try {
    const result = await authStore.signUp(
      form.value.email,
      form.value.password,
      {
        nome: form.value.nome,
        matricula: form.value.matricula,
        regional_id: form.value.regional_id,
        cargo_id: form.value.cargo_id
      }
    )

    if (result.success) {
      messageType.value = 'success'
      message.value = result.message || 'Conta criada com sucesso!'
      
      // Se não precisa de confirmação, redireciona
      if (!result.needsConfirmation) {
        setTimeout(() => {
          router.push('/')
        }, 2000)
      } else {
        // Se precisa confirmação, mostra mensagem e opção de ir para login
        setTimeout(() => {
          router.push('/login')
        }, 3000)
      }
    } else {
      messageType.value = 'error'
      message.value = result.error || 'Erro ao criar conta'
    }
  } catch (error) {
    messageType.value = 'error'
    message.value = 'Erro inesperado ao criar conta'
    console.error('Erro no cadastro:', error)
  } finally {
    isLoading.value = false
  }
}
</script>
