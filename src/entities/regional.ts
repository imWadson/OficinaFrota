export interface Regional {
  id: string
  nome: string
  estado: string
  sigla: string
  ativo: boolean
  created_at: string
  updated_at: string
}

export interface Estado {
  id: string
  nome: string
  sigla: string
  regionais: Regional[]
}

// Dados estáticos dos estados e regionais
export const ESTADOS: Estado[] = [
  {
    id: '1',
    nome: 'Piauí',
    sigla: 'PI',
    regionais: [
      { id: '1', nome: 'Metropolitana', estado: 'Piauí', sigla: 'MET', ativo: true, created_at: '', updated_at: '' },
      { id: '2', nome: 'Norte', estado: 'Piauí', sigla: 'NORTE', ativo: true, created_at: '', updated_at: '' },
      { id: '3', nome: 'Sul', estado: 'Piauí', sigla: 'SUL', ativo: true, created_at: '', updated_at: '' },
      { id: '4', nome: 'Centro Sul', estado: 'Piauí', sigla: 'CENTRO_SUL', ativo: true, created_at: '', updated_at: '' }
    ]
  },
  {
    id: '2',
    nome: 'Maranhão',
    sigla: 'MA',
    regionais: [
      { id: '5', nome: 'Noroeste', estado: 'Maranhão', sigla: 'NOROESTE', ativo: true, created_at: '', updated_at: '' },
      { id: '6', nome: 'Norte', estado: 'Maranhão', sigla: 'NORTE', ativo: true, created_at: '', updated_at: '' },
      { id: '7', nome: 'Sul', estado: 'Maranhão', sigla: 'SUL', ativo: true, created_at: '', updated_at: '' }
    ]
  }
]

export const CARGOS = [
  { id: '1', nome: 'Oficina', sigla: 'OFICINA', nivel: 1 },
  { id: '2', nome: 'Supervisor', sigla: 'SUPERVISOR', nivel: 2 },
  { id: '3', nome: 'Gerente', sigla: 'GERENTE', nivel: 3 },
  { id: '4', nome: 'Coordenador', sigla: 'COORDENADOR', nivel: 4 }
] as const

export type Cargo = typeof CARGOS[number]
