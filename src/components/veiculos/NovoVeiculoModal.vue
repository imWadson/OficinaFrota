<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    @click="closeModal"
  >
    <div
      class="bg-white rounded-2xl p-6 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto"
      @click.stop
    >
      <!-- Header -->
      <div class="flex items-center justify-between mb-6">
        <div>
          <h3 class="text-2xl font-bold text-slate-900">Novo Veículo</h3>
          <p class="text-slate-600">Cadastre um novo veículo na frota</p>
        </div>
        <button
          @click="closeModal"
          class="text-slate-400 hover:text-slate-600 transition-colors"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Alertas de erro/sucesso -->
      <div v-if="errorMessage" class="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
        <div class="flex">
          <svg class="w-5 h-5 text-red-400 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
          </svg>
          <span class="text-red-800">{{ errorMessage }}</span>
        </div>
      </div>

      <!-- Formulário -->
      <form @submit.prevent="salvarVeiculo" class="space-y-6">
        <!-- Informações Básicas -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Placa *
            </label>
            <input
              v-model="form.placa"
              type="text"
              required
              class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="ABC-1234"
              :class="{ 'border-red-500': errors.placa }"
            />
            <p v-if="errors.placa" class="mt-1 text-sm text-red-600">{{ errors.placa }}</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Regional *
            </label>
            <select
              v-model="form.regional_id"
              required
              class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              :class="{ 'border-red-500': errors.regional_id }"
            >
              <option value="">Selecione a regional</option>
              <option 
                v-for="regional in regionaisDisponiveis" 
                :key="regional.id" 
                :value="regional.id"
              >
                {{ regional.nome }}
              </option>
            </select>
            <p v-if="errors.regional_id" class="mt-1 text-sm text-red-600">{{ errors.regional_id }}</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Modelo *
            </label>
            <input
              v-model="form.modelo"
              type="text"
              required
              class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Fiat Strada"
              :class="{ 'border-red-500': errors.modelo }"
            />
            <p v-if="errors.modelo" class="mt-1 text-sm text-red-600">{{ errors.modelo }}</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Tipo *
            </label>
            <select
              v-model="form.tipo"
              required
              class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              :class="{ 'border-red-500': errors.tipo }"
            >
              <option value="">Selecione o tipo</option>
              <option value="carro">Carro</option>
              <option value="caminhao">Caminhão</option>
              <option value="van">Van</option>
              <option value="moto">Moto</option>
              <option value="onibus">Ônibus</option>
              <option value="caminhonete">Caminhonete</option>
            </select>
            <p v-if="errors.tipo" class="mt-1 text-sm text-red-600">{{ errors.tipo }}</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Ano de Fabricação *
            </label>
            <input
              v-model="form.ano"
              type="number"
              required
              min="1980"
              :max="new Date().getFullYear() + 1"
              class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="2020"
              :class="{ 'border-red-500': errors.ano }"
            />
            <p v-if="errors.ano" class="mt-1 text-sm text-red-600">{{ errors.ano }}</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Quilometragem Atual
            </label>
            <input
              v-model="form.quilometragem"
              type="number"
              min="0"
              class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="45000"
              :class="{ 'border-red-500': errors.quilometragem }"
            />
            <p v-if="errors.quilometragem" class="mt-1 text-sm text-red-600">{{ errors.quilometragem }}</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Status *
            </label>
            <select
              v-model="form.status"
              required
              class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              :class="{ 'border-red-500': errors.status }"
            >
              <option value="">Selecione o status</option>
              <option value="ativo">Ativo</option>
              <option value="manutencao">Em Manutenção</option>
              <option value="inativo">Inativo</option>
            </select>
            <p v-if="errors.status" class="mt-1 text-sm text-red-600">{{ errors.status }}</p>
          </div>
        </div>

        <!-- Botões -->
        <div class="flex items-center justify-end space-x-4 pt-6 border-t border-slate-200">
          <button
            type="button"
            @click="closeModal"
            class="px-6 py-3 border border-slate-300 rounded-lg text-slate-700 hover:bg-slate-50 transition-colors"
          >
            Cancelar
          </button>
          <button
            type="submit"
            :disabled="isLoading"
            class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            <span v-if="isLoading" class="flex items-center">
              <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Salvando...
            </span>
            <span v-else>Salvar Veículo</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, watch, computed } from 'vue'
import { veiculoRepository } from '@/services/repositories/veiculoRepository'
import { useAuth } from '@/composables/useAuth'
import { useUserContext } from '@/composables/useUserContext'
import { supabase } from '@/services/supabase'
import type { VeiculoInsert } from '@/entities/veiculo'
import { ESTADOS } from '@/entities/rbac'

interface Props {
  isOpen: boolean
}

