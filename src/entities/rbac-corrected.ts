// =====================================================
// ESTRUTURA CORRIGIDA - SETORES E CARGOS
// =====================================================

export interface Setor {
  id: string
  nome: string
  sigla: string
  ativo: boolean
}

export interface Cargo {
  id: string
  nome: string
  sigla: string
  nivel: number
  setor_id?: string
}

export interface Estado {
  id: string
  nome: string
  sigla: string
  regionais: Regional[]
}

export interface Regional {
  id: string
  nome: string
  sigla: string
  estado_id: string
}

export interface Usuario {
  id: string
  auth_user_id: string
  nome: string
  email: string
  matricula: string
  cargo_id: string
  regional_id: string
  supervisor_id?: string
  ativo: boolean
  criado_em: string
}

// =====================================================
// DADOS ESTÁTICOS CORRIGIDOS
// =====================================================

export const SETORES: Setor[] = [
  {
    id: 'setor-operacao',
    nome: 'Operação',
    sigla: 'OPERACAO',
    ativo: true
  },
  {
    id: 'setor-oficina',
    nome: 'Oficina',
    sigla: 'OFICINA',
    ativo: true
  }
]

export const CARGOS: Cargo[] = [
  // Operação
  {
    id: 'cargo-supervisor',
    nome: 'Supervisor',
    sigla: 'SUPERVISOR',
    nivel: 3,
    setor_id: 'setor-operacao'
  },
  {
    id: 'cargo-coordenador',
    nome: 'Coordenador',
    sigla: 'COORDENADOR',
    nivel: 4,
    setor_id: 'setor-operacao'
  },
  {
    id: 'cargo-gerente',
    nome: 'Gerente',
    sigla: 'GERENTE',
    nivel: 5,
    setor_id: 'setor-operacao'
  },
  
  // Oficina
  {
    id: 'cargo-mecanico',
    nome: 'Mecânico',
    sigla: 'MECANICO',
    nivel: 1,
    setor_id: 'setor-oficina'
  },
  {
    id: 'cargo-analista-oficina',
    nome: 'Analista da Oficina',
    sigla: 'ANALISTA_OFICINA',
    nivel: 2,
    setor_id: 'setor-oficina'
  },
  {
    id: 'cargo-administrativo',
    nome: 'Administrativo',
    sigla: 'ADMINISTRATIVO',
    nivel: 2,
    setor_id: 'setor-oficina'
  },
  
  // Admin (sem setor específico)
  {
    id: 'cargo-diretor',
    nome: 'Diretor',
    sigla: 'DIRETOR',
    nivel: 6
  }
]

export const ESTADOS: Estado[] = [
  {
    id: 'estado-pi',
    nome: 'Piauí',
    sigla: 'PI',
    regionais: [
      {
        id: 'regional-metropolitana',
        nome: 'Metropolitana',
        sigla: 'MET',
        estado_id: 'estado-pi'
      },
      {
        id: 'regional-norte-pi',
        nome: 'Norte',
        sigla: 'NORTE',
        estado_id: 'estado-pi'
      },
      {
        id: 'regional-sul-pi',
        nome: 'Sul',
        sigla: 'SUL',
        estado_id: 'estado-pi'
      },
      {
        id: 'regional-centro-sul',
        nome: 'Centro Sul',
        sigla: 'CENTRO_SUL',
        estado_id: 'estado-pi'
      }
    ]
  },
  {
    id: 'estado-ma',
    nome: 'Maranhão',
    sigla: 'MA',
    regionais: [
      {
        id: 'regional-noroeste',
        nome: 'Noroeste',
        sigla: 'NOROESTE',
        estado_id: 'estado-ma'
      },
      {
        id: 'regional-norte-ma',
        nome: 'Norte',
        sigla: 'NORTE',
        estado_id: 'estado-ma'
      },
      {
        id: 'regional-sul-ma',
        nome: 'Sul',
        sigla: 'SUL',
        estado_id: 'estado-ma'
      }
    ]
  }
]

// =====================================================
// FUNÇÕES UTILITÁRIAS
// =====================================================

export function getCargoBySigla(sigla: string): Cargo | undefined {
  return CARGOS.find(cargo => cargo.sigla === sigla)
}

export function getSetorBySigla(sigla: string): Setor | undefined {
  return SETORES.find(setor => setor.sigla === sigla)
}

export function getCargosPorSetor(setorSigla: string): Cargo[] {
  const setor = getSetorBySigla(setorSigla)
  if (!setor) return []
  
  return CARGOS.filter(cargo => cargo.setor_id === setor.id)
}

export function getCargosOperacao(): Cargo[] {
  return getCargosPorSetor('OPERACAO')
}

export function getCargosOficina(): Cargo[] {
  return getCargosPorSetor('OFICINA')
}

export function getRegionalById(id: string): Regional | undefined {
  return ESTADOS
    .flatMap(estado => estado.regionais)
    .find(regional => regional.id === id)
}

export function getEstadoByRegionalId(regionalId: string): Estado | undefined {
  return ESTADOS.find(estado => 
    estado.regionais.some(regional => regional.id === regionalId)
  )
}
