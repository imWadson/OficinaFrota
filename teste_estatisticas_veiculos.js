// Script de teste para verificar veículos na página de estatísticas
// Execute no console do navegador na página de estatísticas

console.log('🚀 Teste de veículos na página de estatísticas...')

// 1. Verificar dados do usuário
const authStore = useAuthStore()
console.log('📊 Dados do usuário:')
console.log('- User Data:', authStore.userData)
console.log('- Regional Data:', authStore.userRegionalData)
console.log('- Cargo Data:', authStore.userCargoData)

// 2. Testar consulta direta de veículos
async function testarVeiculos() {
  try {
    console.log('🔍 Testando consulta de veículos...')
    
    // Consulta sem filtros
    const { data: todosVeiculos, error: errorTodos } = await supabase
      .from('veiculos')
      .select('*')
      .order('placa')
    
    console.log('📋 Todos os veículos:', todosVeiculos?.length || 0)
    console.log('📋 Dados:', todosVeiculos)
    console.log('❌ Erro:', errorTodos)
    
    // Consulta com regional_id específico
    const regionalId = authStore.userData?.regional_id
    console.log('🔍 Regional ID do usuário:', regionalId)
    
    if (regionalId) {
      const { data: veiculosRegional, error: errorRegional } = await supabase
        .from('veiculos')
        .select('*')
        .eq('regional_id', regionalId)
        .order('placa')
      
      console.log('📋 Veículos da regional:', veiculosRegional?.length || 0)
      console.log('📋 Dados:', veiculosRegional)
      console.log('❌ Erro:', errorRegional)
    }
    
    // 3. Testar repositório
    console.log('🔍 Testando repositório...')
    const veiculoRepository = await import('/src/services/repositories/veiculoRepository.ts')
    const veiculosRepo = await veiculoRepository.veiculoRepository.findAll()
    console.log('📋 Veículos do repositório:', veiculosRepo?.length || 0)
    console.log('📋 Dados:', veiculosRepo)
    
  } catch (error) {
    console.error('💥 Erro no teste:', error)
  }
}

// 4. Verificar se há veículos na página
function verificarVeiculosPagina() {
  console.log('🔍 Verificando veículos na página...')
  
  // Verificar se o select existe
  const selectVeiculos = document.querySelector('select[v-model="veiculoSelecionado"]')
  console.log('📋 Select encontrado:', !!selectVeiculos)
  
  if (selectVeiculos) {
    const options = selectVeiculos.querySelectorAll('option')
    console.log('📋 Opções no select:', options.length)
    
    options.forEach((option, index) => {
      console.log(`  ${index + 1}. ${option.textContent} (${option.value})`)
    })
  }
  
  // Verificar se há dados no Vue
  const app = document.querySelector('#app')
  if (app && app.__vue_app__) {
    console.log('📋 App Vue encontrado')
    // Tentar acessar dados do componente
    console.log('📋 Tentando acessar dados do componente...')
  }
}

// Executar testes
testarVeiculos()
verificarVeiculosPagina()
