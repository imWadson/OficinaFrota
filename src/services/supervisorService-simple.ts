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

// =====================================================
// FUNÇÕES SIMPLIFICADAS - SEM OVERENGINEERING
// =====================================================

/**
 * Busca todos os supervisores (usuários do setor Operação)
 */
export async function buscarSupervisores(): Promise<Supervisor[]> {
    try {
        // Query única com joins para evitar múltiplas consultas
        const { data, error } = await supabase
            .from('usuarios')
            .select(`
        id,
        nome,
        email,
        matricula,
        regional_id,
        ativo,
        created_at,
        cargos!inner(
          id,
          nome,
          setores!inner(
            id,
            sigla
          )
        ),
        regionais!inner(
          id,
          nome,
          estados!inner(
            id,
            nome
          )
        )
      `)
            .eq('cargos.setores.sigla', 'OPERACAO')
            .eq('ativo', true)
            .order('nome')

        if (error) throw error

        // Mapeamento simples
        return (data || []).map(usuario => ({
            id: usuario.id,
            nome: usuario.nome,
            email: usuario.email,
            matricula: usuario.matricula,
            cargo: usuario.cargos?.nome || 'N/A',
            regional_id: usuario.regional_id,
            ativo: usuario.ativo,
            criado_em: usuario.created_at,
            regional: usuario.regionais ? {
                id: usuario.regionais.id,
                nome: usuario.regionais.nome,
                estado: usuario.regionais.estados ? {
                    id: usuario.regionais.estados.id,
                    nome: usuario.regionais.estados.nome
                } : undefined
            } : undefined
        }))
    } catch (error) {
        console.error('Erro ao buscar supervisores:', error)
        throw error
    }
}

/**
 * Busca supervisor por ID
 */
export async function buscarSupervisorPorId(id: string): Promise<Supervisor | null> {
    try {
        const { data, error } = await supabase
            .from('usuarios')
            .select(`
        id,
        nome,
        email,
        matricula,
        regional_id,
        ativo,
        created_at,
        cargos!inner(
          id,
          nome,
          setores!inner(
            id,
            sigla
          )
        ),
        regionais!inner(
          id,
          nome,
          estados!inner(
            id,
            nome
          )
        )
      `)
            .eq('id', id)
            .eq('cargos.setores.sigla', 'OPERACAO')
            .single()

        if (error) throw error
        if (!data) return null

        return {
            id: data.id,
            nome: data.nome,
            email: data.email,
            matricula: data.matricula,
            cargo: data.cargos?.nome || 'N/A',
            regional_id: data.regional_id,
            ativo: data.ativo,
            criado_em: data.created_at,
            regional: data.regionais ? {
                id: data.regionais.id,
                nome: data.regionais.nome,
                estado: data.regionais.estados ? {
                    id: data.regionais.estados.id,
                    nome: data.regionais.estados.nome
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
export async function criarSupervisor(dados: SupervisorCreate): Promise<Supervisor> {
    try {
        const { data, error } = await supabase
            .from('usuarios')
            .insert({
                nome: dados.nome,
                email: dados.email,
                matricula: dados.matricula,
                cargo_id: dados.cargo_id,
                regional_id: dados.regional_id,
                ativo: dados.ativo ?? true
            })
            .select()
            .single()

        if (error) throw error

        // Buscar dados completos
        return await buscarSupervisorPorId(data.id) || data as any
    } catch (error) {
        console.error('Erro ao criar supervisor:', error)
        throw error
    }
}

/**
 * Atualiza um supervisor
 */
export async function atualizarSupervisor(id: string, dados: SupervisorUpdate): Promise<Supervisor> {
    try {
        const { data, error } = await supabase
            .from('usuarios')
            .update(dados)
            .eq('id', id)
            .select()
            .single()

        if (error) throw error

        // Buscar dados completos
        return await buscarSupervisorPorId(id) || data as any
    } catch (error) {
        console.error('Erro ao atualizar supervisor:', error)
        throw error
    }
}

/**
 * Remove um supervisor (desativa)
 */
export async function removerSupervisor(id: string): Promise<void> {
    try {
        const { error } = await supabase
            .from('usuarios')
            .update({ ativo: false })
            .eq('id', id)

        if (error) throw error
    } catch (error) {
        console.error('Erro ao remover supervisor:', error)
        throw error
    }
}
