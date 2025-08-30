<template>
  <div class="bg-white shadow rounded-lg overflow-hidden">
    <!-- Header da Tabela -->
    <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h3 class="text-lg font-medium text-gray-900">{{ title }}</h3>
          <p v-if="description" class="mt-1 text-sm text-gray-500">{{ description }}</p>
        </div>
        <div class="mt-4 sm:mt-0 flex flex-col sm:flex-row gap-2">
          <slot name="actions" />
        </div>
      </div>
    </div>

    <!-- Tabela Desktop -->
    <div class="hidden sm:block overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th
              v-for="column in columns"
              :key="column.key"
              :class="[
                'px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider',
                column.class || ''
              ]"
            >
              {{ column.label }}
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr
            v-for="(item, index) in items"
            :key="index"
            class="hover:bg-gray-50 transition-colors"
          >
            <td
              v-for="column in columns"
              :key="column.key"
              :class="[
                'px-6 py-4 whitespace-nowrap text-sm',
                column.class || ''
              ]"
            >
              <slot :name="column.key" :item="item" :value="item[column.key]">
                {{ item[column.key] }}
              </slot>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Cards Mobile -->
    <div class="sm:hidden">
      <div
        v-for="(item, index) in items"
        :key="index"
        class="border-b border-gray-200 last:border-b-0"
      >
        <div class="px-4 py-4">
          <div class="space-y-3">
            <div
              v-for="column in columns"
              :key="column.key"
              class="flex justify-between items-start"
            >
              <div class="text-sm font-medium text-gray-500 min-w-0 flex-1">
                {{ column.label }}
              </div>
              <div class="text-sm text-gray-900 text-right min-w-0 flex-1">
                <slot :name="column.key" :item="item" :value="item[column.key]">
                  {{ item[column.key] }}
                </slot>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Estado Vazio -->
    <div v-if="items.length === 0" class="text-center py-12">
      <div class="mx-auto w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center mb-4">
        <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
        </svg>
      </div>
      <h3 class="text-sm font-medium text-gray-900 mb-1">{{ emptyTitle || 'Nenhum item encontrado' }}</h3>
      <p class="text-sm text-gray-500">{{ emptyDescription || 'Não há dados para exibir no momento.' }}</p>
    </div>

    <!-- Paginação -->
    <div v-if="showPagination && items.length > 0" class="px-4 py-3 border-t border-gray-200 sm:px-6">
      <div class="flex items-center justify-between">
        <div class="flex-1 flex justify-between sm:hidden">
          <button
            v-if="hasPreviousPage"
            @click="$emit('previous-page')"
            class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
          >
            Anterior
          </button>
          <button
            v-if="hasNextPage"
            @click="$emit('next-page')"
            class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
          >
            Próxima
          </button>
        </div>
        <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
          <div>
            <p class="text-sm text-gray-700">
              Mostrando <span class="font-medium">{{ startIndex + 1 }}</span> a 
              <span class="font-medium">{{ endIndex }}</span> de 
              <span class="font-medium">{{ totalItems }}</span> resultados
            </p>
          </div>
          <div>
            <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px">
              <button
                v-if="hasPreviousPage"
                @click="$emit('previous-page')"
                class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
              >
                <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
                </svg>
              </button>
              <button
                v-if="hasNextPage"
                @click="$emit('next-page')"
                class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
              >
                <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
                </svg>
              </button>
            </nav>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Column {
  key: string
  label: string
  class?: string
}

interface Props {
  title: string
  description?: string
  columns: Column[]
  items: any[]
  emptyTitle?: string
  emptyDescription?: string
  showPagination?: boolean
  hasPreviousPage?: boolean
  hasNextPage?: boolean
  startIndex?: number
  endIndex?: number
  totalItems?: number
}

defineProps<Props>()

defineEmits<{
  'previous-page': []
  'next-page': []
}>()
</script>
