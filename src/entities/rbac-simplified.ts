// =====================================================
// ENTIDADES RBAC SIMPLIFICADAS
// =====================================================
// Versão otimizada sem overengineering

// =========================================
// ESTRUTURA BÁSICA
// =========================================

export interface Estado {
  id: string
  nome: string
  sigla: string
  ativo: boolean
  created_at: string
}

export interface Regional {
  id: string
  nome: string
  sigla: string
  estado_id: string
  estado?: Estado
  ativo: boolean
  created_at: string
}

export interface Cargo {
  id: string
  nome: string
  sigla: string
  nivel: number
  categoria: 'oficina' | 'operacao' | 'admin'
  ativo: boolean
  created_at: string
}

export interface Usuario {
  id: string
  auth_user_id?: string
  nome: string
  email: string
  matricula: string
  cargo_id: string
  cargo?: Cargo
  regional_id?: string
  regional?: Regional
  supervisor_id?: string
  supervisor?: Usuario
  ativo: boolean
  created_at: string
}

// =========================================
// ENTIDADES DE NEGÓCIO
// =========================================

export interface Veiculo {
  id: string
  placa: string
  modelo: string
  tipo: string
  ano?: number
  quilometragem: number
  status: 'ativo' | 'manutencao' | 'inativo' | 'oficina_externa'
  regional_id?: string
  regional?: Regional
  responsavel_id?: string
  responsavel?: Usuario
  criado_por: string
  criado_em: string
}

export interface OrdemServico {
  id: string
  numero_os: string
  veiculo_id: string
  veiculo?: Veiculo
  problema_reportado: string
  diagnostico?: string
  status: 'em_andamento' | 'concluida' | 'cancelada' | 'oficina_externa'
  prioridade: 'baixa' | 'normal' | 'alta' | 'urgente'
  data_entrada: string
  data_saida?: string
  supervisor_entrega_id?: string
  supervisor_entrega?: Usuario
  supervisor_retirada_id?: string
  supervisor_retirada?: Usuario
  mecanico_responsavel_id?: string
  mecanico_responsavel?: Usuario
  criado_por: string
  criado_em: string
}

export interface Peca {
  id: string
  nome: string
  codigo: string
  fornecedor?: string
  custo_unitario: number
  quantidade_estoque: number
  quantidade_minima: number
  categoria?: string
  regional_id?: string
  regional?: Regional
  ativo: boolean
  criado_por: string
  criado_em: string
}

export interface PecaUsada {
  id: string
  ordem_servico_id: string
  ordem_servico?: OrdemServico
  peca_id: string
  peca?: Peca
  quantidade: number
  custo_unitario: number
  responsavel_id: string
  responsavel?: Usuario
  criado_em: string
}

export interface OficinaExterna {
  id: string
  nome: string
  cnpj: string
  endereco?: string
  telefone?: string
  contato?: string
  regional_id?: string
  regional?: Regional
  ativo: boolean
  criado_por: string
  criado_em: string
}

export interface ServicoExterno {
  id: string
  ordem_servico_id: string
  ordem_servico?: OrdemServico
  oficina_externa_id: string
  oficina_externa?: OficinaExterna
  descricao: string
  valor: number
  data_envio: string
  data_retorno?: string
  status: 'em_andamento' | 'concluido' | 'cancelado'
  criado_por: string
  criado_em: string
}

// =========================================
// CONSTANTES SIMPLIFICADAS
// =========================================

export const CARGOS = {
  MECANICO: 'MECANICO',
  ANALISTA_OFICINA: 'ANALISTA_OFICINA',
  SUPERVISOR: 'SUPERVISOR',
  COORDENADOR: 'COORDENADOR',
  GERENTE: 'GERENTE',
  DIRETOR: 'DIRETOR'
} as const

export type CargoSigla = typeof CARGOS[keyof typeof CARGOS]

export const STATUS_VEICULO = {
  ATIVO: 'ativo',
  MANUTENCAO: 'manutencao',
  INATIVO: 'inativo',
  OFICINA_EXTERNA: 'oficina_externa'
} as const

export type StatusVeiculo = typeof STATUS_VEICULO[keyof typeof STATUS_VEICULO]

export const STATUS_ORDEM_SERVICO = {
  EM_ANDAMENTO: 'em_andamento',
  CONCLUIDA: 'concluida',
  CANCELADA: 'cancelada',
  OFICINA_EXTERNA: 'oficina_externa'
} as const

export type StatusOrdemServico = typeof STATUS_ORDEM_SERVICO[keyof typeof STATUS_ORDEM_SERVICO]

