import { supabase } from '../supabase'

export interface PecaUsada {
  id: number
  ordem_servico_id: number
  peca_id: number
  quantidade: number
  data_uso: string
  supervisor_id?: number
  // Joins
  pecas?: {
    nome: string
    codigo: string
    custo_unitario: number
  }
}

export interface PecaUsadaInsert {
  ordem_servico_id: number
  peca_id: number
  quantidade: number
  supervisor_id?: number
}

export const pecasUsadasRepository = {
  async findByOrdemServico(ordemServicoId: number) {
    const { data, error } = await supabase
      .from('pecas_usadas')
      .select(`
        *,
        pecas(nome, codigo, custo_unitario)
      `)
      .eq('ordem_servico_id', ordemServicoId)
      .order('data_uso', { ascending: false })
    
    if (error) throw error
    return data as PecaUsada[]
  },

  async create(pecaUsada: PecaUsadaInsert) {
    // Verificar se há estoque suficiente
    const { data: peca, error: pecaError } = await supabase
      .from('pecas')
      .select('quantidade_estoque')
      .eq('id', pecaUsada.peca_id)
      .single()
    
    if (pecaError) throw pecaError
    
    if (peca.quantidade_estoque < pecaUsada.quantidade) {
      throw new Error('Estoque insuficiente para esta peça')
    }

    // Inserir uso da peça
    const { data, error } = await supabase
      .from('pecas_usadas')
      .insert(pecaUsada)
      .select(`
        *,
        pecas(nome, codigo, custo_unitario)
      `)
      .single()
    
    if (error) throw error

    // Atualizar estoque
    await supabase
      .from('pecas')
      .update({ 
        quantidade_estoque: peca.quantidade_estoque - pecaUsada.quantidade 
      })
      .eq('id', pecaUsada.peca_id)
    
    return data as PecaUsada
  },

  async delete(id: number) {
    // Buscar dados da peça usada para reverter estoque
    const { data: pecaUsada, error: fetchError } = await supabase
      .from('pecas_usadas')
      .select('peca_id, quantidade')
      .eq('id', id)
      .single()
    
    if (fetchError) throw fetchError

    // Deletar registro
    const { error } = await supabase
      .from('pecas_usadas')
      .delete()
      .eq('id', id)
    
    if (error) throw error

    // Reverter estoque
    const { data: peca } = await supabase
      .from('pecas')
      .select('quantidade_estoque')
      .eq('id', pecaUsada.peca_id)
      .single()

    if (peca) {
      await supabase
        .from('pecas')
        .update({ 
          quantidade_estoque: peca.quantidade_estoque + pecaUsada.quantidade 
        })
        .eq('id', pecaUsada.peca_id)
    }
  }
}
