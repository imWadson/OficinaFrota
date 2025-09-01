import { supabase } from './supabase'

export interface Regional {
  id: string
  nome: string
  sigla: string
  estado_id: string
  estado?: {
    id: string
    nome: string
    sigla: string
  }
}

export class RegionalService {
  /**
   * Busca todas as regionais
   */
  static async getAll(): Promise<Regional[]> {
    const { data, error } = await supabase
      .from('regionais')
      .select(`
        id,
        nome,
        sigla,
        estado_id,
        estados(
          id,
          nome,
          sigla
        )
      `)
      .order('nome')

    if (error) {
      console.error('Erro ao buscar regionais:', error)
      throw error
    }

    return data?.map(item => ({
      id: item.id,
      nome: item.nome,
      sigla: item.sigla,
      estado_id: item.estado_id,
      estado: item.estados ? {
        id: item.estados.id,
        nome: item.estados.nome,
        sigla: item.estados.sigla
      } : undefined
    })) || []
  }

  /**
   * Busca uma regional por ID
   */
  static async getById(id: string): Promise<Regional | null> {
    const { data, error } = await supabase
      .from('regionais')
      .select(`
        id,
        nome,
        sigla,
        estado_id,
        estados(
          id,
          nome,
          sigla
        )
      `)
      .eq('id', id)
      .single()

    if (error) {
      console.error('Erro ao buscar regional:', error)
      throw error
    }

    if (!data) return null

    return {
      id: data.id,
      nome: data.nome,
      sigla: data.sigla,
      estado_id: data.estado_id,
      estado: data.estados ? {
        id: data.estados.id,
        nome: data.estados.nome,
        sigla: data.estados.sigla
      } : undefined
    }
  }

  /**
   * Busca regionais por estado
   */
  static async getByEstado(estadoId: string): Promise<Regional[]> {
    const { data, error } = await supabase
      .from('regionais')
      .select(`
        id,
        nome,
        sigla,
        estado_id,
        estados(
          id,
          nome,
          sigla
        )
      `)
      .eq('estado_id', estadoId)
      .order('nome')

    if (error) {
      console.error('Erro ao buscar regionais por estado:', error)
      throw error
    }

    return data?.map(item => ({
      id: item.id,
      nome: item.nome,
      sigla: item.sigla,
      estado_id: item.estado_id,
      estado: item.estados ? {
        id: item.estados.id,
        nome: item.estados.nome,
        sigla: item.estados.sigla
      } : undefined
    })) || []
  }
}