export const PRIORIDADES = {
  BAIXA: 'baixa',
  NORMAL: 'normal',
  ALTA: 'alta',
  URGENTE: 'urgente'
} as const

export type Prioridade = typeof PRIORIDADES[keyof typeof PRIORIDADES]

export const TIPOS_VEICULO = {
  CAMINHONETE: 'Caminhonete',
  VAN: 'Van',
  UTILITARIO: 'Utilitário',
  GUINDAUTO: 'Guindauto',
  MUNCK: 'Munck',
  GUINCHO: 'Guincho',
  MAQUINA: 'Máquina',
  GERADOR: 'Gerador'
} as const

export type TipoVeiculo = typeof TIPOS_VEICULO[keyof typeof TIPOS_VEICULO]

// =========================================
// INTERFACES PARA FORMULÁRIOS
// =========================================

export interface CreateUsuarioData {
  nome: string
  email: string
  matricula: string
  cargo_id: string
  regional_id?: string
  supervisor_id?: string
}

export interface CreateVeiculoData {
  placa: string
  modelo: string
  tipo: string
  ano?: number
  quilometragem: number
  status?: StatusVeiculo
  regional_id?: string
  responsavel_id?: string
}

export interface CreateOrdemServicoData {
  numero_os: string
  veiculo_id: string
  problema_reportado: string
  diagnostico?: string
  prioridade?: Prioridade
  supervisor_entrega_id?: string
  mecanico_responsavel_id?: string
}

export interface CreatePecaData {
  nome: string
  codigo: string
  fornecedor?: string
  custo_unitario: number
  quantidade_estoque: number
  quantidade_minima: number
  categoria?: string
  regional_id?: string
}

export interface CreatePecaUsadaData {
  ordem_servico_id: string
  peca_id: string
  quantidade: number
  custo_unitario: number
}

export interface CreateOficinaExternaData {
  nome: string
  cnpj: string
  endereco?: string
  telefone?: string
  contato?: string
  regional_id?: string
}

export interface CreateServicoExternoData {
  ordem_servico_id: string
  oficina_externa_id: string
  descricao: string
  valor: number
  data_retorno?: string
}

// =========================================
// INTERFACES PARA FILTROS
// =========================================

export interface FiltroVeiculos {
  placa?: string
  modelo?: string
  tipo?: string
  status?: StatusVeiculo
  regional_id?: string
}

export interface FiltroOrdensServico {
  numero_os?: string
  veiculo_id?: string
  status?: StatusOrdemServico
  prioridade?: Prioridade
  data_entrada_inicio?: string
  data_entrada_fim?: string
}

export interface FiltroPecas {
  nome?: string
  codigo?: string
  categoria?: string
  regional_id?: string
  ativo?: boolean
}

// =========================================
// INTERFACES PARA DASHBOARD
// =========================================

export interface DashboardData {
  frota: {
    total: number
    ativos: number
    manutencao: number
    oficina_externa: number
  }
  oficina: {
    total_ordens: number
    em_andamento: number
    concluidas_hoje: number
    urgentes: number
  }
  estoque: {
    total_pecas: number
    baixo_estoque: number
    valor_total: number
  }
}

// =========================================
// FUNÇÕES UTILITÁRIAS
// =========================================

export const getCargoNivel = (cargo: CargoSigla): number => {
  const niveis = {
    [CARGOS.MECANICO]: 1,
    [CARGOS.ANALISTA_OFICINA]: 2,
    [CARGOS.SUPERVISOR]: 3,
    [CARGOS.COORDENADOR]: 4,
    [CARGOS.GERENTE]: 5,
    [CARGOS.DIRETOR]: 5
  }
  return niveis[cargo] || 0
}

export const canAccess = (userCargo: CargoSigla, requiredCargo: CargoSigla): boolean => {
  return getCargoNivel(userCargo) >= getCargoNivel(requiredCargo)
}

export const isAdmin = (cargo: CargoSigla): boolean => {
  return cargo === CARGOS.DIRETOR
}

export const isGerente = (cargo: CargoSigla): boolean => {
  return cargo === CARGOS.GERENTE || cargo === CARGOS.DIRETOR
}

export const isSupervisor = (cargo: CargoSigla): boolean => {
  return getCargoNivel(cargo) >= getCargoNivel(CARGOS.SUPERVISOR)
}

export const isOficina = (cargo: CargoSigla): boolean => {
  return cargo === CARGOS.MECANICO || cargo === CARGOS.ANALISTA_OFICINA
}
