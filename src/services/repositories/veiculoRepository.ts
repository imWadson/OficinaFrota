import { supabase } from '../supabase'
import type { Veiculo, VeiculoInsert, VeiculoUpdate } from '../../entities/veiculo'

export const veiculoRepository = {
  async findAll() {
    const { data, error } = await supabase
      .from('veiculos')
      .select('*')
      .order('placa')
    
    if (error) throw error
    return data as Veiculo[]
  },

  async findById(id: number) {
    const { data, error } = await supabase
      .from('veiculos')
      .select('*')
      .eq('id', id)
      .single()
    
    if (error) throw error
    return data as Veiculo
  },

  async findByPlaca(placa: string) {
    const { data, error } = await supabase
      .from('veiculos')
      .select('*')
      .eq('placa', placa)
      .single()
    
    if (error) throw error
    return data as Veiculo
  },

  async create(veiculo: VeiculoInsert) {
    const { data, error } = await supabase
      .from('veiculos')
      .insert(veiculo)
      .select()
      .single()
    
    if (error) throw error
    return data as Veiculo
  },

  async update(id: number, veiculo: VeiculoUpdate) {
    const { data, error } = await supabase
      .from('veiculos')
      .update(veiculo)
      .eq('id', id)
      .select()
      .single()
    
    if (error) throw error
    return data as Veiculo
  },

  async delete(id: number) {
    const { error } = await supabase
      .from('veiculos')
      .delete()
      .eq('id', id)
    
    if (error) throw error
  },

  async getVeiculosEmManutencao() {
    const { data, error } = await supabase
      .from('veiculos')
      .select('*')
      .eq('status', 'manutencao')
      .order('placa')
    
    if (error) throw error
    return data as Veiculo[]
  }
}
