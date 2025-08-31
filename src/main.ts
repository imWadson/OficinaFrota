import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { VueQueryPlugin } from '@tanstack/vue-query'
import App from './App.vue'
import router from './app/router'
import { useAuthStore } from './features/auth/stores/authStore'
import './app/styles.css'

const app = createApp(App)

app.use(createPinia())
app.use(VueQueryPlugin)
app.use(router)

// Inicializar autenticação antes de montar a aplicação
const authStore = useAuthStore()
await authStore.initializeAuth()

app.mount('#app')
