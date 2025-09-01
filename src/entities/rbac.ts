// =====================================================
// ENTIDADES DO SISTEMA RBAC
// =====================================================
// Interfaces TypeScript para o sistema de permissões baseado em roles

// =========================================
// ESTRUTURA HIERÁRQUICA
// =========================================

export interface Estado {
  id: string
  nome: string
  sigla: string
  ativo: boolean
  created_at: string
  updated_at: string
}

export interface Regional {
  id: string
  nome: string
  sigla: string
  estado_id: string
  estado?: Estado
  ativo: boolean
  created_at: string
  updated_at: string
}

export interface Cargo {
  id: string
  nome: string
  sigla: string
  nivel: number
  categoria: 'oficina' | 'operacao' | 'admin'
  descricao?: string
  ativo: boolean
  created_at: string
  updated_at: string
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
  updated_at: string
}

// =========================================
// SISTEMA DE PERMISSÕES
// =========================================

export interface Permissao {
  id: string
  nome: string
  codigo: string
  descricao?: string
  modulo: string
  ativo: boolean
  created_at: string
}

export interface CargoPermissao {
  id: string
  cargo_id: string
  cargo?: Cargo
  permissao_id: string
  permissao?: Permissao
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
  criado_por_usuario?: Usuario
  criado_em: string
  updated_at: string
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
  data_limite?: string
  supervisor_entrega_id?: string
  supervisor_entrega?: Usuario
  supervisor_retirada_id?: string
  supervisor_retirada?: Usuario
  mecanico_responsavel_id?: string
  mecanico_responsavel?: Usuario
  observacoes?: string
  criado_por: string
  criado_por_usuario?: Usuario
  criado_em: string
  updated_at: string
}

export interface Peca {
  id: string
  nome: string
  codigo: string
  fornecedor?: string
  custo_unitario: number
  quantidade_estoque: number
  quantidade_minima: number
  unidade: string
  categoria?: string
  regional_id?: string
  regional?: Regional
  ativo: boolean
  criado_por: string
  criado_por_usuario?: Usuario
  criado_em: string
  updated_at: string
}

export interface PecaUsada {
  id: string
  ordem_servico_id: string
  ordem_servico?: OrdemServico
  peca_id: string
  peca?: Peca
  quantidade: number
  custo_unitario: number
  data_uso: string
  responsavel_id: string
  responsavel?: Usuario
  observacoes?: string
  criado_em: string
}

export interface OficinaExterna {
  id: string
  nome: string
  cnpj: string
  endereco?: string
  telefone?: string
  contato?: string
  email?: string
  regional_id?: string
  regional?: Regional
  ativo: boolean
  criado_por: string
  criado_por_usuario?: Usuario
  criado_em: string
  updated_at: string
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
  observacoes?: string
  criado_por: string
  criado_por_usuario?: Usuario
  criado_em: string
  updated_at: string
}

// =========================================
// TIPOS DE CARGO
// =========================================

export const CARGOS = {
  // Oficina
  MECANICO: 'MECANICO',
  ANALISTA_OFICINA: 'ANALISTA_OFICINA',
  ADMIN_OFICINA: 'ADMIN_OFICINA',
  
  // Operação
  SUPERVISOR: 'SUPERVISOR',
  COORDENADOR: 'COORDENADOR',
  GERENTE: 'GERENTE',
  ANALISTA_OPERACAO: 'ANALISTA_OPERACAO',
  
  // Admin
  DIRETOR: 'DIRETOR'
} as const

export type CargoSigla = typeof CARGOS[keyof typeof CARGOS]

// =========================================
// CATEGORIAS DE CARGO
// =========================================

export const CATEGORIAS_CARGO = {
  OFICINA: 'oficina',
  OPERACAO: 'operacao',
  ADMIN: 'admin'
} as const

export type CategoriaCargo = typeof CATEGORIAS_CARGO[keyof typeof CATEGORIAS_CARGO]

// =========================================
// PERMISSÕES DO SISTEMA
// =========================================

export const PERMISSOES = {
  // Frota
  FROTA_VISUALIZAR: 'frota.visualizar',
  FROTA_GERENCIAR: 'frota.gerenciar',
  FROTA_RELATORIOS: 'frota.relatorios',
  
  // Oficina
  OFICINA_VISUALIZAR: 'oficina.visualizar',
  OFICINA_CRIAR: 'oficina.criar',
  OFICINA_GERENCIAR: 'oficina.gerenciar',
  OFICINA_CONCLUIR: 'oficina.concluir',
  OFICINA_RELATORIOS: 'oficina.relatorios',
  
  // Estoque
  ESTOQUE_VISUALIZAR: 'estoque.visualizar',
  ESTOQUE_GERENCIAR: 'estoque.gerenciar',
  ESTOQUE_MOVIMENTAR: 'estoque.movimentar',
  ESTOQUE_RELATORIOS: 'estoque.relatorios',
  
  // Oficinas Externas
  EXTERNAS_VISUALIZAR: 'externas.visualizar',
  EXTERNAS_GERENCIAR: 'externas.gerenciar',
  
  // Usuários
  USUARIOS_VISUALIZAR: 'usuarios.visualizar',
  USUARIOS_GERENCIAR: 'usuarios.gerenciar',
  
  // Sistema
  SISTEMA_CONFIG: 'sistema.config',
  SISTEMA_TOTAL: 'sistema.total'
} as const

export type PermissaoCodigo = typeof PERMISSOES[keyof typeof PERMISSOES]

