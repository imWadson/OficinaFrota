<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-semibold text-gray-900">
          OS #{{ $route.params.id }}
        </h1>
        <p class="mt-1 text-sm text-gray-500">
          Detalhes e edição da ordem de serviço
        </p>
      </div>
      <router-link 
        to="/ordens-servico"
        class="text-gray-500 hover:text-gray-700"
      >
        ← Voltar
      </router-link>
    </div>

    <!-- Loading -->
    <div v-if="ordemServico.isLoading.value" class="text-center py-8">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
      <p class="mt-2 text-sm text-gray-500">Carregando ordem de serviço...</p>
    </div>

    <!-- Erro -->
    <div v-else-if="ordemServico.error.value" class="card">
      <div class="text-center py-8">
        <p class="text-red-600">Erro ao carregar ordem de serviço</p>
        <p class="text-sm text-gray-500 mt-2">{{ ordemServico.error.value.message }}</p>
      </div>
    </div>

    <!-- Conteúdo -->
    <div v-else-if="os" class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      
      <!-- Informações Principais -->
      <div class="lg:col-span-2 space-y-6">
        
        <!-- Dados da OS -->
        <div class="card">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-medium text-gray-900">Informações da OS</h3>
            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                  :class="getStatusClass(os.status)">
              {{ getStatusText(os.status) }}
            </span>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <dt class="text-sm font-medium text-gray-500">Veículo</dt>
              <dd class="mt-1 text-sm text-gray-900">
                {{ os.veiculos?.placa }} - {{ os.veiculos?.modelo }}
              </dd>
            </div>
            
            <div>
              <dt class="text-sm font-medium text-gray-500">Data de Entrada</dt>
              <dd class="mt-1 text-sm text-gray-900">
                {{ formatDate(os.data_entrada) }}
              </dd>
            </div>
            
            <div v-if="os.data_saida">
              <dt class="text-sm font-medium text-gray-500">Data de Saída</dt>
              <dd class="mt-1 text-sm text-gray-900">
                {{ formatDate(os.data_saida) }}
              </dd>
            </div>
            
            <div v-if="os.criador">
              <dt class="text-sm font-medium text-gray-500">Criador da OS</dt>
              <dd class="mt-1 text-sm text-gray-900">
                {{ os.criador?.nome }} ({{ os.criador?.email }})
              </dd>
            </div>
          </div>
        </div>

        <!-- Problema e Diagnóstico -->
        <div class="card">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Problema e Diagnóstico</h3>
          
          <div class="space-y-4">
            <div>
              <dt class="text-sm font-medium text-gray-500">Problema Reportado</dt>
              <dd class="mt-1 text-sm text-gray-900 bg-gray-50 p-3 rounded-lg">
                {{ os.problema_reportado }}
              </dd>
            </div>
            
            <div>
              <dt class="text-sm font-medium text-gray-500">Diagnóstico</dt>
              <dd class="mt-1">
                <textarea
                  v-model="diagnostico"
                  rows="4"
                  placeholder="Descreva o diagnóstico e solução aplicada..."
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                  :disabled="os.status === 'concluida'"
                ></textarea>
              </dd>
            </div>
            
            <div v-if="os.status !== 'concluida'" class="flex justify-end">
              <BaseButton 
                @click="salvarDiagnostico"
                :loading="salvandoDiagnostico"
                variant="secondary"
                size="sm"
              >
                Salvar Diagnóstico
              </BaseButton>
            </div>
          </div>
        </div>

        <!-- Serviços Externos -->
        <div class="card">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-medium text-gray-900">Serviços Externos</h3>
            <BaseButton 
              v-if="os.status !== 'concluida' && os.status !== 'cancelada'"
              @click="mostrarModalOficina = true"
              size="sm"
              variant="warning"
            >
