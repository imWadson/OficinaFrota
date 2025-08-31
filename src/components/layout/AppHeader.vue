<template>
  <header class="bg-white/95 backdrop-blur-sm border-b border-slate-200/60 sticky top-0 z-40 shadow-sm overflow-hidden">
    <div class="flex items-center justify-between h-20 px-6 min-w-0">
      <!-- Left side - Mais orgânico -->
      <div class="flex items-center space-x-6 min-w-0">
        <!-- Mobile menu button - Mais expressivo -->
        <button
          @click="$emit('toggleMobileMenu')"
          class="lg:hidden p-3 text-slate-600 hover:text-slate-900 hover:bg-slate-100 rounded-xl transition-all duration-200 shadow-sm hover:shadow-md flex-shrink-0"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path v-if="!mobileMenuOpen" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        <!-- Desktop sidebar toggle - Sutil -->
        <button
          @click="$emit('toggleSidebar')"
          class="hidden lg:flex p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-lg transition-all duration-200 flex-shrink-0"
          :title="sidebarCollapsed ? 'Expandir sidebar' : 'Minimizar sidebar'"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>

        <!-- Page Title - Hierarquia mais clara -->
        <div class="min-w-0 flex-1">
          <div class="flex items-center space-x-3">
            <div class="w-2 h-8 bg-gradient-to-b from-amber-500 to-orange-600 rounded-full flex-shrink-0"></div>
            <div class="min-w-0">
              <h2 class="text-2xl font-bold text-slate-900 tracking-tight truncate">
                {{ pageInfo.title }}
              </h2>
              <p class="text-sm text-slate-500 font-medium truncate">
                {{ pageInfo.description }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Right side - Menos simétrico -->
      <div class="flex items-center space-x-4 flex-shrink-0">
        <!-- Status Badge - Mais orgânico -->
        <div class="hidden sm:flex items-center space-x-2 px-4 py-2 bg-gradient-to-r from-green-50 to-emerald-50 rounded-full border border-green-200/50">
          <div class="relative">
            <div class="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
            <div class="absolute inset-0 w-3 h-3 bg-green-400 rounded-full animate-ping"></div>
          </div>
          <span class="text-sm font-semibold text-green-800">Sistema Online</span>
        </div>

        <!-- Notifications - Mais expressivo -->
        <button class="relative p-3 text-slate-600 hover:text-slate-900 hover:bg-slate-100 rounded-xl transition-all duration-200 shadow-sm hover:shadow-md">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
          </svg>
          <span class="absolute top-2 right-2 w-3 h-3 bg-red-500 rounded-full border-2 border-white animate-pulse"></span>
        </button>

        <!-- User Menu - Mais humano -->
        <div class="relative user-menu">
          <button
            @click="userMenuOpen = !userMenuOpen"
            class="flex items-center space-x-4 p-3 rounded-xl hover:bg-slate-100 transition-all duration-200 shadow-sm hover:shadow-md"
          >
            <div class="text-right hidden sm:block min-w-0">
              <p class="text-sm font-bold text-slate-900 truncate">{{ userName }}</p>
              <p class="text-xs text-slate-500 font-medium truncate">{{ userCargoDisplay }}</p>
              <p class="text-xs text-amber-600 font-medium truncate">{{ userRegionalDisplay }}</p>
            </div>
            <div class="relative flex-shrink-0">
              <div class="w-10 h-10 bg-gradient-to-br from-amber-500 to-orange-600 rounded-lg flex items-center justify-center shadow-md">
                <span class="text-white font-bold text-sm">{{ userInitials }}</span>
              </div>
              <div class="absolute -bottom-1 -right-1 w-3 h-3 bg-green-400 rounded-full border-2 border-white"></div>
            </div>
            <svg class="w-4 h-4 text-slate-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
          </button>

          <!-- User Dropdown - Mais orgânico -->
          <div
            v-if="userMenuOpen"
            class="absolute right-0 mt-3 w-64 bg-white rounded-2xl shadow-xl border border-slate-200/60 py-2 z-50 backdrop-blur-sm"
          >
            <!-- User Info -->
            <div class="px-6 py-4 border-b border-slate-100">
              <div class="flex items-center space-x-3">
                <div class="w-12 h-12 bg-gradient-to-br from-amber-500 to-orange-600 rounded-xl flex items-center justify-center">
                  <span class="text-white font-bold text-lg">{{ userInitials }}</span>
                </div>
                <div class="min-w-0">
                  <p class="text-sm font-bold text-slate-900 truncate">{{ userName }}</p>
                  <p class="text-xs text-slate-500 font-medium truncate">{{ userEmail }}</p>
                  <p class="text-xs text-amber-600 font-semibold truncate">{{ userCargoDisplay }}</p>
                  <p class="text-xs text-slate-600 font-medium truncate">{{ userRegionalDisplay }}</p>
                </div>
              </div>
            </div>

            <!-- Menu Items -->
            <div class="py-2">
              <button class="w-full text-left px-6 py-3 text-sm text-slate-700 hover:bg-slate-50 font-medium transition-colors">
                <div class="flex items-center space-x-3">
                  <svg class="w-4 h-4 text-slate-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                  <span>Meu Perfil</span>
                </div>
              </button>
              <button class="w-full text-left px-6 py-3 text-sm text-slate-700 hover:bg-slate-50 font-medium transition-colors">
                <div class="flex items-center space-x-3">
                  <svg class="w-4 h-4 text-slate-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  <span>Configurações</span>
                </div>
              </button>
            </div>

            <!-- Logout -->
            <div class="border-t border-slate-100 pt-2">
              <button
                @click="$emit('logout')"
                class="w-full text-left px-6 py-3 text-sm text-red-600 hover:bg-red-50 font-semibold transition-colors"
              >
                <div class="flex items-center space-x-3">
                  <svg class="w-4 h-4 text-red-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                  </svg>
                  <span>Sair do Sistema</span>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { getPageInfo } from '@/constants/pageInfo'

interface Props {
  mobileMenuOpen: boolean
  sidebarCollapsed?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  sidebarCollapsed: false
})

const router = useRouter()
const { userInitials, userName, userEmail, userRole, userCargoDisplay, userRegionalDisplay } = useAuth()

const userMenuOpen = ref(false)

// Computed page info - elimina necessidade de props
const pageInfo = computed(() => {
  return getPageInfo(router.currentRoute.value.path)
})

// Display do role em português
const userRoleDisplay = computed(() => {
  const roleMap: Record<string, string> = {
    'admin': 'Administrador',
    'supervisor': 'Supervisor',
    'usuario': 'Usuário'
  }
  return roleMap[userRole.value] || 'Usuário'
})

defineEmits<{
  toggleMobileMenu: []
  toggleSidebar: []
  logout: []
}>()

// Close dropdowns when clicking outside
function handleClickOutside(event: Event) {
  const target = event.target as HTMLElement
  if (!target.closest('.user-menu')) {
    userMenuOpen.value = false
  }
}

// Add click outside listener
onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>
