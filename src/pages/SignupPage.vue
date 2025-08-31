<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-gray-50">
    <div class="min-h-screen flex">
      <!-- Lado Esquerdo - Branding (mesmo do login) -->
      <div class="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-blue-600 to-blue-800 relative overflow-hidden">
        <div class="absolute inset-0 bg-black bg-opacity-20"></div>
        
        <!-- Background Pattern -->
        <div class="absolute inset-0 opacity-10">
          <svg class="h-full w-full" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <defs>
              <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
                <path d="M 40 0 L 0 0 0 40" fill="none" stroke="white" stroke-width="1"/>
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#grid)" />
          </svg>
        </div>
        
        <div class="relative z-10 flex flex-col justify-center px-12 text-white">
          <!-- Logo Grande -->
          <div class="flex items-center space-x-4 mb-8">
            <div class="w-16 h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center backdrop-blur-sm">
              <WrenchScrewdriverIcon class="w-8 h-8 text-white" />
            </div>
            <div>
              <h1 class="text-4xl font-bold">OficinaFrota</h1>
              <p class="text-blue-100 text-lg">Sistema Corporativo</p>
            </div>
          </div>
          
          <!-- Benefits for Signup -->
          <div class="space-y-6">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                <UsersIcon class="w-6 h-6" />
              </div>
              <div>
                <h3 class="text-xl font-semibold">Acesso Completo</h3>
                <p class="text-blue-100">Gerencie toda sua operação em um só lugar</p>
              </div>
            </div>
            
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                <ChartBarIcon class="w-6 h-6" />
              </div>
              <div>
                <h3 class="text-xl font-semibold">Relatórios Avançados</h3>
                <p class="text-blue-100">Insights para otimizar sua frota</p>
              </div>
            </div>
            
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                </svg>
              </div>
              <div>
                <h3 class="text-xl font-semibold">Segurança Total</h3>
                <p class="text-blue-100">Seus dados protegidos com criptografia</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Lado Direito - Signup Form -->
      <div class="flex-1 flex flex-col justify-center px-4 sm:px-6 lg:px-20 xl:px-24">
        <div class="mx-auto w-full max-w-sm lg:w-96">
          <!-- Mobile Logo -->
          <div class="lg:hidden flex items-center justify-center mb-8">
            <div class="w-12 h-12 bg-gradient-to-br from-blue-600 to-blue-800 rounded-xl flex items-center justify-center">
              <WrenchScrewdriverIcon class="w-6 h-6 text-white" />
            </div>
            <div class="ml-3">
              <h1 class="text-2xl font-bold text-gray-900">OficinaFrota</h1>
              <p class="text-sm text-gray-500">Sistema Corporativo</p>
            </div>
          </div>

          <div>
            <h2 class="text-3xl font-bold text-gray-900">
              Criar conta corporativa
            </h2>
            <p class="mt-2 text-sm text-gray-600">
              Comece a gerenciar sua frota hoje mesmo
            </p>
          </div>

          <div class="mt-8">
            <form class="space-y-6" @submit.prevent="handleSignup">
              <div class="grid grid-cols-1 gap-5">
                <div>
                  <label for="nome" class="block text-sm font-medium text-gray-700">
                    Nome completo
                  </label>
                  <div class="mt-1 relative">
                    <BaseInput
                      id="nome"
                      v-model="form.nome"
                      type="text"
                      placeholder="João Silva Santos"
                      required
                      :error="errors.nome"
                      class="pl-10"
                    />
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                      </svg>
                    </div>
                  </div>
                </div>

                <div>
                  <label for="email" class="block text-sm font-medium text-gray-700">
                    Email corporativo
                  </label>
                  <div class="mt-1 relative">
                    <BaseInput
                      id="email"
                      v-model="form.email"
                      type="email"
                      placeholder="joao.silva@empresa.com"
                      required
                      :error="errors.email"
                      class="pl-10"
                    />
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
                      </svg>
                    </div>
                  </div>
                </div>

                <div>
                  <label for="password" class="block text-sm font-medium text-gray-700">
                    Senha
                  </label>
                  <div class="mt-1 relative">
                    <BaseInput
                      id="password"
                      v-model="form.password"
                      type="password"
                      placeholder="••••••••••••"
                      required
                      :error="errors.password"
                      class="pl-10"
                    />
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                      </svg>
                    </div>
                  </div>
                </div>

                <div>
                  <label for="confirmPassword" class="block text-sm font-medium text-gray-700">
                    Confirmar senha
                  </label>
                  <div class="mt-1 relative">
                    <BaseInput
                      id="confirmPassword"
                      v-model="form.confirmPassword"
                      type="password"
                      placeholder="••••••••••••"
                      required
                      :error="errors.confirmPassword"
                      class="pl-10"
                    />
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                      </svg>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Terms & Conditions -->
              <div class="flex items-start">
                <div class="flex items-center h-5">
                  <input 
                    id="terms" 
                    name="terms" 
                    type="checkbox" 
                    required
                    class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  >
                </div>
                <div class="ml-3 text-sm">
                  <label for="terms" class="text-gray-700">
                    Eu concordo com os 
                    <a href="#" class="font-medium text-blue-600 hover:text-blue-500">Termos de Serviço</a>
                    e 
                    <a href="#" class="font-medium text-blue-600 hover:text-blue-500">Política de Privacidade</a>
                  </label>
                </div>
              </div>

        <div v-if="message" class="rounded-md p-4" :class="messageType === 'success' ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'">
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

              <div>
                <BaseButton
                  type="submit"
                  :loading="authStore.loading"
                  :disabled="!isFormValid"
                  class="w-full justify-center py-3 text-base font-medium"
                >
                  <span v-if="!authStore.loading">Criar Conta Corporativa</span>
                  <span v-else>Criando conta...</span>
                </BaseButton>
              </div>

              <div class="mt-6">
                <div class="relative">
                  <div class="absolute inset-0 flex items-center">
                    <div class="w-full border-t border-gray-300" />
                  </div>
                  <div class="relative flex justify-center text-sm">
                    <span class="px-2 bg-white text-gray-500">Já tem uma conta?</span>
                  </div>
                </div>

                <div class="mt-6">
                  <router-link
                    to="/login"
                    class="w-full flex justify-center py-3 px-4 border border-gray-300 rounded-lg shadow-sm bg-white text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors duration-200"
                  >
                    Fazer Login
                  </router-link>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../features/auth/stores/authStore'
