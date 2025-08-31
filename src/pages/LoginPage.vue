<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-50 via-white to-amber-50/30 flex items-center justify-center p-4">
    <!-- Container Principal -->
    <div class="w-full max-w-md">
      <!-- Card de Login -->
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
          <p class="text-amber-100 text-sm">Faça login para acessar o sistema</p>
        </div>

        <!-- Formulário -->
        <div class="px-8 py-8">
          <form @submit.prevent="handleLogin" class="space-y-6">
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
                  v-model="email"
                  name="email"
                  type="email"
                  autocomplete="email"
                  required
                  class="block w-full pl-12 pr-4 py-3 border border-slate-300 rounded-xl placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 transition-all duration-200"
                  placeholder="seu.email@empresa.com"
                />
              </div>
            </div>

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
                  v-model="password"
                  name="password"
                  :type="showPassword ? 'text' : 'password'"
                  autocomplete="current-password"
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

            <!-- Opções -->
            <div class="flex items-center justify-between">
              <div class="flex items-center">
                <input
                  id="remember-me"
                  v-model="rememberMe"
                  name="remember-me"
                  type="checkbox"
                  class="h-4 w-4 text-amber-600 focus:ring-amber-500 border-slate-300 rounded"
                />
                <label for="remember-me" class="ml-2 block text-sm text-slate-700">
                  Lembrar de mim
                </label>
              </div>

              <div class="text-sm">
                <a href="#" class="font-medium text-amber-600 hover:text-amber-700 transition-colors">
                  Esqueceu a senha?
                </a>
              </div>
            </div>

            <!-- Botão de Login -->
            <div>
              <button
                type="submit"
                :disabled="isLoading"
                class="w-full flex justify-center items-center py-3 px-4 border border-transparent rounded-xl text-sm font-semibold text-white bg-gradient-to-r from-amber-500 to-orange-600 hover:from-amber-600 hover:to-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-amber-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 transform hover:-translate-y-0.5 shadow-lg hover:shadow-xl"
              >
                <svg v-if="isLoading" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                {{ isLoading ? 'Entrando...' : 'Entrar no Sistema' }}
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
                <span class="px-4 bg-white text-slate-500 font-medium">Novo no sistema?</span>
              </div>
            </div>

            <!-- Botão de Cadastro -->
            <div class="mt-6">
              <router-link
                to="/signup"
                class="w-full flex justify-center py-3 px-4 border border-slate-300 rounded-xl shadow-sm text-sm font-semibold text-slate-700 bg-white hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-amber-500 transition-all duration-200"
              >
                Criar nova conta
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
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/features/auth/stores/authStore'
import { WrenchScrewdriverIcon } from '@heroicons/vue/24/outline'

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
