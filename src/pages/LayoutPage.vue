<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-50 via-white to-amber-50/30 overflow-x-hidden">
    <!-- Desktop Sidebar -->
    <div 
      class="fixed inset-y-0 left-0 z-50 bg-gradient-to-b from-slate-800 via-slate-700 to-slate-800 lg:block hidden shadow-2xl transition-all duration-300"
      :class="sidebarCollapsed ? 'w-20' : 'w-72'"
    >
      <AppSidebar 
        :collapsed="sidebarCollapsed"
        @logout="handleLogout" 
        @toggle="sidebarCollapsed = !sidebarCollapsed"
      />
    </div>

    <!-- Main Content -->
    <div :class="sidebarCollapsed ? 'lg:pl-20' : 'lg:pl-72'" class="transition-all duration-300 min-w-0">
      <!-- Header -->
      <AppHeader
        :mobile-menu-open="mobileMenuOpen"
        :sidebar-collapsed="sidebarCollapsed"
        @toggle-mobile-menu="mobileMenuOpen = !mobileMenuOpen"
        @toggle-sidebar="sidebarCollapsed = !sidebarCollapsed"
        @logout="handleLogout"
      />

      <!-- Mobile Sidebar Overlay -->
      <div v-if="mobileMenuOpen" class="lg:hidden">
        <div class="fixed inset-0 z-30 bg-black/50 backdrop-blur-sm" @click="mobileMenuOpen = false"></div>
        
        <div class="fixed inset-y-0 left-0 z-40 w-80 bg-gradient-to-b from-slate-800 via-slate-700 to-slate-800 shadow-2xl">
          <!-- Mobile Sidebar Content -->
          <AppSidebar @close="mobileMenuOpen = false" @logout="handleLogout" />
        </div>
      </div>

      <!-- Page content - Mais orgânico -->
      <main class="p-6 pb-24 min-w-0">
        <div class="max-w-7xl mx-auto">
          <router-view />
        </div>
      </main>

      <!-- Footer -->
      <AppFooter />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/features/auth/stores/authStore'
import AppSidebar from '@/components/layout/AppSidebar.vue'
import AppHeader from '@/components/layout/AppHeader.vue'
import AppFooter from '@/components/layout/AppFooter.vue'

const router = useRouter()
const authStore = useAuthStore()

// Menu state
const mobileMenuOpen = ref(false)
const sidebarCollapsed = ref(false)

async function handleLogout() {
  const result = await authStore.signOut()
  if (result.success) {
    router.push('/login')
  }
}
</script>
