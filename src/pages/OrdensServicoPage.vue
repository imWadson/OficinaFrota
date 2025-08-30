<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-semibold text-gray-900">Ordens de Serviço</h1>
        <p class="mt-1 text-sm text-gray-500">
          Gestão das ordens de manutenção
        </p>
      </div>
      <BaseButton @click="$router.push('/ordens-servico/nova')">
        Nova OS
      </BaseButton>
    </div>

    <div class="card">
      <div v-if="ordensServico.isLoading.value" class="text-center py-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
        <p class="mt-2 text-sm text-gray-500">Carregando ordens de serviço...</p>
      </div>
      
      <div v-else-if="ordensServico.data.value?.length === 0" class="text-center py-8">
        <p class="text-gray-500">Nenhuma ordem de serviço encontrada</p>
      </div>
      
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                OS #
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Veículo
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Problema
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Data Entrada
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Ações
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="os in ordensServico.data.value" :key="os.id">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                #{{ os.id }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ os.veiculos?.placa }} - {{ os.veiculos?.modelo }}
              </td>
              <td class="px-6 py-4 text-sm text-gray-500">
                <div class="max-w-xs truncate">
                  {{ os.problema_reportado }}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                      :class="getStatusClass(os.status)">
                  {{ getStatusText(os.status) }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(os.data_entrada) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <router-link 
                  :to="`/ordens-servico/${os.id}`"
                  class="text-primary-600 hover:text-primary-900"
                >
                  Ver detalhes
                </router-link>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useOrdensServico } from '../features/ordens-servico/hooks/useOrdensServico'
import BaseButton from '../shared/ui/BaseButton.vue'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'

const { ordensServico } = useOrdensServico()

function getStatusClass(status: string) {
  switch (status) {
    case 'em_andamento':
      return 'bg-yellow-100 text-yellow-800'
    case 'concluida':
      return 'bg-green-100 text-green-800'
    case 'cancelada':
      return 'bg-red-100 text-red-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

function getStatusText(status: string) {
  switch (status) {
    case 'em_andamento':
      return 'Em Andamento'
    case 'concluida':
      return 'Concluída'
    case 'cancelada':
      return 'Cancelada'
    default:
      return status
  }
}

function formatDate(dateString: string) {
  return format(new Date(dateString), 'dd/MM/yyyy HH:mm', { locale: ptBR })
}
</script>
