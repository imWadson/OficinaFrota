<template>
  <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1">
    <div class="p-6">
      <div class="flex items-center justify-between mb-4">
        <div :class="[
          'w-12 h-12 rounded-xl flex items-center justify-center shadow-lg',
          iconBgClass
        ]">
          <component :is="icon" class="w-6 h-6 text-white" />
        </div>
        <div class="text-right">
          <span class="text-2xl font-bold text-slate-900">{{ value }}</span>
          <div v-if="trend" :class="[
            'text-xs font-semibold flex items-center',
            trend.type === 'positive' ? 'text-green-600' : 
            trend.type === 'negative' ? 'text-red-600' : 'text-amber-600'
          ]">
            <component :is="trend.icon" class="w-3 h-3 mr-1" />
            {{ trend.value }}
          </div>
        </div>
      </div>
      <h3 class="text-lg font-bold text-slate-900 mb-1">{{ title }}</h3>
      <p class="text-sm text-slate-600">{{ description }}</p>
    </div>
    <div :class="['h-1', accentColorClass]"></div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import {
  ArrowTrendingUpIcon,
  ArrowTrendingDownIcon,
  ExclamationTriangleIcon
} from '@heroicons/vue/20/solid'

interface Trend {
  type: 'positive' | 'negative' | 'warning'
  value: string
  icon?: any
}

interface Props {
  title: string
  description: string
  value: string | number
  icon: any
  color: 'blue' | 'green' | 'amber' | 'red' | 'purple'
  trend?: Trend
}

const props = defineProps<Props>()

const iconBgClass = computed(() => {
  const classes = {
    blue: 'bg-gradient-to-br from-blue-500 to-blue-600',
    green: 'bg-gradient-to-br from-green-500 to-emerald-600',
    amber: 'bg-gradient-to-br from-amber-500 to-orange-600',
    red: 'bg-gradient-to-br from-red-500 to-red-600',
    purple: 'bg-gradient-to-br from-purple-500 to-purple-600'
  }
  return classes[props.color]
})

const accentColorClass = computed(() => {
  const classes = {
    blue: 'bg-gradient-to-r from-blue-500 to-blue-600',
    green: 'bg-gradient-to-r from-green-500 to-emerald-600',
    amber: 'bg-gradient-to-r from-amber-500 to-orange-600',
    red: 'bg-gradient-to-r from-red-500 to-red-600',
    purple: 'bg-gradient-to-r from-purple-500 to-purple-600'
  }
  return classes[props.color]
})

// Mapear ícones de tendência
const trendIconMap = {
  positive: ArrowTrendingUpIcon,
  negative: ArrowTrendingDownIcon,
  warning: ExclamationTriangleIcon
}

// Substituir ícone se necessário
const trend = computed(() => {
  if (!props.trend) return undefined
  
  return {
    ...props.trend,
    icon: trendIconMap[props.trend.type]
  }
})
</script>
