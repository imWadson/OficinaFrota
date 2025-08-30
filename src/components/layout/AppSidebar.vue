<template>
  <div class="flex flex-col h-full">
    <!-- Sidebar Header -->
    <div class="flex items-center justify-center h-16 px-4 border-b border-gray-200">
      <div class="flex items-center space-x-3">
        <div class="w-8 h-8 bg-gradient-to-br from-blue-600 to-blue-700 rounded-lg flex items-center justify-center">
          <WrenchScrewdriverIcon class="w-5 h-5 text-white" />
        </div>
        <div class="min-w-0">
          <h1 class="text-lg font-bold text-gray-900 truncate">OficinaFrota</h1>
          <p class="text-xs text-gray-500 truncate">Sistema Corporativo</p>
        </div>
      </div>
    </div>

    <!-- Sidebar Navigation -->
    <nav class="flex-1 px-3 sm:px-4 py-4 sm:py-6 space-y-1 sm:space-y-2 overflow-y-auto">
      <router-link
        v-for="item in navigationItems"
        :key="item.name"
        :to="item.href"
        @click="$emit('close')"
        :class="[
          $route.path === item.href
            ? 'bg-blue-50 text-blue-700 border-l-4 border-blue-600'
            : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900 border-l-4 border-transparent',
          'flex items-center px-3 sm:px-4 py-2 sm:py-3 text-sm font-medium transition-all duration-200 rounded-r-lg'
        ]"
      >
        <component 
          :is="item.icon" 
          class="w-5 h-5 mr-3 flex-shrink-0" 
        />
        <span class="truncate">{{ item.name }}</span>
      </router-link>
    </nav>

    <!-- Sidebar Footer -->
    <div class="p-3 sm:p-4 border-t border-gray-200">
      <div class="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
        <div class="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center flex-shrink-0">
          <span class="text-white font-medium text-sm">{{ userInitials }}</span>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-gray-900 truncate">{{ user?.name || 'Usuário' }}</p>
          <p class="text-xs text-gray-500 truncate">{{ userRole }}</p>
        </div>
        <button
          @click="$emit('logout')"
          class="p-1 text-gray-400 hover:text-red-600 transition-colors flex-shrink-0"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import {
  ChartBarIcon,
  TruckIcon,
  WrenchScrewdriverIcon,
  ArchiveBoxIcon,
  BuildingOfficeIcon,
  UsersIcon,
  ChartPieIcon,
  CogIcon
} from '@heroicons/vue/24/outline'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const { user, userInitials, userRole } = useAuth()

const navigationItems = [
  { name: 'Dashboard', href: '/', icon: ChartBarIcon },
  { name: 'Veículos', href: '/veiculos', icon: TruckIcon },
  { name: 'Ordens de Serviço', href: '/ordens-servico', icon: WrenchScrewdriverIcon },
  { name: 'Estoque', href: '/estoque', icon: ArchiveBoxIcon },
  { name: 'Oficinas Externas', href: '/oficinas-externas', icon: BuildingOfficeIcon },
  { name: 'Supervisores', href: '/supervisores', icon: UsersIcon },
  { name: 'Relatórios', href: '/relatorios', icon: ChartPieIcon },
  { name: 'Admin', href: '/admin', icon: CogIcon }
]

defineEmits<{
  close: []
  logout: []
}>()
</script>
