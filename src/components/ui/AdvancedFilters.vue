<template>
  <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
    <!-- Header dos Filtros -->
    <div class="p-4 border-b border-gray-100 bg-gradient-to-r from-slate-50 to-gray-50">
      <div class="flex items-center justify-between">
        <div class="flex items-center space-x-3">
          <FunnelIcon class="w-5 h-5 text-gray-600" />
          <h3 class="text-lg font-semibold text-gray-900">Filtros Avançados</h3>
        </div>
        
        <div class="flex items-center space-x-2">
          <button
            @click="toggleExpanded"
            class="text-sm text-gray-600 hover:text-gray-900 font-medium flex items-center space-x-1"
          >
            <span>{{ isExpanded ? 'Recolher' : 'Expandir' }}</span>
            <ChevronDownIcon 
              class="w-4 h-4 transition-transform duration-200"
              :class="{ 'rotate-180': isExpanded }"
            />
          </button>
          
          <button
            @click="clearAllFilters"
            class="text-sm text-red-600 hover:text-red-700 font-medium hover:underline"
          >
            Limpar Filtros
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros Expandidos -->
    <div v-if="isExpanded" class="p-6 space-y-6">
      <!-- Filtros de Status -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
          <select
            v-model="filters.status"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          >
            <option value="">Todos os status</option>
            <option value="em_andamento">Em andamento</option>
            <option value="concluida">Concluída</option>
            <option value="cancelada">Cancelada</option>
            <option value="oficina_externa">Oficina externa</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Prioridade</label>
          <select
            v-model="filters.prioridade"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          >
            <option value="">Todas as prioridades</option>
            <option value="baixa">Baixa</option>
            <option value="normal">Normal</option>
            <option value="alta">Alta</option>
            <option value="urgente">Urgente</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Veículo</label>
          <select
            v-model="filters.veiculo_id"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          >
            <option value="">Todos os veículos</option>
            <option
              v-for="veiculo in veiculos"
              :key="veiculo.id"
              :value="veiculo.id"
            >
              {{ veiculo.placa }} - {{ veiculo.modelo }}
            </option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Supervisor</label>
          <select
            v-model="filters.supervisor_id"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          >
            <option value="">Todos os supervisores</option>
            <option
              v-for="supervisor in supervisores"
              :key="supervisor.id"
              :value="supervisor.id"
            >
              {{ supervisor.nome }}
            </option>
          </select>
        </div>
      </div>

      <!-- Filtros de Data -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Data de Entrada (De)</label>
          <input
            v-model="filters.data_entrada_de"
            type="date"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Data de Entrada (Até)</label>
          <input
            v-model="filters.data_entrada_ate"
            type="date"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Período</label>
          <select
            v-model="filters.periodo"
            @change="handlePeriodoChange"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          >
            <option value="">Personalizado</option>
            <option value="hoje">Hoje</option>
            <option value="ontem">Ontem</option>
            <option value="semana">Última semana</option>
            <option value="mes">Último mês</option>
            <option value="trimestre">Último trimestre</option>
          </select>
        </div>
      </div>

      <!-- Filtros de Texto -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Buscar no Problema</label>
          <div class="relative">
            <input
              v-model="filters.problema_busca"
              type="text"
              placeholder="Digite palavras-chave..."
              class="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
            />
            <MagnifyingGlassIcon class="w-5 h-5 text-gray-400 absolute left-3 top-2.5" />
          </div>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Número da OS</label>
          <input
            v-model="filters.numero_os"
            type="text"
            placeholder="Ex: OS-001, OS-002..."
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          />
        </div>
      </div>

      <!-- Filtros de Ordenação -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Ordenar por</label>
          <select
            v-model="filters.ordenacao"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          >
            <option value="data_entrada_desc">Data de entrada (mais recente)</option>
            <option value="data_entrada_asc">Data de entrada (mais antiga)</option>
            <option value="prioridade_desc">Prioridade (mais alta)</option>
            <option value="prioridade_asc">Prioridade (mais baixa)</option>
            <option value="numero_os_asc">Número da OS (crescente)</option>
            <option value="numero_os_desc">Número da OS (decrescente)</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Itens por página</label>
          <select
            v-model="filters.limit"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          >
            <option value="10">10 itens</option>
            <option value="25">25 itens</option>
            <option value="50">50 itens</option>
            <option value="100">100 itens</option>
          </select>
        </div>

        <div class="flex items-end">
          <label class="flex items-center space-x-2">
            <input
              v-model="filters.apenas_nao_lidas"
              type="checkbox"
              class="w-4 h-4 text-amber-600 focus:ring-amber-500 border-gray-300 rounded"
            />
            <span class="text-sm text-gray-700">Apenas não lidas</span>
          </label>
        </div>
      </div>

      <!-- Botões de Ação -->
      <div class="flex items-center justify-between pt-4 border-t border-gray-200">
        <div class="text-sm text-gray-600">
          <span v-if="totalFiltros > 0">
            {{ totalFiltros }} filtro{{ totalFiltros !== 1 ? 's' : '' }} ativo{{ totalFiltros !== 1 ? 's' : '' }}
          </span>
          <span v-else>Nenhum filtro ativo</span>
        </div>

        <div class="flex items-center space-x-3">
          <button
            @click="resetFilters"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          >
            Resetar
          </button>
          
          <button
            @click="applyFilters"
            class="px-4 py-2 text-sm font-medium text-white bg-amber-600 border border-transparent rounded-lg hover:bg-amber-700 focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          >
            Aplicar Filtros
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros Ativos (Mini) -->
    <div v-if="!isExpanded && totalFiltros > 0" class="p-4 bg-amber-50 border-t border-amber-200">
      <div class="flex items-center space-x-2">
        <span class="text-sm text-amber-800 font-medium">Filtros ativos:</span>
        <div class="flex flex-wrap gap-2">
          <span
            v-for="(value, key) in activeFilters"
            :key="key"
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-amber-100 text-amber-800"
          >
            {{ getFilterLabel(key, value) }}
            <button
              @click="removeFilter(key)"
              class="ml-1.5 text-amber-600 hover:text-amber-800"
            >
              <XMarkIcon class="w-3 h-3" />
            </button>
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import {
  FunnelIcon,
  ChevronDownIcon,
  MagnifyingGlassIcon,
  XMarkIcon
} from '@heroicons/vue/24/outline'

