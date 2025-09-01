-- =====================================================
-- LIMPEZA E SETUP COMPLETO - FROTA GESTOR RBAC
-- =====================================================
-- Script para limpar banco existente e criar nova estrutura
-- Versão com funções no schema public (para evitar problemas de permissão)

-- =========================================
-- 1. LIMPEZA COMPLETA
-- =========================================

-- Desabilitar RLS em todas as tabelas (se existirem)
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename) || ' DISABLE ROW LEVEL SECURITY;';
    END LOOP;
END $$;

-- Remover políticas RLS (se existirem)
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "Usuários podem ver dados apropriados" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
        EXECUTE 'DROP POLICY IF EXISTS "Veículos por regional" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
        EXECUTE 'DROP POLICY IF EXISTS "Veículos por regional - write" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
        EXECUTE 'DROP POLICY IF EXISTS "OS por regional" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
        EXECUTE 'DROP POLICY IF EXISTS "OS por regional - write" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
        EXECUTE 'DROP POLICY IF EXISTS "Peças por regional" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
        EXECUTE 'DROP POLICY IF EXISTS "Peças por regional - write" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
        EXECUTE 'DROP POLICY IF EXISTS "Peças usadas por regional" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
        EXECUTE 'DROP POLICY IF EXISTS "Peças usadas por regional - write" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
        EXECUTE 'DROP POLICY IF EXISTS "Oficinas externas por regional" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
        EXECUTE 'DROP POLICY IF EXISTS "Oficinas externas por regional - write" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
        EXECUTE 'DROP POLICY IF EXISTS "Serviços externos por regional" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
        EXECUTE 'DROP POLICY IF EXISTS "Serviços externos por regional - write" ON public.' || quote_ident(r.tablename) || ' CASCADE;';
    END LOOP;
END $$;

-- Remover funções (se existirem) - agora no schema public
DROP FUNCTION IF EXISTS public.user_cargo() CASCADE;
DROP FUNCTION IF EXISTS public.user_regional() CASCADE;
DROP FUNCTION IF EXISTS public.can_access(TEXT) CASCADE;

-- Remover tabelas na ordem correta (dependências)
DROP TABLE IF EXISTS servicos_externos CASCADE;
DROP TABLE IF EXISTS pecas_usadas CASCADE;
DROP TABLE IF EXISTS ordens_servico CASCADE;
DROP TABLE IF EXISTS veiculos CASCADE;
DROP TABLE IF EXISTS pecas CASCADE;
DROP TABLE IF EXISTS oficinas_externas CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS cargos CASCADE;
DROP TABLE IF EXISTS regionais CASCADE;
DROP TABLE IF EXISTS estados CASCADE;

-- Remover índices (se existirem)
DROP INDEX IF EXISTS idx_usuarios_cargo_regional CASCADE;
DROP INDEX IF EXISTS idx_usuarios_supervisor CASCADE;
DROP INDEX IF EXISTS idx_veiculos_placa CASCADE;
DROP INDEX IF EXISTS idx_veiculos_regional_status CASCADE;
DROP INDEX IF EXISTS idx_os_numero CASCADE;
DROP INDEX IF EXISTS idx_os_veiculo_status CASCADE;
DROP INDEX IF EXISTS idx_os_data_entrada CASCADE;
DROP INDEX IF EXISTS idx_pecas_codigo CASCADE;
DROP INDEX IF EXISTS idx_pecas_regional CASCADE;

-- =========================================
-- 2. SETUP COMPLETO RBAC SIMPLIFICADO
-- =========================================