// =========================================
// MÓDULOS DO SISTEMA
// =========================================

export const MODULOS = {
  FROTA: 'frota',
  OFICINA: 'oficina',
  ESTOQUE: 'estoque',
  EXTERNAS: 'externas',
  USUARIOS: 'usuarios',
  SISTEMA: 'sistema'
} as const

export type Modulo = typeof MODULOS[keyof typeof MODULOS]

// =========================================
// STATUS E PRIORIDADES
// =========================================

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

export const STATUS_SERVICO_EXTERNO = {
  EM_ANDAMENTO: 'em_andamento',
  CONCLUIDO: 'concluido',
  CANCELADO: 'cancelado'
} as const

export type StatusServicoExterno = typeof STATUS_SERVICO_EXTERNO[keyof typeof STATUS_SERVICO_EXTERNO]

// =========================================
// TIPOS DE VEÍCULO
// =========================================

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

export interface UpdateUsuarioData {
  nome?: string
  cargo_id?: string
  regional_id?: string
  supervisor_id?: string
  ativo?: boolean
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

export interface UpdateVeiculoData {
  modelo?: string
  tipo?: string
  ano?: number
  quilometragem?: number
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
  data_limite?: string
  supervisor_entrega_id?: string
  mecanico_responsavel_id?: string
  observacoes?: string
}

export interface UpdateOrdemServicoData {
  problema_reportado?: string
  diagnostico?: string
  status?: StatusOrdemServico
  prioridade?: Prioridade
  data_saida?: string
  data_limite?: string
  supervisor_retirada_id?: string
  mecanico_responsavel_id?: string
  observacoes?: string
}

export interface CreatePecaData {
  nome: string
  codigo: string
  fornecedor?: string
  custo_unitario: number
  quantidade_estoque: number
  quantidade_minima: number
  unidade?: string
  categoria?: string
  regional_id?: string
}

export interface UpdatePecaData {
  nome?: string
  fornecedor?: string
  custo_unitario?: number
  quantidade_estoque?: number
  quantidade_minima?: number
  unidade?: string
  categoria?: string
  regional_id?: string
  ativo?: boolean
}

export interface CreatePecaUsadaData {
  ordem_servico_id: string
  peca_id: string
  quantidade: number
  custo_unitario: number
  observacoes?: string
}

export interface CreateOficinaExternaData {
  nome: string
  cnpj: string
  endereco?: string
  telefone?: string
  contato?: string
  email?: string
  regional_id?: string
}

export interface UpdateOficinaExternaData {
  nome?: string
  endereco?: string
  telefone?: string
  contato?: string
  email?: string
  regional_id?: string
  ativo?: boolean
}

export interface CreateServicoExternoData {
  ordem_servico_id: string
  oficina_externa_id: string
  descricao: string
  valor: number
  data_retorno?: string
  observacoes?: string
}

export interface UpdateServicoExternoData {
  descricao?: string
  valor?: number
  data_retorno?: string
  status?: StatusServicoExterno
  observacoes?: string
}

// =========================================
// INTERFACES PARA FILTROS E BUSCA
// =========================================

export interface FiltroVeiculos {
  placa?: string
  modelo?: string
  tipo?: string
  status?: StatusVeiculo
  regional_id?: string
  responsavel_id?: string
}

export interface FiltroOrdensServico {
  numero_os?: string
  veiculo_id?: string
  status?: StatusOrdemServico
  prioridade?: Prioridade
  supervisor_entrega_id?: string
  mecanico_responsavel_id?: string
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

export interface FiltroUsuarios {
  nome?: string
  email?: string
  matricula?: string
  cargo_id?: string
  regional_id?: string
  supervisor_id?: string
  ativo?: boolean
}

// =========================================
// INTERFACES PARA RELATÓRIOS
// =========================================

export interface RelatorioFrota {
  total_veiculos: number
  veiculos_ativos: number
  veiculos_manutencao: number
  veiculos_inativos: number
  veiculos_oficina_externa: number
  por_regional: Array<{
    regional: Regional
    total: number
    ativos: number
    manutencao: number
  }>
  por_tipo: Array<{
    tipo: string
    total: number
  }>
}

export interface RelatorioOficina {
  total_ordens: number
  ordens_em_andamento: number
  ordens_concluidas: number
  ordens_canceladas: number
  ordens_oficina_externa: number
  tempo_medio_conclusao: number
  por_prioridade: Array<{
    prioridade: Prioridade
    total: number
  }>
  por_mecanico: Array<{
    mecanico: Usuario
    total: number
    concluidas: number
  }>
}

export interface RelatorioEstoque {
  total_pecas: number
  valor_total_estoque: number
  pecas_baixo_estoque: number
  por_categoria: Array<{
    categoria: string
    total: number
    valor: number
  }>
  por_regional: Array<{
    regional: Regional
    total: number
    valor: number
  }>
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
  servicos_externos: {
    em_andamento: number
    concluidos_mes: number
    valor_total_mes: number
  }
}

// =========================================
// INTERFACES PARA NOTIFICAÇÕES
// =========================================

export interface Notificacao {
  id: string
  tipo: 'info' | 'warning' | 'error' | 'success'
  titulo: string
  mensagem: string
  data: string
  lida: boolean
  usuario_id: string
  link?: string
}

export interface CreateNotificacaoData {
  tipo: Notificacao['tipo']
  titulo: string
  mensagem: string
  usuario_id: string
  link?: string
}
