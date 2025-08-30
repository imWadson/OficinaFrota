<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-gray-50">
    <div class="min-h-screen flex">
      <!-- Lado Esquerdo - Branding -->
      <div class="hidden md:flex md:w-1/2 bg-gradient-to-br from-blue-600 to-blue-800 relative overflow-hidden">
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
        
        <div class="relative z-10 flex flex-col justify-center px-8 lg:px-12 text-white">
          <!-- Logo Grande -->
          <div class="flex items-center space-x-4 mb-8">
            <div class="w-12 h-12 lg:w-16 lg:h-16 bg-white bg-opacity-20 rounded-xl flex items-center justify-center backdrop-blur-sm">
              <WrenchScrewdriverIcon class="w-6 h-6 lg:w-8 lg:h-8 text-white" />
            </div>
            <div>
              <h1 class="text-2xl lg:text-4xl font-bold">OficinaFrota</h1>
              <p class="text-blue-100 text-sm lg:text-lg">Sistema Corporativo</p>
            </div>
          </div>
          
          <!-- Features -->
          <div class="space-y-4 lg:space-y-6">
            <div class="flex items-center space-x-3 lg:space-x-4">
              <div class="w-10 h-10 lg:w-12 lg:h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                <ChartBarIcon class="w-5 h-5 lg:w-6 lg:h-6" />
              </div>
              <div>
                <h3 class="text-lg lg:text-xl font-semibold">Gestão Inteligente</h3>
                <p class="text-blue-100 text-sm lg:text-base">Controle total da sua frota em tempo real</p>
              </div>
            </div>
            
            <div class="flex items-center space-x-3 lg:space-x-4">
              <div class="w-10 h-10 lg:w-12 lg:h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                <TruckIcon class="w-5 h-5 lg:w-6 lg:h-6" />
              </div>
              <div>
                <h3 class="text-lg lg:text-xl font-semibold">Manutenção Preventiva</h3>
                <p class="text-blue-100 text-sm lg:text-base">Reduza custos com manutenção inteligente</p>
              </div>
            </div>
            
            <div class="flex items-center space-x-3 lg:space-x-4">
              <div class="w-10 h-10 lg:w-12 lg:h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                <ArchiveBoxIcon class="w-5 h-5 lg:w-6 lg:h-6" />
              </div>
              <div>
                <h3 class="text-lg lg:text-xl font-semibold">Controle de Estoque</h3>
                <p class="text-blue-100 text-sm lg:text-base">Gestão eficiente de peças e suprimentos</p>
              </div>
            </div>
          </div>
          
          <!-- Stats -->
          <div class="mt-8 lg:mt-12 grid grid-cols-3 gap-4 lg:gap-6">
            <div class="text-center">
              <div class="text-2xl lg:text-3xl font-bold">99%</div>
              <div class="text-blue-100 text-xs lg:text-sm">Disponibilidade</div>
            </div>
            <div class="text-center">
              <div class="text-2xl lg:text-3xl font-bold">500+</div>
              <div class="text-blue-100 text-xs lg:text-sm">Veículos</div>
            </div>
            <div class="text-center">
              <div class="text-2xl lg:text-3xl font-bold">24/7</div>
              <div class="text-blue-100 text-xs lg:text-sm">Suporte</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Lado Direito - Login Form -->
      <div class="flex-1 flex flex-col justify-center px-4 sm:px-6 md:px-8 lg:px-12 xl:px-16">
        <div class="mx-auto w-full max-w-sm md:w-96">
          <!-- Mobile Logo -->
          <div class="md:hidden flex items-center justify-center mb-6">
            <div class="w-10 h-10 bg-gradient-to-br from-blue-600 to-blue-800 rounded-xl flex items-center justify-center">
              <WrenchScrewdriverIcon class="w-5 h-5 text-white" />
            </div>
            <div class="ml-3">
              <h1 class="text-xl font-bold text-gray-900">OficinaFrota</h1>
              <p class="text-xs text-gray-500">Sistema Corporativo</p>
            </div>
          </div>

          <div>
            <h2 class="text-2xl sm:text-3xl font-bold text-gray-900">
              Bem-vindo de volta
            </h2>
            <p class="mt-2 text-sm sm:text-base text-gray-600">
              Entre com suas credenciais para acessar o sistema
            </p>
          </div>

          <form @submit.prevent="handleLogin" class="mt-8 space-y-6">
            <div>
              <label for="email" class="block text-sm font-medium text-gray-700">
                Email
              </label>
              <div class="mt-1 relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
                  </svg>
                </div>
                <input
                  id="email"
                  v-model="email"
                  name="email"
                  type="email"
                  autocomplete="email"
                  required
                  class="appearance-none block w-full pl-10 pr-3 py-2 sm:py-3 border border-gray-300 rounded-lg placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                  placeholder="joao.silva@empresa.com"
                />
              </div>
            </div>

            <div>
              <label for="password" class="block text-sm font-medium text-gray-700">
                Senha
              </label>
              <div class="mt-1 relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                  </svg>
                </div>
                <input
                  id="password"
                  v-model="password"
                  name="password"
                  :type="showPassword ? 'text' : 'password'"
                  autocomplete="current-password"
                  required
                  class="appearance-none block w-full pl-10 pr-10 py-2 sm:py-3 border border-gray-300 rounded-lg placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  @click="showPassword = !showPassword"
                  class="absolute inset-y-0 right-0 pr-3 flex items-center"
                >
                  <svg v-if="showPassword" class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21" />
                  </svg>
                  <svg v-else class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                  </svg>
                </button>
              </div>
            </div>

            <div class="flex items-center justify-between">
              <div class="flex items-center">
                <input
                  id="remember-me"
                  v-model="rememberMe"
                  name="remember-me"
                  type="checkbox"
                  class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                />
                <label for="remember-me" class="ml-2 block text-sm text-gray-900">
                  Lembrar de mim
                </label>
              </div>

              <div class="text-sm">
                <a href="#" class="font-medium text-blue-600 hover:text-blue-500">
                  Esqueceu a senha?
                </a>
              </div>
            </div>

            <div>
              <button
                type="submit"
                :disabled="isLoading"
                class="group relative w-full flex justify-center py-2 sm:py-3 px-4 border border-transparent text-sm sm:text-base font-medium rounded-lg text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <svg v-if="isLoading" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                {{ isLoading ? 'Entrando...' : 'Entrar' }}
              </button>
            </div>
          </form>

          <div class="mt-6">
            <div class="relative">
              <div class="absolute inset-0 flex items-center">
                <div class="w-full border-t border-gray-300" />
              </div>
              <div class="relative flex justify-center text-sm">
                <span class="px-2 bg-white text-gray-500">Novo no sistema?</span>
              </div>
            </div>

            <div class="mt-6">
              <router-link
                to="/signup"
                class="w-full flex justify-center py-2 px-4 border border-gray-300 rounded-lg shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
              >
                Criar conta
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/features/auth/stores/authStore'
import {
  WrenchScrewdriverIcon,
  ChartBarIcon,
  TruckIcon,
  ArchiveBoxIcon
} from '@heroicons/vue/24/outline'

const router = useRouter()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const rememberMe = ref(false)
const showPassword = ref(false)
const isLoading = ref(false)

async function handleLogin() {
  if (isLoading.value) return

  isLoading.value = true
  try {
    const result = await authStore.signIn(email.value, password.value)
    if (result.success) {
      router.push('/')
    } else {
      console.error('Erro no login:', result.error)
    }
  } catch (error) {
    console.error('Erro no login:', error)
  } finally {
    isLoading.value = false
  }
}
</script>
