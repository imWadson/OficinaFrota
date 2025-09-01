import { ref, computed } from 'vue'
import { buscarEstatisticasVeiculo, type EstatisticasVeiculo, type FiltroEstatisticas } from '../../../services/estatisticasVeiculoService-simple'

export function useEstatisticasVeiculo() {
  // Estado
  const estatisticas = ref<EstatisticasVeiculo | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)
  const veiculoSelecionado = ref<string>('')
  const periodoAtivo = ref<'mes' | 'trimestre' | 'ano' | 'todos'>('ano')

  // Computed
  const temEstatisticas = computed(() => estatisticas.value !== null)
  const veiculoInfo = computed(() => estatisticas.value?.veiculo)
  const resumo = computed(() => estatisticas.value?.resumo)
  const oficinaInterna = computed(() => estatisticas.value?.oficina_interna)
  const oficinaExterna = computed(() => estatisticas.value?.oficina_externa)
  const distribuicao = computed(() => {
    if (!estatisticas.value) return null
    const totalVisitas = estatisticas.value.oficina_interna.total_visitas + estatisticas.value.oficina_externa.total_visitas
    if (totalVisitas === 0) return { oficina_interna: 0, oficina_externa: 0 }
    return {
      oficina_interna: Math.round((estatisticas.value.oficina_interna.total_visitas / totalVisitas) * 100),
      oficina_externa: Math.round((estatisticas.value.oficina_externa.total_visitas / totalVisitas) * 100)
    }
  })
  const problemas = computed(() => estatisticas.value?.problemas_comuns)
  const pecas = computed(() => estatisticas.value?.pecas_utilizadas)
  const custos = computed(() => {
    if (!estatisticas.value) return null
    return {
      oficina_interna: estatisticas.value.oficina_interna.custo_total,
      oficina_externa: estatisticas.value.oficina_externa.custo_total,
      pecas: 0,
      total: estatisticas.value.oficina_interna.custo_total + estatisticas.value.oficina_externa.custo_total,
      por_mes: []
    }
  })
  const historico = computed(() => estatisticas.value?.historico)
  const analiseTemporal = computed(() => null) // Não implementado no serviço simplificado

  // Métodos
  const carregarEstatisticas = async (veiculoId: string, periodo?: 'mes' | 'trimestre' | 'ano' | 'todos') => {
    if (!veiculoId) return

    try {
      isLoading.value = true
      error.value = null
      veiculoSelecionado.value = veiculoId

      if (periodo) {
        periodoAtivo.value = periodo
      }

      const filtro: FiltroEstatisticas = {
        veiculo_id: veiculoId,
        periodo: periodoAtivo.value
      }

      const resultado = await buscarEstatisticasVeiculo(filtro)
      estatisticas.value = resultado
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erro ao carregar estatísticas'
      console.error('Erro ao carregar estatísticas:', err)
    } finally {
      isLoading.value = false
    }
  }

  const alterarPeriodo = async (novoPeriodo: 'mes' | 'trimestre' | 'ano' | 'todos') => {
    if (novoPeriodo === periodoAtivo.value) return

    periodoAtivo.value = novoPeriodo

    if (veiculoSelecionado.value) {
      await carregarEstatisticas(veiculoSelecionado.value, novoPeriodo)
    }
  }

  const limparEstatisticas = () => {
    estatisticas.value = null
    veiculoSelecionado.value = ''
    error.value = null
    isLoading.value = false
  }

  const exportarRelatorio = async () => {
    if (!estatisticas.value) return

    try {
      // Implementar exportação para Excel/CSV
      const dados = {
        veiculo: estatisticas.value.veiculo,
        periodo: periodoAtivo.value,
        estatisticas: estatisticas.value,
        data_exportacao: new Date().toISOString()
      }

      // Criar arquivo para download
      const blob = new Blob([JSON.stringify(dados, null, 2)], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `estatisticas_${estatisticas.value.veiculo.placa}_${periodoAtivo.value}.json`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    } catch (err) {
      error.value = 'Erro ao exportar relatório'
      console.error('Erro ao exportar:', err)
    }
  }

  const gerarPDF = async () => {
    if (!estatisticas.value) return

    try {
      // Implementar geração de PDF
      console.log('Gerando PDF para:', estatisticas.value.veiculo.placa)

      // Aqui você pode integrar com uma biblioteca como jsPDF ou usar uma API
      // Por enquanto, apenas simular
      await new Promise(resolve => setTimeout(resolve, 1000))

      // Simular download
      const dados = {
        veiculo: estatisticas.value.veiculo,
        periodo: periodoAtivo.value,
        estatisticas: estatisticas.value
      }

      console.log('PDF gerado com sucesso:', dados)
    } catch (err) {
      error.value = 'Erro ao gerar PDF'
      console.error('Erro ao gerar PDF:', err)
    }
  }

  // Análises computadas
  const analiseCustos = computed(() => {
    if (!custos.value) return null

    const { oficina_interna, oficina_externa, pecas, total } = custos.value

    return {
      percentualOficinaInterna: total > 0 ? Math.round((oficina_interna / total) * 100) : 0,
      percentualOficinaExterna: total > 0 ? Math.round((oficina_externa / total) * 100) : 0,
      percentualPecas: total > 0 ? Math.round((pecas / total) * 100) : 0,
      custoMedioPorOS: estatisticas.value?.resumo.total_os > 0
        ? Math.round(total / estatisticas.value.resumo.total_os)
        : 0
    }
  })

  const analiseFrequencia = computed(() => {
    if (!oficinaInterna.value || !oficinaExterna.value) return null

    const totalVisitas = oficinaInterna.value.total_visitas + oficinaExterna.value.total_visitas

    return {
      totalVisitas,
      mediaVisitasPorMes: totalVisitas > 0 ? Math.round(totalVisitas / 12) : 0,
      frequenciaOficinaInterna: oficinaInterna.value.media_dias_entre_visitas,
      frequenciaOficinaExterna: oficinaExterna.value.media_dias_entre_visitas,
      recomendacao: getRecomendacaoManutencao(
        oficinaInterna.value.media_dias_entre_visitas,
        oficinaExterna.value.media_dias_entre_visitas
      )
    }
  })

  const analiseProblemas = computed(() => {
    if (!problemas.value || problemas.value.length === 0) return null

    const problemaMaisFrequente = problemas.value[0]
    const totalProblemas = problemas.value.reduce((acc, p) => acc + p.quantidade, 0)
    const custoTotalProblemas = problemas.value.reduce((acc, p) => acc + p.custo_total, 0)

    return {
      problemaMaisFrequente,
      totalProblemas,
      custoTotalProblemas,
      problemaMaisCustoso: problemas.value.reduce((max, p) =>
        p.custo_total > max.custo_total ? p : max
      ),
      distribuicaoProblemas: problemas.value.map(p => ({
        tipo: p.tipo,
        percentual: Math.round((p.quantidade / totalProblemas) * 100)
      }))
    }
  })

  const analisePecas = computed(() => {
    if (!pecas.value || pecas.value.length === 0) return null

    const pecaMaisUtilizada = pecas.value[0]
    const totalPecas = pecas.value.reduce((acc, p) => acc + p.quantidade, 0)
    const custoTotalPecas = pecas.value.reduce((acc, p) => acc + p.custo_total, 0)

    return {
      pecaMaisUtilizada,
      totalPecas,
      custoTotalPecas,
      pecaMaisCustosa: pecas.value.reduce((max, p) =>
        p.custo_total > max.custo_total ? p : max
      ),
      mediaCustoPorPeca: Math.round(custoTotalPecas / totalPecas)
    }
  })

  // Funções auxiliares
  const getRecomendacaoManutencao = (mediaInterna: number, mediaExterna: number): string => {
    const mediaGeral = Math.round((mediaInterna + mediaExterna) / 2)

    if (mediaGeral <= 30) {
      return 'Manutenção muito frequente - verificar se há problemas recorrentes'
    } else if (mediaGeral <= 60) {
      return 'Frequência de manutenção adequada'
    } else if (mediaGeral <= 90) {
      return 'Manutenção preventiva pode ser otimizada'
    } else {
      return 'Manutenção preventiva muito espaçada - risco de falhas'
    }
  }

  const getIndicadorSaude = computed(() => {
    if (!estatisticas.value) return 'N/A'

    const { eficiencia, custo_total, total_os } = estatisticas.value.resumo

    // Algoritmo simples para calcular saúde do veículo
    let pontuacao = 0

    // Eficiência (0-100 pontos)
    pontuacao += eficiencia * 0.4

    // Custo por OS (0-40 pontos)
    const custoMedio = total_os > 0 ? custo_total / total_os : 0
    if (custoMedio <= 500) pontuacao += 40
    else if (custoMedio <= 1000) pontuacao += 30
    else if (custoMedio <= 2000) pontuacao += 20
    else pontuacao += 10

    // Frequência de manutenção (0-20 pontos)
    const mediaVisitas = analiseFrequencia.value?.mediaVisitasPorMes || 0
    if (mediaVisitas <= 1) pontuacao += 20
    else if (mediaVisitas <= 2) pontuacao += 15
    else if (mediaVisitas <= 3) pontuacao += 10
    else pontuacao += 5

    // Classificar saúde
    if (pontuacao >= 80) return { nivel: 'Excelente', cor: 'text-green-600', bg: 'bg-green-100' }
    if (pontuacao >= 60) return { nivel: 'Boa', cor: 'text-blue-600', bg: 'bg-blue-100' }
    if (pontuacao >= 40) return { nivel: 'Regular', cor: 'text-yellow-600', bg: 'bg-yellow-100' }
    return { nivel: 'Precisa Atenção', cor: 'text-red-600', bg: 'bg-red-100' }
  })

  return {
    // Estado
    estatisticas,
    isLoading,
    error,
    veiculoSelecionado,
    periodoAtivo,

    // Computed
    temEstatisticas,
    veiculoInfo,
    resumo,
    oficinaInterna,
    oficinaExterna,
    distribuicao,
    problemas,
    pecas,
    custos,
    historico,
    analiseTemporal,

    // Análises
    analiseCustos,
    analiseFrequencia,
    analiseProblemas,
    analisePecas,
    getIndicadorSaude,

    // Métodos
    carregarEstatisticas,
    alterarPeriodo,
    limparEstatisticas,
    exportarRelatorio,
    gerarPDF
  }
}
