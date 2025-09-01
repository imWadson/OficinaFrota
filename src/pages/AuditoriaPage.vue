<template>
  <div class="space-y-8">
    <!-- Header da Página -->
    <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between">
      <div class="mb-6 lg:mb-0">
        <div class="flex items-center space-x-4 mb-2">
          <div class="w-1 h-12 bg-gradient-to-b from-blue-500 to-blue-600 rounded-full"></div>
          <div>
            <h1 class="text-3xl lg:text-4xl font-bold text-slate-900 tracking-tight">Auditoria</h1>
            <p class="text-lg text-slate-600 font-medium">
              Logs de todas as ações do sistema
            </p>
          </div>
        </div>
      </div>
      <div class="flex flex-col sm:flex-row gap-4">
        <BaseButton 
          variant="outline" 
          size="lg"
          :icon="ArrowDownTrayIcon"
          @click="handleExportarAuditoria"
          :loading="exportarAuditoria.isPending"
        >
          Exportar CSV
        </BaseButton>
        <BaseButton 
          variant="outline" 
          size="lg"
          :icon="TrashIcon"
          @click="handleLimparAuditoriaAntiga"
          :loading="limparAuditoriaAntiga.isPending"
        >
          Limpar Antiga
        </BaseButton>
        <BaseButton 
          variant="primary" 
          size="lg"
          :icon="ArrowPathIcon"
          @click="atualizarAuditoria"
        >
          Atualizar
        </BaseButton>
      </div>
    </div>

    <!-- Filtros -->
    <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 p-6">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Usuário</label>
          <select
            v-model="filtros.usuario_id"
            @change="aplicarFiltros"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Todos os usuários</option>
            <option v-for="usuario in usuarios" :key="usuario.id" :value="usuario.id">
              {{ usuario.nome }}
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Ação</label>
          <select
            v-model="filtros.acao"
            @change="aplicarFiltros"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Todas as ações</option>
            <option v-for="acao in acoes" :key="acao" :value="acao">
              {{ formatarAcao(acao) }}
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Entidade</label>
          <select
            v-model="filtros.entidade"
            @change="aplicarFiltros"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Todas as entidades</option>
            <option v-for="entidade in entidades" :key="entidade" :value="entidade">
              {{ formatarEntidade(entidade) }}
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Data Início</label>
          <input
            v-model="filtros.data_inicio"
            type="date"
            @change="aplicarFiltros"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">Data Fim</label>
          <input
            v-model="filtros.data_fim"
            type="date"
            @change="aplicarFiltros"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <div class="md:col-span-2">
          <label class="block text-sm font-medium text-slate-700 mb-2">Limite de registros</label>
          <select
            v-model="filtros.limit"
            @change="aplicarFiltros"
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option :value="50">50 registros</option>
            <option :value="100">100 registros</option>
            <option :value="250">250 registros</option>
            <option :value="500">500 registros</option>
            <option :value="1000">1000 registros</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="auditoria.isLoading || auditoria.isFetching" class="flex items-center justify-center py-12">
      <div class="text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
        <p class="text-slate-600">Carregando logs de auditoria...</p>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="auditoria.error && !auditoria.isLoading" class="bg-red-50 border border-red-200 rounded-xl p-6">
      <div class="flex items-center">
        <ExclamationTriangleIcon class="w-6 h-6 text-red-500 mr-3" />
        <div>
          <h3 class="text-lg font-semibold text-red-800">Erro ao carregar auditoria</h3>
          <p class="text-red-600">{{ (auditoria.error as any)?.message || 'Erro desconhecido' }}</p>
        </div>
      </div>
      <BaseButton 
        variant="outline" 
        size="sm"
        class="mt-4"
        @click="atualizarAuditoria"
      >
        Tentar novamente
      </BaseButton>
    </div>

    <!-- Tabela de Auditoria -->
    <div v-else-if="auditoria.data && Array.isArray(auditoria.data) && auditoria.data.length > 0 && !auditoria.isLoading" class="space-y-6">
      <!-- Estatísticas -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-6">
        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 p-6">
          <div class="flex items-center">
            <div class="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
              <ClipboardDocumentListIcon class="w-6 h-6 text-blue-600" />
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-slate-600">Total de Ações</p>
              <p class="text-2xl font-bold text-slate-900">{{ Array.isArray(auditoria.data) ? auditoria.data.length : 0 }}</p>
            </div>
          </div>
        </div>
        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 p-6">
          <div class="flex items-center">
            <div class="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
              <UsersIcon class="w-6 h-6 text-green-600" />
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-slate-600">Usuários Ativos</p>
              <p class="text-2xl font-bold text-slate-900">{{ usuariosUnicos }}</p>
            </div>
          </div>
        </div>
        <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 p-6">
          <div class="flex items-center">
            <div class="w-12 h-12 bg-purple-100 rounded-xl flex items-center justify-center">
              <CubeIcon class="w-6 h-6 text-purple-600" />
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-slate-600">Entidades</p>
              <p class="text-2xl font-bold text-slate-900">{{ entidadesUnicas }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabela -->
      <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-slate-200">
            <thead class="bg-slate-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                  Usuário
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                  Ação
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                  Entidade
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                  ID Entidade
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                  IP
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                  Data/Hora
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                  Detalhes
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-slate-200">
              <tr v-for="log in (Array.isArray(auditoria.data) ? auditoria.data : [])" :key="log?.id || Math.random()" class="hover:bg-slate-50">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                      <span class="text-sm font-medium text-blue-800">
                        {{ getIniciais(log?.usuarios?.nome) }}
                      </span>
                    </div>
                    <div class="ml-3">
                      <div class="text-sm font-medium text-slate-900">
                        {{ log?.usuarios?.nome || 'Usuário Desconhecido' }}
                      </div>
                      <div class="text-sm text-slate-500">
                        {{ log?.usuarios?.email || 'N/A' }}
                      </div>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
                    :class="getClasseAcao(log?.acao)"
                  >
                    {{ formatarAcao(log?.acao) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="text-sm text-slate-900">
                    {{ formatarEntidade(log?.entidade) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-500">
                  {{ log?.entidade_id || 'N/A' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-500">
                  {{ log?.ip_address || 'N/A' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-500">
                  {{ formatarData(log?.criada_em) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <BaseButton
                    v-if="log?.dados_anteriores || log?.dados_novos"
                    variant="outline"
                    size="sm"
                    @click="verDetalhes(log)"
                  >
                    Ver
                  </BaseButton>
                  <span v-else class="text-slate-400">-</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Paginação -->
      <div class="flex items-center justify-between">
        <div class="text-sm text-slate-700">
          Mostrando {{ Array.isArray(auditoria.data) ? auditoria.data.length : 0 }} registros
        </div>
        <div class="flex items-center space-x-2">
          <BaseButton
            variant="outline"
            size="sm"
            :disabled="!filtros.offset || filtros.offset <= 0"
            @click="anteriorPagina"
          >
            Anterior
          </BaseButton>
          <BaseButton
            variant="outline"
            size="sm"
            :disabled="(Array.isArray(auditoria.data) ? auditoria.data.length : 0) < (filtros.limit || 50)"
            @click="proximaPagina"
          >
            Próxima
          </BaseButton>
        </div>
      </div>
    </div>

    <!-- Mensagem quando não há dados -->
    <div v-else-if="auditoria.data && Array.isArray(auditoria.data) && auditoria.data.length === 0 && !auditoria.isLoading" class="text-center py-12">
      <div class="w-16 h-16 bg-slate-100 rounded-full flex items-center justify-center mx-auto mb-4">
        <ClipboardDocumentListIcon class="w-8 h-8 text-slate-400" />
      </div>
      <h3 class="text-lg font-medium text-slate-900 mb-2">Nenhum log encontrado</h3>
      <p class="text-slate-600">Tente ajustar os filtros ou verificar se há dados de auditoria.</p>
    </div>

    <!-- Modal de Detalhes -->
    <div
      v-if="modalDetalhes"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click="modalDetalhes = false"
    >
      <div
        class="bg-white rounded-2xl p-6 max-w-2xl w-full mx-4 max-h-96 overflow-y-auto"
        @click.stop
      >
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold text-slate-900">Detalhes da Auditoria</h3>
          <button
            @click="modalDetalhes = false"
            class="text-slate-400 hover:text-slate-600"
          >
            <XMarkIcon class="w-6 h-6" />
          </button>
        </div>
        
        <div v-if="logSelecionado" class="space-y-4">
          <div>
            <h4 class="font-medium text-slate-900 mb-2">Dados Anteriores</h4>
            <pre v-if="logSelecionado.dados_anteriores" class="bg-slate-100 p-3 rounded-lg text-sm overflow-x-auto">
              {{ JSON.stringify(logSelecionado.dados_anteriores, null, 2) }}
            </pre>
            <p v-else class="text-slate-500">Nenhum dado anterior</p>
          </div>
          
          <div>
            <h4 class="font-medium text-slate-900 mb-2">Dados Novos</h4>
            <pre v-if="logSelecionado.dados_novos" class="bg-slate-100 p-3 rounded-lg text-sm overflow-x-auto">
              {{ JSON.stringify(logSelecionado.dados_novos, null, 2) }}
            </pre>
            <p v-else class="text-slate-500">Nenhum dado novo</p>
          </div>
          
          <div v-if="logSelecionado.contexto">
            <h4 class="font-medium text-slate-900 mb-2">Contexto</h4>
            <pre class="bg-slate-100 p-3 rounded-lg text-sm overflow-x-auto">
              {{ logSelecionado.contexto }}
            </pre>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import {
  ArrowDownTrayIcon,
  ArrowPathIcon,
  TrashIcon,
  ExclamationTriangleIcon,
  ClipboardDocumentListIcon,
  UsersIcon,
  CubeIcon,
  XMarkIcon
} from '@heroicons/vue/24/outline'
import BaseButton from '@/components/ui/BaseButton.vue'
import { useAuditoria } from '@/features/auditoria/hooks/useAuditoria'
import { AcaoAuditoria, EntidadeAuditoria, type AuditoriaFiltros } from '@/entities/auditoria'
import { useQuery } from '@tanstack/vue-query'
import { auditoriaService } from '@/services/auditoriaService'

// Estado reativo
const modalDetalhes = ref(false)
const logSelecionado = ref<any>(null)

// Filtros
const filtros = reactive({
  usuario_id: undefined as number | undefined,
  acao: '',
  entidade: '',
  data_inicio: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
  data_fim: new Date().toISOString().split('T')[0],
  limit: 100,
  offset: 0
})

// Hook de auditoria
const { auditoria, exportarAuditoria, limparAuditoriaAntiga } = useAuditoria()

// Dados auxiliares
const usuarios = ref<Array<{ id: number; nome: string; email: string }>>([])
const acoes = Object.values(AcaoAuditoria)
const entidades = Object.values(EntidadeAuditoria)

// Computed
const usuariosUnicos = computed(() => {
  if (!auditoria.data || !Array.isArray(auditoria.data)) return 0
  return new Set(auditoria.data.map((log: any) => log.usuario_id)).size
})

const entidadesUnicas = computed(() => {
  if (!auditoria.data || !Array.isArray(auditoria.data)) return 0
  return new Set(auditoria.data.map((log: any) => log.entidade)).size
})

// Funções
const aplicarFiltros = () => {
  // Resetar offset ao aplicar novos filtros
  filtros.offset = 0
  // Refetch da query com novos filtros
  if (auditoria.refetch) {
    auditoria.refetch()
  }
}

const atualizarAuditoria = () => {
  if (auditoria.refetch) {
    auditoria.refetch()
  }
}

const handleExportarAuditoria = async () => {
  try {
    if (exportarAuditoria.mutateAsync) {
      await exportarAuditoria.mutateAsync(filtros)
    }
  } catch (err) {
    console.error('Erro ao exportar auditoria:', err)
  }
}

const handleLimparAuditoriaAntiga = async () => {
  if (!confirm('Tem certeza que deseja limpar a auditoria antiga? Esta ação não pode ser desfeita.')) {
    return
  }

  try {
    if (limparAuditoriaAntiga.mutateAsync) {
      await limparAuditoriaAntiga.mutateAsync()
    }
  } catch (err) {
    console.error('Erro ao limpar auditoria antiga:', err)
  }
}

const anteriorPagina = () => {
  if (filtros.offset > 0) {
    filtros.offset = Math.max(0, filtros.offset - (filtros.limit || 50))
    if (auditoria.refetch) {
      auditoria.refetch()
    }
  }
}

const proximaPagina = () => {
  filtros.offset += filtros.limit || 50
  if (auditoria.refetch) {
    auditoria.refetch()
  }
}

const verDetalhes = (log: any) => {
  if (log) {
    logSelecionado.value = log
    modalDetalhes.value = true
  }
}

const formatarAcao = (acao: string | null | undefined): string => {
  if (!acao) return 'N/A'
  const acoes = {
    'CREATE': 'Criar',
    'READ': 'Ler',
    'UPDATE': 'Atualizar',
    'DELETE': 'Excluir',
    'LOGIN': 'Login',
    'LOGOUT': 'Logout',
    'LOGIN_FAILED': 'Login Falhou',
    'PASSWORD_CHANGE': 'Alterar Senha',
    'PASSWORD_RESET': 'Resetar Senha'
  }
  return acoes[acao as keyof typeof acoes] || acao
}

const formatarEntidade = (entidade: string | null | undefined): string => {
  if (!entidade) return 'N/A'
  const entidades = {
    'usuario': 'Usuário',
    'supervisor': 'Supervisor',
    'veiculo': 'Veículo',
    'ordem_servico': 'Ordem de Serviço',
    'peca': 'Peça',
    'peca_usada': 'Peça Usada',
    'servico_externo': 'Serviço Externo',
    'oficina_externa': 'Oficina Externa',
    'relatorio': 'Relatório',
    'notificacao': 'Notificação',
    'configuracao': 'Configuração',
    'sistema': 'Sistema'
  }
  return entidades[entidade as keyof typeof entidades] || entidade
}

const getClasseAcao = (acao: string | null | undefined): string => {
  if (!acao) return 'bg-gray-100 text-gray-800'
  if (acao.includes('CREATE')) return 'bg-green-100 text-green-800'
  if (acao.includes('UPDATE')) return 'bg-blue-100 text-blue-800'
  if (acao.includes('DELETE')) return 'bg-red-100 text-red-800'
  if (acao.includes('LOGIN')) return 'bg-purple-100 text-purple-800'
  if (acao.includes('LOGOUT')) return 'bg-slate-100 text-slate-800'
  return 'bg-gray-100 text-gray-800'
}

const formatarData = (data: string | null | undefined): string => {
  if (!data) return 'N/A'
  try {
    return new Date(data).toLocaleString('pt-BR')
  } catch {
    return 'Data inválida'
  }
}

const getIniciais = (nome: string | null | undefined): string => {
  if (!nome) return 'N/A'
  return nome
    .split(' ')
    .map(n => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
}

// Carregar dados quando o componente for montado
onMounted(() => {
  // Em uma implementação real, carregaríamos os usuários aqui
  // Por enquanto, vamos usar dados fictícios
  usuarios.value = [
    { id: 1, nome: 'João Silva', email: 'joao@exemplo.com' },
    { id: 2, nome: 'Maria Santos', email: 'maria@exemplo.com' }
  ]
})
</script>
