<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Desktop Sidebar -->
    <div class="fixed inset-y-0 left-0 z-50 w-64 bg-white border-r border-gray-200 lg:block hidden">
      <AppSidebar @logout="handleLogout" />
    </div>

    <!-- Main Content -->
    <div class="lg:pl-64">
      <!-- Header -->
      <AppHeader
        :mobile-menu-open="mobileMenuOpen"
        @toggle-mobile-menu="mobileMenuOpen = !mobileMenuOpen"
        @logout="handleLogout"
      />

      <!-- Mobile Sidebar Overlay -->
      <div v-if="mobileMenuOpen" class="lg:hidden">
        <div class="fixed inset-0 z-30 bg-black bg-opacity-50" @click="mobileMenuOpen = false"></div>
        
        <div class="fixed inset-y-0 left-0 z-40 w-80 bg-white shadow-xl">
          <!-- Mobile Sidebar Content -->
          <AppSidebar @close="mobileMenuOpen = false" @logout="handleLogout" />
        </div>
      </div>

      <!-- Page content -->
      <main class="p-4 sm:p-6 pb-20">
        <router-view />
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

async function handleLogout() {
  const result = await authStore.signOut()
  if (result.success) {
    router.push('/login')
  }
}
</script>
