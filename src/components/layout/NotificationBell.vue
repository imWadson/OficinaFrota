<template>
  <div class="relative">
    <!-- Botão da Campainha -->
    <button
      @click="toggleDropdown"
      class="relative p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors duration-200"
      :class="{ 'bg-amber-50 text-amber-600': unreadCount > 0 }"
    >
      <BellIcon class="w-6 h-6" />
      
      <!-- Badge de notificações não lidas -->
      <span
        v-if="unreadCount > 0"
        class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center font-medium animate-pulse"
      >
        {{ unreadCount > 99 ? '99+' : unreadCount }}
      </span>
    </button>

    <!-- Dropdown de Notificações -->
    <div
      v-if="isDropdownOpen"
      class="absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-lg border border-gray-200 z-50 max-h-96 overflow-hidden"
    >
      <!-- Header do Dropdown -->
      <div class="p-4 border-b border-gray-100 bg-gradient-to-r from-amber-50 to-orange-50">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-gray-900">Notificações</h3>
          <div class="flex items-center space-x-2">
            <button
              v-if="unreadCount > 0"
              @click="marcarTodasComoLidas"
              class="text-sm text-amber-600 hover:text-amber-700 font-medium"
            >
              Marcar todas como lidas
            </button>
            <button
              @click="closeDropdown"
              class="text-gray-400 hover:text-gray-600"
            >
              <XMarkIcon class="w-5 h-5" />
            </button>
          </div>
        </div>
        
        <!-- Contador de notificações -->
        <div class="flex items-center mt-2">
          <span class="text-sm text-gray-600">
            {{ unreadCount }} não lida{{ unreadCount !== 1 ? 's' : '' }}
          </span>
        </div>
      </div>

      <!-- Lista de Notificações -->
      <div class="max-h-80 overflow-y-auto">
        <div v-if="notificacoes.length === 0" class="p-8 text-center">
          <BellSlashIcon class="w-12 h-12 text-gray-300 mx-auto mb-3" />
          <p class="text-gray-500 font-medium">Nenhuma notificação</p>
          <p class="text-sm text-gray-400">Você está em dia!</p>
        </div>

        <div v-else class="divide-y divide-gray-100">
          <div
            v-for="notificacao in notificacoes"
            :key="notificacao.id"
            class="p-4 hover:bg-gray-50 transition-colors duration-150 cursor-pointer"
            :class="{ 'bg-amber-50': !notificacao.lida }"
            @click="handleNotificacaoClick(notificacao)"
          >
            <div class="flex items-start space-x-3">
              <!-- Ícone do tipo -->
              <div class="flex-shrink-0 mt-1">
                <div
                  class="w-8 h-8 rounded-full flex items-center justify-center"
                  :class="getTipoIconClass(notificacao.tipo)"
                >
                  <component :is="getTipoIcon(notificacao.tipo)" class="w-4 h-4 text-white" />
                </div>
              </div>

              <!-- Conteúdo da notificação -->
              <div class="flex-1 min-w-0">
                <div class="flex items-start justify-between">
                  <p class="text-sm font-medium text-gray-900 line-clamp-2">
                    {{ notificacao.titulo }}
                  </p>
                  <span
                    v-if="!notificacao.lida"
                    class="flex-shrink-0 w-2 h-2 bg-amber-500 rounded-full"
                  ></span>
                </div>
                
                <p class="text-sm text-gray-600 mt-1 line-clamp-2">
                  {{ notificacao.mensagem }}
                </p>
                
                <div class="flex items-center justify-between mt-2">
                  <span class="text-xs text-gray-400">
                    {{ formatDate(notificacao.data) }}
                  </span>
                  
                  <button
                    v-if="notificacao.acao_url && notificacao.acao_texto"
                    @click.stop="navigateToAction(notificacao)"
                    class="text-xs text-amber-600 hover:text-amber-700 font-medium hover:underline"
                  >
                    {{ notificacao.acao_texto }}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer do Dropdown -->
      <div v-if="notificacoes.length > 0" class="p-3 border-t border-gray-100 bg-gray-50">
        <router-link
          to="/notificacoes"
          class="block text-center text-sm text-gray-600 hover:text-gray-900 font-medium"
        >
          Ver todas as notificações
        </router-link>
      </div>
    </div>

    <!-- Overlay para fechar o dropdown -->
    <div
      v-if="isDropdownOpen"
      @click="closeDropdown"
      class="fixed inset-0 z-40"
    ></div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  BellIcon,
  BellSlashIcon,
  XMarkIcon,
  InformationCircleIcon,
  ExclamationTriangleIcon,
  ExclamationCircleIcon,
  CheckCircleIcon
} from '@heroicons/vue/24/outline'
import { useNotificacoes } from '@/services/notificacaoService'
import { formatDistanceToNow } from 'date-fns'
import { ptBR } from 'date-fns/locale'

const router = useRouter()
const { notificacoes, unreadCount, marcarComoLida, marcarTodasComoLidas } = useNotificacoes()

const isDropdownOpen = ref(false)

// Fechar dropdown ao clicar fora
const closeDropdown = () => {
  isDropdownOpen.value = false
}

const toggleDropdown = () => {
  isDropdownOpen.value = !isDropdownOpen.value
}

const handleNotificacaoClick = async (notificacao: any) => {
  if (!notificacao.lida) {
    await marcarComoLida(notificacao.id)
  }
  
  if (notificacao.acao_url) {
    router.push(notificacao.acao_url)
    closeDropdown()
  }
}

const navigateToAction = (notificacao: any) => {
  if (notificacao.acao_url) {
    router.push(notificacao.acao_url)
    closeDropdown()
  }
}

const formatDate = (dateString: string): string => {
  try {
    return formatDistanceToNow(new Date(dateString), { 
      addSuffix: true, 
      locale: ptBR 
    })
  } catch {
    return 'há pouco tempo'
  }
}

const getTipoIcon = (tipo: string) => {
  const iconMap: Record<string, any> = {
    'info': InformationCircleIcon,
    'warning': ExclamationTriangleIcon,
    'error': ExclamationCircleIcon,
    'success': CheckCircleIcon
  }
  return iconMap[tipo] || InformationCircleIcon
}

const getTipoIconClass = (tipo: string) => {
  const classMap: Record<string, string> = {
    'info': 'bg-blue-500',
    'warning': 'bg-amber-500',
    'error': 'bg-red-500',
    'success': 'bg-green-500'
  }
  return classMap[tipo] || 'bg-gray-500'
}

// Fechar dropdown ao navegar
onMounted(() => {
  router.afterEach(() => {
    closeDropdown()
  })
})

// Fechar dropdown ao pressionar ESC
onMounted(() => {
  const handleEscape = (e: KeyboardEvent) => {
    if (e.key === 'Escape') {
      closeDropdown()
    }
  }
  
  document.addEventListener('keydown', handleEscape)
  
  onUnmounted(() => {
    document.removeEventListener('keydown', handleEscape)
  })
})
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: .5;
  }
}
</style>
