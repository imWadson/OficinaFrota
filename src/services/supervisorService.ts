import { supabase } from './supabase'

export interface Supervisor {
  id: string
  nome: string
  email: string
  matricula: string
  cargo: string
  regional_id: string
  ativo: boolean
  criado_em: string
  regional?: {
    id: string
    nome: string
    estado?: {
      id: string
      nome: string
    }
  }
}

export interface SupervisorCreate {
  nome: string
  email: string
  matricula: string
  cargo_id: string
  regional_id: string
  ativo?: boolean
}

export interface SupervisorUpdate {
  nome?: string
  email?: string
  matricula?: string
  cargo_id?: string
  regional_id?: string
  ativo?: boolean
}

export class SupervisorService {
  /**
   * Busca todos os supervisores
   */
  static async getAll(): Promise<Supervisor[]> {
    try {
      // Buscar todos os usuários
      const { data: usuarios, error: usuariosError } = await supabase
        .from('usuarios')
        .select(`
          id,
          nome,
          email,
          matricula,
          cargo_id,
          regional_id,
          ativo,
          created_at
        `)
        .order('nome')

      if (usuariosError) {
        console.error('Erro ao buscar usuários:', usuariosError)
        throw usuariosError
      }

      if (!usuarios || usuarios.length === 0) {
        return []
      }

      // Buscar todos os cargos
      const { data: cargos, error: cargosError } = await supabase
        .from('cargos')
        .select(`
          id,
          nome,
          setor_id
        `)

      if (cargosError) {
        console.error('Erro ao buscar cargos:', cargosError)
        throw cargosError
      }

      // Buscar todos os setores
      const { data: setores, error: setoresError } = await supabase
        .from('setores')
        .select(`
          id,
          sigla
        `)

      if (setoresError) {
        console.error('Erro ao buscar setores:', setoresError)
        throw setoresError
      }

      // Filtrar apenas usuários do setor Operação
      const supervisores = usuarios.filter(usuario => {
        const cargo = cargos?.find(c => c.id === usuario.cargo_id)
        const setor = setores?.find(s => s.id === cargo?.setor_id)
        return setor?.sigla === 'OPERACAO'
      })

      if (supervisores.length === 0) {
        return []
      }

      // Buscar regionais para os supervisores
      const regionalIds = [...new Set(supervisores.map(s => s.regional_id).filter(Boolean))]
      
      let regionais: any[] = []
      if (regionalIds.length > 0) {
        const { data: regionaisData, error: regionaisError } = await supabase
          .from('regionais')
          .select(`
            id,
            nome,
            estado_id
          `)
          .in('id', regionalIds)

        if (regionaisError) {
          console.error('Erro ao buscar regionais:', regionaisError)
          throw regionaisError
        }

        regionais = regionaisData || []
      }

      // Buscar estados para as regionais
      const estadoIds = [...new Set(regionais.map(r => r.estado_id).filter(Boolean))]
      
      let estados: any[] = []
      if (estadoIds.length > 0) {
        const { data: estadosData, error: estadosError } = await supabase
          .from('estados')
          .select(`
            id,
            nome
          `)
          .in('id', estadoIds)

        if (estadosError) {
          console.error('Erro ao buscar estados:', estadosError)
          throw estadosError
        }

        estados = estadosData || []
      }

      // Mapear dados
      return supervisores.map(usuario => {
        const cargo = cargos?.find(c => c.id === usuario.cargo_id)
        const regional = regionais.find(r => r.id === usuario.regional_id)
        const estado = regional ? estados.find(e => e.id === regional.estado_id) : null

        return {
          id: usuario.id,
          nome: usuario.nome,
          email: usuario.email,
          matricula: usuario.matricula,
          cargo: cargo?.nome || 'N/A',
          regional_id: usuario.regional_id,
          ativo: usuario.ativo,
          criado_em: usuario.created_at,
          regional: regional ? {
            id: regional.id,
            nome: regional.nome,
            estado: estado ? {
              id: estado.id,
              nome: estado.nome
            } : undefined
          } : undefined
        }
      })
    } catch (error) {
      console.error('Erro ao buscar supervisores:', error)
      throw error
    }
  }

