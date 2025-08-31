<template>
  <footer class="fixed bottom-0 left-0 right-0 bg-white/95 backdrop-blur-sm border-t border-slate-200/60 z-30 shadow-lg">
    <div class="max-w-7xl mx-auto px-6 py-4">
      <div class="flex items-center justify-between">
        <!-- Status e Versão -->
        <div class="flex items-center space-x-4 text-sm text-slate-600">
          <div class="flex items-center space-x-2">
            <div class="relative">
              <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
              <div class="absolute inset-0 w-2 h-2 bg-green-400 rounded-full animate-ping"></div>
            </div>
            <span class="font-medium">Sistema Operacional</span>
          </div>
          <div class="w-1 h-1 bg-slate-300 rounded-full"></div>
          <span class="font-semibold text-amber-600">v1.0.0</span>
          <div class="w-1 h-1 bg-slate-300 rounded-full"></div>
          <span class="text-slate-500">© {{ new Date().getFullYear() }} OficinaFrota</span>
        </div>

        <!-- Links rápidos -->
        <div class="hidden sm:flex items-center space-x-6 text-sm">
          <a href="#" class="text-slate-600 hover:text-amber-600 font-medium transition-colors">Suporte</a>
          <a href="#" class="text-slate-600 hover:text-amber-600 font-medium transition-colors">Documentação</a>
          <a href="#" class="text-slate-600 hover:text-amber-600 font-medium transition-colors">Contato</a>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
// Sem imports necessários
</script>
