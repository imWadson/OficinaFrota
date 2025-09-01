<template>
  <div class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex items-center justify-center min-h-screen px-4 pt-4 pb-20 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div class="fixed inset-0 transition-opacity bg-black/50 backdrop-blur-sm" @click="$emit('close')"></div>

      <!-- Modal panel -->
      <div class="inline-block w-full max-w-2xl p-6 my-8 overflow-hidden text-left align-middle transition-all transform bg-white shadow-2xl rounded-2xl">
        <!-- Header -->
        <div class="flex items-center justify-between mb-6">
          <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
              <UsersIcon class="w-6 h-6 text-white" />
            </div>
            <div>
              <h3 class="text-xl font-bold text-slate-900">
                {{ isEditing ? 'Editar Supervisor' : 'Novo Supervisor' }}
              </h3>
              <p class="text-sm text-slate-500">
                {{ isEditing ? 'Atualize as informações do supervisor' : 'Preencha as informações do novo supervisor' }}
              </p>
            </div>
          </div>
          <button
            @click="$emit('close')"
            class="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-lg transition-colors"
          >
            <XMarkIcon class="w-5 h-5" />
          </button>
        </div>

        <!-- Form -->
        <form @submit.prevent="handleSubmit" class="space-y-6">
          <!-- Nome -->
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Nome Completo *
            </label>
            <input
              v-model="form.nome"
              type="text"
              required
              class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
              placeholder="Digite o nome completo"
            />
          </div>

          <!-- Email -->
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Email *
            </label>
            <input
              v-model="form.email"
              type="email"
              required
              class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
              placeholder="Digite o email"
            />
          </div>

          <!-- Matrícula -->
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Matrícula *
            </label>
            <input
              v-model="form.matricula"
              type="text"
              required
              class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
              placeholder="Digite a matrícula"
            />
          </div>

                     <!-- Cargo -->
           <div>
             <label class="block text-sm font-medium text-slate-700 mb-2">
               Cargo *
             </label>
             <select
               v-model="form.cargo_id"
               required
               class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
             >
               <option value="">Selecione o cargo</option>
               <option v-for="cargo in cargos" :key="cargo.id" :value="cargo.id">
                 {{ cargo.nome }}
               </option>
             </select>
           </div>

          <!-- Regional -->
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Regional *
            </label>
            <select
              v-model="form.regional_id"
              required
              class="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
            >
              <option value="">Selecione a regional</option>
              <option v-for="regional in regionais" :key="regional.id" :value="regional.id">
                {{ regional.nome }} - {{ regional.estado?.nome }}
              </option>
            </select>
          </div>

                     <!-- Status -->
           <div>
             <label class="block text-sm font-medium text-slate-700 mb-2">
               Status
             </label>
             <div class="flex items-center space-x-4">
               <label class="flex items-center">
                 <input
                   v-model="form.ativo"
                   type="radio"
                   :value="true"
                   class="w-4 h-4 text-blue-600 border-slate-300 focus:ring-blue-500"
                 />
                 <span class="ml-2 text-sm text-slate-700">Ativo</span>
               </label>
               <label class="flex items-center">
                 <input
                   v-model="form.ativo"
                   type="radio"
                   :value="false"
                   class="w-4 h-4 text-blue-600 border-slate-300 focus:ring-blue-500"
                 />
                 <span class="ml-2 text-sm text-slate-700">Inativo</span>
               </label>
             </div>
           </div>

          <!-- Error Message -->
          <div v-if="error" class="bg-red-50 border border-red-200 rounded-lg p-4">
            <div class="flex items-center">
              <ExclamationTriangleIcon class="w-5 h-5 text-red-500 mr-2" />
              <p class="text-red-700">{{ error }}</p>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex items-center justify-end space-x-4 pt-6 border-t border-slate-200">
            <BaseButton
              type="button"
              variant="outline"
              @click="$emit('close')"
            >
              Cancelar
            </BaseButton>
            <BaseButton
              type="submit"
              variant="primary"
              :loading="isSubmitting"
            >
              {{ isEditing ? 'Atualizar' : 'Criar' }}
            </BaseButton>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { UsersIcon, XMarkIcon, ExclamationTriangleIcon } from '@heroicons/vue/24/outline'
import BaseButton from '@/components/ui/BaseButton.vue'
import { RegionalService } from '@/services/regionalService'
import { supabase } from '@/services/supabase'

interface Props {
  supervisor?: any
  isEditing?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  isEditing: false
})

const emit = defineEmits<{
  close: []
  save: [data: any]
}>()

// Estado reativo
const isSubmitting = ref(false)
const error = ref<string | null>(null)
const regionais = ref<any[]>([])
const cargos = ref<any[]>([])

// Formulário
const form = reactive({
  nome: '',
  email: '',
  matricula: '',
  cargo_id: '',
  regional_id: '',
  ativo: true
})

// Carregar regionais
const loadRegionais = async () => {
  try {
    regionais.value = await RegionalService.getAll()
  } catch (err) {
    console.error('Erro ao carregar regionais:', err)
  }
}

// Carregar cargos do setor Operação
const loadCargos = async () => {
  try {
    // Buscar todos os cargos
    const { data: cargosData } = await supabase
      .from('cargos')
      .select('id, nome, setor_id')
      .order('nome')

    if (cargosData) {
      // Buscar setores
      const { data: setoresData } = await supabase
        .from('setores')
        .select('id, sigla')

      if (setoresData) {
        // Filtrar apenas cargos do setor Operação
        const cargosOperacao = cargosData.filter(cargo => {
          const setor = setoresData.find(s => s.id === cargo.setor_id)
          return setor?.sigla === 'OPERACAO'
        })

        cargos.value = cargosOperacao
      }
    }
  } catch (err) {
    console.error('Erro ao carregar cargos:', err)
  }
}

// Preencher formulário quando editar
const fillForm = () => {
  if (props.supervisor) {
    form.nome = props.supervisor.nome || ''
    form.email = props.supervisor.email || ''
    form.matricula = props.supervisor.matricula || ''
    form.cargo_id = props.supervisor.cargo_id || ''
    form.regional_id = props.supervisor.regional_id || ''
    form.ativo = props.supervisor.ativo ?? true
  }
}

// Handle submit
const handleSubmit = async () => {
  try {
    isSubmitting.value = true
    error.value = null

    // Validar campos obrigatórios
    if (!form.nome || !form.email || !form.matricula || !form.cargo_id || !form.regional_id) {
      error.value = 'Todos os campos obrigatórios devem ser preenchidos'
      return
    }

    // Validar email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(form.email)) {
      error.value = 'Digite um email válido'
      return
    }

    // Emitir evento de save
    emit('save', { ...form })
  } catch (err) {
    console.error('Erro ao salvar supervisor:', err)
    error.value = 'Erro ao salvar supervisor. Tente novamente.'
  } finally {
    isSubmitting.value = false
  }
}

// Watch para preencher formulário quando supervisor mudar
watch(() => props.supervisor, fillForm, { immediate: true })

// Carregar dados quando componente for montado
onMounted(() => {
  loadRegionais()
  loadCargos()
  fillForm()
})
</script>