-- Estados (apenas os necessários)
CREATE TABLE IF NOT EXISTS estados (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL UNIQUE,
    sigla VARCHAR(2) NOT NULL UNIQUE,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Regionais
CREATE TABLE IF NOT EXISTS regionais (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    sigla VARCHAR(20) NOT NULL,
    estado_id UUID NOT NULL REFERENCES estados(id) ON DELETE CASCADE,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(estado_id, nome)
);

-- Cargos simplificados (apenas os essenciais)
CREATE TABLE IF NOT EXISTS cargos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL UNIQUE,
    sigla VARCHAR(20) NOT NULL UNIQUE,
    nivel INTEGER NOT NULL CHECK (nivel >= 1 AND nivel <= 5),
    categoria VARCHAR(20) NOT NULL CHECK (categoria IN ('oficina', 'operacao', 'admin')),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Usuários com hierarquia simples
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    matricula VARCHAR(50) NOT NULL UNIQUE,
    cargo_id UUID NOT NULL REFERENCES cargos(id),
    regional_id UUID REFERENCES regionais(id),
    supervisor_id UUID REFERENCES usuarios(id),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Veículos
CREATE TABLE IF NOT EXISTS veiculos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    placa VARCHAR(20) NOT NULL UNIQUE,
    modelo VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    ano INTEGER CHECK (ano >= 1980),
    quilometragem INTEGER DEFAULT 0 CHECK (quilometragem >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'ativo' CHECK (status IN ('ativo', 'manutencao', 'inativo', 'oficina_externa')),
    regional_id UUID REFERENCES regionais(id),
    responsavel_id UUID REFERENCES usuarios(id),
    criado_por UUID NOT NULL REFERENCES usuarios(id),
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ordens de serviço
CREATE TABLE IF NOT EXISTS ordens_servico (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_os VARCHAR(50) NOT NULL UNIQUE,
    veiculo_id UUID NOT NULL REFERENCES veiculos(id) ON DELETE RESTRICT,
    problema_reportado TEXT NOT NULL,
    diagnostico TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'em_andamento' CHECK (status IN ('em_andamento', 'concluida', 'cancelada', 'oficina_externa')),
    prioridade VARCHAR(20) DEFAULT 'normal' CHECK (prioridade IN ('baixa', 'normal', 'alta', 'urgente')),
    data_entrada TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    data_saida TIMESTAMP WITH TIME ZONE,
    supervisor_entrega_id UUID REFERENCES usuarios(id),
    supervisor_retirada_id UUID REFERENCES usuarios(id),
    mecanico_responsavel_id UUID REFERENCES usuarios(id),
    criado_por UUID NOT NULL REFERENCES usuarios(id),
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Peças
CREATE TABLE IF NOT EXISTS pecas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(200) NOT NULL,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    fornecedor VARCHAR(200),
    custo_unitario DECIMAL(12,2) NOT NULL CHECK (custo_unitario >= 0),
    quantidade_estoque INTEGER NOT NULL DEFAULT 0 CHECK (quantidade_estoque >= 0),
    quantidade_minima INTEGER DEFAULT 0 CHECK (quantidade_minima >= 0),
    categoria VARCHAR(100),
    regional_id UUID REFERENCES regionais(id),
    ativo BOOLEAN DEFAULT true,
    criado_por UUID NOT NULL REFERENCES usuarios(id),
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Peças usadas
CREATE TABLE IF NOT EXISTS pecas_usadas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ordem_servico_id UUID NOT NULL REFERENCES ordens_servico(id) ON DELETE CASCADE,
    peca_id UUID NOT NULL REFERENCES pecas(id) ON DELETE RESTRICT,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    custo_unitario DECIMAL(12,2) NOT NULL CHECK (custo_unitario >= 0),
    responsavel_id UUID NOT NULL REFERENCES usuarios(id),
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Oficinas externas
CREATE TABLE IF NOT EXISTS oficinas_externas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(200) NOT NULL,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    endereco TEXT,
    telefone VARCHAR(20),
    contato VARCHAR(100),
    regional_id UUID REFERENCES regionais(id),
    ativo BOOLEAN DEFAULT true,
    criado_por UUID NOT NULL REFERENCES usuarios(id),
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Serviços externos
CREATE TABLE IF NOT EXISTS servicos_externos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ordem_servico_id UUID NOT NULL REFERENCES ordens_servico(id) ON DELETE CASCADE,
    oficina_externa_id UUID NOT NULL REFERENCES oficinas_externas(id) ON DELETE RESTRICT,
    descricao TEXT NOT NULL,
    valor DECIMAL(12,2) NOT NULL CHECK (valor >= 0),
    data_envio TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    data_retorno TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'em_andamento' CHECK (status IN ('em_andamento', 'concluido', 'cancelado')),
    criado_por UUID NOT NULL REFERENCES usuarios(id),
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =========================================
-- ÍNDICES ESSENCIAIS
-- =========================================

-- Hierarquia
CREATE INDEX IF NOT EXISTS idx_usuarios_cargo_regional ON usuarios(cargo_id, regional_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_supervisor ON usuarios(supervisor_id);

-- Veículos
CREATE INDEX IF NOT EXISTS idx_veiculos_placa ON veiculos(placa);
CREATE INDEX IF NOT EXISTS idx_veiculos_regional_status ON veiculos(regional_id, status);

-- Ordens de serviço
CREATE INDEX IF NOT EXISTS idx_os_numero ON ordens_servico(numero_os);
CREATE INDEX IF NOT EXISTS idx_os_veiculo_status ON ordens_servico(veiculo_id, status);
CREATE INDEX IF NOT EXISTS idx_os_data_entrada ON ordens_servico(data_entrada);

-- Peças
CREATE INDEX IF NOT EXISTS idx_pecas_codigo ON pecas(codigo);
CREATE INDEX IF NOT EXISTS idx_pecas_regional ON pecas(regional_id);

-- =========================================
-- DADOS INICIAIS
-- =========================================

-- Estados
INSERT INTO estados (nome, sigla) VALUES
    ('Piauí', 'PI'),
    ('Maranhão', 'MA')
ON CONFLICT (nome) DO NOTHING;

-- Regionais
INSERT INTO regionais (nome, sigla, estado_id) 
SELECT 
    r.nome,
    r.sigla,
    e.id
FROM (
    VALUES 
        ('Metropolitana', 'MET', 'Piauí'),
        ('Norte', 'NORTE', 'Piauí'),
        ('Sul', 'SUL', 'Piauí'),
        ('Centro Sul', 'CENTRO_SUL', 'Piauí'),
        ('Noroeste', 'NOROESTE', 'Maranhão'),
        ('Norte', 'NORTE', 'Maranhão'),
        ('Sul', 'SUL', 'Maranhão')
) AS r(nome, sigla, estado_nome)
JOIN estados e ON e.nome = r.estado_nome
ON CONFLICT (estado_id, nome) DO NOTHING;

-- Cargos simplificados
INSERT INTO cargos (nome, sigla, nivel, categoria) VALUES
    -- Oficina
    ('Mecânico', 'MECANICO', 1, 'oficina'),
    ('Analista da Oficina', 'ANALISTA_OFICINA', 2, 'oficina'),
    
    -- Operação
    ('Supervisor', 'SUPERVISOR', 3, 'operacao'),
    ('Coordenador', 'COORDENADOR', 4, 'operacao'),
    ('Gerente', 'GERENTE', 5, 'operacao'),
    
    -- Admin
    ('Diretor', 'DIRETOR', 5, 'admin')
ON CONFLICT (nome) DO NOTHING;

-- =========================================
-- FUNÇÕES SIMPLIFICADAS (NO SCHEMA PUBLIC)
-- =========================================

-- Função para obter cargo do usuário
CREATE OR REPLACE FUNCTION public.user_cargo()
RETURNS TEXT AS $$
BEGIN
    RETURN (
        SELECT c.sigla 
        FROM usuarios u 
        JOIN cargos c ON u.cargo_id = c.id 
        WHERE u.auth_user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter regional do usuário
CREATE OR REPLACE FUNCTION public.user_regional()
RETURNS UUID AS $$
BEGIN
    RETURN (
        SELECT regional_id 
        FROM usuarios 
        WHERE auth_user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar permissão baseada em cargo
CREATE OR REPLACE FUNCTION public.can_access(required_cargo TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    user_cargo TEXT;
    user_nivel INTEGER;
    required_nivel INTEGER;
BEGIN
    SELECT c.sigla, c.nivel INTO user_cargo, user_nivel
    FROM usuarios u
    JOIN cargos c ON u.cargo_id = c.id
    WHERE u.auth_user_id = auth.uid();
    
    SELECT nivel INTO required_nivel
    FROM cargos
    WHERE sigla = required_cargo;
    
    -- Usuário pode acessar se tem nível igual ou superior
    RETURN user_nivel >= required_nivel;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================
-- ROW LEVEL SECURITY SIMPLIFICADO
-- =========================================

-- Habilitar RLS
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE veiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;
ALTER TABLE pecas ENABLE ROW LEVEL SECURITY;
ALTER TABLE pecas_usadas ENABLE ROW LEVEL SECURITY;
ALTER TABLE oficinas_externas ENABLE ROW LEVEL SECURITY;
ALTER TABLE servicos_externos ENABLE ROW LEVEL SECURITY;

-- Políticas simples baseadas em cargo e regional

-- Usuários: ver próprios dados ou se for gerente/diretor
CREATE POLICY "Usuários podem ver dados apropriados" ON usuarios
    FOR SELECT USING (
        auth_user_id = auth.uid() OR 
        public.can_access('GERENTE')
    );

-- Veículos: ver da própria regional ou se for diretor
CREATE POLICY "Veículos por regional" ON veiculos
    FOR SELECT USING (
        regional_id = public.user_regional() OR 
        public.user_cargo() = 'DIRETOR'
    );

CREATE POLICY "Veículos por regional - write" ON veiculos
    FOR ALL USING (
        (regional_id = public.user_regional() AND public.can_access('SUPERVISOR')) OR 
        public.user_cargo() = 'DIRETOR'
    );

-- Ordens de serviço: ver da própria regional
CREATE POLICY "OS por regional" ON ordens_servico
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM veiculos v 
            WHERE v.id = ordens_servico.veiculo_id 
            AND (v.regional_id = public.user_regional() OR public.user_cargo() = 'DIRETOR')
        )
    );

CREATE POLICY "OS por regional - write" ON ordens_servico
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM veiculos v 
            WHERE v.id = ordens_servico.veiculo_id 
            AND (v.regional_id = public.user_regional() OR public.user_cargo() = 'DIRETOR')
        ) AND public.can_access('SUPERVISOR')
    );

-- Peças: ver da própria regional
CREATE POLICY "Peças por regional" ON pecas
    FOR SELECT USING (
        regional_id = public.user_regional() OR 
        public.user_cargo() = 'DIRETOR'
    );

CREATE POLICY "Peças por regional - write" ON pecas
    FOR ALL USING (
        (regional_id = public.user_regional() AND public.can_access('ANALISTA_OFICINA')) OR 
        public.user_cargo() = 'DIRETOR'
    );

-- Peças usadas: ver da própria regional
CREATE POLICY "Peças usadas por regional" ON pecas_usadas
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM ordens_servico os
            JOIN veiculos v ON os.veiculo_id = v.id
            WHERE os.id = pecas_usadas.ordem_servico_id
            AND (v.regional_id = public.user_regional() OR public.user_cargo() = 'DIRETOR')
        )
    );

CREATE POLICY "Peças usadas por regional - write" ON pecas_usadas
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM ordens_servico os
            JOIN veiculos v ON os.veiculo_id = v.id
            WHERE os.id = pecas_usadas.ordem_servico_id
            AND (v.regional_id = public.user_regional() OR public.user_cargo() = 'DIRETOR')
        ) AND public.can_access('MECANICO')
    );

