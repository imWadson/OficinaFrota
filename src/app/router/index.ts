import { createRouter, createWebHistory, type RouteLocationNormalized, type NavigationGuardNext } from 'vue-router'
import { useAuthStore } from '../../features/auth/stores/authStore'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../../pages/LoginPage.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/signup',
    name: 'Signup',
    component: () => import('../../pages/SignupPage.vue'),
    meta: { requiresAuth: false }
  },

  {
    path: '/',
    component: () => import('../../pages/LayoutPage.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'Dashboard',
        component: () => import('../../pages/DashboardPage.vue')
      },
      {
        path: 'veiculos',
        name: 'Veiculos',
        component: () => import('../../pages/VeiculosPage.vue')
      },
      {
        path: 'veiculos/estatisticas',
        name: 'EstatisticasVeiculo',
        component: () => import('../../pages/EstatisticasVeiculoPage.vue')
      },
      {
        path: 'ordens-servico',
        name: 'OrdensServico',
        component: () => import('../../pages/OrdensServicoPage.vue')
      },
      {
        path: 'ordens-servico/nova',
        name: 'NovaOrdemServico',
        component: () => import('../../pages/NovaOrdemServicoPage.vue')
      },
      {
        path: 'ordens-servico/:id',
        name: 'DetalhesOrdemServico',
        component: () => import('../../pages/DetalhesOrdemServicoPage.vue')
      },
      {
        path: 'estoque',
        name: 'Estoque',
        component: () => import('../../pages/EstoquePage.vue')
      },
      {
        path: 'oficinas-externas',
        name: 'OficinasExternas',
        component: () => import('../../pages/OficinasExternasPage.vue')
      },
      {
        path: 'supervisores',
        name: 'Supervisores',
        component: () => import('../../pages/SupervisoresPage.vue')
      },
      {
        path: 'relatorios',
        name: 'Relatorios',
        component: () => import('../../pages/RelatoriosPage.vue')
      },
      {
        path: 'auditoria',
        name: 'Auditoria',
        component: () => import('../../pages/AuditoriaPage.vue')
      },

    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to: RouteLocationNormalized, _from: RouteLocationNormalized, next: NavigationGuardNext) => {
  const authStore = useAuthStore()

  // Aguardar a inicialização da autenticação se ainda não foi inicializada
  if (!authStore.initialized) {
    await authStore.initializeAuth()
  }

  if (to.meta.requiresAuth !== false && !authStore.isAuthenticated) {
    next('/login')
  } else if ((to.path === '/login' || to.path === '/signup') && authStore.isAuthenticated) {
    next('/')
  } else {
    next()
  }
})

export default router