  /**
   * Busca um supervisor por ID
   */
  static async getById(id: string): Promise<Supervisor | null> {
    try {
      const { data: usuario, error: usuarioError } = await supabase
        .from('usuarios')
        .select(`
          id,
          nome,
          email,
          matricula,
          cargo_id,
          regional_id,
          ativo,
          created_at
        `)
        .eq('id', id)
        .single()

      if (usuarioError || !usuario) {
        return null
      }

      // Buscar cargo
      const { data: cargo } = await supabase
        .from('cargos')
        .select('nome')
        .eq('id', usuario.cargo_id)
        .single()

      // Buscar regional
      const { data: regional } = await supabase
        .from('regionais')
        .select(`
          id,
          nome,
          estado_id
        `)
        .eq('id', usuario.regional_id)
        .single()

      // Buscar estado
      let estado = null
      if (regional?.estado_id) {
        const { data: estadoData } = await supabase
          .from('estados')
          .select('id, nome')
          .eq('id', regional.estado_id)
          .single()
        estado = estadoData
      }

      return {
        id: usuario.id,
        nome: usuario.nome,
        email: usuario.email,
        matricula: usuario.matricula,
        cargo: cargo?.nome || 'N/A',
        regional_id: usuario.regional_id,
        ativo: usuario.ativo,
        criado_em: usuario.created_at,
        regional: regional ? {
          id: regional.id,
          nome: regional.nome,
          estado: estado ? {
            id: estado.id,
            nome: estado.nome
          } : undefined
        } : undefined
      }
    } catch (error) {
      console.error('Erro ao buscar supervisor:', error)
      throw error
    }
  }

  /**
   * Cria um novo supervisor
   */
  static async create(supervisorData: SupervisorCreate): Promise<Supervisor> {
    try {
      const { data, error } = await supabase
        .from('usuarios')
        .insert({
          nome: supervisorData.nome,
          email: supervisorData.email,
          matricula: supervisorData.matricula,
          cargo_id: supervisorData.cargo_id,
          regional_id: supervisorData.regional_id,
          ativo: supervisorData.ativo ?? true
        })
        .select()
        .single()

      if (error) {
        console.error('Erro ao criar supervisor:', error)
        throw error
      }

      // Buscar dados relacionados
      const { data: cargo } = await supabase
        .from('cargos')
        .select('nome')
        .eq('id', data.cargo_id)
        .single()

      const { data: regional } = await supabase
        .from('regionais')
        .select(`
          id,
          nome,
          estado_id
        `)
        .eq('id', data.regional_id)
        .single()

      // Buscar estado
      let estado = null
      if (regional?.estado_id) {
        const { data: estadoData } = await supabase
          .from('estados')
          .select('id, nome')
          .eq('id', regional.estado_id)
          .single()
        estado = estadoData
      }

      return {
        id: data.id,
        nome: data.nome,
        email: data.email,
        matricula: data.matricula,
        cargo: cargo?.nome || 'N/A',
        regional_id: data.regional_id,
        ativo: data.ativo,
        criado_em: data.created_at,
        regional: regional ? {
          id: regional.id,
          nome: regional.nome,
          estado: estado ? {
            id: estado.id,
            nome: estado.nome
          } : undefined
        } : undefined
      }
    } catch (error) {
      console.error('Erro ao criar supervisor:', error)
      throw error
    }
  }

