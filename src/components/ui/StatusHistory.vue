<template>
  <div class="space-y-6">
    <!-- Estatísticas de Tempo -->
    <div class="card">
      <h3 class="text-lg font-medium text-gray-900 mb-4">Estatísticas de Tempo</h3>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Tempo Total -->
        <div class="bg-blue-50 p-4 rounded-lg">
          <div class="flex items-center">
            <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
              <ClockIcon class="w-5 h-5 text-blue-600" />
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-blue-600">Tempo Total</p>
              <p class="text-xl font-bold text-blue-900">{{ formatInterval(tempoTotal) }}</p>
            </div>
          </div>
        </div>

        <!-- Status Atual -->
        <div class="bg-green-50 p-4 rounded-lg">
          <div class="flex items-center">
            <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
              <CheckCircleIcon class="w-5 h-5 text-green-600" />
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-green-600">Status Atual</p>
              <p class="text-xl font-bold text-green-900">{{ getStatusText(statusAtual) }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Tempo por Status -->
      <div class="mt-6">
        <h4 class="text-md font-medium text-gray-700 mb-3">Tempo por Status</h4>
        <div class="space-y-2">
          <div 
            v-for="tempo in tempoPorStatus" 
            :key="tempo.status"
            class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
          >
            <div class="flex items-center space-x-3">
              <div class="w-8 h-8 rounded-full flex items-center justify-center"
                   :class="getStatusColorClass(tempo.status)">
                <span class="text-xs font-medium text-white">
                  {{ getStatusIcon(tempo.status) }}
                </span>
              </div>
              <div>
                <p class="font-medium text-gray-900">{{ getStatusText(tempo.status) }}</p>
                <p class="text-xs text-gray-500">
                  {{ formatDate(tempo.inicio_status) }} - {{ formatDate(tempo.fim_status) }}
                </p>
              </div>
            </div>
            <div class="text-right">
              <p class="font-bold text-gray-900">{{ formatInterval(tempo.tempo_total) }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Histórico de Mudanças -->
    <div class="card">
      <h3 class="text-lg font-medium text-gray-900 mb-4">Histórico de Mudanças</h3>
      
      <div v-if="statusHistory.isLoading.value" class="text-center py-4">
        <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600 mx-auto"></div>
      </div>
      
      <div v-else-if="!statusHistory.data.value?.length" class="text-center py-8 text-gray-500">
        Nenhuma mudança de status registrada
      </div>
      
      <div v-else class="space-y-4">
        <div 
          v-for="(mudanca, index) in statusHistory.data.value" 
          :key="mudanca.id"
          class="flex items-start space-x-4 p-4 border rounded-lg"
          :class="index === 0 ? 'bg-blue-50 border-blue-200' : 'bg-gray-50 border-gray-200'"
        >
          <!-- Ícone de Status -->
          <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0"
               :class="getStatusColorClass(mudanca.status_novo)">
            <span class="text-sm font-medium text-white">
              {{ getStatusIcon(mudanca.status_novo) }}
            </span>
          </div>
          
          <!-- Conteúdo -->
          <div class="flex-1 min-w-0">
            <div class="flex items-center space-x-2 mb-1">
              <span class="font-medium text-gray-900">
                {{ getStatusText(mudanca.status_novo) }}
              </span>
              <span class="text-sm text-gray-500">•</span>
              <span class="text-sm text-gray-500">{{ formatDate(mudanca.criado_em) }}</span>
            </div>
            
            <p v-if="mudanca.observacao" class="text-sm text-gray-600 mb-2">
              {{ mudanca.observacao }}
            </p>
            
            <div class="flex items-center space-x-4 text-xs text-gray-500">
              <span v-if="mudanca.usuario?.nome">
                Por: {{ mudanca.usuario.nome }}
              </span>
              <span v-if="mudanca.status_anterior">
                De: {{ getStatusText(mudanca.status_anterior) }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { ClockIcon, CheckCircleIcon } from '@heroicons/vue/24/outline'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'

interface Props {
  ordemServicoId: string
  statusAtual: string
}

const props = defineProps<Props>()

// Importar hooks
import { useStatusHistory, useTempoStats } from '../../features/ordens-servico/hooks/useOrdensServico'

const { statusHistory } = useStatusHistory(props.ordemServicoId)
const { tempoPorStatus, tempoTotal } = useTempoStats(props.ordemServicoId)

// Funções auxiliares
function getStatusText(status: string): string {
  const statusMap: Record<string, string> = {
    'em_andamento': 'Em Andamento',
    'concluida': 'Concluída',
    'cancelada': 'Cancelada',
    'oficina_externa': 'Oficina Externa',
    'aguardando_peca': 'Aguardando Peça',
    'diagnostico': 'Diagnóstico',
    'aguardando_aprovacao': 'Aguardando Aprovação'
  }
  return statusMap[status] || status
}

function getStatusColorClass(status: string): string {
  const colorMap: Record<string, string> = {
    'em_andamento': 'bg-yellow-500',
    'concluida': 'bg-green-500',
    'cancelada': 'bg-red-500',
    'oficina_externa': 'bg-purple-500',
    'aguardando_peca': 'bg-orange-500',
    'diagnostico': 'bg-blue-500',
    'aguardando_aprovacao': 'bg-indigo-500'
  }
  return colorMap[status] || 'bg-gray-500'
}

function getStatusIcon(status: string): string {
  const iconMap: Record<string, string> = {
    'em_andamento': '⚙️',
    'concluida': '✅',
    'cancelada': '❌',
    'oficina_externa': '🏭',
    'aguardando_peca': '📦',
    'diagnostico': '🔍',
    'aguardando_aprovacao': '⏳'
  }
  return iconMap[status] || '📋'
}

function formatDate(dateString: string): string {
  try {
    return format(new Date(dateString), 'dd/MM/yyyy HH:mm', { locale: ptBR })
  } catch {
    return dateString
  }
}

function formatInterval(interval: string): string {
  if (!interval || interval === '0') return '0h 0m'
  
  // Converter interval string para formato legível
  const match = interval.match(/(\d+) days? (\d+):(\d+):(\d+)/)
  if (match) {
    const [, days, hours, minutes] = match
    if (parseInt(days) > 0) {
      return `${days}d ${hours}h ${minutes}m`
    } else {
      return `${hours}h ${minutes}m`
    }
  }
  
  // Fallback para outros formatos
  return interval
}
</script>
