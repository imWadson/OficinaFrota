import { ref, computed } from 'vue'
import { buscarEstatisticasVeiculo, type EstatisticasVeiculo, type FiltroEstatisticas } from '../../../services/estatisticasVeiculoService-simple'

export function useEstatisticasVeiculo() {
    // Estado essencial apenas
    const estatisticas = ref<EstatisticasVeiculo | null>(null)
    const isLoading = ref(false)
    const error = ref<string | null>(null)
    const periodoAtivo = ref<'mes' | 'trimestre' | 'ano' | 'todos'>('ano')

    // Computed essenciais apenas
    const temEstatisticas = computed(() => estatisticas.value !== null)
    const veiculoInfo = computed(() => estatisticas.value?.veiculo)
    const resumo = computed(() => estatisticas.value?.resumo)

    // Método principal simplificado
    const carregarEstatisticas = async (veiculoId: string, periodo?: 'mes' | 'trimestre' | 'ano' | 'todos') => {
        if (!veiculoId) return

        try {
            isLoading.value = true
            error.value = null

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

    // Alterar período
    const alterarPeriodo = async (novoPeriodo: 'mes' | 'trimestre' | 'ano' | 'todos') => {
        if (novoPeriodo === periodoAtivo.value) return
        periodoAtivo.value = novoPeriodo
    }

    // Limpar estado
    const limparEstatisticas = () => {
        estatisticas.value = null
        error.value = null
        isLoading.value = false
    }

    return {
        // Estado
        estatisticas,
        isLoading,
        error,
        periodoAtivo,

        // Computed
        temEstatisticas,
        veiculoInfo,
        resumo,

        // Métodos
        carregarEstatisticas,
        alterarPeriodo,
        limparEstatisticas
    }
}