import BaseInput from '../shared/ui/BaseInput.vue'
import BaseButton from '../shared/ui/BaseButton.vue'
import {
  WrenchScrewdriverIcon,
  ChartBarIcon,
  UsersIcon
} from '@heroicons/vue/24/outline'

const router = useRouter()
const authStore = useAuthStore()

const form = ref({
  nome: '',
  email: '',
  password: '',
  confirmPassword: ''
})

const errors = ref({
  nome: '',
  email: '',
  password: '',
  confirmPassword: ''
})

const message = ref('')
const messageType = ref<'success' | 'error'>('success')

const isFormValid = computed(() => {
  return form.value.nome.trim() !== '' &&
         form.value.email.trim() !== '' &&
         form.value.password.length >= 6 &&
         form.value.password === form.value.confirmPassword
})

function validateForm() {
  errors.value = {
    nome: '',
    email: '',
    password: '',
    confirmPassword: ''
  }

  let isValid = true

  if (!form.value.nome.trim()) {
    errors.value.nome = 'Nome é obrigatório'
    isValid = false
  }

  if (!form.value.email.trim()) {
    errors.value.email = 'Email é obrigatório'
    isValid = false
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.value.email)) {
    errors.value.email = 'Email inválido'
    isValid = false
  }

  if (!form.value.password) {
    errors.value.password = 'Senha é obrigatória'
    isValid = false
  } else if (form.value.password.length < 6) {
    errors.value.password = 'Senha deve ter pelo menos 6 caracteres'
    isValid = false
  }

  if (form.value.password !== form.value.confirmPassword) {
    errors.value.confirmPassword = 'Senhas não coincidem'
    isValid = false
  }

  return isValid
}

async function handleSignup() {
  if (!validateForm()) {
    return
  }

  message.value = ''

  const result = await authStore.signUp(
    form.value.email,
    form.value.password,
    { nome: form.value.nome, role: 'usuario' }
  )

  if (result.success) {
    messageType.value = 'success'
    message.value = result.message || 'Conta criada com sucesso!'
    
    // Se não precisa de confirmação, redireciona
    if (!result.needsConfirmation) {
      setTimeout(() => {
        router.push('/dashboard')
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
}
</script>
