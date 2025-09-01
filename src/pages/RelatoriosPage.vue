<template>
  <div class="space-y-8">
    <!-- Header da Página -->
    <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between">
      <div class="mb-6 lg:mb-0">
        <div class="flex items-center space-x-4 mb-2">
          <div class="w-1 h-12 bg-gradient-to-b from-purple-500 to-purple-600 rounded-full"></div>
          <div>
            <h1 class="text-3xl lg:text-4xl font-bold text-slate-900 tracking-tight">Relatórios</h1>
            <p class="text-lg text-slate-600 font-medium">
              Análises e estatísticas do sistema
            </p>
          </div>
        </div>
      </div>
      <div class="flex flex-col sm:flex-row gap-4">
        <BaseButton 
          variant="outline" 
          size="lg"
          :icon="ArrowDownTrayIcon"
          @click="exportReport"
        >
          Exportar
        </BaseButton>
        <BaseButton 
          variant="primary" 
          size="lg"
          :icon="ArrowPathIcon"
          @click="refreshData"
        >
          Atualizar
        </BaseButton>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="flex items-center justify-center py-12">
      <div class="text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-500 mx-auto mb-4"></div>
        <p class="text-slate-600">Carregando relatórios...</p>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-xl p-6">
      <div class="flex items-center">
        <ExclamationTriangleIcon class="w-6 h-6 text-red-500 mr-3" />
        <div>
          <h3 class="text-lg font-semibold text-red-800">Erro ao carregar dados</h3>
          <p class="text-red-600">{{ error }}</p>
        </div>
      </div>
      <BaseButton 
        variant="outline" 
        size="sm"
        class="mt-4"
        @click="loadReportData"
      >
        Tentar novamente
      </BaseButton>
    </div>

    <!-- Content -->
    <div v-else>
      <!-- Filtros -->
      <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 p-6 mb-8">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">Período</label>
            <select
              v-model="filters.period"
              @change="loadReportData"
              class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
            >
              <option value="7">Últimos 7 dias</option>
              <option value="30">Últimos 30 dias</option>
              <option value="90">Últimos 90 dias</option>
              <option value="365">Último ano</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">Regional</label>
            <select
              v-model="filters.regional"
              @change="loadReportData"
              class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
            >
              <option value="">Todas as regionais</option>
              <option v-for="regional in regionais" :key="regional.id" :value="regional.id">
                {{ regional.nome }}
              </option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">Tipo de Relatório</label>
            <select
              v-model="filters.reportType"
              @change="loadReportData"
              class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
            >
              <option value="overview">Visão Geral</option>
              <option value="vehicles">Veículos</option>
              <option value="orders">Ordens de Serviço</option>
              <option value="stock">Estoque</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">Formato</label>
            <select
              v-model="filters.format"
              class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
            >
              <option value="pdf">PDF</option>
              <option value="excel">Excel</option>
              <option value="csv">CSV</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Cards de Resumo -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 p-6">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-slate-600">Total de OS</p>
              <p class="text-2xl font-bold text-slate-900">{{ summary.totalOS }}</p>
            </div>
            <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <WrenchScrewdriverIcon class="w-6 h-6 text-blue-600" />
            </div>
          </div>
          <div class="mt-4">
            <span class="text-sm text-green-600 font-medium">+{{ summary.osGrowth }}%</span>
            <span class="text-sm text-slate-500 ml-2">vs período anterior</span>
          </div>
        </div>

        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 p-6">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-slate-600">Veículos Ativos</p>
              <p class="text-2xl font-bold text-slate-900">{{ summary.activeVehicles }}</p>
            </div>
            <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <TruckIcon class="w-6 h-6 text-green-600" />
            </div>
          </div>
          <div class="mt-4">
            <span class="text-sm text-green-600 font-medium">+{{ summary.vehiclesGrowth }}%</span>
            <span class="text-sm text-slate-500 ml-2">vs período anterior</span>
          </div>
        </div>

        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 p-6">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-slate-600">Tempo Médio OS</p>
              <p class="text-2xl font-bold text-slate-900">{{ summary.avgOSTime }}h</p>
            </div>
            <div class="w-12 h-12 bg-amber-100 rounded-lg flex items-center justify-center">
              <ClockIcon class="w-6 h-6 text-amber-600" />
            </div>
          </div>
          <div class="mt-4">
            <span class="text-sm text-red-600 font-medium">-{{ summary.timeImprovement }}%</span>
            <span class="text-sm text-slate-500 ml-2">vs período anterior</span>
          </div>
        </div>

        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 p-6">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-slate-600">Custo Total</p>
              <p class="text-2xl font-bold text-slate-900">R$ {{ summary.totalCost }}</p>
            </div>
            <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
              <CurrencyDollarIcon class="w-6 h-6 text-purple-600" />
            </div>
          </div>
          <div class="mt-4">
            <span class="text-sm text-red-600 font-medium">+{{ summary.costGrowth }}%</span>
            <span class="text-sm text-slate-500 ml-2">vs período anterior</span>
          </div>
        </div>
      </div>

      <!-- Gráficos -->
      <div class="grid grid-cols-1 xl:grid-cols-2 gap-8 mb-8">
        <!-- Gráfico de OS por Status -->
        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
          <div class="p-6 border-b border-slate-100">
            <h3 class="text-xl font-bold text-slate-900">OS por Status</h3>
          </div>
          <div class="p-6">
            <div class="h-80 bg-gradient-to-br from-slate-50 to-purple-50/30 rounded-xl flex items-center justify-center border-2 border-dashed border-slate-200">
              <div class="text-center">
                <ChartPieIcon class="w-16 h-16 text-slate-300 mx-auto mb-4" />
                <p class="text-slate-500 font-medium">Gráfico de pizza será implementado aqui</p>
                <p class="text-sm text-slate-400 mt-2">Status das ordens de serviço</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Gráfico de OS por Período -->
        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
          <div class="p-6 border-b border-slate-100">
            <h3 class="text-xl font-bold text-slate-900">OS por Período</h3>
          </div>
          <div class="p-6">
            <div class="h-80 bg-gradient-to-br from-slate-50 to-purple-50/30 rounded-xl flex items-center justify-center border-2 border-dashed border-slate-200">
              <div class="text-center">
                <ChartBarIcon class="w-16 h-16 text-slate-300 mx-auto mb-4" />
                <p class="text-slate-500 font-medium">Gráfico de barras será implementado aqui</p>
                <p class="text-sm text-slate-400 mt-2">Evolução das ordens de serviço</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabela de Dados -->
      <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
        <div class="p-6 border-b border-slate-100">
          <h3 class="text-xl font-bold text-slate-900">Dados Detalhados</h3>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full">
            <thead class="bg-slate-50 border-b border-slate-200">
              <tr>
                <th class="px-6 py-4 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">
                  Data
                </th>
                <th class="px-6 py-4 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">
                  OS Criadas
                </th>
                <th class="px-6 py-4 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">
                  OS Concluídas
                </th>
                <th class="px-6 py-4 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">
                  Tempo Médio
                </th>
                <th class="px-6 py-4 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">
                  Custo
                </th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-200">
              <tr v-for="item in detailedData" :key="item.date" class="hover:bg-slate-50">
                <td class="px-6 py-4 text-sm text-slate-900">{{ item.date }}</td>
                <td class="px-6 py-4 text-sm text-slate-900">{{ item.created }}</td>
                <td class="px-6 py-4 text-sm text-slate-900">{{ item.completed }}</td>
                <td class="px-6 py-4 text-sm text-slate-900">{{ item.avgTime }}h</td>
                <td class="px-6 py-4 text-sm text-slate-900">R$ {{ item.cost }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import {
  ArrowDownTrayIcon,
  ArrowPathIcon,
  ExclamationTriangleIcon,
  WrenchScrewdriverIcon,
  TruckIcon,
  ClockIcon,
  CurrencyDollarIcon,
  ChartPieIcon,
  ChartBarIcon
} from '@heroicons/vue/24/outline'
import BaseButton from '@/components/ui/BaseButton.vue'
import { RegionalService } from '@/services/regionalService'

// Estado reativo
const isLoading = ref(true)
const error = ref<string | null>(null)
const regionais = ref<any[]>([])

// Filtros
const filters = reactive({
  period: '30',
  regional: '',
  reportType: 'overview',
  format: 'pdf'
})

// Dados do relatório
const summary = reactive({
  totalOS: 0,
  osGrowth: 0,
  activeVehicles: 0,
  vehiclesGrowth: 0,
  avgOSTime: 0,
  timeImprovement: 0,
  totalCost: 0,
  costGrowth: 0
})

const detailedData = ref<any[]>([])

// Funções
const loadReportData = async () => {
  try {
    isLoading.value = true
    error.value = null

    // Simular carregamento de dados
    await new Promise(resolve => setTimeout(resolve, 1000))

    // Dados mockados para demonstração
    summary.totalOS = 156
    summary.osGrowth = 12
    summary.activeVehicles = 89
    summary.vehiclesGrowth = 5
    summary.avgOSTime = 4.2
    summary.timeImprovement = 8
    summary.totalCost = '45.230'
    summary.costGrowth = 3

    detailedData.value = [
      { date: '01/01/2024', created: 5, completed: 4, avgTime: 3.5, cost: '1.200' },
      { date: '02/01/2024', created: 7, completed: 6, avgTime: 4.1, cost: '1.800' },
      { date: '03/01/2024', created: 3, completed: 5, avgTime: 3.8, cost: '1.500' },
      { date: '04/01/2024', created: 8, completed: 7, avgTime: 4.5, cost: '2.100' },
      { date: '05/01/2024', created: 6, completed: 6, avgTime: 4.0, cost: '1.900' }
    ]
  } catch (err) {
    console.error('Erro ao carregar dados do relatório:', err)
    error.value = 'Erro ao carregar dados do relatório. Tente novamente.'
  } finally {
    isLoading.value = false
  }
}

const loadRegionais = async () => {
  try {
    regionais.value = await RegionalService.getAll()
  } catch (err) {
    console.error('Erro ao carregar regionais:', err)
  }
}

const refreshData = () => {
  loadReportData()
}

const exportReport = () => {
  // Implementar exportação
  
}

// Carregar dados quando o componente for montado
onMounted(() => {
  loadRegionais()
  loadReportData()
})
</script>
