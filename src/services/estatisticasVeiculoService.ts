import { supabase } from './supabase'

export interface EstatisticasVeiculo {
  veiculo: {
    id: string
    placa: string
    modelo: string
    tipo: string
    status: string
    ano_fabricacao: string
    marca: string
    km_atual: number
  }
  resumo: {
    total_os: number
    dias_operacao: number
    custo_total: number
    eficiencia: number
    km_total_percorrido: number
    media_km_diaria: number
  }
  oficina_interna: {
    total_visitas: number
    ultima_visita: string | null
    media_dias_entre_visitas: number
    total_dias: number
    custo_total: number
    os_por_mes: number
  }
  oficina_externa: {
    total_visitas: number
    ultima_visita: string | null
    media_dias_entre_visitas: number
    total_dias: number
    custo_total: number
    os_por_mes: number
    oficinas_utilizadas: Array<{
      nome: string
      quantidade: number
      custo_total: number
    }>
  }
  distribuicao: {
    oficina_interna: number
    oficina_externa: number
  }
  problemas_mais_comuns: Array<{
    tipo: string
    quantidade: number
    custo_total: number
    ultima_ocorrencia: string
  }>
  pecas_mais_utilizadas: Array<{
    nome: string
    quantidade: number
    custo_total: number
    ultima_troca: string
  }>
  custos: {
    oficina_interna: number
    oficina_externa: number
    pecas: number
    total: number
    por_mes: Array<{
      mes: string
      total: number
      oficina_interna: number
      oficina_externa: number
      pecas: number
    }>
  }
  historico: Array<{
    id: string
    data: string
    tipo: 'oficina_interna' | 'oficina_externa' | 'peca' | 'manutencao'
    descricao: string
    detalhes?: string
    custo: number
    status: string
    km_veiculo?: number
    supervisor?: string
  }>
  analise_temporal: {
    os_por_mes: Array<{
      mes: string
      quantidade: number
      custo: number
    }>
    custos_por_mes: Array<{
      mes: string
      total: number
      oficina_interna: number
      oficina_externa: number
      pecas: number
    }>
    problemas_por_mes: Array<{
      mes: string
      quantidade: number
      tipos: string[]
    }>
  }
}

export interface FiltroEstatisticas {
  veiculo_id: string
  periodo: 'mes' | 'trimestre' | 'ano' | 'todos'
  data_inicio?: string
  data_fim?: string
}

class EstatisticasVeiculoService {
  /**
   * Busca estatísticas completas de um veículo
   */
  async buscarEstatisticas(filtro: FiltroEstatisticas): Promise<EstatisticasVeiculo> {
    try {
      const { data: veiculoData, error: veiculoError } = await this.buscarDadosVeiculo(filtro.veiculo_id)
      if (veiculoError) throw veiculoError
      if (!veiculoData) throw new Error('Veículo não encontrado')

      // Mapear dados do veículo para o formato esperado
      const veiculo = {
        id: veiculoData.id,
        placa: veiculoData.placa,
        modelo: veiculoData.modelo,
        tipo: veiculoData.tipo,
        status: veiculoData.status,
        ano_fabricacao: veiculoData.ano?.toString() || 'N/A',
        marca: 'N/A', // Não temos marca na tabela
        km_atual: veiculoData.quilometragem || 0
      }

      const [
        resumo,
        oficinaInterna,
        oficinaExterna,
        problemas,
        pecas,
        historico,
        analiseTemporal
      ] = await Promise.all([
        this.calcularResumo(filtro),
        this.calcularOficinaInterna(filtro),
        this.calcularOficinaExterna(filtro),
        this.analisarProblemas(filtro),
        this.analisarPecas(filtro),
        this.buscarHistorico(filtro),
        this.analisarTemporal(filtro)
      ])

      const custos = this.calcularCustos(oficinaInterna, oficinaExterna, pecas)
      const distribuicao = this.calcularDistribuicao(oficinaInterna, oficinaExterna)

      return {
        veiculo,
        resumo,
        oficina_interna: oficinaInterna,
        oficina_externa: oficinaExterna,
        distribuicao,
        problemas_mais_comuns: problemas,
        pecas_mais_utilizadas: pecas,
        custos,
        historico,
        analise_temporal: analiseTemporal
      }
    } catch (error) {
      console.error('Erro ao buscar estatísticas:', error)
      throw error
    }
  }

  /**
   * Busca dados básicos do veículo
   */
  private async buscarDadosVeiculo(veiculoId: string) {
    const { data, error } = await supabase
      .from('veiculos')
      .select('id, placa, modelo, tipo, status, ano, quilometragem')
      .eq('id', veiculoId)
      .single()

    return { data, error }
  }

