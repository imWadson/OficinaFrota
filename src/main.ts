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

// Carregar usuário atual ao iniciar a aplicação
const authStore = useAuthStore()
authStore.getCurrentUser()

app.mount('#app')
