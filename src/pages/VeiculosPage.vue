<template>
  <div class="space-y-6">
    <!-- Header da Página -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
      <div>
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Veículos</h1>
        <p class="mt-1 text-sm sm:text-base text-gray-600">
          Gestão completa da frota de veículos
        </p>
      </div>
      <div class="mt-4 sm:mt-0 flex flex-col sm:flex-row gap-2">
        <button class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
          </svg>
          Novo Veículo
        </button>
      </div>
    </div>

    <!-- Filtros e Busca -->
    <div class="bg-white shadow rounded-lg p-4 sm:p-6">
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Buscar</label>
          <input
            v-model="searchTerm"
            type="text"
            placeholder="Placa, modelo..."
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Tipo</label>
          <select
            v-model="selectedType"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
          >
            <option value="">Todos os tipos</option>
            <option value="carro">Carro</option>
            <option value="caminhao">Caminhão</option>
            <option value="van">Van</option>
            <option value="moto">Moto</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
          <select
            v-model="selectedStatus"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
          >
            <option value="">Todos os status</option>
            <option value="ativo">Ativo</option>
            <option value="manutencao">Em Manutenção</option>
            <option value="inativo">Inativo</option>
          </select>
        </div>
        <div class="flex items-end">
          <button
            @click="clearFilters"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
          >
            Limpar Filtros
          </button>
        </div>
      </div>
    </div>

    <!-- Tabela de Veículos -->
    <ResponsiveTable
      title="Lista de Veículos"
      :description="`${filteredVeiculos.length} veículos encontrados`"
      :columns="columns"
      :items="filteredVeiculos"
      empty-title="Nenhum veículo encontrado"
      empty-description="Não há veículos cadastrados ou que correspondam aos filtros aplicados."
    >
      <template #actions>
        <button class="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          Exportar
        </button>
      </template>

      <template #placa="{ value }">
        <span class="font-medium text-gray-900">{{ value }}</span>
      </template>

      <template #modelo="{ value }">
        <span class="text-gray-900">{{ value }}</span>
      </template>

      <template #tipo="{ value }">
        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
          {{ value }}
        </span>
      </template>

      <template #status="{ value }">
        <span
          :class="[
            'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
            value === 'ativo' ? 'bg-green-100 text-green-800' : '',
            value === 'manutencao' ? 'bg-yellow-100 text-yellow-800' : '',
            value === 'inativo' ? 'bg-red-100 text-red-800' : ''
          ]"
        >
          {{ value === 'ativo' ? 'Ativo' : value === 'manutencao' ? 'Em Manutenção' : 'Inativo' }}
        </span>
      </template>

      <template #acoes="{ item }">
        <div class="flex items-center space-x-2">
          <button
            @click="viewVeiculo(item)"
            class="text-blue-600 hover:text-blue-900 text-sm font-medium"
          >
            Ver
          </button>
          <button
            @click="editVeiculo(item)"
            class="text-gray-600 hover:text-gray-900 text-sm font-medium"
          >
            Editar
          </button>
        </div>
      </template>
    </ResponsiveTable>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import ResponsiveTable from '@/components/ui/ResponsiveTable.vue'

// Dados mockados para exemplo
const veiculos = ref([
  {
    id: 1,
    placa: 'ABC-1234',
    modelo: 'Fiat Strada',
    tipo: 'caminhao',
    status: 'ativo',
    ano: 2020,
    km: 45000
  },
  {
    id: 2,
    placa: 'DEF-5678',
    modelo: 'Ford Transit',
    tipo: 'van',
    status: 'manutencao',
    ano: 2019,
    km: 78000
  },
  {
    id: 3,
    placa: 'GHI-9012',
    modelo: 'Honda Civic',
    tipo: 'carro',
    status: 'ativo',
    ano: 2021,
    km: 25000
  }
])

const searchTerm = ref('')
const selectedType = ref('')
const selectedStatus = ref('')

const columns = [
  { key: 'placa', label: 'Placa' },
  { key: 'modelo', label: 'Modelo' },
  { key: 'tipo', label: 'Tipo' },
  { key: 'status', label: 'Status' },
  { key: 'acoes', label: 'Ações' }
]

const filteredVeiculos = computed(() => {
  return veiculos.value.filter(veiculo => {
    const matchesSearch = !searchTerm.value || 
      veiculo.placa.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
      veiculo.modelo.toLowerCase().includes(searchTerm.value.toLowerCase())
    
    const matchesType = !selectedType.value || veiculo.tipo === selectedType.value
    const matchesStatus = !selectedStatus.value || veiculo.status === selectedStatus.value
    
    return matchesSearch && matchesType && matchesStatus
  })
})

function clearFilters() {
  searchTerm.value = ''
  selectedType.value = ''
  selectedStatus.value = ''
}

function viewVeiculo(veiculo: any) {
  // Implementar visualização
}

function editVeiculo(veiculo: any) {
  // Implementar edição
}
</script>
