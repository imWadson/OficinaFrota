<template>
  <div class="space-y-6">
    <!-- Header da Página -->
    <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between">
      <div class="mb-6 lg:mb-0">
        <div class="flex items-center space-x-4 mb-2">
          <div class="w-1 h-12 bg-gradient-to-b from-blue-500 to-blue-600 rounded-full"></div>
          <div>
            <h1 class="text-3xl lg:text-4xl font-bold text-slate-900 tracking-tight">Estatísticas por Veículo</h1>
            <p class="text-lg text-slate-600 font-medium">
              Análise detalhada de cada veículo da frota
            </p>
          </div>
        </div>
      </div>
      
      <div class="flex flex-col sm:flex-row gap-4">
        <BaseButton 
          @click="exportarRelatorio"
          variant="secondary"
          size="lg"
          :disabled="!veiculoSelecionado"
        >
          Exportar Relatório
        </BaseButton>
        
        <BaseButton 
          @click="gerarPDF"
          variant="primary"
          size="lg"
          :disabled="!veiculoSelecionado"
        >
          Gerar PDF
        </BaseButton>
      </div>
    </div>

    <!-- Seletor de Veículo -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
      <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        <div>
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Selecionar Veículo</h3>
          <p class="text-sm text-gray-600">Escolha um veículo para visualizar suas estatísticas completas</p>
        </div>
        
        <div class="flex-1 max-w-md">
          <select
            v-model="veiculoSelecionado"
            @change="carregarEstatisticasVeiculo"
            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          >
            <option value="">Selecione um veículo...</option>
            <option
              v-for="veiculo in veiculos"
              :key="veiculo.id"
              :value="veiculo.id"
            >
              {{ veiculo.placa }} - {{ veiculo.modelo }} ({{ veiculo.tipo }})
            </option>
          </select>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="text-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
      <p class="text-slate-600">Carregando estatísticas do veículo...</p>
    </div>

    <!-- Estatísticas do Veículo Selecionado -->
    <div v-else-if="veiculoSelecionado && temEstatisticas" class="space-y-6">
      <!-- Informações Básicas do Veículo -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex items-center space-x-4 mb-6">
          <div class="w-16 h-16 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center">
            <TruckIcon class="w-8 h-8 text-white" />
          </div>
          <div>
            <h2 class="text-2xl font-bold text-gray-900">{{ veiculoInfo?.placa }}</h2>
            <p class="text-lg text-gray-600">{{ veiculoInfo?.modelo }}</p>
            <div class="flex items-center space-x-4 mt-2">
              <span class="px-3 py-1 bg-blue-100 text-blue-800 text-sm font-medium rounded-full">
                {{ veiculoInfo?.tipo }}
              </span>
              <span class="px-3 py-1 bg-green-100 text-green-800 text-sm font-medium rounded-full">
                {{ veiculoInfo?.status }}
              </span>
              <span class="px-3 py-1 bg-amber-100 text-amber-800 text-sm font-medium rounded-full">
                {{ veiculoInfo?.ano }}
              </span>
            </div>
          </div>
        </div>

        <!-- Indicador de Saúde -->
        <div class="mb-6 p-4 bg-gradient-to-r from-slate-50 to-blue-50 rounded-lg border border-slate-200">
          <div class="flex items-center justify-between">
            <div>
              <h4 class="text-lg font-semibold text-slate-900 mb-2">Indicador de Saúde do Veículo</h4>
              <p class="text-sm text-slate-600">Análise baseada em eficiência, custos e frequência de manutenção</p>
            </div>
            <div class="text-right">
              <div class="text-2xl font-bold text-gray-500">
                N/A
              </div>
              <div class="text-sm text-slate-500">Status Geral</div>
            </div>
          </div>
        </div>

        <!-- Resumo Rápido -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div class="text-center p-4 bg-blue-50 rounded-lg">
            <div class="text-2xl font-bold text-blue-600">{{ resumo?.total_os || 0 }}</div>
            <div class="text-sm text-blue-800">Total de OS</div>
          </div>
          <div class="text-center p-4 bg-green-50 rounded-lg">
            <div class="text-2xl font-bold text-green-600">N/A</div>
            <div class="text-sm text-green-800">Dias em Operação</div>
          </div>
          <div class="text-center p-4 bg-amber-50 rounded-lg">
            <div class="text-2xl font-bold text-amber-600">{{ resumo?.custo_total || 0 }}</div>
            <div class="text-sm text-amber-800">Custo Total (R$)</div>
          </div>
          <div class="text-center p-4 bg-purple-50 rounded-lg">
            <div class="text-2xl font-bold text-purple-600">N/A</div>
            <div class="text-sm text-purple-800">Eficiência</div>
          </div>
        </div>
      </div>

      <!-- Filtros de Período -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
          <div>
            <h3 class="text-lg font-semibold text-gray-900 mb-2">Filtros de Período</h3>
            <p class="text-sm text-gray-600">Ajuste o período para análise das estatísticas</p>
          </div>
          
          <div class="flex flex-wrap gap-3">
            <button
              v-for="periodo in periodos"
              :key="periodo.value"
              @click="selecionarPeriodo(periodo.value)"
              :class="[
                'px-4 py-2 rounded-lg text-sm font-medium transition-colors',
                periodoAtivo === periodo.value
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              ]"
            >
              {{ periodo.label }}
            </button>
          </div>
        </div>
      </div>

      <!-- Estatísticas Detalhadas -->
      <div class="grid grid-cols-1 xl:grid-cols-2 gap-6">
        <!-- Visitas à Oficina -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Visitas à Oficina</h3>
          
          <div class="space-y-4">
            <!-- Oficina Interna -->
            <div class="p-4 bg-blue-50 rounded-lg">
              <div class="flex items-center justify-between mb-2">
                <span class="text-sm font-medium text-blue-800">Oficina Interna</span>
                <span class="text-lg font-bold text-blue-600">{{ oficinaInterna?.total_visitas || 0 }}</span>
              </div>
              <div class="text-xs text-blue-600">
                Última visita: N/A
              </div>
              <div class="mt-2">
                <div class="flex justify-between text-xs text-blue-600">
                  <span>Média: N/A</span>
                  <span>Total: N/A</span>
                </div>
              </div>
            </div>

            <!-- Oficina Externa -->
            <div class="p-4 bg-amber-50 rounded-lg">
              <div class="flex items-center justify-between mb-2">
                <span class="text-sm font-medium text-amber-800">Oficina Externa</span>
                <span class="text-lg font-bold text-amber-600">{{ oficinaExterna?.total_visitas || 0 }}</span>
              </div>
              <div class="text-xs text-amber-600">
                Última visita: N/A
              </div>
              <div class="mt-2">
                <div class="flex justify-between text-xs text-amber-600">
                  <span>Média: N/A</span>
                  <span>Total: N/A</span>
                </div>
              </div>
            </div>

            <!-- Comparativo -->
            <div class="p-4 bg-gray-50 rounded-lg">
              <div class="text-sm font-medium text-gray-800 mb-2">Distribuição de Visitas</div>
              <div class="flex items-center space-x-2">
                <div class="flex-1 bg-gray-200 rounded-full h-2">
                  <div 
                    class="bg-blue-500 h-2 rounded-full"
                    :style="{ width: `${distribuicao?.oficina_interna || 0}%` }"
                  ></div>
                </div>
                <span class="text-xs text-gray-600">{{ distribuicao?.oficina_interna || 0 }}%</span>
              </div>
              <div class="flex items-center space-x-2 mt-1">
                <div class="flex-1 bg-gray-200 rounded-full h-2">
                  <div 
                    class="bg-amber-500 h-2 rounded-full"
                    :style="{ width: `${distribuicao?.oficina_externa || 0}%` }"
                  ></div>
                </div>
                <span class="text-xs text-gray-600">{{ distribuicao?.oficina_externa || 0 }}%</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Problemas e Peças -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Problemas e Peças</h3>
          
          <div class="space-y-4">
            <!-- Problemas Mais Comuns -->
            <div class="p-4 bg-red-50 rounded-lg">
              <div class="text-sm font-medium text-red-800 mb-2">Problemas Mais Comuns</div>
              <div class="space-y-2">
                <div
                  v-for="problema in problemas"
                  :key="problema.tipo"
                  class="flex justify-between text-sm"
                >
                  <span class="text-red-700">{{ problema.tipo }}</span>
                  <span class="font-medium text-red-800">{{ problema.quantidade }}x</span>
                </div>
              </div>
            </div>

            <!-- Peças Utilizadas -->
            <div class="p-4 bg-green-50 rounded-lg">
              <div class="text-sm font-medium text-green-800 mb-2">Peças Mais Utilizadas</div>
              <div class="space-y-2">
                <div
                  v-for="peca in pecas"
                  :key="peca.nome"
                  class="flex justify-between text-sm"
                >
                  <span class="text-green-700">{{ peca.nome }}</span>
                  <span class="font-medium text-green-800">{{ peca.quantidade }}x</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Gráficos e Análises -->
      <div class="grid grid-cols-1 xl:grid-cols-2 gap-6">
        <!-- Evolução Temporal -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Evolução Temporal</h3>
          <div class="h-64 bg-gradient-to-br from-slate-50 to-blue-50 rounded-lg flex items-center justify-center border-2 border-dashed border-slate-200">
            <div class="text-center">
              <ChartBarIcon class="w-12 h-12 text-slate-300 mx-auto mb-2" />
              <p class="text-slate-500">Gráfico de evolução será implementado aqui</p>
              <p class="text-sm text-slate-400 mt-1">Período: {{ getPeriodoLabel() }}</p>
            </div>
          </div>
        </div>

        <!-- Análise de Custos -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Análise de Custos</h3>
          <div class="space-y-4">
            <div class="flex justify-between items-center">
              <span class="text-sm text-gray-600">Custo por Tipo de Serviço</span>
            </div>
            <div class="space-y-2">
              <div class="flex justify-between text-sm">
                <span class="text-blue-600">Oficina Interna</span>
                <span class="font-medium">R$ {{ custos?.oficina_interna || 0 }}</span>
              </div>
              <div class="flex justify-between text-sm">
                <span class="text-amber-600">Oficina Externa</span>
                <span class="font-medium">R$ {{ custos?.oficina_externa || 0 }}</span>
              </div>
              <div class="flex justify-between text-sm">
                <span class="text-green-600">Peças</span>
                <span class="font-medium">R$ {{ custos?.pecas || 0 }}</span>
              </div>
            </div>
            <div class="pt-2 border-t border-gray-200">
              <div class="flex justify-between text-sm font-semibold">
                <span>Total</span>
                <span class="text-lg">R$ {{ custos?.total || 0 }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabela de Histórico -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div class="p-6 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">Histórico Completo</h3>
          <p class="text-sm text-gray-600">Todas as ordens de serviço e manutenções do veículo</p>
        </div>
        
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Data
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipo
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Descrição
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Custo
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr
                v-for="item in historico"
                :key="item.id"
                class="hover:bg-gray-50 transition-colors duration-150"
              >
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ formatDate(item.data) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                    :class="getTipoClass(item.tipo)"
                  >
                    {{ getTipoLabel(item.tipo) }}
                  </span>
                </td>
                <td class="px-6 py-4 text-sm text-gray-500">
                  <div class="max-w-xs">
                    <p class="font-medium text-gray-900">{{ item.descricao }}</p>
                    <p class="text-xs text-gray-400 mt-1">N/A</p>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  R$ {{ item.custo }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
                  >
                    N/A
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Estado Vazio -->
    <div v-else-if="!veiculoSelecionado" class="text-center py-12">
      <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
        <TruckIcon class="w-8 h-8 text-gray-400" />
      </div>
      <h3 class="text-lg font-medium text-gray-900 mb-2">Selecione um Veículo</h3>
      <p class="text-gray-500">Escolha um veículo da lista acima para visualizar suas estatísticas detalhadas</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import {
  TruckIcon,
  ChartBarIcon
} from '@heroicons/vue/24/outline'
import BaseButton from '../shared/ui/BaseButton.vue'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import { useEstatisticasVeiculo } from '../features/veiculos/hooks/useEstatisticasVeiculo'
import { veiculoRepository } from '../services/repositories/veiculoRepository'
import { useUserContext } from '../composables/useUserContext'
import { useAuthStore } from '../features/auth/stores/authStore'

// Hook de estatísticas
const {
  estatisticas,
  isLoading,
  error,
  veiculoSelecionado,
  periodoAtivo,
  temEstatisticas,
  veiculoInfo,
  resumo,
  oficinaInterna,
  oficinaExterna,
  distribuicao,
  problemas,
  pecas,
  custos,
  historico,
  analiseCustos,
  analiseFrequencia,
  analiseProblemas,
  analisePecas,
  getIndicadorSaude,
  carregarEstatisticas,
  alterarPeriodo,
  exportarRelatorio,
  gerarPDF
} = useEstatisticasVeiculo()

// Períodos disponíveis
const periodos = [
  { value: 'mes', label: 'Último Mês' },
  { value: 'trimestre', label: 'Último Trimestre' },
  { value: 'ano', label: 'Último Ano' },
  { value: 'todos', label: 'Todos os Tempos' }
]

// Estado local
const veiculos = ref<any[]>([])
const authStore = useAuthStore()

// Métodos
const carregarEstatisticasVeiculo = async () => {
  if (!veiculoSelecionado.value) return
  await carregarEstatisticas(veiculoSelecionado.value, periodoAtivo.value)
}

const selecionarPeriodo = async (periodo: string) => {
  await alterarPeriodo(periodo as 'mes' | 'trimestre' | 'ano' | 'todos')
}

const formatDate = (dateString: string): string => {
  try {
    return format(new Date(dateString), 'dd/MM/yyyy', { locale: ptBR })
  } catch {
    return 'N/A'
  }
}

const getPeriodoLabel = (): string => {
  const periodo = periodos.find(p => p.value === periodoAtivo.value)
  return periodo ? periodo.label : 'Período'
}

const getTipoClass = (tipo: string): string => {
  const classMap: Record<string, string> = {
    'oficina_interna': 'bg-blue-100 text-blue-800',
    'oficina_externa': 'bg-amber-100 text-amber-800',
    'peca': 'bg-green-100 text-green-800',
    'manutencao': 'bg-purple-100 text-purple-800'
  }
  return classMap[tipo] || 'bg-gray-100 text-gray-800'
}

const getTipoLabel = (tipo: string): string => {
  const labelMap: Record<string, string> = {
    'oficina_interna': 'Oficina Interna',
    'oficina_externa': 'Oficina Externa',
    'peca': 'Troca de Peça',
    'manutencao': 'Manutenção'
  }
  return labelMap[tipo] || tipo
}

const getStatusClass = (status: string): string => {
  const classMap: Record<string, string> = {
    'concluida': 'bg-green-100 text-green-800',
    'em_andamento': 'bg-yellow-100 text-yellow-800',
    'cancelada': 'bg-red-100 text-red-800'
  }
  return classMap[status] || 'bg-gray-100 text-gray-800'
}

const getStatusLabel = (status: string): string => {
  const labelMap: Record<string, string> = {
    'concluida': 'Concluída',
    'em_andamento': 'Em Andamento',
    'cancelada': 'Cancelada'
  }
  return labelMap[status] || status
}

// Carregar dados iniciais
onMounted(async () => {
  try {
    // Aguardar autenticação ser inicializada
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // Buscar veículos diretamente do repository
    const regionalId = authStore.userRegionalData?.id || authStore.userData?.regional_id
    if (regionalId) {
      const veiculosData = await veiculoRepository.findAll(regionalId)
      veiculos.value = veiculosData || []
    }
  } catch (error) {
    console.error('Erro ao carregar veículos:', error)
  }
})
</script>
