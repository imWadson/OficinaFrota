<template>
  <button
    :class="[
      'inline-flex items-center justify-center font-semibold rounded-xl transition-all duration-200 transform hover:-translate-y-0.5 focus:outline-none focus:ring-2 focus:ring-offset-2',
      sizeClasses[size],
      variantClasses[variant],
      disabled && 'opacity-50 cursor-not-allowed transform-none hover:transform-none'
    ]"
    :disabled="disabled"
    @click="$emit('click')"
  >
    <component 
      v-if="icon" 
      :is="icon" 
      :class="[
        iconSizeClasses[size],
        'mr-2'
      ]" 
    />
    <slot />
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger'
  size?: 'sm' | 'md' | 'lg' | 'xl'
  icon?: any
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  disabled: false
})

defineEmits<{
  click: []
}>()

const sizeClasses = {
  sm: 'px-3 py-2 text-sm',
  md: 'px-4 py-2.5 text-sm',
  lg: 'px-6 py-3 text-base',
  xl: 'px-8 py-4 text-lg'
}

const iconSizeClasses = {
  sm: 'w-4 h-4',
  md: 'w-4 h-4',
  lg: 'w-5 h-5',
  xl: 'w-6 h-6'
}

const variantClasses = {
  primary: 'bg-gradient-to-r from-amber-500 to-orange-600 text-white shadow-lg hover:shadow-xl hover:from-amber-600 hover:to-orange-700 focus:ring-amber-500',
  secondary: 'bg-gradient-to-r from-slate-600 to-slate-700 text-white shadow-lg hover:shadow-xl hover:from-slate-700 hover:to-slate-800 focus:ring-slate-500',
  outline: 'border-2 border-slate-300 text-slate-700 hover:border-amber-500 hover:text-amber-600 hover:bg-amber-50 focus:ring-amber-500',
  ghost: 'text-slate-700 hover:bg-slate-100 hover:text-slate-900 focus:ring-slate-500',
  danger: 'bg-gradient-to-r from-red-500 to-red-600 text-white shadow-lg hover:shadow-xl hover:from-red-600 hover:to-red-700 focus:ring-red-500'
}
</script>
