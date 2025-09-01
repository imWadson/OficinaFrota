<template>
  <div v-if="isOpen" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-medium text-gray-900">Mudar Status</h3>
        <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600">✕</button>
      </div>
      
      <form @submit.prevent="handleMudarStatus" class="space-y-4">
        <!-- Status Atual -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Status Atual</label>
          <div class="px-3 py-2 bg-gray-50 border border-gray-300 rounded-md text-gray-700">
            {{ getStatusText(statusAtual) }}
          </div>
        </div>

        <!-- Novo Status -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Novo Status *</label>
          <select 
            v-model="form.novoStatus"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            required
          >
            <option value="">Selecione o novo status</option>
            <option 
              v-for="status in statusDisponiveis" 
              :key="status.value" 
              :value="status.value"
            >
              {{ status.label }}
            </option>
          </select>
        </div>

        <!-- Observação -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Observação</label>
          <textarea
            v-model="form.observacao"
            rows="3"
            placeholder="Descreva o motivo da mudança de status..."
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
          ></textarea>
        </div>

        <!-- Erro -->
        <div v-if="errorMessage" class="p-3 rounded-lg bg-red-50 border border-red-200">
          <p class="text-sm text-red-800">{{ errorMessage }}</p>
        </div>

        <!-- Botões -->
        <div class="flex justify-end space-x-3 pt-4 border-t">
          <BaseButton 
            type="button" 
            variant="secondary"
            @click="$emit('close')"
          >
            Cancelar
          </BaseButton>
          <BaseButton 
            type="submit" 
            :loading="loading"
            :disabled="!form.novoStatus"
          >
            Mudar Status
          </BaseButton>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useMudarStatus } from '../../features/ordens-servico/hooks/useOrdensServico'
import BaseButton from './BaseButton.vue'

interface Props {
  isOpen: boolean
  ordemServicoId: string
  statusAtual: string
}

const props = defineProps<Props>()

const emit = defineEmits<{
  close: []
  success: []
}>()

const { mudarStatus: mudarStatusMutation } = useMudarStatus()

// Form data
const form = ref({
  novoStatus: '',
  observacao: ''
})

// Estados
const loading = ref(false)
const errorMessage = ref('')

// Computed
const statusDisponiveis = computed(() => {
  const statusMap = {
    'em_andamento': [
      { value: 'diagnostico', label: '🔍 Diagnóstico' },
      { value: 'aguardando_peca', label: '📦 Aguardando Peça' },
      { value: 'aguardando_aprovacao', label: '⏳ Aguardando Aprovação' },
      { value: 'oficina_externa', label: '🏭 Oficina Externa' },
      { value: 'concluida', label: '✅ Concluída' },
      { value: 'cancelada', label: '❌ Cancelada' }
    ],
    'diagnostico': [
      { value: 'em_andamento', label: '⚙️ Em Andamento' },
      { value: 'aguardando_peca', label: '📦 Aguardando Peça' },
      { value: 'aguardando_aprovacao', label: '⏳ Aguardando Aprovação' },
      { value: 'oficina_externa', label: '🏭 Oficina Externa' },
      { value: 'concluida', label: '✅ Concluída' },
      { value: 'cancelada', label: '❌ Cancelada' }
    ],
    'aguardando_peca': [
      { value: 'em_andamento', label: '⚙️ Em Andamento' },
      { value: 'diagnostico', label: '🔍 Diagnóstico' },
      { value: 'aguardando_aprovacao', label: '⏳ Aguardando Aprovação' },
      { value: 'oficina_externa', label: '🏭 Oficina Externa' },
      { value: 'concluida', label: '✅ Concluída' },
      { value: 'cancelada', label: '❌ Cancelada' }
    ],
    'aguardando_aprovacao': [
      { value: 'em_andamento', label: '⚙️ Em Andamento' },
      { value: 'diagnostico', label: '🔍 Diagnóstico' },
      { value: 'aguardando_peca', label: '📦 Aguardando Peça' },
      { value: 'oficina_externa', label: '🏭 Oficina Externa' },
      { value: 'concluida', label: '✅ Concluída' },
      { value: 'cancelada', label: '❌ Cancelada' }
    ],
    'oficina_externa': [
      { value: 'em_andamento', label: '⚙️ Em Andamento' },
      { value: 'diagnostico', label: '🔍 Diagnóstico' },
      { value: 'aguardando_peca', label: '📦 Aguardando Peça' },
      { value: 'aguardando_aprovacao', label: '⏳ Aguardando Aprovação' },
      { value: 'concluida', label: '✅ Concluída' },
      { value: 'cancelada', label: '❌ Cancelada' }
    ]
  }
  
  return statusMap[props.statusAtual as keyof typeof statusMap] || []
})

// Funções
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

async function handleMudarStatus() {
  if (!form.value.novoStatus) return
  
  loading.value = true
  errorMessage.value = ''
  
  try {
    await mudarStatusMutation.mutateAsync({
      id: props.ordemServicoId,
      novoStatus: form.value.novoStatus,
      observacao: form.value.observacao.trim() || undefined
    })
    
    // Limpar form
    form.value = {
      novoStatus: '',
      observacao: ''
    }
    
    // Emitir sucesso
    emit('success')
    emit('close')
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Erro ao mudar status'
  } finally {
    loading.value = false
  }
}
</script>
