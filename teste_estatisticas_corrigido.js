// Script de teste para verificar se as correções no serviço de estatísticas funcionaram
// Execute no console do navegador na página de estatísticas

console.log('🚀 Teste das correções no serviço de estatísticas...')

// 1. Verificar se o veículo ainda aparece no dropdown
function verificarVeiculoDropdown() {
    console.log('🔍 Verificando veículo no dropdown...')

    const selectVeiculos = document.querySelector('select[v-model="veiculoSelecionado"]')
    if (selectVeiculos) {
        const options = selectVeiculos.querySelectorAll('option')
        console.log('📋 Opções no select:', options.length)

        options.forEach((option, index) => {
            console.log(`  ${index + 1}. ${option.textContent} (${option.value})`)
        })
    } else {
        console.log('❌ Select não encontrado')
    }
}

// 2. Testar seleção de veículo
async function testarSelecaoVeiculo() {
    console.log('🔍 Testando seleção de veículo...')

    const selectVeiculos = document.querySelector('select[v-model="veiculoSelecionado"]')
    if (selectVeiculos && selectVeiculos.options.length > 1) {
        // Selecionar o primeiro veículo (pular a opção vazia)
        const primeiroVeiculo = selectVeiculos.options[1]
        console.log('🎯 Selecionando veículo:', primeiroVeiculo.textContent)

        // Simular mudança no select
        selectVeiculos.value = primeiroVeiculo.value
        selectVeiculos.dispatchEvent(new Event('change'))

        console.log('✅ Veículo selecionado, aguardando carregamento...')

        // Aguardar um pouco e verificar se há erros
        setTimeout(() => {
            console.log('🔍 Verificando se há erros no console...')
            console.log('📋 Se não houver erros acima, as correções funcionaram!')
        }, 3000)
    } else {
        console.log('❌ Nenhum veículo disponível para teste')
    }
}

// 3. Verificar estrutura da tabela ordens_servico
async function verificarEstruturaTabela() {
    console.log('🔍 Verificando estrutura da tabela ordens_servico...')

    try {
        const { data, error } = await supabase
            .from('ordens_servico')
            .select('*')
            .limit(1)

        if (error) {
            console.error('❌ Erro ao consultar ordens_servico:', error)
        } else {
            console.log('✅ Estrutura da tabela ordens_servico:')
            console.log('📋 Colunas disponíveis:', Object.keys(data?.[0] || {}))
        }
    } catch (error) {
        console.error('💥 Erro ao verificar estrutura:', error)
    }
}

// Executar testes
verificarVeiculoDropdown()
testarSelecaoVeiculo()
verificarEstruturaTabela()

console.log('🎯 Testes iniciados. Verifique o console para resultados.')
