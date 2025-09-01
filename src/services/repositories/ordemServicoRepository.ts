import { supabase } from '../supabase'
import type { OrdemServico, OrdemServicoInsert, OrdemServicoUpdate, OrdemServicoStatusHistory, TempoPorStatus } from '../../entities/ordemServico'

export const ordemServicoRepository = {
  async findAll() {
    const { data, error } = await supabase
      .from('ordens_servico')
      .select(`
        *,
        veiculos(placa, modelo),
        criador:usuarios!criado_por(nome, email)
      `)
      .order('data_entrada', { ascending: false })

    if (error) throw error
    return data
  },

  async findById(id: string) {
    const { data, error } = await supabase
      .from('ordens_servico')
      .select(`
        *,
        veiculos(placa, modelo),
        criador:usuarios!criado_por(nome, email)
      `)
      .eq('id', id)
      .single()

    if (error) throw error
    return data
  },

  async findByVeiculo(veiculoId: string) {
    const { data, error } = await supabase
      .from('ordens_servico')
      .select(`
        *,
        veiculos(placa, modelo),
        criador:usuarios!criado_por(nome, email)
      `)
      .eq('veiculo_id', veiculoId)
      .order('data_entrada', { ascending: false })

    if (error) throw error
    return data
  },

  async create(ordemServico: OrdemServicoInsert) {
    // Obter o usuário atual
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      throw new Error('Usuário não autenticado')
    }

    // Buscar o ID do usuário na tabela usuarios
    const { data: userData, error: userError } = await supabase
      .from('usuarios')
      .select('id')
      .eq('auth_user_id', user.id)
      .single()

    if (userError || !userData) {
      throw new Error('Usuário não encontrado na base de dados')
    }

    // Preparar dados da OS com o criador
    const osData = {
      ...ordemServico,
      criado_por: userData.id
    }

    // Tentar usar a função RPC primeiro
    const { data: rpcData, error: rpcError } = await supabase.rpc('criar_ordem_servico', {
      p_veiculo_id: ordemServico.veiculo_id,
      p_problema_reportado: ordemServico.problema_reportado,
      p_supervisor_entrega_id: ordemServico.supervisor_entrega_id || null,
      p_criado_por: userData.id
    })

    if (rpcError) {
      console.warn('Função RPC não disponível, usando fallback:', rpcError)
      
      // Gerar número da OS para o fallback
      const hoje = new Date().toISOString().slice(0, 10).replace(/-/g, '')
      
      // Buscar última OS do dia de forma mais robusta
      const { data: ultimasOS } = await supabase
        .from('ordens_servico')
        .select('numero_os')
        .ilike('numero_os', `OS-${hoje}-%`)
        .order('numero_os', { ascending: false })
        .limit(1)
      
      let numeroOS = `OS-${hoje}-0001`
      if (ultimasOS && ultimasOS.length > 0 && ultimasOS[0]?.numero_os) {
        const ultimoNumero = parseInt(ultimasOS[0].numero_os.slice(-4))
        numeroOS = `OS-${hoje}-${String(ultimoNumero + 1).padStart(4, '0')}`
      }
      
      // Fallback: criar sem mudança automática de status
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('ordens_servico')
        .insert({
          ...osData,
          numero_os: numeroOS
        })
        .select()
        .single()
      
      if (fallbackError) throw fallbackError
      
      // Atualizar status do veículo manualmente
      await supabase
        .from('veiculos')
        .update({ status: 'manutencao' })
        .eq('id', ordemServico.veiculo_id)
      
      return fallbackData as OrdemServico
    }

    return rpcData as OrdemServico
  },

  async update(id: string, ordemServico: OrdemServicoUpdate) {
    const { data, error } = await supabase
      .from('ordens_servico')
      .update(ordemServico)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error

    // Se a OS foi concluída, atualizar status do veículo para ativo
    if (ordemServico.status === 'concluida') {
      const veiculoId = data.veiculo_id
      await supabase
        .from('veiculos')
        .update({ status: 'ativo' })
        .eq('id', veiculoId)
    }

    return data as OrdemServico
  },

  async concluir(id: string, supervisorRetiradaId: string) {
    const { data, error } = await supabase
      .from('ordens_servico')
      .update({
        status: 'concluida',
        data_saida: new Date().toISOString(),
        supervisor_retirada_id: supervisorRetiradaId
      })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data as OrdemServico
  },

  async getOrdensEmAndamento() {
    const { data, error } = await supabase
      .from('ordens_servico')
      .select(`
        *,
        veiculos(placa, modelo),
        criador:usuarios!criado_por(nome, email)
      `)
      .eq('status', 'em_andamento')
      .order('data_entrada')

    if (error) throw error
    return data
  },

  async getOrdensConcluidas() {
    const { data, error } = await supabase
      .from('ordens_servico')
      .select(`
        *,
        veiculos(placa, modelo),
        criador:usuarios!criado_por(nome, email)
      `)
      .eq('status', 'concluida')
      .order('data_saida', { ascending: false })

    if (error) throw error
    return data
  },

  // Novos métodos para histórico de status
  async getStatusHistory(ordemServicoId: string): Promise<OrdemServicoStatusHistory[]> {
    const { data, error } = await supabase
      .from('ordens_servico_status_history')
      .select(`
        *,
        usuario:usuarios!criado_por(nome, email)
      `)
      .eq('ordem_servico_id', ordemServicoId)
      .order('criado_em', { ascending: true })

    if (error) throw error
    return data || []
  },

  async getTempoPorStatus(ordemServicoId: string): Promise<TempoPorStatus[]> {
    const { data, error } = await supabase
      .rpc('calcular_tempo_por_status', {
        p_ordem_servico_id: ordemServicoId
      })

    if (error) throw error
    return data || []
  },

  async getTempoTotal(ordemServicoId: string): Promise<string> {
    const { data, error } = await supabase
      .rpc('calcular_tempo_total_os', {
        p_ordem_servico_id: ordemServicoId
      })

    if (error) throw error
    return data || '0'
  },

  // Método para mudar status com observação
  async mudarStatus(id: string, novoStatus: string, observacao?: string) {
    // Obter o usuário atual
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      throw new Error('Usuário não autenticado')
    }

    // Buscar o ID do usuário na tabela usuarios
    const { data: userData, error: userError } = await supabase
      .from('usuarios')
      .select('id')
      .eq('auth_user_id', user.id)
      .single()

    if (userError || !userData) {
      throw new Error('Usuário não encontrado na base de dados')
    }

    // Atualizar status da OS
    const { data, error } = await supabase
      .from('ordens_servico')
      .update({ status: novoStatus })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error

    // Registrar no histórico manualmente se necessário
    if (observacao) {
      await supabase
        .from('ordens_servico_status_history')
        .insert({
          ordem_servico_id: id,
          status_novo: novoStatus,
          observacao,
          criado_por: userData.id
        })
    }

    return data as OrdemServico
  }
}
