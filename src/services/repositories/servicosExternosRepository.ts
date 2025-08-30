import { supabase } from '../supabase'

export interface ServicoExterno {
  id: number
  ordem_servico_id: number
  oficina_externa_id: number
  descricao: string
  valor: number
  data_envio: string
  data_retorno?: string
  // Joins
  oficinas_externas?: {
    nome: string
    cnpj: string
    telefone?: string
  }
}

export interface ServicoExternoInsert {
  ordem_servico_id: number
  oficina_externa_id: number
  descricao: string
  valor: number
}

export const servicosExternosRepository = {
  async findByOrdemServico(ordemServicoId: number) {
    const { data, error } = await supabase
      .from('servicos_externos')
      .select(`
        *,
        oficinas_externas(nome, cnpj, telefone)
      `)
      .eq('ordem_servico_id', ordemServicoId)
      .order('data_envio', { ascending: false })
    
    if (error) throw error
    return data as ServicoExterno[]
  },

  async create(servico: ServicoExternoInsert) {
    const { data, error } = await supabase
      .from('servicos_externos')
      .insert(servico)
      .select(`
        *,
        oficinas_externas(nome, cnpj, telefone)
      `)
      .single()
    
    if (error) throw error
    return data as ServicoExterno
  },

  async finalizarServico(id: number, dataRetorno?: string) {
    const { data, error } = await supabase
      .from('servicos_externos')
      .update({ 
        data_retorno: dataRetorno || new Date().toISOString() 
      })
      .eq('id', id)
      .select(`
        *,
        oficinas_externas(nome, cnpj, telefone)
      `)
      .single()
    
    if (error) throw error
    return data as ServicoExterno
  },

  async delete(id: number) {
    const { error } = await supabase
      .from('servicos_externos')
      .delete()
      .eq('id', id)
    
    if (error) throw error
  }
}
