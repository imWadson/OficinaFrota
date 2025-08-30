<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-semibold text-gray-900">Oficinas Externas</h1>
        <p class="mt-1 text-sm text-gray-500">
          Gestão de oficinas terceirizadas parceiras
        </p>
      </div>
      <BaseButton @click="mostrarModal = true">
        Nova Oficina
      </BaseButton>
    </div>

    <div class="card">
      <div v-if="oficinasExternas.isLoading.value" class="text-center py-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
        <p class="mt-2 text-sm text-gray-500">Carregando oficinas...</p>
      </div>
      
      <div v-else-if="oficinasExternas.data.value?.length === 0" class="text-center py-8">
        <p class="text-gray-500">Nenhuma oficina externa cadastrada</p>
      </div>
      
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Nome
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                CNPJ
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Contato
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Telefone
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Ações
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="oficina in oficinasExternas.data.value" :key="oficina.id">
              <td class="px-6 py-4 whitespace-nowrap">
                <div>
                  <div class="text-sm font-medium text-gray-900">{{ oficina.nome }}</div>
                  <div class="text-sm text-gray-500">{{ oficina.endereco || '-' }}</div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatCNPJ(oficina.cnpj) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ oficina.contato || '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ oficina.telefone || '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <button 
                  @click="editarOficina(oficina)"
                  class="text-primary-600 hover:text-primary-900 mr-3"
                >
                  Editar
                </button>
                <button 
                  @click="excluirOficina(oficina.id)"
                  class="text-red-600 hover:text-red-900"
                >
                  Excluir
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal Criar/Editar Oficina -->
    <div v-if="mostrarModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-lg mx-4">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-medium text-gray-900">
            {{ oficinaEditando ? 'Editar Oficina' : 'Nova Oficina' }}
          </h3>
          <button @click="fecharModal" class="text-gray-400 hover:text-gray-600">✕</button>
        </div>
        
        <form @submit.prevent="salvarOficina" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Nome *</label>
            <input
              v-model="form.nome"
              type="text"
              required
              placeholder="Nome da oficina"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">CNPJ *</label>
            <input
              v-model="form.cnpj"
              type="text"
              required
              placeholder="00.000.000/0000-00"
              @input="formatarCNPJ"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Endereço</label>
            <input
              v-model="form.endereco"
              type="text"
              placeholder="Endereço completo"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Telefone</label>
            <input
              v-model="form.telefone"
              type="text"
              placeholder="(11) 99999-9999"
              @input="formatarTelefone"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Contato</label>
            <input
              v-model="form.contato"
              type="text"
              placeholder="Nome do responsável"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            />
          </div>

          <div v-if="errorMessage" class="p-3 rounded-lg bg-red-50 border border-red-200">
            <p class="text-sm text-red-800">{{ errorMessage }}</p>
          </div>

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
              :loading="salvando"
            >
              {{ oficinaEditando ? 'Salvar' : 'Cadastrar' }}
            </BaseButton>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useOficinasExternas } from '../features/oficinas-externas/hooks/useOficinasExternas'
import BaseButton from '../shared/ui/BaseButton.vue'
import type { OficinaExterna } from '../services/repositories/oficinasExternasRepository'

const { oficinasExternas, createOficina, updateOficina, deleteOficina } = useOficinasExternas()

// Estados
const mostrarModal = ref(false)
const salvando = ref(false)
const errorMessage = ref('')
const oficinaEditando = ref<OficinaExterna | null>(null)

const form = reactive({
  nome: '',
  cnpj: '',
  endereco: '',
  telefone: '',
  contato: ''
})

// Funções
function fecharModal() {
  mostrarModal.value = false
  oficinaEditando.value = null
  errorMessage.value = ''
  Object.assign(form, {
    nome: '',
    cnpj: '',
    endereco: '',
    telefone: '',
    contato: ''
  })
}

function editarOficina(oficina: OficinaExterna) {
  oficinaEditando.value = oficina
  Object.assign(form, {
    nome: oficina.nome,
    cnpj: oficina.cnpj,
    endereco: oficina.endereco || '',
    telefone: oficina.telefone || '',
    contato: oficina.contato || ''
  })
  mostrarModal.value = true
}

async function salvarOficina() {
  salvando.value = true
  errorMessage.value = ''

  try {
    const dados = {
      nome: form.nome.trim(),
      cnpj: form.cnpj.replace(/\D/g, ''),
      endereco: form.endereco.trim() || undefined,
      telefone: form.telefone.replace(/\D/g, '') || undefined,
      contato: form.contato.trim() || undefined
    }

    if (oficinaEditando.value) {
      await updateOficina.mutateAsync({ id: oficinaEditando.value.id, data: dados })
    } else {
      await createOficina.mutateAsync(dados)
    }

    fecharModal()
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Erro ao salvar oficina'
  } finally {
    salvando.value = false
  }
}

async function excluirOficina(id: number) {
  if (!confirm('Tem certeza que deseja excluir esta oficina?')) return

  try {
    await deleteOficina.mutateAsync(id)
  } catch (error) {
    alert('Erro ao excluir oficina')
  }
}

// Formatação
function formatarCNPJ() {
  let value = form.cnpj.replace(/\D/g, '')
  value = value.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5')
  form.cnpj = value
}

function formatarTelefone() {
  let value = form.telefone.replace(/\D/g, '')
  if (value.length <= 10) {
    value = value.replace(/^(\d{2})(\d{4})(\d{4})/, '($1) $2-$3')
  } else {
    value = value.replace(/^(\d{2})(\d{5})(\d{4})/, '($1) $2-$3')
  }
  form.telefone = value
}

function formatCNPJ(cnpj: string) {
  return cnpj.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5')
}
</script>
