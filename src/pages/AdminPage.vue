<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-2xl font-semibold text-gray-900">Administração</h1>
      <p class="mt-1 text-sm text-gray-500">
        Configurações e manutenção do sistema
      </p>
    </div>

    <div class="card">
      <h3 class="text-lg font-medium text-gray-900 mb-4">Estrutura do Banco de Dados</h3>
      <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4">
        <h4 class="font-medium text-blue-800 mb-2">Como criar as tabelas:</h4>
        <ol class="text-sm text-blue-700 space-y-1">
          <li>1. Acesse o dashboard do Supabase</li>
          <li>2. Vá em "SQL Editor"</li>
          <li>3. Copie e execute o SQL do arquivo <code class="bg-blue-100 px-1 rounded">database-setup.sql</code></li>
          <li>4. Clique em "Run" para criar todas as tabelas</li>
        </ol>
      </div>
      
      <BaseButton
        @click="executeMigration"
        :loading="migrationLoading"
        :disabled="true"
        variant="secondary"
      >
        Migração via Edge Function (Em desenvolvimento)
      </BaseButton>

      <div v-if="migrationResult" class="mt-4 p-4 rounded-lg" :class="migrationResult.success ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg v-if="migrationResult.success" class="h-5 w-5 text-green-400" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
            </svg>
            <svg v-else class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
            </svg>
          </div>
          <div class="ml-3">
            <h4 class="text-sm font-medium" :class="migrationResult.success ? 'text-green-800' : 'text-red-800'">
              {{ migrationResult.success ? 'Sucesso!' : 'Erro na migração' }}
            </h4>
            <div class="mt-2 text-sm" :class="migrationResult.success ? 'text-green-700' : 'text-red-700'">
              <p>{{ migrationResult.message || migrationResult.error }}</p>
              <p v-if="migrationResult.tables?.length" class="mt-1">
                Tabelas verificadas: {{ migrationResult.tables.join(', ') }}
              </p>
              <p v-if="migrationResult.timestamp" class="mt-1 text-xs opacity-75">
                Executado em: {{ new Date(migrationResult.timestamp).toLocaleString('pt-BR') }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="card">
      <h3 class="text-lg font-medium text-gray-900 mb-4">Informações do Sistema</h3>
      <dl class="grid grid-cols-1 gap-x-4 gap-y-6 sm:grid-cols-2">
        <div>
          <dt class="text-sm font-medium text-gray-500">Versão do Sistema</dt>
          <dd class="mt-1 text-sm text-gray-900">1.0.0</dd>
        </div>
        <div>
          <dt class="text-sm font-medium text-gray-500">Ambiente</dt>
          <dd class="mt-1 text-sm text-gray-900">{{ environment }}</dd>
        </div>
        <div>
          <dt class="text-sm font-medium text-gray-500">Supabase URL</dt>
          <dd class="mt-1 text-sm text-gray-900">{{ supabaseUrl ? 'Configurado' : 'Não configurado' }}</dd>
        </div>
        <div>
          <dt class="text-sm font-medium text-gray-500">Usuário Atual</dt>
          <dd class="mt-1 text-sm text-gray-900">{{ authStore.user?.email || 'Não autenticado' }}</dd>
        </div>
      </dl>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { supabase } from '../services/supabase'
import { useAuthStore } from '../features/auth/stores/authStore'
import BaseButton from '../shared/ui/BaseButton.vue'

const authStore = useAuthStore()
const migrationLoading = ref(false)
const migrationResult = ref<any>(null)

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const environment = import.meta.env.MODE

async function executeMigration() {
  migrationLoading.value = true
  migrationResult.value = null

  try {
    const { data, error } = await supabase.functions.invoke('migrate')
    
    if (error) {
      throw error
    }

    migrationResult.value = data
  } catch (error) {
    migrationResult.value = {
      success: false,
      error: error instanceof Error ? error.message : 'Erro desconhecido',
      timestamp: new Date().toISOString()
    }
  } finally {
    migrationLoading.value = false
  }
}
</script>