  /**
   * Atualiza um supervisor
   */
  static async update(id: string, supervisorData: SupervisorUpdate): Promise<Supervisor> {
    try {
      const { data, error } = await supabase
        .from('usuarios')
        .update({
          nome: supervisorData.nome,
          email: supervisorData.email,
          matricula: supervisorData.matricula,
          cargo_id: supervisorData.cargo_id,
          regional_id: supervisorData.regional_id,
          ativo: supervisorData.ativo
        })
        .eq('id', id)
        .select()
        .single()

      if (error) {
        console.error('Erro ao atualizar supervisor:', error)
        throw error
      }

      // Buscar dados relacionados
      const { data: cargo } = await supabase
        .from('cargos')
        .select('nome')
        .eq('id', data.cargo_id)
        .single()

      const { data: regional } = await supabase
        .from('regionais')
        .select(`
          id,
          nome,
          estado_id
        `)
        .eq('id', data.regional_id)
        .single()

      // Buscar estado
      let estado = null
      if (regional?.estado_id) {
        const { data: estadoData } = await supabase
          .from('estados')
          .select('id, nome')
          .eq('id', regional.estado_id)
          .single()
        estado = estadoData
      }

      return {
        id: data.id,
        nome: data.nome,
        email: data.email,
        matricula: data.matricula,
        cargo: cargo?.nome || 'N/A',
        regional_id: data.regional_id,
        ativo: data.ativo,
        criado_em: data.created_at,
        regional: regional ? {
          id: regional.id,
          nome: regional.nome,
          estado: estado ? {
            id: estado.id,
            nome: estado.nome
          } : undefined
        } : undefined
      }
    } catch (error) {
      console.error('Erro ao atualizar supervisor:', error)
      throw error
    }
  }

