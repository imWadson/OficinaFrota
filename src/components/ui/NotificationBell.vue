<template>
  <div class="relative">
    <!-- Botão do sino -->
    <button
      @click="toggleDropdown"
      class="relative p-2 text-slate-600 hover:text-slate-900 hover:bg-slate-100 rounded-lg transition-colors"
      :class="{ 'bg-slate-100': isDropdownOpen }"
    >
      <BellIcon class="w-6 h-6" />
      
      <!-- Badge de contador -->
      <span
        v-if="contadorNaoLidas > 0"
        class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center font-medium"
      >
        {{ contadorNaoLidas > 99 ? '99+' : contadorNaoLidas }}
      </span>
    </button>

    <!-- Dropdown de notificações -->
    <div
      v-if="isDropdownOpen"
      class="absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-lg border border-slate-200/60 z-50"
    >
      <!-- Header do dropdown -->
      <div class="flex items-center justify-between p-4 border-b border-slate-100">
        <h3 class="text-lg font-semibold text-slate-900">Notificações</h3>
        <div class="flex items-center space-x-2">
          <button
            @click="marcarTodasComoLidas"
            :disabled="marcarTodasComoLidas.isPending"
            class="text-sm text-slate-600 hover:text-slate-900 transition-colors"
          >
            {{ marcarTodasComoLidas.isPending ? 'Marcando...' : 'Marcar todas como lidas' }}
          </button>
          <button
            @click="limparAntigas"
            :disabled="limparAntigas.isPending"
            class="text-sm text-slate-600 hover:text-slate-900 transition-colors"
          >
            {{ limparAntigas.isPending ? 'Limpando...' : 'Limpar antigas' }}
          </button>
        </div>
      </div>

      <!-- Lista de notificações -->
      <div class="max-h-96 overflow-y-auto">
        <div v-if="notificacoesNaoLidas.isLoading" class="p-4 text-center">
          <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-purple-500 mx-auto"></div>
          <p class="text-slate-600 mt-2">Carregando...</p>
        </div>

        <div v-else-if="notificacoesNaoLidas.error" class="p-4 text-center">
          <ExclamationTriangleIcon class="w-8 h-8 text-red-500 mx-auto mb-2" />
          <p class="text-red-600">Erro ao carregar notificações</p>
        </div>

        <div v-else-if="!notificacoesNaoLidas.data || notificacoesNaoLidas.data.length === 0" class="p-4 text-center">
          <BellSlashIcon class="w-8 h-8 text-slate-400 mx-auto mb-2" />
          <p class="text-slate-600">Nenhuma notificação</p>
        </div>

        <div v-else class="divide-y divide-slate-100">
          <div
            v-for="notificacao in notificacoesNaoLidas.data"
            :key="notificacao.id"
            class="p-4 hover:bg-slate-50 transition-colors cursor-pointer"
            @click="marcarComoLida(notificacao.id!)"
          >
            <!-- Ícone de prioridade -->
            <div class="flex items-start space-x-3">
              <div class="flex-shrink-0">
                <div
                  class="w-2 h-2 rounded-full"
                  :class="{
                    'bg-green-500': notificacao.prioridade === 'baixa',
                    'bg-blue-500': notificacao.prioridade === 'media',
                    'bg-orange-500': notificacao.prioridade === 'alta',
                    'bg-red-500': notificacao.prioridade === 'critica'
                  }"
                ></div>
              </div>

              <!-- Conteúdo da notificação -->
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between">
                  <p class="text-sm font-medium text-slate-900 truncate">
                    {{ notificacao.titulo }}
                  </p>
                  <span class="text-xs text-slate-500">
                    {{ formatarData(notificacao.criada_em!) }}
                  </span>
                </div>
                <p class="text-sm text-slate-600 mt-1 line-clamp-2">
                  {{ notificacao.mensagem }}
                </p>
                
                <!-- Badge de categoria -->
                <div class="mt-2">
                  <span
                    class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
                    :class="{
                      'bg-blue-100 text-blue-800': notificacao.categoria === 'estoque',
                      'bg-orange-100 text-orange-800': notificacao.categoria === 'manutencao',
                      'bg-purple-100 text-purple-800': notificacao.categoria === 'sistema',
                      'bg-green-100 text-green-800': notificacao.categoria === 'usuario'
                    }"
                  >
                    {{ formatarCategoria(notificacao.categoria) }}
                  </span>
                </div>
              </div>

              <!-- Botão de deletar -->
              <button
                @click.stop="deletarNotificacao(notificacao.id!)"
                :disabled="deletarNotificacao.isPending"
                class="flex-shrink-0 text-slate-400 hover:text-red-500 transition-colors"
              >
                <XMarkIcon class="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer do dropdown -->
      <div class="p-4 border-t border-slate-100 bg-slate-50 rounded-b-xl">
        <router-link
          to="/notificacoes"
          class="block text-center text-sm text-slate-600 hover:text-slate-900 font-medium transition-colors"
        >
          Ver todas as notificações
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import {
  BellIcon,
  BellSlashIcon,
  ExclamationTriangleIcon,
  XMarkIcon
} from '@heroicons/vue/24/outline'
import { useNotificacoes } from '@/features/notificacoes/hooks/useNotificacoes'

// Estado local
const isDropdownOpen = ref(false)

// Hook de notificações
const {
  notificacoesNaoLidas,
  contadorNaoLidas,
  marcarComoLida,
  marcarTodasComoLidas,
  deletarNotificacao,
  limparAntigas
} = useNotificacoes()

// Funções
const toggleDropdown = () => {
  isDropdownOpen.value = !isDropdownOpen.value
}

const formatarData = (data: string): string => {
  const agora = new Date()
  const dataNotificacao = new Date(data)
  const diffMs = agora.getTime() - dataNotificacao.getTime()
  const diffMins = Math.floor(diffMs / (1000 * 60))
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))

  if (diffMins < 1) return 'Agora'
  if (diffMins < 60) return `${diffMins}m atrás`
  if (diffHours < 24) return `${diffHours}h atrás`
  if (diffDays < 7) return `${diffDays}d atrás`
  
  return dataNotificacao.toLocaleDateString('pt-BR')
}

const formatarCategoria = (categoria: string): string => {
  const categorias = {
    estoque: 'Estoque',
    manutencao: 'Manutenção',
    sistema: 'Sistema',
    usuario: 'Usuário'
  }
  return categorias[categoria as keyof typeof categorias] || categoria
}

// Fechar dropdown ao clicar fora
const handleClickOutside = (event: MouseEvent) => {
  const target = event.target as HTMLElement
  if (!target.closest('.relative')) {
    isDropdownOpen.value = false
  }
}

// Lifecycle
onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
