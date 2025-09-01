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
    try {
      const { data, error } = await supabase
        .from('regionais')
        .select(`
          id,
          nome,
          sigla,
          estado_id
        `)
        .order('nome')

      if (error) {
        console.error('Erro ao buscar regionais:', error)
        throw error
      }

      if (!data || data.length === 0) {
        return []
      }

      // Buscar estados separadamente
      const estadoIds = [...new Set(data.map(item => item.estado_id).filter(Boolean))]
      
      let estados: any[] = []
      if (estadoIds.length > 0) {
        const { data: estadosData, error: estadosError } = await supabase
          .from('estados')
          .select(`
            id,
            nome,
            sigla
          `)
          .in('id', estadoIds)

        if (estadosError) {
          console.error('Erro ao buscar estados:', estadosError)
          throw estadosError
        }

        estados = estadosData || []
      }

      return data.map(item => ({
        id: item.id,
        nome: item.nome,
        sigla: item.sigla,
        estado_id: item.estado_id,
        estado: estados.find(e => e.id === item.estado_id) ? {
          id: estados.find(e => e.id === item.estado_id)!.id,
          nome: estados.find(e => e.id === item.estado_id)!.nome,
          sigla: estados.find(e => e.id === item.estado_id)!.sigla
        } : undefined
      }))
    } catch (error) {
      console.error('Erro ao buscar regionais:', error)
      throw error
    }
  }

  /**
   * Busca uma regional por ID
   */
  static async getById(id: string): Promise<Regional | null> {
    try {
      const { data, error } = await supabase
        .from('regionais')
        .select(`
          id,
          nome,
          sigla,
          estado_id
        `)
        .eq('id', id)
        .single()

      if (error) {
        console.error('Erro ao buscar regional:', error)
        throw error
      }

      if (!data) return null

      // Buscar estado separadamente
      let estado = null
      if (data.estado_id) {
        const { data: estadoData, error: estadoError } = await supabase
          .from('estados')
          .select(`
            id,
            nome,
            sigla
          `)
          .eq('id', data.estado_id)
          .single()

        if (!estadoError) {
          estado = estadoData
        }
      }

      return {
        id: data.id,
        nome: data.nome,
        sigla: data.sigla,
        estado_id: data.estado_id,
        estado: estado ? {
          id: estado.id,
          nome: estado.nome,
          sigla: estado.sigla
        } : undefined
      }
    } catch (error) {
      console.error('Erro ao buscar regional:', error)
      throw error
    }
  }

  /**
   * Busca regionais por estado
   */
  static async getByEstado(estadoId: string): Promise<Regional[]> {
    try {
      const { data, error } = await supabase
        .from('regionais')
        .select(`
          id,
          nome,
          sigla,
          estado_id
        `)
        .eq('estado_id', estadoId)
        .order('nome')

      if (error) {
        console.error('Erro ao buscar regionais por estado:', error)
        throw error
      }

      if (!data || data.length === 0) {
        return []
      }

      // Buscar estado separadamente
      const { data: estadoData, error: estadoError } = await supabase
        .from('estados')
        .select(`
          id,
          nome,
          sigla
        `)
        .eq('id', estadoId)
        .single()

      const estado = !estadoError ? estadoData : null

      return data.map(item => ({
        id: item.id,
        nome: item.nome,
        sigla: item.sigla,
        estado_id: item.estado_id,
        estado: estado ? {
          id: estado.id,
          nome: estado.nome,
          sigla: estado.sigla
        } : undefined
      }))
    } catch (error) {
      console.error('Erro ao buscar regionais por estado:', error)
      throw error
    }
  }
}
