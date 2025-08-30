<template>
  <header class="bg-white border-b border-gray-200 sticky top-0 z-40">
    <div class="flex items-center justify-between h-16 px-4 sm:px-6">
      <!-- Left side -->
      <div class="flex items-center space-x-3 sm:space-x-4">
        <!-- Mobile menu button -->
        <button
          @click="$emit('toggleMobileMenu')"
          class="lg:hidden p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <svg class="w-5 h-5 sm:w-6 sm:h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path v-if="!mobileMenuOpen" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        <!-- Page Title -->
        <div class="min-w-0 flex-1">
          <h2 class="text-base sm:text-lg font-semibold text-gray-900 truncate">
            {{ pageInfo.title }}
          </h2>
          <p class="text-xs sm:text-sm text-gray-500 truncate">
            {{ pageInfo.description }}
          </p>
        </div>
      </div>

      <!-- Right side -->
      <div class="flex items-center space-x-2 sm:space-x-4">
        <!-- Status Badge -->
        <div class="hidden sm:flex items-center space-x-2 px-3 py-1 bg-green-100 rounded-full">
          <div class="w-2 h-2 bg-green-500 rounded-full"></div>
          <span class="text-xs font-medium text-green-800">Online</span>
        </div>

        <!-- Notifications -->
        <button class="relative p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors">
          <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
          </svg>
          <span class="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
        </button>

        <!-- User Menu -->
        <div class="relative user-menu">
          <button
            @click="userMenuOpen = !userMenuOpen"
            class="flex items-center space-x-2 sm:space-x-3 p-2 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <div class="text-right hidden sm:block">
              <p class="text-sm font-medium text-gray-900 truncate">{{ user?.name || 'Usuário' }}</p>
              <p class="text-xs text-gray-500 truncate">{{ userRole }}</p>
            </div>
            <div class="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center">
              <span class="text-white font-medium text-sm">{{ userInitials }}</span>
            </div>
          </button>

          <!-- User Dropdown -->
          <div
            v-if="userMenuOpen"
            class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-50"
          >
            <div class="px-4 py-2 border-b border-gray-100 sm:hidden">
              <p class="text-sm font-medium text-gray-900">{{ user?.name || 'Usuário' }}</p>
              <p class="text-xs text-gray-500">{{ user?.email || 'usuario@empresa.com' }}</p>
            </div>
            <button class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-50">
              Perfil
            </button>
            <button class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-50">
              Configurações
            </button>
            <div class="border-t border-gray-100 my-1"></div>
            <button
              @click="$emit('logout')"
              class="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50"
            >
              Sair
            </button>
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
}

const props = defineProps<Props>()
const router = useRouter()
const { user, userInitials, userRole } = useAuth()

const userMenuOpen = ref(false)

// Computed page info - elimina necessidade de props
const pageInfo = computed(() => {
  return getPageInfo(router.currentRoute.value.path)
})

defineEmits<{
  toggleMobileMenu: []
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
