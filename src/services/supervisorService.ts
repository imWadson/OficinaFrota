import { supabase } from './supabase'

// Interfaces
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
      // Primeiro, buscar o setor Operação
      const { data: setorOperacao, error: setorError } = await supabase
        .from('setores')
        .select('id')
        .eq('sigla', 'OPERACAO')
        .single()

      if (setorError || !setorOperacao) {
        console.error('Erro ao buscar setor Operação:', setorError)
        throw new Error('Setor Operação não encontrado')
      }

      // Buscar cargos do setor Operação
      const { data: cargos, error: cargosError } = await supabase
        .from('cargos')
        .select('id, nome')
        .eq('setor_id', setorOperacao.id)

      if (cargosError) {
        console.error('Erro ao buscar cargos:', cargosError)
        throw cargosError
      }

      if (!cargos || cargos.length === 0) {
        return []
      }

      // Buscar usuários com esses cargos
      const cargosIds = cargos.map(c => c.id)
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
        .in('cargo_id', cargosIds)
        .order('nome')

      if (usuariosError) {
        console.error('Erro ao buscar usuários:', usuariosError)
        throw usuariosError
      }

      if (!usuarios) return []

      // Buscar regionais
      const { data: regionais, error: regionaisError } = await supabase
        .from('regionais')
        .select(`
          id,
          nome,
          estado_id,
          estados(id, nome)
        `)

      if (regionaisError) {
        console.error('Erro ao buscar regionais:', regionaisError)
        throw regionaisError
      }

      // Mapear dados
      return usuarios.map(usuario => {
        const cargo = cargos.find(c => c.id === usuario.cargo_id)
        const regional = regionais?.find(r => r.id === usuario.regional_id)
        const estado = regional?.estados

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

      if (usuarioError) {
        console.error('Erro ao buscar usuário:', usuarioError)
        throw usuarioError
      }

      if (!usuario) return null

      // Verificar se é do setor Operação
      const { data: setorOperacao } = await supabase
        .from('setores')
        .select('id')
        .eq('sigla', 'OPERACAO')
        .single()

      if (!setorOperacao) {
        return null
      }

      const { data: cargo, error: cargoError } = await supabase
        .from('cargos')
        .select('nome')
        .eq('id', usuario.cargo_id)
        .eq('setor_id', setorOperacao.id)
        .single()

      if (cargoError || !cargo) {
        return null // Não é do setor Operação
      }

      // Buscar regional
      const { data: regional, error: regionalError } = await supabase
        .from('regionais')
        .select(`
          id,
          nome,
          estado_id,
          estados(id, nome)
        `)
        .eq('id', usuario.regional_id)
        .single()

      if (regionalError) {
        console.error('Erro ao buscar regional:', regionalError)
      }

      return {
        id: usuario.id,
        nome: usuario.nome,
        email: usuario.email,
        matricula: usuario.matricula,
        cargo: cargo.nome,
        regional_id: usuario.regional_id,
        ativo: usuario.ativo,
        criado_em: usuario.created_at,
        regional: regional ? {
          id: regional.id,
          nome: regional.nome,
          estado: regional.estados ? {
            id: regional.estados.id,
            nome: regional.estados.nome
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
          estado_id,
          estados(id, nome)
        `)
        .eq('id', data.regional_id)
        .single()

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
          estado: regional.estados ? {
            id: regional.estados.id,
            nome: regional.estados.nome
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
          estado_id,
          estados(id, nome)
        `)
        .eq('id', data.regional_id)
        .single()

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
          estado: regional.estados ? {
            id: regional.estados.id,
            nome: regional.estados.nome
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
  static async delete(id: string): Promise<void> {
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
      // Primeiro, buscar o setor Operação
      const { data: setorOperacao, error: setorError } = await supabase
        .from('setores')
        .select('id')
        .eq('sigla', 'OPERACAO')
        .single()

      if (setorError || !setorOperacao) {
        console.error('Erro ao buscar setor Operação:', setorError)
        throw new Error('Setor Operação não encontrado')
      }

      // Buscar cargos do setor Operação
      const { data: cargos, error: cargosError } = await supabase
        .from('cargos')
        .select('id, nome')
        .eq('setor_id', setorOperacao.id)

      if (cargosError) {
        console.error('Erro ao buscar cargos:', cargosError)
        throw cargosError
      }

      if (!cargos || cargos.length === 0) {
        return []
      }

      // Buscar usuários da regional com esses cargos
      const cargosIds = cargos.map(c => c.id)
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
        .in('cargo_id', cargosIds)
        .order('nome')

      if (usuariosError) {
        console.error('Erro ao buscar usuários por regional:', usuariosError)
        throw usuariosError
      }

      if (!usuarios) return []

      // Buscar regional
      const { data: regional, error: regionalError } = await supabase
        .from('regionais')
        .select(`
          id,
          nome,
          estado_id,
          estados(id, nome)
        `)
        .eq('id', regionalId)
        .single()

      if (regionalError) {
        console.error('Erro ao buscar regional:', regionalError)
      }

      // Mapear dados
      return usuarios.map(usuario => {
        const cargo = cargos.find(c => c.id === usuario.cargo_id)

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
            estado: regional.estados ? {
              id: regional.estados.id,
              nome: regional.estados.nome
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
   * Busca apenas supervisores ativos
   */
  static async getActive(): Promise<Supervisor[]> {
    try {
      // Primeiro, buscar o setor Operação
      const { data: setorOperacao, error: setorError } = await supabase
        .from('setores')
        .select('id')
        .eq('sigla', 'OPERACAO')
        .single()

      if (setorError || !setorOperacao) {
        console.error('Erro ao buscar setor Operação:', setorError)
        throw new Error('Setor Operação não encontrado')
      }

      // Buscar cargos do setor Operação
      const { data: cargos, error: cargosError } = await supabase
        .from('cargos')
        .select('id, nome')
        .eq('setor_id', setorOperacao.id)

      if (cargosError) {
        console.error('Erro ao buscar cargos:', cargosError)
        throw cargosError
      }

      if (!cargos || cargos.length === 0) {
        return []
      }

      // Buscar usuários ativos com esses cargos
      const cargosIds = cargos.map(c => c.id)
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
        .in('cargo_id', cargosIds)
        .order('nome')

      if (usuariosError) {
        console.error('Erro ao buscar usuários ativos:', usuariosError)
        throw usuariosError
      }

      if (!usuarios) return []

      // Buscar regionais
      const { data: regionais, error: regionaisError } = await supabase
        .from('regionais')
        .select(`
          id,
          nome,
          estado_id,
          estados(id, nome)
        `)

      if (regionaisError) {
        console.error('Erro ao buscar regionais:', regionaisError)
        throw regionaisError
      }

      // Mapear dados
      return usuarios.map(usuario => {
        const cargo = cargos.find(c => c.id === usuario.cargo_id)
        const regional = regionais?.find(r => r.id === usuario.regional_id)
        const estado = regional?.estados

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
