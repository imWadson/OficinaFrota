import { supabase } from '../supabase'

export interface Supervisor {
  id: number
  nome: string
  cargo?: string
  contato?: string
}

export const supervisorRepository = {
  async findAll() {
    const { data, error } = await supabase
      .from('supervisores')
      .select('*')
      .order('nome')
    
    if (error) throw error
    return data as Supervisor[]
  },

  async findById(id: number) {
    const { data, error } = await supabase
      .from('supervisores')
      .select('*')
      .eq('id', id)
      .single()
    
    if (error) throw error
    return data as Supervisor
  }
}
