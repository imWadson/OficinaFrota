<template>
  <div class="space-y-8">
    <!-- Header da Página - Mais expressivo -->
    <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between">
      <div class="mb-6 lg:mb-0">
        <div class="flex items-center space-x-4 mb-2">
          <div class="w-1 h-12 bg-gradient-to-b from-amber-500 to-orange-600 rounded-full"></div>
          <div>
            <h1 class="text-3xl lg:text-4xl font-bold text-slate-900 tracking-tight">Dashboard</h1>
            <p class="text-lg text-slate-600 font-medium">
              Visão geral do sistema de gestão de frota
            </p>
          </div>
        </div>
      </div>
      <div class="flex flex-col sm:flex-row gap-4">
        <BaseButton 
          variant="primary" 
          size="lg"
          :icon="PlusIcon"
        >
          Nova OS
        </BaseButton>
        <BaseButton 
          variant="outline" 
          size="lg"
          :icon="ChartBarIcon"
        >
          Relatórios
        </BaseButton>
      </div>
    </div>

    <!-- Cards de Estatísticas - Usando componente reutilizável -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
      <DashboardCard
        title="Total de Veículos"
        description="Frota ativa no sistema"
        :value="156"
        :icon="TruckIcon"
        color="blue"
        :trend="{ type: 'positive', value: '+12%' }"
      />
      
      <DashboardCard
        title="OS em Andamento"
        description="Serviços ativos"
        :value="23"
        :icon="WrenchScrewdriverIcon"
        color="green"
        :trend="{ type: 'positive', value: '+5%' }"
      />
      
      <DashboardCard
        title="Aguardando Peças"
        description="Necessitam atenção"
        :value="7"
        :icon="ClockIcon"
        color="amber"
        :trend="{ type: 'warning', value: 'Atenção' }"
      />
      
      <DashboardCard
        title="Situações Críticas"
        description="Requerem ação imediata"
        :value="3"
        :icon="ExclamationTriangleIcon"
        color="red"
        :trend="{ type: 'warning', value: 'Crítico' }"
      />
    </div>

    <!-- Gráficos e Tabelas - Layout mais orgânico -->
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-8">
      <!-- Gráfico de Atividade - Maior -->
      <div class="xl:col-span-2 bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
        <div class="p-6 border-b border-slate-100">
          <div class="flex items-center justify-between">
            <h3 class="text-xl font-bold text-slate-900">Atividade Recente</h3>
            <div class="flex items-center space-x-2">
              <div class="w-3 h-3 bg-blue-500 rounded-full"></div>
              <span class="text-sm text-slate-600">Ordens de Serviço</span>
            </div>
          </div>
        </div>
        <div class="p-6">
          <div class="h-80 bg-gradient-to-br from-slate-50 to-amber-50/30 rounded-xl flex items-center justify-center border-2 border-dashed border-slate-200">
            <div class="text-center">
              <svg class="w-16 h-16 text-slate-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
              <p class="text-slate-500 font-medium">Gráfico de atividade será implementado aqui</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabela de OS Recentes -->
      <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
        <div class="p-6 border-b border-slate-100">
          <h3 class="text-xl font-bold text-slate-900">OS Recentes</h3>
        </div>
        <div class="p-6">
          <div class="space-y-4">
            <div v-for="(os, index) in recentOS" :key="index" class="flex items-center space-x-4 p-4 bg-slate-50 rounded-xl hover:bg-slate-100 transition-colors">
              <div class="w-10 h-10 bg-gradient-to-br from-amber-500 to-orange-600 rounded-lg flex items-center justify-center">
                <span class="text-white font-bold text-sm">#{{ os.id }}</span>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-semibold text-slate-900 truncate">{{ os.veiculo }}</p>
                <p class="text-xs text-slate-500">{{ os.data }}</p>
              </div>
              <span :class="[
                'px-3 py-1 text-xs font-semibold rounded-full',
                os.status === 'Em andamento' ? 'bg-green-100 text-green-800' :
                os.status === 'Aguardando peças' ? 'bg-amber-100 text-amber-800' :
                'bg-blue-100 text-blue-800'
              ]">
                {{ os.status }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Ações Rápidas - Mais orgânico -->
    <div class="bg-white rounded-2xl shadow-lg border border-slate-200/60 overflow-hidden">
      <div class="p-6 border-b border-slate-100">
        <h3 class="text-xl font-bold text-slate-900">Ações Rápidas</h3>
      </div>
      <div class="p-6">
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          <button class="group flex items-center p-6 border-2 border-slate-200 rounded-xl hover:border-amber-500 hover:bg-amber-50 transition-all duration-200 transform hover:-translate-y-1">
            <div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center mr-4 group-hover:scale-110 transition-transform">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
              </svg>
            </div>
            <div class="text-left">
              <p class="text-sm font-bold text-slate-900 group-hover:text-amber-600">Nova OS</p>
              <p class="text-xs text-slate-500">Criar ordem de serviço</p>
            </div>
          </button>

          <button class="group flex items-center p-6 border-2 border-slate-200 rounded-xl hover:border-amber-500 hover:bg-amber-50 transition-all duration-200 transform hover:-translate-y-1">
            <div class="w-12 h-12 bg-gradient-to-br from-green-500 to-emerald-600 rounded-xl flex items-center justify-center mr-4 group-hover:scale-110 transition-transform">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
            </div>
            <div class="text-left">
              <p class="text-sm font-bold text-slate-900 group-hover:text-amber-600">Novo Veículo</p>
              <p class="text-xs text-slate-500">Cadastrar veículo</p>
            </div>
          </button>

          <button class="group flex items-center p-6 border-2 border-slate-200 rounded-xl hover:border-amber-500 hover:bg-amber-50 transition-all duration-200 transform hover:-translate-y-1">
            <div class="w-12 h-12 bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl flex items-center justify-center mr-4 group-hover:scale-110 transition-transform">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
              </svg>
            </div>
            <div class="text-left">
              <p class="text-sm font-bold text-slate-900 group-hover:text-amber-600">Estoque</p>
              <p class="text-xs text-slate-500">Gerenciar peças</p>
            </div>
          </button>

          <button class="group flex items-center p-6 border-2 border-slate-200 rounded-xl hover:border-amber-500 hover:bg-amber-50 transition-all duration-200 transform hover:-translate-y-1">
            <div class="w-12 h-12 bg-gradient-to-br from-amber-500 to-orange-600 rounded-xl flex items-center justify-center mr-4 group-hover:scale-110 transition-transform">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
            </div>
            <div class="text-left">
              <p class="text-sm font-bold text-slate-900 group-hover:text-amber-600">Relatórios</p>
              <p class="text-xs text-slate-500">Ver relatórios</p>
            </div>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  ChartBarIcon,
  TruckIcon,
  WrenchScrewdriverIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  PlusIcon
} from '@heroicons/vue/24/outline'
import DashboardCard from '@/components/ui/DashboardCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'

// Dados mockados para demonstração
const recentOS = [
  { id: '001', veiculo: 'Caminhão 01', status: 'Em andamento', data: '15/01/2024' },
  { id: '002', veiculo: 'Van 03', status: 'Aguardando peças', data: '14/01/2024' },
  { id: '003', veiculo: 'Carro 05', status: 'Concluída', data: '13/01/2024' },
  { id: '004', veiculo: 'Caminhão 08', status: 'Em andamento', data: '12/01/2024' },
]
</script>
