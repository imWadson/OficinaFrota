<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-semibold text-gray-900">Nova Ordem de Serviço</h1>
        <p class="mt-1 text-sm text-gray-500">
          Registrar entrada de veículo na oficina
        </p>
      </div>
      <router-link 
        to="/ordens-servico"
        class="text-gray-500 hover:text-gray-700"
      >
        ← Voltar
      </router-link>
    </div>

    <div class="card">
      <form @submit.prevent="criarOS" class="space-y-6">
        <!-- Seleção do Veículo -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Veículo *
          </label>
          <select 
            v-model="form.veiculo_id" 
            :disabled="veiculos.isLoading?.value"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            required
          >
            <option value="">Selecione um veículo</option>
            <option 
              v-for="veiculo in veiculosAtivos" 
              :key="veiculo.id" 
              :value="veiculo.id"
            >
              {{ veiculo.placa }} - {{ veiculo.modelo }} ({{ veiculo.tipo }})
            </option>
          </select>
          <p v-if="errors.veiculo" class="mt-1 text-sm text-red-600">{{ errors.veiculo }}</p>
        </div>

        <!-- Problema Reportado -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Problema Reportado *
          </label>
          <textarea
            v-model="form.problema_reportado"
            rows="4"
            placeholder="Descreva o problema ou serviço a ser realizado..."
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            required
          ></textarea>
          <p v-if="errors.problema" class="mt-1 text-sm text-red-600">{{ errors.problema }}</p>
        </div>

        <!-- Criador da OS (usuário atual) -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Criador da Ordem de Serviço
          </label>
          <div class="px-3 py-2 bg-gray-50 border border-gray-300 rounded-md text-gray-700">
            {{ userName }} - {{ userCargoDisplay }}
          </div>
          <p class="mt-1 text-sm text-gray-500">
            A ordem será criada em seu nome automaticamente
          </p>
        </div>

        <!-- Mensagem de Erro Geral -->
        <div v-if="errorMessage" class="p-4 rounded-lg bg-red-50 border border-red-200">
          <p class="text-sm text-red-800">{{ errorMessage }}</p>
        </div>

        <!-- Botões -->
        <div class="flex justify-end space-x-3 pt-4 border-t">
          <router-link to="/ordens-servico">
            <BaseButton variant="secondary" type="button">
              Cancelar
            </BaseButton>
          </router-link>
          <BaseButton 
            type="submit" 
            :loading="loading"
            :disabled="!isFormValid"
          >
            Criar Ordem de Serviço
          </BaseButton>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useVeiculos } from '../features/veiculos/hooks/useVeiculos'
import { useOrdensServico } from '../features/ordens-servico/hooks/useOrdensServico'
import { useAuth } from '../composables/useAuth'
import BaseButton from '../shared/ui/BaseButton.vue'

const router = useRouter()
const { veiculos } = useVeiculos()
const { createOrdemServico } = useOrdensServico()
const { userName, userCargoDisplay } = useAuth()

// Form data
const form = ref({
  veiculo_id: '',
  problema_reportado: ''
})

// Estados
const loading = ref(false)
const errorMessage = ref('')
const errors = ref({
  veiculo: '',
  problema: ''
})

// Computed
const veiculosAtivos = computed(() => {
  if (!veiculos.data?.value) return []
  return veiculos.data.value.filter(v => v.status === 'ativo') || []
})

const isFormValid = computed(() => {
  return form.value.veiculo_id && 
         form.value.problema_reportado.trim()
})

// Validação
function validarForm() {
  errors.value = { veiculo: '', problema: '' }
  
  if (!form.value.veiculo_id) {
    errors.value.veiculo = 'Selecione um veículo'
  }
  
  if (!form.value.problema_reportado.trim()) {
    errors.value.problema = 'Descreva o problema'
  }
  
  return !errors.value.veiculo && !errors.value.problema
}

// Criar OS
async function criarOS() {
  if (!validarForm()) return
  
  loading.value = true
  errorMessage.value = ''
  
  try {
    const osData = {
      veiculo_id: form.value.veiculo_id, // Manter como string (UUID)
      problema_reportado: form.value.problema_reportado.trim()
    }
    
    await createOrdemServico.mutateAsync(osData)
    
    // Sucesso - redireciona para lista
    router.push('/ordens-servico')
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Erro ao criar ordem de serviço'
  } finally {
    loading.value = false
  }
}
</script>
