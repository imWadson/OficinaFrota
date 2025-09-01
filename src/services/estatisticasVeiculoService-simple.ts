import { supabase } from './supabase'

// =====================================================
// INTERFACES SIMPLIFICADAS - SEM OVERENGINEERING
// =====================================================

export interface EstatisticasVeiculo {
  veiculo: {
    id: string
    placa: string
    modelo: string
    tipo: string
    status: string
    ano: number
    quilometragem: number
  }
  resumo: {
    total_os: number
    custo_total: number
    ultima_visita: string | null
  }
  oficina_interna: {
    total_visitas: number
    custo_total: number
  }
  oficina_externa: {
    total_visitas: number
    custo_total: number
  }
  problemas_comuns: Array<{
    tipo: string
    quantidade: number
  }>
  pecas_utilizadas: Array<{
    nome: string
    quantidade: number
  }>
  historico: Array<{
    id: string
    data: string
    tipo: string
    descricao: string
    custo: number
  }>
}

export interface FiltroEstatisticas {
  veiculo_id: string
  periodo: 'mes' | 'trimestre' | 'ano' | 'todos'
}

// =====================================================
// FUNÇÕES SIMPLIFICADAS - SEM OVERENGINEERING
// =====================================================

/**
 * Busca estatísticas básicas de um veículo
 */
export async function buscarEstatisticasVeiculo(filtro: FiltroEstatisticas): Promise<EstatisticasVeiculo> {
  try {
    // 1. Buscar dados do veículo
    const veiculo = await buscarDadosVeiculo(filtro.veiculo_id)
    if (!veiculo) throw new Error('Veículo não encontrado')

    // 2. Buscar ordens de serviço
    const os = await buscarOrdensServico(filtro)

    // 3. Calcular estatísticas básicas
    const resumo = calcularResumoBasico(os)
    const oficinaInterna = calcularOficinaInterna(os)
    const oficinaExterna = calcularOficinaExterna(os)
    const problemas = analisarProblemas(os)
    const pecas = analisarPecas(os)
    const historico = criarHistorico(os)

    return {
      veiculo,
      resumo,
      oficina_interna: oficinaInterna,
      oficina_externa: oficinaExterna,
      problemas_comuns: problemas,
      pecas_utilizadas: pecas,
      historico
    }
  } catch (error) {
    console.error('Erro ao buscar estatísticas:', error)
    throw error
  }
}

/**
 * Busca dados básicos do veículo
 */
async function buscarDadosVeiculo(veiculoId: string) {
  const { data, error } = await supabase
    .from('veiculos')
    .select('id, placa, modelo, tipo, status, ano, quilometragem')
    .eq('id', veiculoId)
    .single()

  if (error) throw error
  return data ? {
    ...data,
    ano: data.ano || 0
  } : null
}

/**
 * Busca ordens de serviço do veículo
 */
async function buscarOrdensServico(filtro: FiltroEstatisticas) {
  const dataInicio = getDataInicio(filtro.periodo)

  const { data, error } = await supabase
    .from('ordens_servico')
    .select(`
      id,
      problema_reportado,
      status,
      data_entrada,
      data_saida,
      criado_em
    `)
    .eq('veiculo_id', filtro.veiculo_id)
    .gte('criado_em', dataInicio)
    .order('criado_em', { ascending: false })

  if (error) throw error
  return data || []
}

/**
 * Calcula resumo básico
 */
function calcularResumoBasico(os: any[]) {
  const totalOS = os.length
  const custoTotal = 0 // Não temos custo_total na tabela
  const ultimaVisita = os.length > 0 ? os[0].criado_em : null

  return {
    total_os: totalOS,
    custo_total: custoTotal,
    ultima_visita: ultimaVisita
  }
}

/**
 * Calcula estatísticas da oficina interna
 */
function calcularOficinaInterna(os: any[]) {
  const osInterna = os.filter(os => os.status !== 'oficina_externa')

  return {
    total_visitas: osInterna.length,
    custo_total: 0 // Não temos custo_total na tabela
  }
}

/**
 * Calcula estatísticas da oficina externa
 */
function calcularOficinaExterna(os: any[]) {
  const osExterna = os.filter(os => os.status === 'oficina_externa')

  return {
    total_visitas: osExterna.length,
    custo_total: 0 // Não temos custo_total na tabela
  }
}

/**
 * Analisa problemas mais comuns
 */
function analisarProblemas(os: any[]) {
  const problemas: { [key: string]: number } = {}

  os.forEach(os => {
    const tipo = os.problema_reportado?.split(' ')[0] || 'Geral'
    problemas[tipo] = (problemas[tipo] || 0) + 1
  })

  return Object.entries(problemas)
    .map(([tipo, quantidade]) => ({ tipo, quantidade }))
    .sort((a, b) => b.quantidade - a.quantidade)
    .slice(0, 5) // Top 5 problemas
}

/**
 * Analisa peças mais utilizadas (simplificado)
 */
function analisarPecas(os: any[]) {
  // Por enquanto retorna array vazio - implementar quando necessário
  return []
}

/**
 * Cria histórico simplificado
 */
function criarHistorico(os: any[]) {
  return os.slice(0, 20).map(os => ({
    id: os.id,
    data: os.criado_em,
    tipo: os.status,
    descricao: os.problema_reportado,
    custo: 0 // Não temos custo_total na tabela
  }))
}

/**
 * Calcula data de início baseada no período
 */
function getDataInicio(periodo: string): string {
  const hoje = new Date()

  switch (periodo) {
    case 'mes':
      return new Date(hoje.getFullYear(), hoje.getMonth(), 1).toISOString()
    case 'trimestre':
      return new Date(hoje.getFullYear(), Math.floor(hoje.getMonth() / 3) * 3, 1).toISOString()
    case 'ano':
      return new Date(hoje.getFullYear(), 0, 1).toISOString()
    case 'todos':
      return new Date(2000, 0, 1).toISOString()
    default:
      return new Date(hoje.getFullYear(), 0, 1).toISOString()
  }
}
