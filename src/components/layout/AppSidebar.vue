<template>
  <div class="flex flex-col h-full bg-gradient-to-b from-slate-800 via-slate-700 to-slate-800 overflow-hidden">
    <!-- Sidebar Header - Mais orgânico -->
    <div class="flex items-center justify-between px-6 py-8 border-b border-slate-600/30 flex-shrink-0">
      <div class="flex items-center space-x-4 min-w-0">
        <div class="relative flex-shrink-0">
          <div class="w-12 h-12 bg-gradient-to-br from-amber-500 to-orange-600 rounded-xl flex items-center justify-center shadow-lg">
            <WrenchScrewdriverIcon class="w-7 h-7 text-white" />
          </div>
          <div class="absolute -top-1 -right-1 w-4 h-4 bg-green-400 rounded-full border-2 border-slate-800"></div>
        </div>
        <div class="min-w-0 transition-all duration-300 overflow-hidden" :class="{ 'opacity-0 w-0': collapsed }">
          <h1 class="text-xl font-bold text-white tracking-tight">Frota Gestor</h1>
          <p class="text-sm text-slate-300 font-medium">Sistema Corporativo</p>
        </div>
      </div>
      
      <!-- Hamburger Button -->
      <button
        @click="$emit('toggle')"
        class="p-2 text-slate-300 hover:text-white hover:bg-slate-600/50 rounded-lg transition-all duration-200 flex-shrink-0"
        :class="{ 'rotate-180': collapsed }"
        :title="collapsed ? 'Expandir sidebar' : 'Minimizar sidebar'"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 19l-7-7 7-7m8 14l-7-7 7-7" />
        </svg>
      </button>
    </div>

    <!-- Sidebar Navigation - Menos simétrico -->
    <nav class="flex-1 px-4 py-6 space-y-2 overflow-y-auto overflow-x-hidden">
      <div class="mb-6">
        <h3 class="text-xs font-semibold text-slate-400 uppercase tracking-wider px-3 mb-3 transition-all duration-300 overflow-hidden" :class="{ 'opacity-0 h-0': collapsed }">Principal</h3>
        <div class="space-y-1">
          <router-link
            v-for="item in mainNavigation"
            :key="item.name"
            :to="item.href"
            @click="$emit('close')"
            :class="[
              $route.path === item.href
                ? 'bg-gradient-to-r from-amber-500/20 to-orange-500/20 text-amber-100 border-l-4 border-amber-400 shadow-lg'
                : 'text-slate-300 hover:bg-slate-600/50 hover:text-white border-l-4 border-transparent',
              'flex items-center px-4 py-3 text-sm font-medium transition-all duration-300 rounded-r-lg group relative overflow-hidden'
            ]"
            :title="collapsed ? item.name : ''"
          >
            <component 
              :is="item.icon" 
              :class="[
                $route.path === item.href ? 'text-amber-400' : 'text-slate-400 group-hover:text-white',
                'w-5 h-5 flex-shrink-0 transition-colors',
                collapsed ? 'mr-0' : 'mr-3'
              ]" 
            />
            <span class="truncate transition-all duration-300 overflow-hidden" :class="{ 'opacity-0 w-0': collapsed }">{{ item.name }}</span>
            
            <!-- Tooltip para sidebar colapsado -->
            <div 
              v-if="collapsed"
              class="absolute left-full ml-2 px-2 py-1 bg-slate-900 text-white text-xs rounded opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none whitespace-nowrap z-50"
            >
              {{ item.name }}
            </div>
          </router-link>
        </div>
      </div>

      <div class="mb-6">
        <h3 class="text-xs font-semibold text-slate-400 uppercase tracking-wider px-3 mb-3 transition-all duration-300 overflow-hidden" :class="{ 'opacity-0 h-0': collapsed }">Gestão</h3>
        <div class="space-y-1">
          <router-link
            v-for="item in managementNavigation"
            :key="item.name"
            :to="item.href"
            @click="$emit('close')"
            :class="[
              $route.path === item.href
                ? 'bg-gradient-to-r from-amber-500/20 to-orange-500/20 text-amber-100 border-l-4 border-amber-400 shadow-lg'
                : 'text-slate-300 hover:bg-slate-600/50 hover:text-white border-l-4 border-transparent',
              'flex items-center px-4 py-3 text-sm font-medium transition-all duration-300 rounded-r-lg group relative overflow-hidden'
            ]"
            :title="collapsed ? item.name : ''"
          >
            <component 
              :is="item.icon" 
              :class="[
                $route.path === item.href ? 'text-amber-400' : 'text-slate-400 group-hover:text-white',
                'w-5 h-5 flex-shrink-0 transition-colors',
                collapsed ? 'mr-0' : 'mr-3'
              ]" 
            />
            <span class="truncate transition-all duration-300 overflow-hidden" :class="{ 'opacity-0 w-0': collapsed }">{{ item.name }}</span>
            
            <!-- Tooltip para sidebar colapsado -->
            <div 
              v-if="collapsed"
              class="absolute left-full ml-2 px-2 py-1 bg-slate-900 text-white text-xs rounded opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none whitespace-nowrap z-50"
            >
              {{ item.name }}
            </div>
          </router-link>
        </div>
      </div>

      <div class="mb-6">
        <h3 class="text-xs font-semibold text-slate-400 uppercase tracking-wider px-3 mb-3 transition-all duration-300 overflow-hidden" :class="{ 'opacity-0 h-0': collapsed }">Sistema</h3>
        <div class="space-y-1">
          <router-link
            v-for="item in systemNavigation"
            :key="item.name"
            :to="item.href"
            @click="$emit('close')"
            :class="[
              $route.path === item.href
                ? 'bg-gradient-to-r from-amber-500/20 to-orange-500/20 text-amber-100 border-l-4 border-amber-400 shadow-lg'
                : 'text-slate-300 hover:bg-slate-600/50 hover:text-white border-l-4 border-transparent',
              'flex items-center px-4 py-3 text-sm font-medium transition-all duration-300 rounded-r-lg group relative overflow-hidden'
            ]"
            :title="collapsed ? item.name : ''"
          >
            <component 
              :is="item.icon" 
              :class="[
                $route.path === item.href ? 'text-amber-400' : 'text-slate-400 group-hover:text-white',
                'w-5 h-5 flex-shrink-0 transition-colors',
                collapsed ? 'mr-0' : 'mr-3'
              ]" 
            />
            <span class="truncate transition-all duration-300 overflow-hidden" :class="{ 'opacity-0 w-0': collapsed }">{{ item.name }}</span>
            
            <!-- Tooltip para sidebar colapsado -->
            <div 
              v-if="collapsed"
              class="absolute left-full ml-2 px-2 py-1 bg-slate-900 text-white text-xs rounded opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none whitespace-nowrap z-50"
            >
              {{ item.name }}
            </div>
          </router-link>
        </div>
      </div>
    </nav>

    <!-- Sidebar Footer - Mais humano -->
    <div class="p-4 border-t border-slate-600/30 flex-shrink-0">
      <div class="bg-slate-700/50 rounded-xl p-4 backdrop-blur-sm">
        <div class="flex items-center space-x-3 min-w-0">
          <div class="relative flex-shrink-0">
            <div class="w-10 h-10 bg-gradient-to-br from-amber-500 to-orange-600 rounded-lg flex items-center justify-center">
              <span class="text-white font-bold text-sm">{{ userInitials }}</span>
            </div>
            <div class="absolute -bottom-1 -right-1 w-3 h-3 bg-green-400 rounded-full border-2 border-slate-700"></div>
          </div>
          <div class="flex-1 min-w-0 transition-all duration-300 overflow-hidden" :class="{ 'opacity-0 w-0': collapsed }">
            <p class="text-sm font-semibold text-white truncate">{{ userName }}</p>
            <p class="text-xs text-slate-300 truncate">{{ userRoleDisplay }}</p>
          </div>
          <button
            @click="$emit('logout')"
            class="p-2 text-slate-400 hover:text-red-400 hover:bg-red-500/10 rounded-lg transition-all duration-200 flex-shrink-0"
            :title="collapsed ? 'Sair' : ''"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
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

interface Props {
  collapsed?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  collapsed: false
})

const router = useRouter()
const { userInitials, userName, userRole, userCargo, userRegional, userCargoDisplay, userRegionalDisplay } = useAuth()

// Navegação organizada por categorias - mais humano
const mainNavigation = [
  { name: 'Dashboard', href: '/', icon: ChartBarIcon },
  { name: 'Veículos', href: '/veiculos', icon: TruckIcon },
  { name: 'Ordens de Serviço', href: '/ordens-servico', icon: WrenchScrewdriverIcon },
]

const managementNavigation = [
  { name: 'Estoque', href: '/estoque', icon: ArchiveBoxIcon },
  { name: 'Oficinas Externas', href: '/oficinas-externas', icon: BuildingOfficeIcon },
  { name: 'Supervisores', href: '/supervisores', icon: UsersIcon },
]

const systemNavigation = [
  { name: 'Relatórios', href: '/relatorios', icon: ChartPieIcon },
  { name: 'Admin', href: '/admin', icon: CogIcon }
]

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
  close: []
  logout: []
  toggle: []
}>()
</script>
