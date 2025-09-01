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
          @click="exportarRelatorio"
          :loading="exportando"
        >
          Exportar
        </BaseButton>
        <BaseButton 
          variant="primary" 
          size="lg"
          :icon="ArrowPathIcon"
          @click="atualizarRelatorios"
        >
          Atualizar
        </BaseButton>
      </div>
    </div>

    <!-- Filtros -->
    <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 p-6 mb-8">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Tipo de Relatório</label>
          <select
            v-model="filtros.tipo"
            @change="mudarTipoRelatorio"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          >
            <option value="frota">Relatório da Frota</option>
            <option value="oficina">Relatório da Oficina</option>
            <option value="estoque">Relatório do Estoque</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Período Início</label>
          <input
            v-model="filtros.periodo_inicio"
            type="date"
            @change="gerarRelatorio"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Período Fim</label>
          <input
            v-model="filtros.periodo_fim"
            type="date"
            @change="gerarRelatorio"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          />
        </div>
      </div>

      <!-- Filtros específicos por tipo -->
      <div v-if="filtros.tipo === 'frota'" class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4 border-t border-slate-200">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Tipo de Veículo</label>
          <select
            v-model="filtrosFrota.tipo_veiculo"
            @change="gerarRelatorio"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          >
            <option value="">Todos os tipos</option>
            <option value="Caminhonete">Caminhonete</option>
            <option value="Van">Van</option>
            <option value="Utilitário">Utilitário</option>
            <option value="Guindauto">Guindauto</option>
            <option value="Munck">Munck</option>
            <option value="Guincho">Guincho</option>
            <option value="Máquina">Máquina</option>
            <option value="Gerador">Gerador</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Status</label>
          <select
            v-model="filtrosFrota.status"
            @change="gerarRelatorio"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          >
            <option value="">Todos os status</option>
            <option value="ativo">Ativo</option>
            <option value="inativo">Inativo</option>
            <option value="manutencao">Manutenção</option>
            <option value="oficina_externa">Oficina Externa</option>
          </select>
        </div>
      </div>

      <div v-if="filtros.tipo === 'oficina'" class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4 border-t border-slate-200">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Supervisor</label>
          <select
            v-model="filtrosOficina.supervisor_id"
            @change="gerarRelatorio"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          >
            <option value="">Todos os supervisores</option>
            <option v-for="supervisor in supervisores" :key="supervisor.id" :value="supervisor.id">
              {{ supervisor.nome }}
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Status</label>
          <select
            v-model="filtrosOficina.status"
            @change="gerarRelatorio"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          >
            <option value="">Todos os status</option>
            <option value="em_andamento">Em andamento</option>
            <option value="concluida">Concluída</option>
            <option value="cancelada">Cancelada</option>
          </select>
        </div>
      </div>

      <div v-if="filtros.tipo === 'estoque'" class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4 border-t border-slate-200">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Fornecedor</label>
          <select
            v-model="filtrosEstoque.fornecedor"
            @change="gerarRelatorio"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          >
            <option value="">Todos os fornecedores</option>
            <option v-for="fornecedor in fornecedores" :key="fornecedor" :value="fornecedor">
              {{ fornecedor }}
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Estoque Baixo</label>
          <select
            v-model="filtrosEstoque.estoque_baixo"
            @change="gerarRelatorio"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          >
            <option value="">Todos</option>
            <option :value="true">Apenas estoque baixo</option>
            <option :value="false">Apenas estoque normal</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="flex items-center justify-center py-12">
      <div class="text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-500 mx-auto mb-4"></div>
        <p class="text-slate-600">Gerando relatório...</p>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-xl p-6">
      <div class="flex items-center">
        <ExclamationTriangleIcon class="w-6 h-6 text-red-500 mr-3" />
        <div>
          <h3 class="text-lg font-semibold text-red-800">Erro ao gerar relatório</h3>
          <p class="text-red-600">{{ error }}</p>
        </div>
      </div>
      <BaseButton 
        variant="outline" 
        size="sm"
        class="mt-4"
        @click="gerarRelatorio"
      >
        Tentar novamente
      </BaseButton>
    </div>

    <!-- Relatório da Frota -->
    <div v-else-if="filtros.tipo === 'frota' && relatorioFrota" class="space-y-8">
      <!-- Cards de Resumo -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <DashboardCard
          title="Total de Veículos"
          description="Frota no período"
          :value="relatorioFrota.total_veiculos"
          :icon="TruckIcon"
          color="blue"
        />
        <DashboardCard
          title="Veículos Ativos"
          description="Em operação"
          :value="relatorioFrota.veiculos_ativos"
          :icon="CheckCircleIcon"
          color="green"
        />
        <DashboardCard
          title="Em Manutenção"
          description="Na oficina"
          :value="relatorioFrota.veiculos_manutencao"
          :icon="WrenchScrewdriverIcon"
          color="amber"
        />
        <DashboardCard
          title="Quilometragem Média"
          description="Km por veículo"
          :value="`${relatorioFrota.quilometragem_media.toLocaleString('pt-BR')} km`"
          :icon="ClockIcon"
          color="purple"
        />
      </div>

      <!-- Gráficos -->
      <div class="grid grid-cols-1 xl:grid-cols-2 gap-8">
        <!-- Veículos por Tipo -->
        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
          <div class="p-6 border-b border-slate-100">
            <h3 class="text-xl font-bold text-slate-900">Veículos por Tipo</h3>
          </div>
          <div class="p-6">
            <div class="space-y-4">
              <div v-for="item in relatorioFrota.veiculos_por_tipo" :key="item.tipo" class="flex items-center justify-between">
                <span class="text-sm font-medium text-slate-700">{{ item.tipo }}</span>
                <div class="flex items-center space-x-3">
                  <div class="w-32 bg-slate-200 rounded-full h-2">
                    <div 
                      class="bg-blue-500 h-2 rounded-full" 
                      :style="{ width: `${item.percentual}%` }"
                    ></div>
                  </div>
                  <span class="text-sm font-semibold text-slate-900">{{ item.quantidade }}</span>
                  <span class="text-xs text-slate-500">({{ item.percentual }}%)</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Custo Médio de Manutenção -->
        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
          <div class="p-6 border-b border-slate-100">
            <h3 class="text-xl font-bold text-slate-900">Custo Médio de Manutenção</h3>
          </div>
          <div class="p-6">
            <div class="text-center">
              <div class="text-4xl font-bold text-blue-600 mb-2">
                R$ {{ relatorioFrota.custo_medio_manutencao.toLocaleString('pt-BR', { minimumFractionDigits: 2 }) }}
              </div>
              <p class="text-slate-600">Por veículo</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Relatório da Oficina -->
    <div v-else-if="filtros.tipo === 'oficina' && relatorioOficina" class="space-y-8">
      <!-- Cards de Resumo -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <DashboardCard
          title="Total de OS"
          description="Ordens no período"
          :value="relatorioOficina.total_ordens"
          :icon="ClipboardDocumentListIcon"
          color="blue"
        />
        <DashboardCard
          title="OS Concluídas"
          description="Finalizadas"
          :value="relatorioOficina.ordens_concluidas"
          :icon="CheckCircleIcon"
          color="green"
        />
        <DashboardCard
          title="Tempo Médio"
          description="Dias para conclusão"
          :value="`${relatorioOficina.tempo_medio_conclusao} dias`"
          :icon="ClockIcon"
          color="amber"
        />
        <DashboardCard
          title="Custo Total"
          description="Pecas + Serviços"
          :value="`R$ ${(relatorioOficina.custo_total_pecas + relatorioOficina.custo_total_servicos_externos).toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`"
          :icon="CurrencyDollarIcon"
          color="purple"
        />
      </div>

      <!-- Gráficos -->
      <div class="grid grid-cols-1 xl:grid-cols-2 gap-8">
        <!-- Produtividade por Supervisor -->
        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
          <div class="p-6 border-b border-slate-100">
            <h3 class="text-xl font-bold text-slate-900">Produtividade por Supervisor</h3>
          </div>
          <div class="p-6">
            <div class="space-y-4">
              <div v-for="item in relatorioOficina.produtividade_por_supervisor" :key="item.supervisor" class="border-b border-slate-100 pb-3 last:border-b-0">
                <div class="flex items-center justify-between mb-2">
                  <span class="font-medium text-slate-900">{{ item.supervisor }}</span>
                  <span class="text-sm text-slate-500">{{ item.ordens_concluidas }} OS</span>
                </div>
                <div class="text-sm text-slate-600">
                  Tempo médio: {{ item.tempo_medio }} dias | 
                  Custo médio: R$ {{ item.custo_medio.toLocaleString('pt-BR', { minimumFractionDigits: 2 }) }}
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- OS por Período -->
        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
          <div class="p-6 border-b border-slate-100">
            <h3 class="text-xl font-bold text-slate-900">OS por Período</h3>
          </div>
          <div class="p-6">
            <div class="space-y-3">
              <div v-for="item in relatorioOficina.ordens_por_periodo" :key="item.data" class="flex items-center justify-between">
                <span class="text-sm text-slate-700">{{ item.data }}</span>
                <div class="flex items-center space-x-4">
                  <span class="text-sm font-medium text-slate-900">{{ item.quantidade }} OS</span>
                  <span class="text-sm text-slate-600">R$ {{ item.valor_total.toLocaleString('pt-BR', { minimumFractionDigits: 2 }) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Relatório do Estoque -->
    <div v-else-if="filtros.tipo === 'estoque' && relatorioEstoque" class="space-y-8">
      <!-- Cards de Resumo -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <DashboardCard
          title="Total de Peças"
          description="No estoque"
          :value="relatorioEstoque.total_pecas"
          :icon="CubeIcon"
          color="blue"
        />
        <DashboardCard
          title="Valor Total"
          description="Do estoque"
          :value="`R$ ${relatorioEstoque.valor_total_estoque.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`"
          :icon="CurrencyDollarIcon"
          color="green"
        />
        <DashboardCard
          title="Estoque Baixo"
          description="Atenção necessária"
          :value="relatorioEstoque.pecas_estoque_baixo"
          :icon="ExclamationTriangleIcon"
          color="red"
        />
        <DashboardCard
          title="Categorias"
          description="Tipos de peças"
          :value="relatorioEstoque.pecas_por_categoria.length"
          :icon="TagIcon"
          color="purple"
        />
      </div>

      <!-- Gráficos -->
      <div class="grid grid-cols-1 xl:grid-cols-2 gap-8">
        <!-- Peças por Categoria -->
        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
          <div class="p-6 border-b border-slate-100">
            <h3 class="text-xl font-bold text-slate-900">Peças por Categoria</h3>
          </div>
          <div class="p-6">
            <div class="space-y-4">
              <div v-for="item in relatorioEstoque.pecas_por_categoria" :key="item.categoria" class="flex items-center justify-between">
                <span class="text-sm font-medium text-slate-700">{{ item.categoria }}</span>
                <div class="flex items-center space-x-3">
                  <span class="text-sm font-semibold text-slate-900">{{ item.quantidade }}</span>
                  <span class="text-xs text-slate-500">R$ {{ item.valor_total.toLocaleString('pt-BR', { minimumFractionDigits: 2 }) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Fornecedores Principais -->
        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
          <div class="p-6 border-b border-slate-100">
            <h3 class="text-xl font-bold text-slate-900">Fornecedores Principais</h3>
          </div>
          <div class="p-6">
            <div class="space-y-4">
              <div v-for="item in relatorioEstoque.fornecedores_principais" :key="item.fornecedor" class="border-b border-slate-100 pb-3 last:border-b-0">
                <div class="flex items-center justify-between mb-2">
                  <span class="font-medium text-slate-900">{{ item.fornecedor }}</span>
                  <span class="text-sm text-slate-500">{{ item.quantidade_pecas }} peças</span>
                </div>
                <div class="text-sm text-slate-600">
                  Valor total: R$ {{ item.valor_total.toLocaleString('pt-BR', { minimumFractionDigits: 2 }) }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Mensagem quando não há dados -->
    <div v-else-if="!isLoading && !error" class="text-center py-12">
      <div class="w-16 h-16 bg-slate-100 rounded-full flex items-center justify-center mx-auto mb-4">
        <DocumentChartBarIcon class="w-8 h-8 text-slate-400" />
      </div>
      <h3 class="text-lg font-medium text-slate-900 mb-2">Nenhum relatório gerado</h3>
      <p class="text-slate-600">Selecione os filtros e clique em "Atualizar" para gerar um relatório.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import {
  ArrowDownTrayIcon,
  ArrowPathIcon,
  ExclamationTriangleIcon,
  TruckIcon,
  CheckCircleIcon,
  WrenchScrewdriverIcon,
  ClipboardDocumentListIcon,
  ClockIcon,
  CurrencyDollarIcon,
  CubeIcon,
  TagIcon,
  DocumentChartBarIcon
} from '@heroicons/vue/24/outline'
import BaseButton from '@/components/ui/BaseButton.vue'
import DashboardCard from '@/components/ui/DashboardCard.vue'
import { useRelatorioFrota, useRelatorioOficina, useRelatorioEstoque, useExportarRelatorio } from '@/features/relatorios/hooks/useRelatorios'
import { supervisorRepository } from '@/services/repositories/supervisorRepository'
import { pecaRepository } from '@/services/repositories/pecaRepository'

// Estado reativo
const exportando = ref(false)
const supervisores = ref<any[]>([])
const fornecedores = ref<string[]>([])

// Filtros principais
const filtros = reactive({
  tipo: 'frota' as 'frota' | 'oficina' | 'estoque',
  periodo_inicio: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
  periodo_fim: new Date().toISOString().split('T')[0]
})

// Filtros específicos por tipo
const filtrosFrota = reactive({
  tipo_veiculo: '',
  status: ''
})

const filtrosOficina = reactive({
  supervisor_id: undefined as number | undefined,
  status: ''
})

const filtrosEstoque = reactive({
  fornecedor: '',
  estoque_baixo: undefined as boolean | undefined
})

// Computed para parâmetros dos relatórios
const paramsFrota = computed(() => ({
  periodo_inicio: filtros.periodo_inicio,
  periodo_fim: filtros.periodo_fim,
  tipo_veiculo: filtrosFrota.tipo_veiculo || undefined,
  status: filtrosFrota.status || undefined
}))

const paramsOficina = computed(() => ({
  periodo_inicio: filtros.periodo_inicio,
  periodo_fim: filtros.periodo_fim,
  supervisor_id: filtrosOficina.supervisor_id,
  status: filtrosOficina.status || undefined
}))

const paramsEstoque = computed(() => ({
  fornecedor: filtrosEstoque.fornecedor || undefined,
  estoque_baixo: filtrosEstoque.estoque_baixo
}))

// Queries dos relatórios
const { data: relatorioFrota, isLoading: loadingFrota, error: errorFrota } = useRelatorioFrota(paramsFrota.value)
const { data: relatorioOficina, isLoading: loadingOficina, error: errorOficina } = useRelatorioOficina(paramsOficina.value)
const { data: relatorioEstoque, isLoading: loadingEstoque, error: errorEstoque } = useRelatorioEstoque(paramsEstoque.value)

// Mutation para exportar
const { mutateAsync: exportarRelatorioAsync } = useExportarRelatorio()

// Computed para estado geral
const currentRelatorio = computed(() => {
  switch (filtros.tipo) {
    case 'frota': return relatorioFrota.value
    case 'oficina': return relatorioOficina.value
    case 'estoque': return relatorioEstoque.value
    default: return null
  }
})

const isLoadingRelatorio = computed(() => {
  switch (filtros.tipo) {
    case 'frota': return loadingFrota.value
    case 'oficina': return loadingOficina.value
    case 'estoque': return loadingEstoque.value
    default: return false
  }
})

const errorRelatorio = computed(() => {
  switch (filtros.tipo) {
    case 'frota': return errorFrota.value
    case 'oficina': return errorOficina.value
    case 'estoque': return errorEstoque.value
    default: return null
  }
})

// Computed para estado geral da UI
const isLoading = computed(() => isLoadingRelatorio.value)
const error = computed(() => errorRelatorio.value?.message || null)

// Funções
const mudarTipoRelatorio = () => {
  // Resetar filtros específicos ao mudar tipo
  Object.assign(filtrosFrota, { tipo_veiculo: '', status: '' })
  Object.assign(filtrosOficina, { supervisor_id: undefined, status: '' })
  Object.assign(filtrosEstoque, { fornecedor: '', estoque_baixo: undefined })
}

const gerarRelatorio = () => {
  // Os relatórios são gerados automaticamente quando os filtros mudam
  // devido aos computed properties
}

const atualizarRelatorios = () => {
  // Forçar refresh das queries
  window.location.reload()
}

const exportarRelatorio = async () => {
  if (!currentRelatorio.value) return

  try {
    exportando.value = true
    
    const blob = await exportarRelatorioAsync({
      tipo: filtros.tipo,
      dados: currentRelatorio.value,
      formato: 'csv' // Por enquanto apenas CSV
    })

    // Download do arquivo
    const url = window.URL.createObjectURL(blob as Blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `relatorio-${filtros.tipo}-${new Date().toISOString().split('T')[0]}.csv`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
      } catch (err) {
      console.error('Erro ao exportar relatório:', err)
      // error é computed, não pode ser modificado diretamente
    } finally {
      exportando.value = false
    }
}

const carregarDadosAuxiliares = async () => {
  try {
    // Carregar supervisores
    const supervisoresData = await supervisorRepository.findAll()
    supervisores.value = supervisoresData || []

    // Carregar fornecedores únicos
    const pecasData = await pecaRepository.findAll()
    const fornecedoresUnicos = [...new Set(pecasData?.map(p => p.fornecedor).filter((f): f is string => Boolean(f)) || [])]
    fornecedores.value = fornecedoresUnicos
  } catch (err) {
    console.error('Erro ao carregar dados auxiliares:', err)
  }
}

// Carregar dados quando o componente for montado
onMounted(() => {
  carregarDadosAuxiliares()
})
</script>
