<template>
  <div class="space-y-8">
    <!-- Header da Página -->
    <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between">
      <div class="mb-6 lg:mb-0">
        <div class="flex items-center space-x-4 mb-2">
          <div class="w-1 h-12 bg-gradient-to-b from-blue-500 to-blue-600 rounded-full"></div>
          <div>
            <h1 class="text-3xl lg:text-4xl font-bold text-slate-900 tracking-tight">Gestão de supervisores e coordenadores</h1>
          </div>
        </div>
      </div>
      <div class="flex flex-col sm:flex-row gap-4">
        <BaseButton 
          variant="primary" 
          size="lg"
          :icon="PlusIcon"
          @click="openCreateModal"
        >
          Novo Supervisor
        </BaseButton>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="flex items-center justify-center py-12">
      <div class="text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
        <p class="text-slate-600">Carregando supervisores...</p>
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
        @click="loadSupervisores"
      >
        Tentar novamente
      </BaseButton>
    </div>

    <!-- Content -->
    <div v-else>
      <!-- Filtros e Busca -->
      <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 p-6 mb-8">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">Buscar</label>
            <input
              v-model="searchTerm"
              type="text"
              placeholder="Nome, email ou matrícula..."
              class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">Cargo</label>
            <select
              v-model="filterCargo"
              class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="">Todos os cargos</option>
              <option value="Supervisor">Supervisor</option>
              <option value="Coordenador">Coordenador</option>
              <option value="Gerente">Gerente</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">Status</label>
            <select
              v-model="filterStatus"
              class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="">Todos</option>
              <option value="ativo">Ativo</option>
              <option value="inativo">Inativo</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Tabela de Supervisores -->
      <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full">
            <thead class="bg-slate-50 border-b border-slate-200">
              <tr>
                <th class="px-6 py-4 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">
                  Supervisor
                </th>
                <th class="px-6 py-4 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">
                  Cargo
                </th>
                <th class="px-6 py-4 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">
                  Regional
                </th>
                <th class="px-6 py-4 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">
                  Status
                </th>
                <th class="px-6 py-4 text-left text-xs font-semibold text-slate-600 uppercase tracking-wider">
                  Ações
                </th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-200">
              <tr v-for="supervisor in filteredSupervisores" :key="supervisor.id" class="hover:bg-slate-50">
                <td class="px-6 py-4">
                  <div class="flex items-center">
                    <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center mr-4">
                      <span class="text-white font-bold text-sm">{{ getInitials(supervisor.nome) }}</span>
                    </div>
                    <div>
                      <p class="text-sm font-semibold text-slate-900">{{ supervisor.nome }}</p>
                      <p class="text-xs text-slate-500">{{ supervisor.email }}</p>
                      <p class="text-xs text-slate-400">Matrícula: {{ supervisor.matricula }}</p>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4">
                  <span :class="[
                    'px-3 py-1 text-xs font-semibold rounded-full',
                    getCargoClass(supervisor.cargo)
                  ]">
                    {{ supervisor.cargo }}
                  </span>
                </td>
                <td class="px-6 py-4">
                  <p class="text-sm text-slate-900">{{ supervisor.regional?.nome || 'N/A' }}</p>
                  <p class="text-xs text-slate-500">{{ supervisor.regional?.estado?.nome || '' }}</p>
                </td>
                                 <td class="px-6 py-4">
                   <span :class="[
                     'px-3 py-1 text-xs font-semibold rounded-full',
                     supervisor.ativo ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                   ]">
                     {{ supervisor.ativo ? 'Ativo' : 'Inativo' }}
                   </span>
                 </td>
                <td class="px-6 py-4">
                  <div class="flex items-center space-x-2">
                    <button
                      @click="editSupervisor(supervisor)"
                      class="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                      title="Editar"
                    >
                      <PencilIcon class="w-4 h-4" />
                    </button>
                    <button
                      @click="toggleStatus(supervisor)"
                      :class="[
                        'p-2 rounded-lg transition-colors',
                        supervisor.ativo 
                          ? 'text-slate-400 hover:text-red-600 hover:bg-red-50' 
                          : 'text-slate-400 hover:text-green-600 hover:bg-green-50'
                      ]"
                      :title="supervisor.ativo ? 'Desativar' : 'Ativar'"
                    >
                      <component :is="supervisor.ativo ? XMarkIcon : CheckIcon" class="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Empty State -->
        <div v-if="filteredSupervisores.length === 0" class="text-center py-12">
          <UsersIcon class="w-16 h-16 text-slate-300 mx-auto mb-4" />
          <p class="text-slate-500 font-medium">Nenhum supervisor encontrado</p>
          <p class="text-sm text-slate-400 mt-2">Tente ajustar os filtros ou adicionar um novo supervisor</p>
        </div>
      </div>
    </div>

    <!-- Modal de Criação/Edição -->
    <SupervisorModal
      v-if="showModal"
      :supervisor="editingSupervisor"
      :is-editing="!!editingSupervisor"
      @close="closeModal"
      @save="handleSave"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import {
  PlusIcon,
  PencilIcon,
  XMarkIcon,
  CheckIcon,
  UsersIcon,
  ExclamationTriangleIcon
} from '@heroicons/vue/24/outline'
import BaseButton from '@/components/ui/BaseButton.vue'
import SupervisorModal from '@/components/supervisores/SupervisorModal.vue'
import { SupervisorService } from '@/services/supervisorService'

