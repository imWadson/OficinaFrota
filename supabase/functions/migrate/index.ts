import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const sql = `
-- Tabela de veículos
CREATE TABLE IF NOT EXISTS public.veiculos (
  id bigserial PRIMARY KEY,
  placa text NOT NULL UNIQUE,
  modelo text NOT NULL,
  tipo text NOT NULL,
  ano int CHECK (ano >= 1980),
  quilometragem int DEFAULT 0 CHECK (quilometragem >= 0),
  status text NOT NULL DEFAULT 'ativo',
  criado_em timestamptz NOT NULL DEFAULT now()
);

-- Tabela de supervisores
CREATE TABLE IF NOT EXISTS public.supervisores (
  id bigserial PRIMARY KEY,
  nome text NOT NULL,
  cargo text,
  contato text
);

-- Tabela de ordens de serviço
CREATE TABLE IF NOT EXISTS public.ordens_servico (
  id bigserial PRIMARY KEY,
  veiculo_id bigint NOT NULL REFERENCES public.veiculos(id) ON DELETE RESTRICT,
  problema_reportado text NOT NULL,
  diagnostico text,
  status text NOT NULL DEFAULT 'em_andamento',
  data_entrada timestamptz NOT NULL DEFAULT now(),
  data_saida timestamptz,
  supervisor_entrega_id bigint REFERENCES public.supervisores(id),
  supervisor_retirada_id bigint REFERENCES public.supervisores(id)
);

-- Tabela de peças
CREATE TABLE IF NOT EXISTS public.pecas (
  id bigserial PRIMARY KEY,
  nome text NOT NULL,
  codigo text NOT NULL UNIQUE,
  fornecedor text,
  custo_unitario numeric(12,2) NOT NULL CHECK (custo_unitario >= 0),
  quantidade_estoque int NOT NULL DEFAULT 0 CHECK (quantidade_estoque >= 0)
);

-- Tabela de peças usadas
CREATE TABLE IF NOT EXISTS public.pecas_usadas (
  id bigserial PRIMARY KEY,
  ordem_servico_id bigint NOT NULL REFERENCES public.ordens_servico(id) ON DELETE CASCADE,
  peca_id bigint NOT NULL REFERENCES public.pecas(id) ON DELETE RESTRICT,
  quantidade int NOT NULL CHECK (quantidade > 0),
  data_uso timestamptz NOT NULL DEFAULT now(),
  supervisor_id bigint REFERENCES public.supervisores(id)
);

-- Tabela de oficinas externas
CREATE TABLE IF NOT EXISTS public.oficinas_externas (
  id bigserial PRIMARY KEY,
  nome text NOT NULL,
  cnpj text NOT NULL UNIQUE,
  endereco text,
  telefone text,
  contato text
);

-- Tabela de serviços externos
CREATE TABLE IF NOT EXISTS public.servicos_externos (
  id bigserial PRIMARY KEY,
  ordem_servico_id bigint NOT NULL REFERENCES public.ordens_servico(id) ON DELETE CASCADE,
  oficina_externa_id bigint NOT NULL REFERENCES public.oficinas_externas(id) ON DELETE RESTRICT,
  descricao text NOT NULL,
  valor numeric(12,2) NOT NULL CHECK (valor >= 0),
  data_envio timestamptz NOT NULL DEFAULT now(),
  data_retorno timestamptz
);

-- Índices úteis
CREATE INDEX IF NOT EXISTS idx_os_veiculo ON public.ordens_servico(veiculo_id);
CREATE INDEX IF NOT EXISTS idx_os_status ON public.ordens_servico(status);
CREATE INDEX IF NOT EXISTS idx_os_data_entrada ON public.ordens_servico(data_entrada);
CREATE INDEX IF NOT EXISTS idx_pu_os ON public.pecas_usadas(ordem_servico_id);
CREATE INDEX IF NOT EXISTS idx_pu_peca ON public.pecas_usadas(peca_id);
CREATE INDEX IF NOT EXISTS idx_pu_data_uso ON public.pecas_usadas(data_uso);
CREATE INDEX IF NOT EXISTS idx_veiculos_placa ON public.veiculos(placa);
CREATE INDEX IF NOT EXISTS idx_veiculos_status ON public.veiculos(status);
CREATE INDEX IF NOT EXISTS idx_pecas_codigo ON public.pecas(codigo);
CREATE INDEX IF NOT EXISTS idx_oficinas_cnpj ON public.oficinas_externas(cnpj);

-- Políticas RLS básicas
ALTER TABLE public.veiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.supervisores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pecas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pecas_usadas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.oficinas_externas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.servicos_externos ENABLE ROW LEVEL SECURITY;

-- Política para usuários autenticados (leitura)
CREATE POLICY IF NOT EXISTS "Usuários autenticados podem ler veículos" ON public.veiculos
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "Usuários autenticados podem ler supervisores" ON public.supervisores
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "Usuários autenticados podem ler ordens de serviço" ON public.ordens_servico
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "Usuários autenticados podem ler peças" ON public.pecas
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "Usuários autenticados podem ler peças usadas" ON public.pecas_usadas
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "Usuários autenticados podem ler oficinas externas" ON public.oficinas_externas
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "Usuários autenticados podem ler serviços externos" ON public.servicos_externos
  FOR SELECT USING (auth.role() = 'authenticated');

-- Política para usuários autenticados (escrita)
CREATE POLICY IF NOT EXISTS "Usuários autenticados podem modificar veículos" ON public.veiculos
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "Usuários autenticados podem modificar supervisores" ON public.supervisores
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "Usuários autenticados podem modificar ordens de serviço" ON public.ordens_servico
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "Usuários autenticados podem modificar peças" ON public.pecas
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "Usuários autenticados podem modificar peças usadas" ON public.pecas_usadas
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "Usuários autenticados podem modificar oficinas externas" ON public.oficinas_externas
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY IF NOT EXISTS "Usuários autenticados podem modificar serviços externos" ON public.servicos_externos
  FOR ALL USING (auth.role() = 'authenticated');
`

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Missing environment variables')
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Executar SQL de migração
    const { error } = await supabase.rpc('exec_sql', { sql })

    if (error) {
      throw error
    }

    // Verificar tabelas criadas
    const { data: tables, error: tablesError } = await supabase
      .from('information_schema.tables')
      .select('table_name')
      .eq('table_schema', 'public')
      .in('table_name', [
        'veiculos',
        'supervisores', 
        'ordens_servico',
        'pecas',
        'pecas_usadas',
        'oficinas_externas',
        'servicos_externos'
      ])

    if (tablesError) {
      throw tablesError
    }

    const result = {
      success: true,
      message: 'Migração executada com sucesso',
      tables: tables?.map(t => t.table_name) || [],
      timestamp: new Date().toISOString()
    }

    return new Response(
      JSON.stringify(result),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    const result = {
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    }

    return new Response(
      JSON.stringify(result),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})