interface Filters {
  status: string
  prioridade: string
  veiculo_id: string
  supervisor_id: string
  data_entrada_de: string
  data_entrada_ate: string
  periodo: string
  problema_busca: string
  numero_os: string
  ordenacao: string
  limit: string
  apenas_nao_lidas: boolean
}

interface Veiculo {
  id: number
  placa: string
  modelo: string
}

interface Supervisor {
  id: number
  nome: string
}

interface Props {
  modelValue?: Partial<Filters>
  veiculos?: Veiculo[]
  supervisores?: Supervisor[]
}

interface Emits {
  (e: 'update:modelValue', value: Partial<Filters>): void
  (e: 'apply', value: Partial<Filters>): void
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: () => ({}),
  veiculos: () => [],
  supervisores: () => []
})

const emit = defineEmits<Emits>()

const isExpanded = ref(false)
const filters = ref<Filters>({
  status: '',
  prioridade: '',
  veiculo_id: '',
  supervisor_id: '',
  data_entrada_de: '',
  data_entrada_ate: '',
  periodo: '',
  problema_busca: '',
  numero_os: '',
  ordenacao: 'data_entrada_desc',
  limit: '25',
  apenas_nao_lidas: false
})

// Inicializar filtros com valores recebidos
watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    filters.value = { ...filters.value, ...newValue }
  }
}, { immediate: true })

