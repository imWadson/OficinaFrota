<template>
  <footer class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-30">
    <div class="max-w-7xl mx-auto px-4 py-3">
      <div class="flex items-center justify-center">
        <!-- Status e Versão -->
        <div class="flex items-center space-x-2 sm:space-x-4 text-xs text-gray-500">
          <div class="flex items-center space-x-1">
            <div class="w-2 h-2 bg-green-400 rounded-full"></div>
            <span class="hidden sm:inline">Sistema Operacional</span>
            <span class="sm:hidden">Online</span>
          </div>
          <span class="hidden sm:inline">•</span>
          <span>v1.0.0</span>
          <span class="hidden sm:inline">•</span>
          <span class="hidden sm:inline">© {{ new Date().getFullYear() }}</span>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
// Sem imports necessários
</script>
