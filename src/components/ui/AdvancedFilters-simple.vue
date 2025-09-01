<template>
  <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
    <!-- Header dos Filtros -->
    <div class="p-4 border-b border-gray-100 bg-gradient-to-r from-slate-50 to-gray-50">
      <div class="flex items-center justify-between">
        <div class="flex items-center space-x-3">
          <FunnelIcon class="w-5 h-5 text-gray-600" />
          <h3 class="text-lg font-semibold text-gray-900">Filtros</h3>
        </div>
        
        <div class="flex items-center space-x-2">
          <button
            @click="toggleExpanded"
            class="text-sm text-gray-600 hover:text-gray-900 font-medium flex items-center space-x-1"
          >
            <span>{{ isExpanded ? 'Recolher' : 'Expandir' }}</span>
            <ChevronDownIcon 
              class="w-4 h-4 transition-transform duration-200"
              :class="{ 'rotate-180': isExpanded }"
            />
          </button>
          
          <button
            @click="clearFilters"
            class="text-sm text-red-600 hover:text-red-700 font-medium hover:underline"
          >
            Limpar
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros Expandidos -->
    <div v-if="isExpanded" class="p-6 space-y-6">
      <!-- Grid de Filtros -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div v-for="filter in activeFilters" :key="filter.key">
          <label class="block text-sm font-medium text-gray-700 mb-2">{{ filter.label }}</label>
          
          <!-- Select para opções -->
          <select
            v-if="filter.type === 'select'"
            v-model="filters[filter.key]"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          >
            <option value="">{{ filter.placeholder || 'Todos' }}</option>
            <option
              v-for="option in filter.options"
              :key="option.value"
              :value="option.value"
            >
              {{ option.label }}
            </option>
          </select>

          <!-- Input para texto -->
          <input
            v-else-if="filter.type === 'text'"
            v-model="filters[filter.key]"
            type="text"
            :placeholder="filter.placeholder"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          />

          <!-- Input para data -->
          <input
            v-else-if="filter.type === 'date'"
            v-model="filters[filter.key]"
            type="date"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
          />
        </div>
      </div>

      <!-- Botões de Ação -->
      <div class="flex justify-end space-x-3 pt-4 border-t border-gray-100">
        <button
          @click="applyFilters"
          class="px-4 py-2 bg-amber-600 text-white rounded-lg hover:bg-amber-700 focus:ring-2 focus:ring-amber-500"
        >
          Aplicar Filtros
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { FunnelIcon, ChevronDownIcon } from '@heroicons/vue/24/outline'

// Props
interface FilterOption {
  value: string | number
  label: string
}

interface FilterConfig {
  key: string
  label: string
  type: 'select' | 'text' | 'date'
  options?: FilterOption[]
  placeholder?: string
}

interface Props {
  filterConfigs: FilterConfig[]
  modelValue?: Record<string, any>
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: () => ({})
})

// Emits
const emit = defineEmits<{
  'update:modelValue': [value: Record<string, any>]
  'filters-changed': [filters: Record<string, any>]
}>()

// Estado
const isExpanded = ref(false)
const filters = ref<Record<string, any>>({ ...props.modelValue })

// Computed
const activeFilters = computed(() => props.filterConfigs)

// Métodos
const toggleExpanded = () => {
  isExpanded.value = !isExpanded.value
}

const clearFilters = () => {
  filters.value = {}
  emit('update:modelValue', {})
  emit('filters-changed', {})
}

const applyFilters = () => {
  emit('update:modelValue', { ...filters.value })
  emit('filters-changed', { ...filters.value })
}

// Watchers
watch(filters, (newFilters) => {
  emit('update:modelValue', { ...newFilters })
}, { deep: true })

watch(() => props.modelValue, (newValue) => {
  filters.value = { ...newValue }
}, { deep: true })
</script>