// Computed para filtros ativos
const activeFilters = computed(() => {
  const active: Record<string, any> = {}
  Object.entries(filters.value).forEach(([key, value]) => {
    if (value && value !== '' && value !== 'data_entrada_desc' && value !== '25') {
      active[key] = value
    }
  })
  return active
})

const totalFiltros = computed(() => Object.keys(activeFilters.value).length)

// Métodos
const toggleExpanded = () => {
  isExpanded.value = !isExpanded.value
}

const clearAllFilters = () => {
  filters.value = {
    status: '',
    prioridade: '',
    veiculo_id: '',
    supervisor_id: '',
    data_entrada_de: '',
    data_entrada_ate: '',
    periodo: '',
    problema_busca: '',
    numero_os: '',
    ordenacao: 'data_entrada_desc',
    limit: '25',
    apenas_nao_lidas: false
  }
  emit('update:modelValue', filters.value)
}

const resetFilters = () => {
  clearAllFilters()
}

const applyFilters = () => {
  emit('update:modelValue', filters.value)
  emit('apply', filters.value)
}

const removeFilter = (key: string) => {
  if (key in filters.value) {
    (filters.value as any)[key] = key === 'ordenacao' ? 'data_entrada_desc' : 
                                  key === 'limit' ? '25' : ''
  }
  emit('update:modelValue', filters.value)
}

const handlePeriodoChange = () => {
  const hoje = new Date()
  
  switch (filters.value.periodo) {
    case 'hoje':
      filters.value.data_entrada_de = hoje.toISOString().split('T')[0]
      filters.value.data_entrada_ate = hoje.toISOString().split('T')[0]
      break
    case 'ontem':
      const ontem = new Date(hoje)
      ontem.setDate(hoje.getDate() - 1)
      filters.value.data_entrada_de = ontem.toISOString().split('T')[0]
      filters.value.data_entrada_ate = ontem.toISOString().split('T')[0]
      break
    case 'semana':
      const semanaAtras = new Date(hoje)
      semanaAtras.setDate(hoje.getDate() - 7)
      filters.value.data_entrada_de = semanaAtras.toISOString().split('T')[0]
      filters.value.data_entrada_ate = hoje.toISOString().split('T')[0]
      break
    case 'mes':
      const mesAtras = new Date(hoje)
      mesAtras.setMonth(hoje.getMonth() - 1)
      filters.value.data_entrada_de = mesAtras.toISOString().split('T')[0]
      filters.value.data_entrada_ate = hoje.toISOString().split('T')[0]
      break
    case 'trimestre':
      const trimestreAtras = new Date(hoje)
      trimestreAtras.setMonth(hoje.getMonth() - 3)
      filters.value.data_entrada_de = trimestreAtras.toISOString().split('T')[0]
      filters.value.data_entrada_ate = hoje.toISOString().split('T')[0]
      break
    default:
      filters.value.data_entrada_de = ''
      filters.value.data_entrada_ate = ''
  }
}

const getFilterLabel = (key: string, value: any): string => {
  const labels: Record<string, string> = {
    status: `Status: ${value}`,
    prioridade: `Prioridade: ${value}`,
    veiculo_id: `Veículo: ${props.veiculos.find(v => v.id.toString() === value)?.placa || value}`,
    supervisor_id: `Supervisor: ${props.supervisores.find(s => s.id.toString() === value)?.nome || value}`,
    data_entrada_de: `De: ${value}`,
    data_entrada_ate: `Até: ${value}`,
    problema_busca: `Busca: ${value}`,
    numero_os: `OS: ${value}`,
    ordenacao: `Ordenação: ${value}`,
    limit: `${value} itens`,
    apenas_nao_lidas: 'Não lidas'
  }
  return labels[key] || `${key}: ${value}`
}

// Watch para emitir mudanças - removido para evitar recursão
// watch(filters, (newFilters) => {
//   emit('update:modelValue', newFilters)
// }, { deep: true })
</script>
