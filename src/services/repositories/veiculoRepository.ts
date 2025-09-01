import { supabase } from '../supabase'
import type { Veiculo, VeiculoInsert, VeiculoUpdate } from '../../entities/veiculo'

export const veiculoRepository = {
  async findAll(regionalId?: string) {
    let query = supabase
      .from('veiculos')
      .select('*')
      .order('placa')

    if (regionalId) {
      query = query.eq('regional_id', regionalId)
    }

    const { data, error } = await query

    if (error) {
      console.error('Erro na query:', error)
      throw error
    }

    return data as Veiculo[]
  },

  async findById(id: string) {
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

  async update(id: string, veiculo: VeiculoUpdate) {
    const { data, error } = await supabase
      .from('veiculos')
      .update(veiculo)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data as Veiculo
  },

  async delete(id: string) {
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