-- Oficinas externas: ver da própria regional
CREATE POLICY "Oficinas externas por regional" ON oficinas_externas
    FOR SELECT USING (
        regional_id = public.user_regional() OR 
        public.user_cargo() = 'DIRETOR'
    );

CREATE POLICY "Oficinas externas por regional - write" ON oficinas_externas
    FOR ALL USING (
        (regional_id = public.user_regional() AND public.can_access('ANALISTA_OFICINA')) OR 
        public.user_cargo() = 'DIRETOR'
    );

-- Serviços externos: ver da própria regional
CREATE POLICY "Serviços externos por regional" ON servicos_externos
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM ordens_servico os
            JOIN veiculos v ON os.veiculo_id = v.id
            WHERE os.id = servicos_externos.ordem_servico_id
            AND (v.regional_id = public.user_regional() OR public.user_cargo() = 'DIRETOR')
        )
    );

CREATE POLICY "Serviços externos por regional - write" ON servicos_externos
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM ordens_servico os
            JOIN veiculos v ON os.veiculo_id = v.id
            WHERE os.id = servicos_externos.ordem_servico_id
            AND (v.regional_id = public.user_regional() OR public.user_cargo() = 'DIRETOR')
        ) AND public.can_access('ANALISTA_OFICINA')
    );