  /**
   * Remove um supervisor
   */
  static async remove(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('usuarios')
        .delete()
        .eq('id', id)

      if (error) {
        console.error('Erro ao remover supervisor:', error)
        throw error
      }
    } catch (error) {
      console.error('Erro ao remover supervisor:', error)
      throw error
    }
  }

  /**
   * Busca supervisores por regional
   */
  static async getByRegional(regionalId: string): Promise<Supervisor[]> {
    try {
      // Buscar usuários da regional
      const { data: usuarios, error: usuariosError } = await supabase
        .from('usuarios')
        .select(`
          id,
          nome,
          email,
          matricula,
          cargo_id,
          regional_id,
          ativo,
          created_at
        `)
        .eq('regional_id', regionalId)
        .order('nome')

      if (usuariosError) {
        console.error('Erro ao buscar usuários por regional:', usuariosError)
        throw usuariosError
      }

      if (!usuarios || usuarios.length === 0) {
        return []
      }

      // Buscar cargos
      const { data: cargos, error: cargosError } = await supabase
        .from('cargos')
        .select(`
          id,
          nome,
          setor_id
        `)

      if (cargosError) {
        console.error('Erro ao buscar cargos:', cargosError)
        throw cargosError
      }

      // Buscar setores
      const { data: setores, error: setoresError } = await supabase
        .from('setores')
        .select(`
          id,
          sigla
        `)

      if (setoresError) {
        console.error('Erro ao buscar setores:', setoresError)
        throw setoresError
      }

      // Buscar regional
      const { data: regional, error: regionalError } = await supabase
        .from('regionais')
        .select(`
          id,
          nome,
          estado_id
        `)
        .eq('id', regionalId)
        .single()

      if (regionalError) {
        console.error('Erro ao buscar regional:', regionalError)
        throw regionalError
      }

      // Buscar estado
      let estado = null
      if (regional?.estado_id) {
        const { data: estadoData } = await supabase
          .from('estados')
          .select('id, nome')
          .eq('id', regional.estado_id)
          .single()
        estado = estadoData
      }

      // Filtrar apenas usuários do setor Operação
      const supervisores = usuarios.filter(usuario => {
        const cargo = cargos?.find(c => c.id === usuario.cargo_id)
        const setor = setores?.find(s => s.id === cargo?.setor_id)
        return setor?.sigla === 'OPERACAO'
      })

      // Mapear dados
      return supervisores.map(usuario => {
        const cargo = cargos?.find(c => c.id === usuario.cargo_id)

        return {
          id: usuario.id,
          nome: usuario.nome,
          email: usuario.email,
          matricula: usuario.matricula,
          cargo: cargo?.nome || 'N/A',
          regional_id: usuario.regional_id,
          ativo: usuario.ativo,
          criado_em: usuario.created_at,
          regional: regional ? {
            id: regional.id,
            nome: regional.nome,
            estado: estado ? {
              id: estado.id,
              nome: estado.nome
            } : undefined
          } : undefined
        }
      })
    } catch (error) {
      console.error('Erro ao buscar supervisores por regional:', error)
      throw error
    }
  }

  /**
   * Busca supervisores ativos
   */
  static async getActive(): Promise<Supervisor[]> {
    try {
      // Buscar usuários ativos
      const { data: usuarios, error: usuariosError } = await supabase
        .from('usuarios')
        .select(`
          id,
          nome,
          email,
          matricula,
          cargo_id,
          regional_id,
          ativo,
          created_at
        `)
        .eq('ativo', true)
        .order('nome')

      if (usuariosError) {
        console.error('Erro ao buscar usuários ativos:', usuariosError)
        throw usuariosError
      }

      if (!usuarios || usuarios.length === 0) {
        return []
      }

      // Buscar cargos
      const { data: cargos, error: cargosError } = await supabase
        .from('cargos')
        .select(`
          id,
          nome,
          setor_id
        `)

      if (cargosError) {
        console.error('Erro ao buscar cargos:', cargosError)
        throw cargosError
      }

      // Buscar setores
      const { data: setores, error: setoresError } = await supabase
        .from('setores')
        .select(`
          id,
          sigla
        `)

      if (setoresError) {
        console.error('Erro ao buscar setores:', setoresError)
        throw setoresError
      }

      // Buscar regionais
      const regionalIds = [...new Set(usuarios.map(u => u.regional_id).filter(Boolean))]
      
      let regionais: any[] = []
      if (regionalIds.length > 0) {
        const { data: regionaisData, error: regionaisError } = await supabase
          .from('regionais')
          .select(`
            id,
            nome,
            estado_id
          `)
          .in('id', regionalIds)

        if (regionaisError) {
          console.error('Erro ao buscar regionais:', regionaisError)
          throw regionaisError
        }

        regionais = regionaisData || []
      }

      // Buscar estados
      const estadoIds = [...new Set(regionais.map(r => r.estado_id).filter(Boolean))]
      
      let estados: any[] = []
      if (estadoIds.length > 0) {
        const { data: estadosData, error: estadosError } = await supabase
          .from('estados')
          .select(`
            id,
            nome
          `)
          .in('id', estadoIds)

        if (estadosError) {
          console.error('Erro ao buscar estados:', estadosError)
          throw estadosError
        }

        estados = estadosData || []
      }

      // Filtrar apenas usuários do setor Operação
      const supervisores = usuarios.filter(usuario => {
        const cargo = cargos?.find(c => c.id === usuario.cargo_id)
        const setor = setores?.find(s => s.id === cargo?.setor_id)
        return setor?.sigla === 'OPERACAO'
      })

      // Mapear dados
      return supervisores.map(usuario => {
        const cargo = cargos?.find(c => c.id === usuario.cargo_id)
        const regional = regionais.find(r => r.id === usuario.regional_id)
        const estado = regional ? estados.find(e => e.id === regional.estado_id) : null

        return {
          id: usuario.id,
          nome: usuario.nome,
          email: usuario.email,
          matricula: usuario.matricula,
          cargo: cargo?.nome || 'N/A',
          regional_id: usuario.regional_id,
          ativo: usuario.ativo,
          criado_em: usuario.created_at,
          regional: regional ? {
            id: regional.id,
            nome: regional.nome,
            estado: estado ? {
              id: estado.id,
              nome: estado.nome
            } : undefined
          } : undefined
        }
      })
    } catch (error) {
      console.error('Erro ao buscar supervisores ativos:', error)
      throw error
    }
  }
}