Enviar para Oficina
            </BaseButton>
          </div>
          
          <!-- Lista de Serviços Externos -->
          <div v-if="servicosExternos.isLoading.value" class="text-center py-4">
            <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600 mx-auto"></div>
          </div>
          
          <div v-else-if="servicosExternos.data.value?.length === 0" class="text-center py-6 text-gray-500">
            Nenhum serviço externo cadastrado
          </div>
          
          <div v-else class="space-y-3">
            <div 
              v-for="servico in servicosExternos.data.value" 
              :key="servico.id"
              class="border rounded-lg p-4"
              :class="servico.data_retorno ? 'bg-green-50 border-green-200' : 'bg-yellow-50 border-yellow-200'"
            >
              <div class="flex justify-between items-start">
                <div class="flex-1">
                  <div class="flex items-center space-x-2 mb-2">
                    <span class="font-medium text-gray-900">{{ servico.oficinas_externas?.nome }}</span>
                    <span 
                      class="px-2 py-1 text-xs rounded-full"
                      :class="servico.data_retorno ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'"
                    >
                      {{ servico.data_retorno ? 'Finalizado' : 'Em andamento' }}
                    </span>
                  </div>
                  <p class="text-sm text-gray-600 mb-2">{{ servico.descricao }}</p>
                  <div class="text-sm text-gray-500">
                    <span>Enviado: {{ format(new Date(servico.data_envio), 'dd/MM/yyyy', { locale: ptBR }) }}</span>
                    <span v-if="servico.data_retorno" class="ml-4">
                      Retornado: {{ format(new Date(servico.data_retorno), 'dd/MM/yyyy', { locale: ptBR }) }}
                    </span>
                    <span class="ml-4 font-medium">Valor: R$ {{ servico.valor.toFixed(2) }}</span>
                  </div>
                </div>
                
                <div class="flex space-x-2 ml-4">
                  <button 
                    v-if="!servico.data_retorno"
                    @click="finalizarServicoExterno(servico.id)"
                    class="text-green-600 hover:text-green-800 text-sm"
                    title="Marcar como finalizado"
                  >
Finalizar
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Peças Utilizadas -->
        <div class="card">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-medium text-gray-900">Peças Utilizadas</h3>
            <BaseButton 
              v-if="os.status !== 'concluida'"
              @click="mostrarModalPecas = true"
              size="sm"
            >
              + Adicionar Peça
            </BaseButton>
          </div>
          
          <!-- Lista de Peças -->
          <div v-if="pecasUsadas.isLoading.value" class="text-center py-4">
            <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600 mx-auto"></div>
          </div>
          
          <div v-else-if="pecasUsadas.data.value?.length === 0" class="text-center py-8 text-gray-500">
            Nenhuma peça utilizada nesta OS
          </div>
          
          <div v-else class="space-y-3">
            <div 
              v-for="pecaUsada in pecasUsadas.data.value" 
              :key="pecaUsada.id"
              class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
            >
              <div class="flex-1">
                <div class="flex items-center space-x-2">
                  <span class="font-medium text-gray-900">{{ pecaUsada.pecas?.nome }}</span>
                  <span class="text-xs bg-gray-200 px-2 py-1 rounded">{{ pecaUsada.pecas?.codigo }}</span>
                </div>
                <div class="text-sm text-gray-500 mt-1">
                  Quantidade: {{ pecaUsada.quantidade }} • 
                  Custo unitário: R$ {{ pecaUsada.pecas?.custo_unitario.toFixed(2) }} •
                  Total: R$ {{ (pecaUsada.quantidade * (pecaUsada.pecas?.custo_unitario || 0)).toFixed(2) }}
                </div>
              </div>
              
              <button 
                v-if="os.status !== 'concluida'"
                @click="removerPecaUsada(pecaUsada.id)"
                class="text-red-600 hover:text-red-800 ml-3"
                title="Remover peça"
              >