-- =========================================
-- COMENTÁRIOS
-- =========================================

COMMENT ON TABLE estados IS 'Estados onde a empresa atua';
COMMENT ON TABLE regionais IS 'Regionais de cada estado';
COMMENT ON TABLE cargos IS 'Cargos dos usuários com níveis hierárquicos';
COMMENT ON TABLE usuarios IS 'Usuários do sistema com hierarquia';
COMMENT ON TABLE veiculos IS 'Veículos da frota';
COMMENT ON TABLE ordens_servico IS 'Ordens de serviço da oficina';
COMMENT ON TABLE pecas IS 'Peças em estoque';
COMMENT ON TABLE pecas_usadas IS 'Peças utilizadas nas ordens de serviço';
COMMENT ON TABLE oficinas_externas IS 'Oficinas externas credenciadas';
COMMENT ON TABLE servicos_externos IS 'Serviços realizados em oficinas externas';

-- =========================================
-- VERIFICAÇÃO FINAL
-- =========================================

-- Verificar se tudo foi criado corretamente
SELECT 'Tabelas criadas:' as info;
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;

SELECT 'Funções criadas:' as info;
SELECT proname FROM pg_proc WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public') AND proname IN ('user_cargo', 'user_regional', 'can_access');

SELECT 'Políticas RLS criadas:' as info;
SELECT schemaname, tablename, policyname FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;
