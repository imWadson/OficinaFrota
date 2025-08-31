import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

// Configurações de segurança para o cliente Supabase
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
    flowType: 'pkce', // Mais seguro que implicit flow
  },
  global: {
    headers: {
      'X-Client-Info': 'frota-gestor-web',
    },
  },
})

export type Database = {
  public: {
    Tables: {
      veiculos: {
        Row: {
          id: number
          placa: string
          modelo: string
          tipo: string
          ano: number
          quilometragem: number
          status: string
          criado_em: string
        }
        Insert: {
          id?: number
          placa: string
          modelo: string
          tipo: string
          ano: number
          quilometragem?: number
          status?: string
          criado_em?: string
        }
        Update: {
          id?: number
          placa?: string
          modelo?: string
          tipo?: string
          ano?: number
          quilometragem?: number
          status?: string
          criado_em?: string
        }
      }
      supervisores: {
        Row: {
          id: number
          nome: string
          cargo: string | null
          contato: string | null
        }
        Insert: {
          id?: number
          nome: string
          cargo?: string | null
          contato?: string | null
        }
        Update: {
          id?: number
          nome?: string
          cargo?: string | null
          contato?: string | null
        }
      }
      ordens_servico: {
        Row: {
          id: number
          veiculo_id: number
          problema_reportado: string
          diagnostico: string | null
          status: string
          data_entrada: string
          data_saida: string | null
          supervisor_entrega_id: number | null
          supervisor_retirada_id: number | null
        }
        Insert: {
          id?: number
          veiculo_id: number
          problema_reportado: string
          diagnostico?: string | null
          status?: string
          data_entrada?: string
          data_saida?: string | null
          supervisor_entrega_id?: number | null
          supervisor_retirada_id?: number | null
        }
        Update: {
          id?: number
          veiculo_id?: number
          problema_reportado?: string
          diagnostico?: string | null
          status?: string
          data_entrada?: string
          data_saida?: string | null
          supervisor_entrega_id?: number | null
          supervisor_retirada_id?: number | null
        }
      }
      pecas: {
        Row: {
          id: number
          nome: string
          codigo: string
          fornecedor: string | null
          custo_unitario: number
          quantidade_estoque: number
        }
        Insert: {
          id?: number
          nome: string
          codigo: string
          fornecedor?: string | null
          custo_unitario: number
          quantidade_estoque?: number
        }
        Update: {
          id?: number
          nome?: string
          codigo?: string
          fornecedor?: string | null
          custo_unitario?: number
          quantidade_estoque?: number
        }
      }
      pecas_usadas: {
        Row: {
          id: number
          ordem_servico_id: number
          peca_id: number
          quantidade: number
          data_uso: string
          supervisor_id: number | null
        }
        Insert: {
          id?: number
          ordem_servico_id: number
          peca_id: number
          quantidade: number
          data_uso?: string
          supervisor_id?: number | null
        }
        Update: {
          id?: number
          ordem_servico_id?: number
          peca_id?: number
          quantidade?: number
          data_uso?: string
          supervisor_id?: number | null
        }
      }
      oficinas_externas: {
        Row: {
          id: number
          nome: string
          cnpj: string
          endereco: string | null
          telefone: string | null
          contato: string | null
        }
        Insert: {
          id?: number
          nome: string
          cnpj: string
          endereco?: string | null
          telefone?: string | null
          contato?: string | null
        }
        Update: {
          id?: number
          nome?: string
          cnpj?: string
          endereco?: string | null
          telefone?: string | null
          contato?: string | null
        }
      }
      servicos_externos: {
        Row: {
          id: number
          ordem_servico_id: number
          oficina_externa_id: number
          descricao: string
          valor: number
          data_envio: string
          data_retorno: string | null
        }
        Insert: {
          id?: number
          ordem_servico_id: number
          oficina_externa_id: number
          descricao: string
          valor: number
          data_envio?: string
          data_retorno?: string | null
        }
        Update: {
          id?: number
          ordem_servico_id?: number
          oficina_externa_id?: number
          descricao?: string
          valor?: number
          data_envio?: string
          data_retorno?: string | null
        }
      }
    }
  }
}
