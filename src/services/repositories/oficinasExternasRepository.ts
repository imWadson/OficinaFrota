import { supabase } from '../supabase'

export interface OficinaExterna {
  id: number
  nome: string
  cnpj: string
  endereco?: string
  telefone?: string
  contato?: string
}

export interface OficinaExternaInsert {
  nome: string
  cnpj: string
  endereco?: string
  telefone?: string
  contato?: string
}

export const oficinasExternasRepository = {
  async findAll() {
    const { data, error } = await supabase
      .from('oficinas_externas')
      .select('*')
      .order('nome')
    
    if (error) throw error
    return data as OficinaExterna[]
  },

  async findById(id: number) {
    const { data, error } = await supabase
      .from('oficinas_externas')
      .select('*')
      .eq('id', id)
      .single()
    
    if (error) throw error
    return data as OficinaExterna
  },

  async create(oficina: OficinaExternaInsert) {
    const { data, error } = await supabase
      .from('oficinas_externas')
      .insert(oficina)
      .select()
      .single()
    
    if (error) throw error
    return data as OficinaExterna
  },

  async update(id: number, oficina: Partial<OficinaExternaInsert>) {
    const { data, error } = await supabase
      .from('oficinas_externas')
      .update(oficina)
      .eq('id', id)
      .select()
      .single()
    
    if (error) throw error
    return data as OficinaExterna
  },

  async delete(id: number) {
    const { error } = await supabase
      .from('oficinas_externas')
      .delete()
      .eq('id', id)
    
    if (error) throw error
  }
}
