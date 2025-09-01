import { supabase } from '../supabase'
import type { OrdemServico, OrdemServicoInsert, OrdemServicoUpdate } from '../../entities/ordemServico'

export const ordemServicoRepository = {
  async findAll() {
    const { data, error } = await supabase
      .from('ordens_servico')
      .select(`
        *,
        veiculos(placa, modelo)
      `)
      .order('data_entrada', { ascending: false })
    
    if (error) throw error
    return data
  },

  async findById(id: number) {
    const { data, error } = await supabase
      .from('ordens_servico')
      .select(`
        *,
        veiculos(placa, modelo)
      `)
      .eq('id', id)
      .single()
    
    if (error) throw error
    return data
  },

  async findByVeiculo(veiculoId: number) {
    const { data, error } = await supabase
      .from('ordens_servico')
      .select(`
        *,
        veiculos(placa, modelo)
      `)
      .eq('veiculo_id', veiculoId)
      .order('data_entrada', { ascending: false })
    
    if (error) throw error
    return data
  },

  async create(ordemServico: OrdemServicoInsert) {
    // Usar transação para criar OS e atualizar status do veículo
    const { data, error } = await supabase.rpc('criar_ordem_servico', {
      p_veiculo_id: ordemServico.veiculo_id,
      p_problema_reportado: ordemServico.problema_reportado,
      p_supervisor_entrega_id: ordemServico.supervisor_entrega_id
    })
    
    if (error) {
      // Fallback: criar sem mudança automática de status
      const { data: osData, error: osError } = await supabase
        .from('ordens_servico')
        .insert(ordemServico)
        .select()
        .single()
      
      if (osError) throw osError
      
      // Atualizar status do veículo manualmente
      await supabase
        .from('veiculos')
        .update({ status: 'manutencao' })
        .eq('id', ordemServico.veiculo_id)
      
      return osData as OrdemServico
    }
    
    return data as OrdemServico
  },

  async update(id: number, ordemServico: OrdemServicoUpdate) {
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

  async concluir(id: number, supervisorRetiradaId: number) {
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
        veiculos(placa, modelo)
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
        veiculos(placa, modelo)
      `)
      .eq('status', 'concluida')
      .order('data_saida', { ascending: false })
    
    if (error) throw error
    return data
  }
}