// Estado reativo
const isLoading = ref(true)
const error = ref<string | null>(null)
const supervisores = ref<any[]>([])
const searchTerm = ref('')
const filterCargo = ref('')
const filterStatus = ref('')
const showModal = ref(false)
const editingSupervisor = ref<any>(null)

// Computed
const filteredSupervisores = computed(() => {
  return supervisores.value.filter(supervisor => {
    const matchesSearch = !searchTerm.value || 
      supervisor.nome.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
      supervisor.email.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
      supervisor.matricula.includes(searchTerm.value)
    
    const matchesCargo = !filterCargo.value || supervisor.cargo === filterCargo.value
    const matchesStatus = !filterStatus.value || 
      (filterStatus.value === 'ativo' && supervisor.ativo) ||
      (filterStatus.value === 'inativo' && !supervisor.ativo)
    
    return matchesSearch && matchesCargo && matchesStatus
  })
})

// Funções utilitárias
const getInitials = (name: string): string => {
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
}

const getCargoClass = (cargo: string): string => {
  const classMap: Record<string, string> = {
    'Supervisor': 'bg-blue-100 text-blue-800',
    'Coordenador': 'bg-purple-100 text-purple-800',
    'Gerente': 'bg-green-100 text-green-800'
  }
  return classMap[cargo] || 'bg-gray-100 text-gray-800'
}

// Funções de carregamento
const loadSupervisores = async () => {
  try {
    isLoading.value = true
    error.value = null
    supervisores.value = await SupervisorService.getAll()
  } catch (err) {
    console.error('Erro ao carregar supervisores:', err)
    error.value = 'Erro ao carregar supervisores. Tente novamente.'
  } finally {
    isLoading.value = false
  }
}

// Funções do modal
const openCreateModal = () => {
  editingSupervisor.value = null
  showModal.value = true
}

const editSupervisor = (supervisor: any) => {
  editingSupervisor.value = { ...supervisor }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingSupervisor.value = null
}

const handleSave = async (supervisorData: any) => {
  try {
    if (editingSupervisor.value) {
      await SupervisorService.update(editingSupervisor.value.id, supervisorData)
    } else {
      await SupervisorService.create(supervisorData)
    }
    
    await loadSupervisores()
    closeModal()
  } catch (err) {
    console.error('Erro ao salvar supervisor:', err)
    // O modal deve tratar o erro
  }
}

const toggleStatus = async (supervisor: any) => {
  try {
    const newAtivo = !supervisor.ativo
    await SupervisorService.update(supervisor.id, { ativo: newAtivo })
    await loadSupervisores()
  } catch (err) {
    console.error('Erro ao alterar status:', err)
  }
}

// Carregar dados quando o componente for montado
onMounted(() => {
  loadSupervisores()
})
</script>