  /**
   * Calcula resumo geral do veículo
   */
  private async calcularResumo(filtro: FiltroEstatisticas) {
    const { data: os, error } = await supabase
      .from('ordens_servico')
      .select('id, status, criado_em, data_entrada, data_saida')
      .eq('veiculo_id', filtro.veiculo_id)
      .gte('criado_em', this.getDataInicio(filtro.periodo))

    if (error) throw error

    const totalOS = os?.length || 0
    const diasOperacao = this.calcularDiasOperacao(filtro.veiculo_id, filtro.periodo)
    const eficiencia = this.calcularEficiencia(os || [])

    return {
      total_os: totalOS,
      dias_operacao: diasOperacao,
      custo_total: 0, // Não temos custo_total na tabela
      eficiencia,
      km_total_percorrido: 0, // Implementar cálculo de KM
      media_km_diaria: 0 // Implementar cálculo de KM
    }
  }

  /**
   * Calcula estatísticas da oficina interna
   */
  private async calcularOficinaInterna(filtro: FiltroEstatisticas) {
    const { data: os, error } = await supabase
      .from('ordens_servico')
      .select('id, status, criado_em, data_entrada, data_saida')
      .eq('veiculo_id', filtro.veiculo_id)
      .neq('status', 'oficina_externa')
      .gte('criado_em', this.getDataInicio(filtro.periodo))
      .order('criado_em', { ascending: false })

    if (error) throw error

    const totalVisitas = os?.length || 0
    const ultimaVisita = os?.[0]?.criado_em || null
    const mediaDias = this.calcularMediaDiasEntreVisitas(os || [])
    const totalDias = this.calcularTotalDias(os || [])
    const osPorMes = this.calcularOSPorMes(os || [])

    return {
      total_visitas: totalVisitas,
      ultima_visita: ultimaVisita,
      media_dias_entre_visitas: mediaDias,
      total_dias: totalDias,
      custo_total: 0, // Não temos custo_total na tabela
      os_por_mes: osPorMes
    }
  }

  /**
   * Calcula estatísticas da oficina externa
   */
  private async calcularOficinaExterna(filtro: FiltroEstatisticas) {
    const { data: os, error } = await supabase
      .from('ordens_servico')
      .select('id, status, criado_em, data_entrada, data_saida')
      .eq('veiculo_id', filtro.veiculo_id)
      .eq('status', 'oficina_externa')
      .gte('criado_em', this.getDataInicio(filtro.periodo))
      .order('criado_em', { ascending: false })

    if (error) throw error

    const totalVisitas = os?.length || 0
    const ultimaVisita = os?.[0]?.criado_em || null
    const mediaDias = this.calcularMediaDiasEntreVisitas(os || [])
    const totalDias = this.calcularTotalDias(os || [])
    const osPorMes = this.calcularOSPorMes(os || [])
    const oficinasUtilizadas = this.agruparOficinasExternas(os || [])

    return {
      total_visitas: totalVisitas,
      ultima_visita: ultimaVisita,
      media_dias_entre_visitas: mediaDias,
      total_dias: totalDias,
      custo_total: 0, // Não temos custo_total na tabela
      os_por_mes: osPorMes,
      oficinas_utilizadas: oficinasUtilizadas
    }
  }

  /**
   * Analisa problemas mais comuns
   */
  private async analisarProblemas(filtro: FiltroEstatisticas) {
    const { data: os, error } = await supabase
      .from('ordens_servico')
      .select('problema_reportado, criado_em')
      .eq('veiculo_id', filtro.veiculo_id)
      .gte('criado_em', this.getDataInicio(filtro.periodo))

    if (error) throw error

    const problemas = os?.reduce((acc, os) => {
      const tipo = os.problema_reportado || 'Não especificado'
      const existing = acc.find((p: any) => p.tipo === tipo)

      if (existing) {
        existing.quantidade++
        if (os.criado_em > existing.ultima_ocorrencia) {
          existing.ultima_ocorrencia = os.criado_em
        }
      } else {
        acc.push({
          tipo,
          quantidade: 1,
          custo_total: 0, // Não temos custo_total na tabela
          ultima_ocorrencia: os.criado_em
        })
      }

      return acc
    }, [] as Array<{
      tipo: string
      quantidade: number
      custo_total: number
      ultima_ocorrencia: string
    }>)

    return (problemas || []).sort((a: any, b: any) => b.quantidade - a.quantidade).slice(0, 5)
  }

  /**
   * Analisa peças mais utilizadas
   */
  private async analisarPecas(filtro: FiltroEstatisticas) {
    // Por enquanto, retornar array vazio para evitar loops
    return []
  }

