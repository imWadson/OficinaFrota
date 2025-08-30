import { supabase } from '../supabase'
import type { Peca, PecaInsert, PecaUpdate } from '../../entities/peca'

export const pecaRepository = {
  async findAll() {
    const { data, error } = await supabase
      .from('pecas')
      .select('*')
      .order('nome')
    
    if (error) throw error
    return data as Peca[]
  },

  async findById(id: number) {
    const { data, error } = await supabase
      .from('pecas')
      .select('*')
      .eq('id', id)
      .single()
    
    if (error) throw error
    return data as Peca
  },

  async findByCodigo(codigo: string) {
    const { data, error } = await supabase
      .from('pecas')
      .select('*')
      .eq('codigo', codigo)
      .single()
    
    if (error) throw error
    return data as Peca
  },

  async create(peca: PecaInsert) {
    const { data, error } = await supabase
      .from('pecas')
      .insert(peca)
      .select()
      .single()
    
    if (error) throw error
    return data as Peca
  },

  async update(id: number, peca: PecaUpdate) {
    const { data, error } = await supabase
      .from('pecas')
      .update(peca)
      .eq('id', id)
      .select()
      .single()
    
    if (error) throw error
    return data as Peca
  },

  async delete(id: number) {
    const { error } = await supabase
      .from('pecas')
      .delete()
      .eq('id', id)
    
    if (error) throw error
  },

  async atualizarEstoque(id: number, quantidade: number) {
    const { data, error } = await supabase
      .from('pecas')
      .update({ quantidade_estoque: quantidade })
      .eq('id', id)
      .select()
      .single()
    
    if (error) throw error
    return data as Peca
  }
}