Remover
              </button>
            </div>
          </div>
          
          <!-- Total de Peças -->
          <div v-if="pecasUsadas.data.value?.length > 0" class="border-t pt-3 mt-4">
            <div class="flex justify-between text-sm font-medium">
              <span>Total em peças:</span>
              <span>R$ {{ totalPecas.toFixed(2) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="space-y-6">
        
        <!-- Ações -->
        <div class="card" v-if="os.status !== 'concluida' && os.status !== 'cancelada'">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Ações</h3>
          
          <div class="space-y-3">
            <BaseButton 
              @click="mostrarModalStatus = true"
              variant="primary"
              class="w-full"
            >
              🔄 Mudar Status
            </BaseButton>
            
            <BaseButton 
              v-if="os.status === 'em_andamento'"
              @click="concluirOS"
              :loading="concluindo"
              class="w-full"
            >
              ✅ Concluir OS
            </BaseButton>
            
            <BaseButton 
              @click="cancelarOS"
              :loading="cancelando"
              variant="secondary"
              class="w-full"
            >
              ❌ Cancelar OS
            </BaseButton>
          </div>
        </div>

        <!-- Resumo -->
        <div class="card">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Resumo</h3>
          
          <div class="space-y-2 text-sm">
            <div class="flex justify-between">
              <span class="text-gray-500">Status:</span>
              <span class="font-medium">{{ getStatusText(os.status) }}</span>
            </div>
            
            <div class="flex justify-between">
              <span class="text-gray-500">Tempo na oficina:</span>
              <span class="font-medium">{{ tempoNaOficina }}</span>
            </div>
            
            <div class="flex justify-between">
              <span class="text-gray-500">Peças utilizadas:</span>
              <span class="font-medium">{{ pecasUsadas.data.value?.length || 0 }} itens</span>
            </div>
            
            <div class="flex justify-between">
              <span class="text-gray-500">Custo total:</span>
              <span class="font-medium">R$ {{ totalPecas.toFixed(2) }}</span>
            </div>
          </div>
        </div>

        <!-- Histórico de Status -->
        <StatusHistory 
          :ordem-servico-id="osId"
          :status-atual="os.status"
        />
      </div>
    </div>

    <!-- Modal Enviar para Oficina Externa -->
    <div v-if="mostrarModalOficina" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-lg mx-4">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-medium text-gray-900">Enviar para Oficina Externa</h3>
          <button @click="fecharModalOficina" class="text-gray-400 hover:text-gray-600">✕</button>
        </div>
        
        <form @submit.prevent="enviarOSParaOficina" class="space-y-4">
          <!-- Oficina -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Oficina *</label>
            <div class="space-y-2">
              <select 
                v-model="formOficina.oficina_externa_id"
                v-if="!formOficina.nova_oficina"
                :disabled="oficinasExternas.isLoading.value"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                required
              >
                <option value="">Selecione uma oficina</option>
                <option 
                  v-for="oficina in oficinasExternas.data.value" 
                  :key="oficina.id" 
                  :value="oficina.id"
                >
                  {{ oficina.nome }}
                </option>
              </select>
              
              <button 
                type="button"
                @click="formOficina.nova_oficina = !formOficina.nova_oficina"
                class="text-sm text-primary-600 hover:text-primary-800"
              >
                {{ formOficina.nova_oficina ? '← Selecionar oficina existente' : '+ Cadastrar nova oficina' }}
              </button>
            </div>
          </div>

          <!-- Campos para Nova Oficina -->
          <div v-if="formOficina.nova_oficina" class="space-y-3 p-3 bg-gray-50 rounded-lg">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nome da Oficina *</label>
              <input
                v-model="formOficina.nome_oficina"
                type="text"
                required
                placeholder="Nome da oficina"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">CNPJ *</label>
                <input
                  v-model="formOficina.cnpj_oficina"
                  type="text"
                  required
                  placeholder="00.000.000/0000-00"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Telefone</label>
                <input
                  v-model="formOficina.telefone_oficina"
                  type="text"
                  placeholder="(11) 99999-9999"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Contato</label>
              <input
                v-model="formOficina.contato_oficina"
                type="text"
                placeholder="Nome do responsável"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
          </div>

          <!-- Descrição do Serviço -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Descrição do Serviço *</label>
            <textarea
              v-model="formOficina.descricao"
              rows="3"
              required
              placeholder="Descreva o serviço que será realizado..."
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            ></textarea>
          </div>

          <!-- Valor Estimado -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Valor Estimado (R$) *</label>
            <input
              v-model.number="formOficina.valor"
              type="number"
              min="0"
              step="0.01"
              required
              placeholder="0,00"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            />
          </div>

          <!-- Erro -->
          <div v-if="errorOficina" class="p-3 rounded-lg bg-red-50 border border-red-200">
            <p class="text-sm text-red-800">{{ errorOficina }}</p>
          </div>

          <!-- Botões -->
          <div class="flex justify-end space-x-3 pt-4 border-t">
            <BaseButton 
              type="button" 
              variant="secondary"
              @click="fecharModalOficina"
            >
              Cancelar
            </BaseButton>
            <BaseButton 
              type="submit" 
              :loading="enviandoParaOficina"
              variant="warning"
            >
Enviar
            </BaseButton>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Adicionar Peça -->
    <div v-if="mostrarModalPecas" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-medium text-gray-900">Adicionar Peça</h3>
          <button @click="fecharModal" class="text-gray-400 hover:text-gray-600">✕</button>
        </div>
        
        <form @submit.prevent="adicionarPecaUsada" class="space-y-4">
          <!-- Seleção da Peça -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Peça *</label>
            <select 
              v-model="formPeca.peca_id" 
              :disabled="pecas.isLoading.value"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              required
            >
              <option value="">Selecione uma peça</option>
              <option 
                v-for="peca in pecasComEstoque" 
                :key="peca.id" 
                :value="peca.id"
              >
                {{ peca.codigo }} - {{ peca.nome }} (Estoque: {{ peca.quantidade_estoque }})
              </option>
            </select>
          </div>

          <!-- Quantidade -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Quantidade *</label>
            <input
              v-model.number="formPeca.quantidade"
              type="number"
              min="1"
              :max="pecaSelecionada?.quantidade_estoque || 999"
              placeholder="Digite a quantidade"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              required
            />
            <p v-if="pecaSelecionada" class="mt-1 text-xs text-gray-500">
              Estoque disponível: {{ pecaSelecionada.quantidade_estoque }}
            </p>
          </div>

          <!-- Erro -->
          <div v-if="errorPeca" class="p-3 rounded-lg bg-red-50 border border-red-200">
            <p class="text-sm text-red-800">{{ errorPeca }}</p>
          </div>

          <!-- Botões -->
          <div class="flex justify-end space-x-3 pt-4 border-t">
            <BaseButton 
              type="button" 
              variant="secondary"
              @click="fecharModal"
            >
              Cancelar
            </BaseButton>
            <BaseButton 
              type="submit" 
              :loading="adicionandoPeca"
              :disabled="!formPeca.peca_id || !formPeca.quantidade"
            >
              Adicionar
            </BaseButton>
          </div>
        </form>
      </div>
         </div>

     <!-- Modal Mudar Status -->
     <StatusChangeModal
       :is-open="mostrarModalStatus"
       :ordem-servico-id="osId"
       :status-atual="os?.status || ''"
       @close="mostrarModalStatus = false"
       @success="mostrarModalStatus = false"
     />
   </div>
 </template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useOrdemServico } from '../features/ordens-servico/hooks/useOrdensServico'
import { useSupervisores } from '../features/supervisores/hooks/useSupervisores'
import { usePecas } from '../features/estoque/hooks/usePecas'
import { usePecasUsadas } from '../features/estoque/hooks/usePecasUsadas'
import { useOficinasExternas } from '../features/oficinas-externas/hooks/useOficinasExternas'
import { useServicosExternos } from '../features/oficinas-externas/hooks/useServicosExternos'
import BaseButton from '../shared/ui/BaseButton.vue'
import StatusHistory from '../components/ui/StatusHistory.vue'
import StatusChangeModal from '../components/ui/StatusChangeModal.vue'
import { format, differenceInDays, differenceInHours } from 'date-fns'
import { ptBR } from 'date-fns/locale'

const route = useRoute()
const osId = route.params.id as string

const { ordemServico, updateOrdemServico } = useOrdemServico(osId)
const { supervisores } = useSupervisores()
const { pecas } = usePecas()
const { pecasUsadas, adicionarPeca, removerPeca } = usePecasUsadas(osId)
const { oficinasExternas, createOficina } = useOficinasExternas()
const { servicosExternos, enviarParaOficina, finalizarServico } = useServicosExternos(osId)

// Estados
const diagnostico = ref('')
const salvandoDiagnostico = ref(false)
const concluindo = ref(false)
const cancelando = ref(false)

// Estados do modal de peças
const mostrarModalPecas = ref(false)
const adicionandoPeca = ref(false)
const errorPeca = ref('')
const formPeca = ref({
  peca_id: '',
  quantidade: 1
})

// Estados do modal de oficina externa
const mostrarModalOficina = ref(false)
const enviandoParaOficina = ref(false)
const errorOficina = ref('')
const formOficina = ref({
  oficina_externa_id: '',
  descricao: '',
  valor: 0,
  // Campos para nova oficina
  nova_oficina: false,
  nome_oficina: '',
  cnpj_oficina: '',
  telefone_oficina: '',
  contato_oficina: ''
})

// Estados do modal de status
const mostrarModalStatus = ref(false)

// Computed
const os = computed(() => ordemServico.data.value)

const tempoNaOficina = computed(() => {
  if (!os.value) return '-'
  
  const entrada = new Date(os.value.data_entrada)
  const saida = os.value.data_saida ? new Date(os.value.data_saida) : new Date()
  
  const dias = differenceInDays(saida, entrada)
  const horas = differenceInHours(saida, entrada)
  
  if (dias > 0) {
    return `${dias} dia${dias > 1 ? 's' : ''}`
  } else {
    return `${horas} hora${horas > 1 ? 's' : ''}`
  }
})

// Computeds para peças
const pecasComEstoque = computed(() => {
  return pecas.data.value?.filter(p => p.quantidade_estoque > 0) || []
})

const pecaSelecionada = computed(() => {
  if (!formPeca.value.peca_id) return null
  return pecas.data.value?.find(p => p.id === Number(formPeca.value.peca_id))
})

const totalPecas = computed(() => {
  if (!pecasUsadas.data.value) return 0
  return pecasUsadas.data.value.reduce((total, pu) => {
    return total + (pu.quantidade * (pu.pecas?.custo_unitario || 0))
  }, 0)
})

// Watchers
import { watch } from 'vue'
watch(() => os.value?.diagnostico, (newDiagnostico) => {
  if (newDiagnostico) {
    diagnostico.value = newDiagnostico
  }
}, { immediate: true })

// Functions
function getStatusClass(status: string) {
  switch (status) {
    case 'em_andamento':
      return 'bg-yellow-100 text-yellow-800'
    case 'concluida':
      return 'bg-green-100 text-green-800'
    case 'cancelada':
      return 'bg-red-100 text-red-800'
    case 'oficina_externa':
      return 'bg-purple-100 text-purple-800'
    case 'aguardando_peca':
      return 'bg-orange-100 text-orange-800'
    case 'diagnostico':
      return 'bg-blue-100 text-blue-800'
    case 'aguardando_aprovacao':
      return 'bg-indigo-100 text-indigo-800'
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
    case 'oficina_externa':
      return 'Oficina Externa'
    case 'aguardando_peca':
      return 'Aguardando Peça'
    case 'diagnostico':
      return 'Diagnóstico'
    case 'aguardando_aprovacao':
      return 'Aguardando Aprovação'
    default:
      return status
  }
}

function formatDate(dateString: string) {
  return format(new Date(dateString), 'dd/MM/yyyy HH:mm', { locale: ptBR })
}

async function salvarDiagnostico() {
  if (!diagnostico.value.trim()) return
  
  salvandoDiagnostico.value = true
  
  try {
    await updateOrdemServico.mutateAsync({
      diagnostico: diagnostico.value.trim()
    })
  } catch (error) {
    alert('Erro ao salvar diagnóstico')
  } finally {
    salvandoDiagnostico.value = false
  }
}

async function concluirOS() {
  if (!diagnostico.value.trim()) {
    alert('Adicione um diagnóstico antes de concluir a OS')
    return
  }
  
  concluindo.value = true
  
  try {
    await updateOrdemServico.mutateAsync({
      status: 'concluida',
      data_saida: new Date().toISOString(),
      diagnostico: diagnostico.value.trim()
    })
  } catch (error) {
    alert('Erro ao concluir OS')
  } finally {
    concluindo.value = false
  }
}

async function cancelarOS() {
  if (!confirm('Tem certeza que deseja cancelar esta OS?')) return
  
  cancelando.value = true
  
  try {
    await updateOrdemServico.mutateAsync({
      status: 'cancelada'
    })
  } catch (error) {
    alert('Erro ao cancelar OS')
  } finally {
    cancelando.value = false
  }
}

// Funções para peças
function fecharModal() {
  mostrarModalPecas.value = false
  errorPeca.value = ''
  formPeca.value = {
    peca_id: '',
    quantidade: 1
  }
}

async function adicionarPecaUsada() {
  if (!formPeca.value.peca_id || !formPeca.value.quantidade) return
  
  adicionandoPeca.value = true
  errorPeca.value = ''
  
  try {
    await adicionarPeca.mutateAsync({
      ordem_servico_id: osId,
      peca_id: Number(formPeca.value.peca_id),
      quantidade: formPeca.value.quantidade
    })
    
    fecharModal()
  } catch (error) {
    errorPeca.value = error instanceof Error ? error.message : 'Erro ao adicionar peça'
  } finally {
    adicionandoPeca.value = false
  }
}

async function removerPecaUsada(id: number) {
  if (!confirm('Tem certeza que deseja remover esta peça? O estoque será revertido.')) return
  
  try {
    await removerPeca.mutateAsync(id)
  } catch (error) {
    alert('Erro ao remover peça')
  }
}

// Funções para oficina externa
function fecharModalOficina() {
  mostrarModalOficina.value = false
  errorOficina.value = ''
  formOficina.value = {
    oficina_externa_id: '',
    descricao: '',
    valor: 0,
    nova_oficina: false,
    nome_oficina: '',
    cnpj_oficina: '',
    telefone_oficina: '',
    contato_oficina: ''
  }
}

async function enviarOSParaOficina() {
  enviandoParaOficina.value = true
  errorOficina.value = ''
  
  try {
    let oficinaId = formOficina.value.oficina_externa_id

    // Se é nova oficina, cadastrar primeiro
    if (formOficina.value.nova_oficina) {
      const novaOficina = await createOficina.mutateAsync({
        nome: formOficina.value.nome_oficina.trim(),
        cnpj: formOficina.value.cnpj_oficina.replace(/\D/g, ''),
        telefone: formOficina.value.telefone_oficina.replace(/\D/g, '') || undefined,
        contato: formOficina.value.contato_oficina.trim() || undefined
      })
      oficinaId = String(novaOficina.id)
    }

    await enviarParaOficina.mutateAsync({
      ordem_servico_id: osId,
      oficina_externa_id: Number(oficinaId),
      descricao: formOficina.value.descricao.trim(),
      valor: formOficina.value.valor
    })
    
    fecharModalOficina()
  } catch (error) {
    errorOficina.value = error instanceof Error ? error.message : 'Erro ao enviar para oficina'
  } finally {
    enviandoParaOficina.value = false
  }
}

async function finalizarServicoExterno(id: number) {
  if (!confirm('Marcar este serviço como finalizado?')) return
  
  try {
    await finalizarServico.mutateAsync({ id })
  } catch (error) {
    alert('Erro ao finalizar serviço')
  }
}
</script>
