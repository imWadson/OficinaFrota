<template>
  <div id="app">
    <!-- Loading enquanto inicializa -->
    <div v-if="!authStore.initialized" class="min-h-screen bg-gradient-to-br from-slate-50 via-white to-amber-50/30 flex items-center justify-center">
      <div class="text-center">
        <div class="w-16 h-16 bg-gradient-to-br from-amber-500 to-orange-600 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
          <svg class="w-8 h-8 text-white animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
        </div>
        <h2 class="text-xl font-bold text-slate-900 mb-2">OficinaFrota</h2>
        <p class="text-slate-600">Carregando...</p>
      </div>
    </div>
    
    <!-- Conteúdo da aplicação -->
    <router-view v-else />
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/features/auth/stores/authStore'

const authStore = useAuthStore()
</script>