  /**
   * Busca histórico completo
   */
  private async buscarHistorico(filtro: FiltroEstatisticas) {
    const { data: historico, error } = await supabase
      .from('ordens_servico')
      .select(`
        id,
        criado_em,
        problema_reportado,
        diagnostico,
        status,
        supervisor_entrega_id,
        data_entrada,
        data_saida
      `)
      .eq('veiculo_id', filtro.veiculo_id)
      .gte('criado_em', this.getDataInicio(filtro.periodo))
      .order('criado_em', { ascending: false })

    if (error) throw error

    return (historico || []).map(item => ({
      id: item.id,
      data: item.criado_em,
      tipo: this.mapearTipoServico(item.status),
      descricao: item.problema_reportado || 'Manutenção',
      detalhes: item.diagnostico,
      custo: 0, // Não temos custo na tabela
      status: item.status,
      km_veiculo: 0, // Não temos km na tabela
      supervisor: item.supervisor_entrega_id
    }))
  }

  /**
   * Analisa dados temporais
   */
  private async analisarTemporal(filtro: FiltroEstatisticas) {
    // Implementar análise temporal com agrupamento por mês
    return {
      os_por_mes: [],
      custos_por_mes: [],
      problemas_por_mes: []
    }
  }

  /**
   * Calcula custos totais
   */
  private calcularCustos(oficinaInterna: any, oficinaExterna: any, pecas: any[]) {
    const custoPecas = pecas.reduce((acc, peca) => acc + peca.custo_total, 0)
    const total = oficinaInterna.custo_total + oficinaExterna.custo_total + custoPecas

    return {
      oficina_interna: oficinaInterna.custo_total,
      oficina_externa: oficinaExterna.custo_total,
      pecas: custoPecas,
      total,
      por_mes: [] // Implementar custos por mês
    }
  }

  /**
   * Calcula distribuição entre oficinas
   */
  private calcularDistribuicao(oficinaInterna: any, oficinaExterna: any) {
    const total = oficinaInterna.total_visitas + oficinaExterna.total_visitas

    if (total === 0) return { oficina_interna: 0, oficina_externa: 0 }

    return {
      oficina_interna: Math.round((oficinaInterna.total_visitas / total) * 100),
      oficina_externa: Math.round((oficinaExterna.total_visitas / total) * 100)
    }
  }

  /**
   * Agrupa oficinas externas utilizadas
   */
  private agruparOficinasExternas(os: any[]) {
    // Como não temos dados de oficinas externas na estrutura atual,
    // retornamos um array vazio
    return []
  }

  /**
   * Mapeia status para tipo de serviço
   */
  private mapearTipoServico(status: string): 'oficina_interna' | 'oficina_externa' | 'peca' | 'manutencao' {
    if (status === 'oficina_externa') {
      return 'oficina_externa'
    }
    return 'oficina_interna'
  }

  /**
   * Calcula data de início baseada no período
   */
  private getDataInicio(periodo: string): string {
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

  /**
   * Calcula dias de operação
   */
  private calcularDiasOperacao(veiculoId: string, periodo: string): number {
    // Implementar cálculo real baseado na data de aquisição e período
    return 730 // Valor simulado
  }

  /**
   * Calcula eficiência do veículo
   */
  private calcularEficiencia(os: any[]): number {
    if (os.length === 0) return 100

    const osConcluidas = os.filter(os => os.status === 'concluida').length
    return Math.round((osConcluidas / os.length) * 100)
  }

  /**
   * Calcula média de dias entre visitas
   */
  private calcularMediaDiasEntreVisitas(os: any[]): number {
    if (os.length < 2) return 0

    const datas = os
      .map(os => new Date(os.criado_em))
      .sort((a, b) => a.getTime() - b.getTime())

    let totalDias = 0
    for (let i = 1; i < datas.length; i++) {
      const diffTime = Math.abs(datas[i].getTime() - datas[i - 1].getTime())
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
      totalDias += diffDays
    }

    return Math.round(totalDias / (datas.length - 1))
  }

  /**
   * Calcula total de dias em manutenção
   */
  private calcularTotalDias(os: any[]): number {
    return os.reduce((acc, os) => {
      if (os.data_entrada && os.data_saida) {
        const inicio = new Date(os.data_entrada)
        const fim = new Date(os.data_saida)
        const diffTime = Math.abs(fim.getTime() - inicio.getTime())
        return acc + Math.ceil(diffTime / (1000 * 60 * 60 * 24))
      }
      return acc
    }, 0)
  }

  /**
   * Calcula OS por mês
   */
  private calcularOSPorMes(os: any[]): number {
    if (os.length === 0) return 0

    const hoje = new Date()
    const mesAtual = hoje.getMonth()
    const anoAtual = hoje.getFullYear()

    const osMesAtual = os.filter(os => {
      const dataOS = new Date(os.criado_em)
      return dataOS.getMonth() === mesAtual && dataOS.getFullYear() === anoAtual
    })

    return osMesAtual.length
  }
}

export const estatisticasVeiculoService = new EstatisticasVeiculoService()
