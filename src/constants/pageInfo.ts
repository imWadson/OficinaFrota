export const PAGE_INFO = {
  '/': {
    title: 'Dashboard',
    description: 'Visão geral do sistema'
  },
  '/veiculos': {
    title: 'Veículos',
    description: 'Gestão da frota de veículos'
  },
  '/ordens-servico': {
    title: 'Ordens de Serviço',
    description: 'Controle de manutenções'
  },
  '/estoque': {
    title: 'Estoque',
    description: 'Controle de peças e suprimentos'
  },
  '/oficinas-externas': {
    title: 'Oficinas Externas',
    description: 'Oficinas parceiras'
  },
  '/supervisores': {
    title: 'Supervisores',
    description: 'Gestão de supervisores'
  },
  '/relatorios': {
    title: 'Relatórios',
    description: 'Relatórios e análises'
  },
  '/admin': {
    title: 'Administração',
    description: 'Configurações do sistema'
  }
} as const

export function getPageInfo(path: string) {
  return PAGE_INFO[path as keyof typeof PAGE_INFO] || {
    title: 'Página',
    description: 'Gerenciamento do sistema'
  }
}
