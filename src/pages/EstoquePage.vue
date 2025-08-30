<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-semibold text-gray-900">Estoque</h1>
        <p class="mt-1 text-sm text-gray-500">
          Controle de peças e estoque
        </p>
      </div>
      <BaseButton @click="showCreateModal = true">
        Nova Peça
      </BaseButton>
    </div>

    <div class="card">
      <div v-if="pecas.isLoading.value" class="text-center py-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
        <p class="mt-2 text-sm text-gray-500">Carregando peças...</p>
      </div>
      
      <div v-else-if="pecas.data.value?.length === 0" class="text-center py-8">
        <p class="text-gray-500">Nenhuma peça cadastrada</p>
      </div>
      
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Código
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Nome
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Fornecedor
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Estoque
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Custo Unitário
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Ações
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="peca in pecas.data.value" :key="peca.id">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {{ peca.codigo }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ peca.nome }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ peca.fornecedor || '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <span :class="getEstoqueClass(peca.quantidade_estoque)">
                  {{ peca.quantidade_estoque }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                R$ {{ peca.custo_unitario.toFixed(2) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <button class="text-primary-600 hover:text-primary-900 mr-3">
                  Editar
                </button>
                <button class="text-red-600 hover:text-red-900">
                  Excluir
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { usePecas } from '../features/estoque/hooks/usePecas'
import BaseButton from '../shared/ui/BaseButton.vue'

const { pecas } = usePecas()
const showCreateModal = ref(false)

function getEstoqueClass(quantidade: number) {
  if (quantidade === 0) {
    return 'text-red-600 font-medium'
  } else if (quantidade <= 5) {
    return 'text-yellow-600 font-medium'
  } else {
    return 'text-green-600'
  }
}
</script>