interface Emits {
  (e: 'close'): void
  (e: 'saved', veiculo: any): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

// Autenticação e contexto do usuário
const { user } = useAuth()
const { canViewAllRegionais, fetchUserData } = useUserContext()

// Estado do formulário
const form = reactive({
  placa: '',
  modelo: '',
  tipo: '',
  ano: '',
  quilometragem: '',
  status: '' as 'ativo' | 'manutencao' | 'inativo' | '',
  regional_id: ''
})

// Estado para dados do usuário
const userData = ref<any>(null)

// Computed properties
const regionaisDisponiveis = computed(() => {
  // Se o usuário pode ver todas as regionais, mostrar todas
  if (canViewAllRegionais.value) {
    return ESTADOS.flatMap(estado => estado.regionais)
  }
  
  // Caso contrário, mostrar apenas a regional do usuário
  if (userData.value?.regional_id) {
    const userRegional = ESTADOS
      .flatMap(estado => estado.regionais)
      .find(regional => regional.id === userData.value.regional_id)
    
    return userRegional ? [userRegional] : []
  }
  
  return []
})

const isLoading = ref(false)
const errorMessage = ref('')
const errors = reactive({
  placa: '',
  modelo: '',
  tipo: '',
  ano: '',
  quilometragem: '',
  status: '',
  regional_id: ''
})

// Métodos
const closeModal = () => {
  emit('close')
}

const resetForm = () => {
  Object.assign(form, {
    placa: '',
    modelo: '',
    tipo: '',
    ano: '',
    quilometragem: '',
    status: '',
    regional_id: ''
  })
  
  // Limpar erros
  Object.keys(errors).forEach(key => {
    (errors as any)[key] = ''
  })
  
  errorMessage.value = ''
}

const validarFormulario = (): boolean => {
  let isValid = true
  
  // Limpar erros anteriores
  Object.keys(errors).forEach(key => {
    (errors as any)[key] = ''
  })
  
  // Validações
  if (!form.placa.trim()) {
    errors.placa = 'Placa é obrigatória'
    isValid = false
  } else if (form.placa.length > 10) {
    errors.placa = 'Placa muito longa (máx. 10 caracteres)'
    isValid = false
  }
  
  if (!form.modelo.trim()) {
    errors.modelo = 'Modelo é obrigatório'
    isValid = false
  }
  
  if (!form.tipo) {
    errors.tipo = 'Tipo é obrigatório'
    isValid = false
  }
  
  if (!form.ano) {
    errors.ano = 'Ano é obrigatório'
    isValid = false
  } else {
    const ano = parseInt(form.ano)
    if (ano < 1980 || ano > new Date().getFullYear() + 1) {
      errors.ano = 'Ano deve estar entre 1980 e ' + (new Date().getFullYear() + 1)
      isValid = false
    }
  }
  
  if (form.quilometragem && parseInt(form.quilometragem) < 0) {
    errors.quilometragem = 'Quilometragem deve ser >= 0'
    isValid = false
  }
  
  if (!form.status) {
    errors.status = 'Status é obrigatório'
    isValid = false
  }
  
  if (!form.regional_id) {
    errors.regional_id = 'Regional é obrigatória'
    isValid = false
  }
  
  // Verificar se usuário está logado
  if (!user.value) {
    errorMessage.value = 'Usuário não está logado. Faça login novamente.'
    isValid = false
  }
  
  return isValid
}

const salvarVeiculo = async () => {
  try {
    // Validar formulário
    if (!validarFormulario()) {
      return
    }
    
    // Verificar se usuário está logado
    if (!user.value) {
      errorMessage.value = 'Usuário não está logado. Faça login novamente.'
      return
    }
    
    isLoading.value = true
    errorMessage.value = ''
    
    // Buscar o ID do usuário na tabela usuarios
    let usuarioId: string | null = null
    
    try {
      const { data: usuarioData, error: usuarioError } = await supabase
        .from('usuarios')
        .select('id')
        .eq('auth_user_id', user.value.id)
      
      if (usuarioError) {
        throw new Error('Erro ao buscar usuário: ' + usuarioError.message)
      }
      
      if (!usuarioData || usuarioData.length === 0) {
        throw new Error('Usuário não encontrado na tabela usuarios')
      }
      
      usuarioId = usuarioData[0].id
    } catch (error) {
      console.error('Erro ao buscar usuário:', error)
      errorMessage.value = 'Erro ao identificar usuário. Faça login novamente.'
      return
    }
    
    if (!usuarioId) {
      errorMessage.value = 'Usuário não encontrado. Faça login novamente.'
      return
    }
    
    // Preparar dados para o Supabase com criado_por
    const veiculoData = {
      placa: form.placa.trim().toUpperCase(),
      modelo: form.modelo.trim(),
      tipo: form.tipo,
      ano: parseInt(form.ano),
      quilometragem: form.quilometragem ? parseInt(form.quilometragem) : 0,
      status: form.status as 'ativo' | 'manutencao' | 'inativo',
      regional_id: form.regional_id,
      criado_por: usuarioId
    }
    
    // Salvar no Supabase usando supabase diretamente para incluir criado_por
    const { data: veiculoSalvo, error: createError } = await supabase
      .from('veiculos')
      .insert(veiculoData)
      .select()
      .single()
    
    if (createError) {
      throw createError
    }
    
    // Emitir evento de sucesso
    emit('saved', veiculoSalvo)
    
    // Resetar formulário e fechar modal
    resetForm()
    closeModal()
    
  } catch (error: any) {
    console.error('Erro ao salvar veículo:', error)
    
    // Tratar erros específicos do Supabase
    if (error.code === '23505') {
      errorMessage.value = 'Já existe um veículo com esta placa.'
    } else if (error.message) {
      errorMessage.value = `Erro ao salvar: ${error.message}`
    } else {
      errorMessage.value = 'Erro ao salvar veículo. Tente novamente.'
    }
  } finally {
    isLoading.value = false
  }
}

// Carregar dados do usuário quando modal abrir
watch(() => props.isOpen, async (newValue) => {
  if (newValue) {
    resetForm()
    
    // Carregar dados do usuário
    try {
      const data = await fetchUserData()
      userData.value = data
      
      // Se o usuário só pode ver sua regional, pré-selecionar
      if (data?.regional_id && !canViewAllRegionais.value) {
        form.regional_id = data.regional_id
      }
    } catch (error) {
      console.error('Erro ao carregar dados do usuário:', error)
      // Em caso de erro, tentar usar dados do auth store
      const { userRegional } = useAuth()
      if (userRegional.value?.id && !canViewAllRegionais.value) {
        form.regional_id = userRegional.value.id
      }
    }
  }
})
</script>
