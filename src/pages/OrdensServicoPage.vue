<template>
  <div class="space-y-6">
    <!-- Header da Página -->
    <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between">
      <div class="mb-6 lg:mb-0">
        <div class="flex items-center space-x-4 mb-2">
          <div class="w-1 h-12 bg-gradient-to-b from-amber-500 to-orange-600 rounded-full"></div>
      <div>
            <h1 class="text-3xl lg:text-4xl font-bold text-slate-900 tracking-tight">Ordens de Serviço</h1>
            <p class="text-lg text-slate-600 font-medium">
          Gestão das ordens de manutenção
        </p>
      </div>
        </div>
      </div>
      
      <div class="flex flex-col sm:flex-row gap-4">
        <BaseButton 
          @click="$router.push('/ordens-servico/nova')"
          variant="primary"
          size="lg"
        >
        Nova OS
      </BaseButton>
        
        <BaseButton 
          @click="exportarDados"
          variant="secondary"
          size="lg"
          :disabled="!ordensServico.data.value?.length"
        >
          Exportar
        </BaseButton>
      </div>
    </div>

    <!-- Filtros Avançados -->
    <AdvancedFilters
      v-model="filtros"
      :veiculos="veiculos"
      :supervisores="supervisores"
      @apply="aplicarFiltros"
    />

    <!-- Estatísticas Rápidas -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <div class="bg-white rounded-xl p-4 border border-gray-200">
        <div class="flex items-center">
          <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
            <ClockIcon class="w-5 h-5 text-blue-600" />
          </div>
          <div class="ml-3">
            <p class="text-sm font-medium text-gray-600">Total</p>
            <p class="text-2xl font-bold text-gray-900">{{ totalOS }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl p-4 border border-gray-200">
        <div class="flex items-center">
          <div class="w-10 h-10 bg-yellow-100 rounded-lg flex items-center justify-center">
            <WrenchScrewdriverIcon class="w-5 h-5 text-yellow-600" />
          </div>
          <div class="ml-3">
            <p class="text-sm font-medium text-gray-600">Em Andamento</p>
            <p class="text-2xl font-bold text-gray-900">{{ osEmAndamento }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl p-4 border border-gray-200">
        <div class="flex items-center">
          <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
            <CheckCircleIcon class="w-5 h-5 text-green-600" />
          </div>
          <div class="ml-3">
            <p class="text-sm font-medium text-gray-600">Concluídas</p>
            <p class="text-2xl font-bold text-gray-900">{{ osConcluidas }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-xl p-4 border border-gray-200">
        <div class="flex items-center">
          <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
            <ExclamationTriangleIcon class="w-5 h-5 text-red-600" />
          </div>
          <div class="ml-3">
            <p class="text-sm font-medium text-gray-600">Urgentes</p>
            <p class="text-2xl font-bold text-gray-900">{{ osUrgentes }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabela de Ordens de Serviço -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
      <!-- Loading State -->
      <div v-if="ordensServico.isLoading.value" class="text-center py-12">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-500 mx-auto mb-4"></div>
        <p class="text-slate-600">Carregando ordens de serviço...</p>
    </div>

      <!-- Error State -->
      <div v-else-if="ordensServico.error.value" class="bg-red-50 border border-red-200 rounded-xl p-6 m-4">
        <div class="flex items-center">
          <ExclamationTriangleIcon class="w-6 h-6 text-red-500 mr-3" />
          <div>
            <h3 class="text-lg font-semibold text-red-800">Erro ao carregar dados</h3>
            <p class="text-red-600">{{ ordensServico.error.value?.message || 'Erro desconhecido' }}</p>
          </div>
        </div>
        <BaseButton 
          variant="secondary" 
          size="sm"
          class="mt-4"
          @click="recarregarDados"
        >
          Tentar novamente
        </BaseButton>
      </div>
      
      <!-- Empty State -->
      <div v-else-if="!ordensServico.data.value?.length" class="text-center py-12">
        <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <ClipboardDocumentListIcon class="w-8 h-8 text-gray-400" />
        </div>
        <h3 class="text-lg font-medium text-gray-900 mb-2">Nenhuma ordem de serviço encontrada</h3>
        <p class="text-gray-500 mb-6">
          {{ temFiltros ? 'Tente ajustar os filtros ou criar uma nova OS.' : 'Comece criando sua primeira ordem de serviço.' }}
        </p>
        <BaseButton 
          v-if="!temFiltros"
          @click="$router.push('/ordens-servico/nova')"
          variant="primary"
        >
          Criar Primeira OS
        </BaseButton>
      </div>
      
      <!-- Tabela com Dados -->
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
                Prioridade
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Criador
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
            <tr 
              v-for="os in ordensServico.data.value" 
              :key="os.id"
              class="hover:bg-gray-50 transition-colors duration-150"
            >
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                <div class="flex items-center space-x-2">
                  <span class="w-8 h-8 bg-gradient-to-br from-amber-500 to-orange-600 rounded-lg flex items-center justify-center">
                    <span class="text-white font-bold text-xs">#{{ os.id }}</span>
                  </span>
                  <span v-if="os.prioridade === 'urgente'" class="text-xs text-red-600 font-medium">
                    URGENTE
                  </span>
                </div>
              </td>
              
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <div class="flex items-center space-x-3">
                  <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                    <TruckIcon class="w-5 h-5 text-blue-600" />
                  </div>
                  <div>
                    <p class="font-medium text-gray-900">{{ os.veiculos?.placa }}</p>
                    <p class="text-xs text-gray-500">{{ os.veiculos?.modelo }}</p>
                  </div>
                </div>
              </td>
              
              <td class="px-6 py-4 text-sm text-gray-500">
                <div class="max-w-xs">
                  <p class="truncate font-medium text-gray-900">{{ os.problema_reportado }}</p>
                  <p v-if="os.observacoes" class="text-xs text-gray-400 mt-1 truncate">
                    {{ os.observacoes }}
                  </p>
                </div>
              </td>
              
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                      :class="getStatusClass(os.status)">
                  {{ getStatusText(os.status) }}
                </span>
              </td>
              
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                      :class="getPrioridadeClass(os.prioridade)">
                  {{ getPrioridadeText(os.prioridade) }}
                </span>
              </td>
              
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <div class="flex items-center space-x-2">
                  <div class="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                    <span class="text-green-600 font-medium text-xs">
                      {{ os.criador?.nome?.charAt(0) || 'U' }}
                    </span>
                  </div>
                  <div>
                    <p class="font-medium text-gray-900">{{ os.criador?.nome || 'Usuário' }}</p>
                    <p class="text-xs text-gray-500">{{ os.criador?.email || '' }}</p>
                  </div>
                </div>
              </td>
              
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <div>
                  <p class="font-medium">{{ formatDate(os.data_entrada) }}</p>
                  <p class="text-xs text-gray-400">{{ formatTime(os.data_entrada) }}</p>
                </div>
              </td>
              
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <div class="flex items-center space-x-2">
                <router-link 
                  :to="`/ordens-servico/${os.id}`"
                    class="text-amber-600 hover:text-amber-900 font-medium hover:underline"
                >
                  Ver detalhes
                </router-link>
                  
                  <button
                    v-if="os.status === 'em_andamento'"
                    @click="concluirOS(os.id)"
                    class="text-green-600 hover:text-green-900 font-medium hover:underline"
                  >
                    Concluir
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Paginação -->
      <div v-if="totalPaginas > 1" class="px-6 py-4 border-t border-gray-200 bg-gray-50">
        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-700">
            Mostrando {{ inicioPagina }} a {{ fimPagina }} de {{ totalRegistros }} resultados
          </div>
          
          <div class="flex items-center space-x-2">
            <button
              @click="paginaAnterior"
              :disabled="paginaAtual === 1"
              class="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Anterior
            </button>
            
            <span class="px-3 py-2 text-sm text-gray-700">
              Página {{ paginaAtual }} de {{ totalPaginas }}
            </span>
            
            <button
              @click="proximaPagina"
              :disabled="paginaAtual === totalPaginas"
              class="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Próxima
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import {
  ClockIcon,
  WrenchScrewdriverIcon,
  CheckCircleIcon,
  ExclamationTriangleIcon,
  ClipboardDocumentListIcon,
  TruckIcon
} from '@heroicons/vue/24/outline'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import { useOrdensServico } from '../features/ordens-servico/hooks/useOrdensServico'
import BaseButton from '../shared/ui/BaseButton.vue'
import AdvancedFilters from '../components/ui/AdvancedFilters.vue'

const router = useRouter()
const { ordensServico, concluirOrdemServico } = useOrdensServico()

// Estado dos filtros
const filtros = ref({
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

// Estado da paginação
const paginaAtual = ref(1)
const totalRegistros = ref(0)
const registrosPorPagina = computed(() => parseInt(filtros.value.limit))

// Dados para filtros
const veiculos = ref([])
const supervisores = ref([])

// Computed
const totalPaginas = computed(() => Math.ceil(totalRegistros.value / registrosPorPagina.value))
const inicioPagina = computed(() => (paginaAtual.value - 1) * registrosPorPagina.value + 1)
const fimPagina = computed(() => Math.min(paginaAtual.value * registrosPorPagina.value, totalRegistros.value))

const temFiltros = computed(() => {
  return Object.values(filtros.value).some((value: any) => 
    value && value !== '' && value !== false && value !== 'data_entrada_desc' && value !== '25'
  )
})

// Estatísticas
const totalOS = computed(() => ordensServico.data.value?.length || 0)
const osEmAndamento = computed(() => 
  ordensServico.data.value?.filter(os => os.status === 'em_andamento').length || 0
)
const osConcluidas = computed(() => 
  ordensServico.data.value?.filter(os => os.status === 'concluida').length || 0
)
const osUrgentes = computed(() => 
  ordensServico.data.value?.filter(os => os.prioridade === 'urgente').length || 0
)

// Métodos
const aplicarFiltros = async (novosFiltros: any) => {
  filtros.value = { ...novosFiltros }
  paginaAtual.value = 1
  await recarregarDados()
}

const recarregarDados = async () => {
  try {
    // Aqui você implementaria a lógica para aplicar os filtros
    // Por enquanto, vamos apenas recarregar os dados existentes
    await ordensServico.refetch()
  } catch (error) {
    console.error('Erro ao recarregar dados:', error)
  }
}

const exportarDados = () => {
  try {
    if (!ordensServico.data.value?.length) {
      alert('Não há dados para exportar')
      return
    }

    // Preparar dados para exportação
    const dados = ordensServico.data.value.map(os => ({
      'OS #': os.id,
      'Veículo': os.veiculos?.placa || 'N/A',
      'Modelo': os.veiculos?.modelo || 'N/A',
      'Problema': os.problema_reportado,
      'Status': getStatusText(os.status),
      'Prioridade': getPrioridadeText(os.prioridade),
      'Data Entrada': formatDate(os.data_entrada),
      'Observações': os.observacoes || ''
    }))

    // Criar CSV
    const headers = Object.keys(dados[0])
    const csvContent = [
      headers.join(','),
      ...dados.map(row => 
        headers.map(header => `"${(row as any)[header] || ''}"`).join(',')
      )
    ].join('\n')

    // Download do arquivo
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `ordens-servico-${new Date().toISOString().split('T')[0]}.csv`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
  } catch (error) {
    console.error('Erro ao exportar dados:', error)
    alert('Erro ao exportar dados. Tente novamente.')
  }
}

const concluirOS = async (osId: string) => {
  try {
    await concluirOrdemServico.mutateAsync({ id: osId, supervisorId: '1' })
    // Recarregar dados após conclusão
    await recarregarDados()
  } catch (error) {
    console.error('Erro ao concluir OS:', error)
  }
}

// Paginação
const paginaAnterior = () => {
  if (paginaAtual.value > 1) {
    paginaAtual.value--
    recarregarDados()
  }
}

const proximaPagina = () => {
  if (paginaAtual.value < totalPaginas.value) {
    paginaAtual.value++
    recarregarDados()
  }
}

// Utilitários
const formatDate = (dateString: string): string => {
  return format(new Date(dateString), 'dd/MM/yyyy', { locale: ptBR })
}

const formatTime = (dateString: string): string => {
  return format(new Date(dateString), 'HH:mm', { locale: ptBR })
}

const getStatusClass = (status: string) => {
  const classMap: Record<string, string> = {
    'em_andamento': 'bg-yellow-100 text-yellow-800',
    'concluida': 'bg-green-100 text-green-800',
    'cancelada': 'bg-red-100 text-red-800',
    'oficina_externa': 'bg-purple-100 text-purple-800',
    'aguardando_peca': 'bg-orange-100 text-orange-800',
    'diagnostico': 'bg-blue-100 text-blue-800',
    'aguardando_aprovacao': 'bg-indigo-100 text-indigo-800'
  }
  return classMap[status] || 'bg-gray-100 text-gray-800'
}

const getStatusText = (status: string) => {
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

const getPrioridadeClass = (prioridade: string) => {
  const classMap: Record<string, string> = {
    'baixa': 'bg-gray-100 text-gray-800',
    'normal': 'bg-blue-100 text-blue-800',
    'alta': 'bg-orange-100 text-orange-800',
    'urgente': 'bg-red-100 text-red-800'
  }
  return classMap[prioridade] || 'bg-gray-100 text-gray-800'
}

const getPrioridadeText = (prioridade: string) => {
  const prioridadeMap: Record<string, string> = {
    'baixa': 'Baixa',
    'normal': 'Normal',
    'alta': 'Alta',
    'urgente': 'Urgente'
  }
  return prioridadeMap[prioridade] || prioridade
}

// Carregar dados iniciais
onMounted(async () => {
  try {
    // Carregar veículos e supervisores para os filtros
    // Aqui você implementaria as chamadas para buscar esses dados
    veiculos.value = []
    supervisores.value = []
  } catch (error) {
    console.error('Erro ao carregar dados iniciais:', error)
  }
})

// Watch para mudanças nos filtros - removido para evitar recursão
// watch(filtros, () => {
//   paginaAtual.value = 1
// }, { deep: true })
</script>
