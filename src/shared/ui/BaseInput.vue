<template>
  <div class="form-group">
    <label v-if="label" :for="id" class="block text-sm font-medium text-gray-700 mb-1">
      {{ label }}
      <span v-if="required" class="text-red-500">*</span>
    </label>
    
    <input
      :id="id"
      :type="type"
      :value="modelValue"
      :placeholder="placeholder"
      :required="required"
      :disabled="disabled"
      :maxlength="maxLength"
      :pattern="pattern"
      class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100 disabled:cursor-not-allowed"
      :class="{ 'border-red-500 focus:ring-red-500 focus:border-red-500': hasError }"
      @input="handleInput"
      @blur="handleBlur"
      @focus="handleFocus"
    />
    
    <div v-if="hasError" class="mt-1 text-sm text-red-600">
      {{ errorMessage }}
    </div>
    
    <div v-if="helpText" class="mt-1 text-sm text-gray-500">
      {{ helpText }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

interface Props {
  modelValue: string
  label?: string
  type?: 'text' | 'email' | 'password' | 'number' | 'tel' | 'url'
  placeholder?: string
  required?: boolean
  disabled?: boolean
  maxLength?: number
  pattern?: string
  helpText?: string
  validation?: {
    required?: boolean
    minLength?: number
    maxLength?: number
    pattern?: RegExp
    custom?: (value: string) => string | null
  }
}

const props = withDefaults(defineProps<Props>(), {
  type: 'text',
  required: false,
  disabled: false
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
  'validation': [isValid: boolean, errorMessage?: string]
}>()

const id = `input-${Math.random().toString(36).substr(2, 9)}`
const hasError = ref(false)
const errorMessage = ref('')
const isTouched = ref(false)

// Sanitização básica para prevenir XSS
const sanitizeInput = (value: string): string => {
  return value
    .replace(/[<>]/g, '') // Remove < e >
    .trim()
}

// Validação
const validate = (value: string): string | null => {
  if (!props.validation) return null
  
  const val = value.trim()
  
  // Required
  if (props.validation.required && !val) {
    return 'Este campo é obrigatório'
  }
  
  // Min length
  if (props.validation.minLength && val.length < props.validation.minLength) {
    return `Mínimo de ${props.validation.minLength} caracteres`
  }
  
  // Max length
  if (props.validation.maxLength && val.length > props.validation.maxLength) {
    return `Máximo de ${props.validation.maxLength} caracteres`
  }
  
  // Pattern
  if (props.validation.pattern && val && !props.validation.pattern.test(val)) {
    return 'Formato inválido'
  }
  
  // Custom validation
  if (props.validation.custom) {
    return props.validation.custom(val)
  }
  
  return null
}

const handleInput = (event: Event) => {
  const target = event.target as HTMLInputElement
  const sanitizedValue = sanitizeInput(target.value)
  
  emit('update:modelValue', sanitizedValue)
  
  if (isTouched.value) {
    const error = validate(sanitizedValue)
    hasError.value = !!error
    errorMessage.value = error || ''
    emit('validation', !error, error || undefined)
  }
}

const handleBlur = () => {
  isTouched.value = true
  const error = validate(props.modelValue)
  hasError.value = !!error
  errorMessage.value = error || ''
  emit('validation', !error, error || undefined)
}

const handleFocus = () => {
  // Reset error on focus for better UX
  if (hasError.value) {
    hasError.value = false
    errorMessage.value = ''
  }
}
</script>
