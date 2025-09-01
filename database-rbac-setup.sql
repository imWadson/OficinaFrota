-- =====================================================
-- FROTA GESTOR - SISTEMA CORPORATIVO RBAC
-- =====================================================
-- Script de configuração do banco de dados com RBAC
-- Sistema para gestão de frota e oficina interna
-- Setor: Energia Elétrica

-- =========================================
-- ESTRUTURA HIERÁRQUICA E PERMISSÕES
-- =========================================

-- Tabela de Estados
CREATE TABLE IF NOT EXISTS estados (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL UNIQUE,
    sigla VARCHAR(2) NOT NULL UNIQUE,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de Regionais
CREATE TABLE IF NOT EXISTS regionais (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    sigla VARCHAR(20) NOT NULL,
    estado_id UUID NOT NULL REFERENCES estados(id) ON DELETE CASCADE,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(estado_id, nome)
);

-- Tabela de Cargos com hierarquia
CREATE TABLE IF NOT EXISTS cargos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL UNIQUE,
    sigla VARCHAR(20) NOT NULL UNIQUE,
    nivel INTEGER NOT NULL CHECK (nivel >= 1 AND nivel <= 10),
    categoria VARCHAR(50) NOT NULL CHECK (categoria IN ('oficina', 'operacao', 'admin')),
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de Usuários com hierarquia
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    matricula VARCHAR(50) NOT NULL UNIQUE,
    cargo_id UUID NOT NULL REFERENCES cargos(id),
    regional_id UUID REFERENCES regionais(id),
    supervisor_id UUID REFERENCES usuarios(id), -- Hierarquia de supervisão
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de Permissões
CREATE TABLE IF NOT EXISTS permissoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL UNIQUE,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT,
    modulo VARCHAR(50) NOT NULL, -- 'frota', 'oficina', 'estoque', 'relatorios', etc.
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de relacionamento Cargo-Permissão
CREATE TABLE IF NOT EXISTS cargo_permissoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cargo_id UUID NOT NULL REFERENCES cargos(id) ON DELETE CASCADE,
    permissao_id UUID NOT NULL REFERENCES permissoes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(cargo_id, permissao_id)
);

-- =========================================
-- TABELAS DE NEGÓCIO
-- =========================================

-- Tabela de veículos
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
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de ordens de serviço
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
    data_limite TIMESTAMP WITH TIME ZONE,
    supervisor_entrega_id UUID REFERENCES usuarios(id),
    supervisor_retirada_id UUID REFERENCES usuarios(id),
    mecanico_responsavel_id UUID REFERENCES usuarios(id),
    observacoes TEXT,
    criado_por UUID NOT NULL REFERENCES usuarios(id),
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de peças
CREATE TABLE IF NOT EXISTS pecas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(200) NOT NULL,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    fornecedor VARCHAR(200),
    custo_unitario DECIMAL(12,2) NOT NULL CHECK (custo_unitario >= 0),
    quantidade_estoque INTEGER NOT NULL DEFAULT 0 CHECK (quantidade_estoque >= 0),
    quantidade_minima INTEGER DEFAULT 0 CHECK (quantidade_minima >= 0),
    unidade VARCHAR(20) DEFAULT 'un',
    categoria VARCHAR(100),
    regional_id UUID REFERENCES regionais(id), -- Para estoque regional
    ativo BOOLEAN DEFAULT true,
    criado_por UUID NOT NULL REFERENCES usuarios(id),
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de peças usadas
CREATE TABLE IF NOT EXISTS pecas_usadas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ordem_servico_id UUID NOT NULL REFERENCES ordens_servico(id) ON DELETE CASCADE,
    peca_id UUID NOT NULL REFERENCES pecas(id) ON DELETE RESTRICT,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    custo_unitario DECIMAL(12,2) NOT NULL CHECK (custo_unitario >= 0),
    data_uso TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    responsavel_id UUID NOT NULL REFERENCES usuarios(id),
    observacoes TEXT,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de oficinas externas
CREATE TABLE IF NOT EXISTS oficinas_externas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(200) NOT NULL,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    endereco TEXT,
    telefone VARCHAR(20),
    contato VARCHAR(100),
    email VARCHAR(255),
    regional_id UUID REFERENCES regionais(id),
    ativo BOOLEAN DEFAULT true,
    criado_por UUID NOT NULL REFERENCES usuarios(id),
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de serviços externos
CREATE TABLE IF NOT EXISTS servicos_externos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ordem_servico_id UUID NOT NULL REFERENCES ordens_servico(id) ON DELETE CASCADE,
    oficina_externa_id UUID NOT NULL REFERENCES oficinas_externas(id) ON DELETE RESTRICT,
    descricao TEXT NOT NULL,
    valor DECIMAL(12,2) NOT NULL CHECK (valor >= 0),
    data_envio TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    data_retorno TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'em_andamento' CHECK (status IN ('em_andamento', 'concluido', 'cancelado')),
    observacoes TEXT,
    criado_por UUID NOT NULL REFERENCES usuarios(id),
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =========================================
-- ÍNDICES PARA PERFORMANCE
-- =========================================

-- Índices para hierarquia
CREATE INDEX IF NOT EXISTS idx_usuarios_cargo_id ON usuarios(cargo_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_regional_id ON usuarios(regional_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_supervisor_id ON usuarios(supervisor_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_ativo ON usuarios(ativo);

-- Índices para veículos
CREATE INDEX IF NOT EXISTS idx_veiculos_placa ON veiculos(placa);
CREATE INDEX IF NOT EXISTS idx_veiculos_status ON veiculos(status);
CREATE INDEX IF NOT EXISTS idx_veiculos_regional_id ON veiculos(regional_id);
CREATE INDEX IF NOT EXISTS idx_veiculos_responsavel_id ON veiculos(responsavel_id);

-- Índices para ordens de serviço
CREATE INDEX IF NOT EXISTS idx_os_numero ON ordens_servico(numero_os);
CREATE INDEX IF NOT EXISTS idx_os_veiculo_id ON ordens_servico(veiculo_id);
CREATE INDEX IF NOT EXISTS idx_os_status ON ordens_servico(status);
CREATE INDEX IF NOT EXISTS idx_os_data_entrada ON ordens_servico(data_entrada);
CREATE INDEX IF NOT EXISTS idx_os_supervisor_entrega ON ordens_servico(supervisor_entrega_id);
CREATE INDEX IF NOT EXISTS idx_os_mecanico ON ordens_servico(mecanico_responsavel_id);

-- Índices para peças
CREATE INDEX IF NOT EXISTS idx_pecas_codigo ON pecas(codigo);
CREATE INDEX IF NOT EXISTS idx_pecas_regional_id ON pecas(regional_id);
CREATE INDEX IF NOT EXISTS idx_pecas_ativo ON pecas(ativo);

-- Índices para peças usadas
CREATE INDEX IF NOT EXISTS idx_pecas_usadas_os ON pecas_usadas(ordem_servico_id);
CREATE INDEX IF NOT EXISTS idx_pecas_usadas_peca ON pecas_usadas(peca_id);
CREATE INDEX IF NOT EXISTS idx_pecas_usadas_data ON pecas_usadas(data_uso);

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

-- Cargos com hierarquia
INSERT INTO cargos (nome, sigla, nivel, categoria, descricao) VALUES
    -- Oficina
    ('Mecânico', 'MECANICO', 1, 'oficina', 'Mecânico da oficina interna'),
    ('Analista da Oficina', 'ANALISTA_OFICINA', 2, 'oficina', 'Analista responsável pela oficina'),
    ('Administrativo da Oficina', 'ADMIN_OFICINA', 2, 'oficina', 'Administrativo da oficina'),
    
    -- Operação
    ('Supervisor', 'SUPERVISOR', 3, 'operacao', 'Supervisor de campo'),
    ('Coordenador', 'COORDENADOR', 4, 'operacao', 'Coordenador de supervisores'),
    ('Gerente', 'GERENTE', 5, 'operacao', 'Gerente regional/estadual'),
    ('Analista da Operação', 'ANALISTA_OPERACAO', 3, 'operacao', 'Analista da operação'),
    
    -- Admin (não disponível no cadastro)
    ('Diretor', 'DIRETOR', 10, 'admin', 'Diretor com acesso total ao sistema')
ON CONFLICT (nome) DO NOTHING;

-- Permissões do sistema
INSERT INTO permissoes (nome, codigo, descricao, modulo) VALUES
    -- Permissões de Frota
    ('Visualizar Frota', 'frota.visualizar', 'Pode visualizar veículos da frota', 'frota'),
    ('Gerenciar Frota', 'frota.gerenciar', 'Pode adicionar, editar e remover veículos', 'frota'),
    ('Relatórios de Frota', 'frota.relatorios', 'Pode gerar relatórios da frota', 'frota'),
    
    -- Permissões de Oficina
    ('Visualizar Ordens de Serviço', 'oficina.visualizar', 'Pode visualizar ordens de serviço', 'oficina'),
    ('Criar Ordens de Serviço', 'oficina.criar', 'Pode criar novas ordens de serviço', 'oficina'),
    ('Gerenciar Ordens de Serviço', 'oficina.gerenciar', 'Pode editar e cancelar ordens de serviço', 'oficina'),
    ('Concluir Ordens de Serviço', 'oficina.concluir', 'Pode marcar ordens como concluídas', 'oficina'),
    ('Relatórios de Oficina', 'oficina.relatorios', 'Pode gerar relatórios da oficina', 'oficina'),
    
    -- Permissões de Estoque
    ('Visualizar Estoque', 'estoque.visualizar', 'Pode visualizar peças em estoque', 'estoque'),
    ('Gerenciar Estoque', 'estoque.gerenciar', 'Pode adicionar, editar e remover peças', 'estoque'),
    ('Movimentar Estoque', 'estoque.movimentar', 'Pode registrar uso de peças', 'estoque'),
    ('Relatórios de Estoque', 'estoque.relatorios', 'Pode gerar relatórios de estoque', 'estoque'),
    
    -- Permissões de Oficinas Externas
    ('Visualizar Oficinas Externas', 'externas.visualizar', 'Pode visualizar oficinas externas', 'externas'),
    ('Gerenciar Oficinas Externas', 'externas.gerenciar', 'Pode gerenciar oficinas externas', 'externas'),
    
    -- Permissões de Usuários
    ('Visualizar Usuários', 'usuarios.visualizar', 'Pode visualizar usuários', 'usuarios'),
    ('Gerenciar Usuários', 'usuarios.gerenciar', 'Pode gerenciar usuários', 'usuarios'),
    
    -- Permissões de Sistema
    ('Configurações do Sistema', 'sistema.config', 'Pode alterar configurações do sistema', 'sistema'),
    ('Acesso Total', 'sistema.total', 'Acesso total ao sistema', 'sistema')
ON CONFLICT (nome) DO NOTHING;

-- Atribuição de permissões aos cargos
INSERT INTO cargo_permissoes (cargo_id, permissao_id)
SELECT c.id, p.id
FROM cargos c, permissoes p
WHERE 
    -- Mecânico
    (c.sigla = 'MECANICO' AND p.codigo IN (
        'oficina.visualizar', 'oficina.criar', 'oficina.concluir',
        'estoque.visualizar', 'estoque.movimentar'
    ))
    OR
    -- Analista da Oficina
    (c.sigla = 'ANALISTA_OFICINA' AND p.codigo IN (
        'frota.visualizar', 'frota.relatorios',
        'oficina.visualizar', 'oficina.criar', 'oficina.gerenciar', 'oficina.concluir', 'oficina.relatorios',
        'estoque.visualizar', 'estoque.gerenciar', 'estoque.movimentar', 'estoque.relatorios',
        'externas.visualizar', 'externas.gerenciar'
    ))
    OR
    -- Administrativo da Oficina
    (c.sigla = 'ADMIN_OFICINA' AND p.codigo IN (
        'frota.visualizar',
        'oficina.visualizar', 'oficina.relatorios',
        'estoque.visualizar', 'estoque.gerenciar', 'estoque.relatorios',
        'externas.visualizar'
    ))
    OR
    -- Supervisor
    (c.sigla = 'SUPERVISOR' AND p.codigo IN (
        'frota.visualizar', 'frota.gerenciar',
        'oficina.visualizar', 'oficina.criar', 'oficina.gerenciar', 'oficina.relatorios',
        'estoque.visualizar', 'estoque.movimentar',
        'externas.visualizar'
    ))
    OR
    -- Coordenador
    (c.sigla = 'COORDENADOR' AND p.codigo IN (
        'frota.visualizar', 'frota.gerenciar', 'frota.relatorios',
        'oficina.visualizar', 'oficina.criar', 'oficina.gerenciar', 'oficina.concluir', 'oficina.relatorios',
        'estoque.visualizar', 'estoque.gerenciar', 'estoque.movimentar', 'estoque.relatorios',
        'externas.visualizar', 'externas.gerenciar',
        'usuarios.visualizar'
    ))
    OR
    -- Gerente
    (c.sigla = 'GERENTE' AND p.codigo IN (
        'frota.visualizar', 'frota.gerenciar', 'frota.relatorios',
        'oficina.visualizar', 'oficina.criar', 'oficina.gerenciar', 'oficina.concluir', 'oficina.relatorios',
        'estoque.visualizar', 'estoque.gerenciar', 'estoque.movimentar', 'estoque.relatorios',
        'externas.visualizar', 'externas.gerenciar',
        'usuarios.visualizar', 'usuarios.gerenciar'
    ))
    OR
    -- Analista da Operação
    (c.sigla = 'ANALISTA_OPERACAO' AND p.codigo IN (
        'frota.visualizar', 'frota.relatorios',
        'oficina.visualizar', 'oficina.relatorios',
        'estoque.visualizar', 'estoque.relatorios',
        'externas.visualizar'
    ))
    OR
    -- Diretor (acesso total)
    (c.sigla = 'DIRETOR' AND p.codigo = 'sistema.total')
ON CONFLICT (cargo_id, permissao_id) DO NOTHING;

-- =========================================
-- FUNÇÕES E TRIGGERS
-- =========================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_estados_updated_at BEFORE UPDATE ON estados
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_regionais_updated_at BEFORE UPDATE ON regionais
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cargos_updated_at BEFORE UPDATE ON cargos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_veiculos_updated_at BEFORE UPDATE ON veiculos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ordens_servico_updated_at BEFORE UPDATE ON ordens_servico
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pecas_updated_at BEFORE UPDATE ON pecas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_oficinas_externas_updated_at BEFORE UPDATE ON oficinas_externas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_servicos_externos_updated_at BEFORE UPDATE ON servicos_externos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =========================================
-- FUNÇÕES DE PERMISSÃO
-- =========================================

-- Função para obter o cargo do usuário atual
CREATE OR REPLACE FUNCTION auth.user_cargo()
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

-- Função para obter a regional do usuário atual
CREATE OR REPLACE FUNCTION auth.user_regional()
RETURNS UUID AS $$
BEGIN
    RETURN (
        SELECT regional_id 
        FROM usuarios 
        WHERE auth_user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter o supervisor do usuário atual
CREATE OR REPLACE FUNCTION auth.user_supervisor()
RETURNS UUID AS $$
BEGIN
    RETURN (
        SELECT supervisor_id 
        FROM usuarios 
        WHERE auth_user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar se usuário tem permissão
CREATE OR REPLACE FUNCTION auth.has_permission(permission_code TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM usuarios u
        JOIN cargos c ON u.cargo_id = c.id
        JOIN cargo_permissoes cp ON c.id = cp.cargo_id
        JOIN permissoes p ON cp.permissao_id = p.id
        WHERE u.auth_user_id = auth.uid()
        AND p.codigo = permission_code
        AND p.ativo = true
        AND c.ativo = true
        AND u.ativo = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar se usuário pode ver dados de outro usuário (hierarquia)
CREATE OR REPLACE FUNCTION auth.can_view_user_data(target_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    current_user_cargo TEXT;
    target_user_cargo TEXT;
    current_user_regional UUID;
    target_user_regional UUID;
BEGIN
    -- Obter dados do usuário atual
    SELECT c.sigla, u.regional_id INTO current_user_cargo, current_user_regional
    FROM usuarios u
    JOIN cargos c ON u.cargo_id = c.id
    WHERE u.auth_user_id = auth.uid();
    
    -- Obter dados do usuário alvo
    SELECT c.sigla, u.regional_id INTO target_user_cargo, target_user_regional
    FROM usuarios u
    JOIN cargos c ON u.cargo_id = c.id
    WHERE u.id = target_user_id;
    
    -- Diretor pode ver tudo
    IF current_user_cargo = 'DIRETOR' THEN
        RETURN true;
    END IF;
    
    -- Gerente pode ver usuários da mesma regional
    IF current_user_cargo = 'GERENTE' AND current_user_regional = target_user_regional THEN
        RETURN true;
    END IF;
    
    -- Coordenador pode ver supervisores e analistas da mesma regional
    IF current_user_cargo = 'COORDENADOR' AND current_user_regional = target_user_regional THEN
        RETURN target_user_cargo IN ('SUPERVISOR', 'ANALISTA_OPERACAO');
    END IF;
    
    -- Supervisor pode ver apenas seus próprios dados
    IF current_user_cargo = 'SUPERVISOR' THEN
        RETURN target_user_id = (SELECT id FROM usuarios WHERE auth_user_id = auth.uid());
    END IF;
    
    -- Outros cargos só podem ver seus próprios dados
    RETURN target_user_id = (SELECT id FROM usuarios WHERE auth_user_id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================
-- ROW LEVEL SECURITY (RLS)
-- =========================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE veiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;
ALTER TABLE pecas ENABLE ROW LEVEL SECURITY;
ALTER TABLE pecas_usadas ENABLE ROW LEVEL SECURITY;
ALTER TABLE oficinas_externas ENABLE ROW LEVEL SECURITY;
ALTER TABLE servicos_externos ENABLE ROW LEVEL SECURITY;

-- Políticas para usuários
CREATE POLICY "Usuários podem ver seus próprios dados" ON usuarios
    FOR SELECT USING (auth_user_id = auth.uid());

CREATE POLICY "Usuários podem editar seus próprios dados" ON usuarios
    FOR UPDATE USING (auth_user_id = auth.uid());

CREATE POLICY "Gerentes podem ver usuários da regional" ON usuarios
    FOR SELECT USING (
        auth.has_permission('usuarios.visualizar') AND
        (auth.user_cargo() = 'GERENTE' AND regional_id = auth.user_regional())
    );

CREATE POLICY "Coordenadores podem ver supervisores da regional" ON usuarios
    FOR SELECT USING (
        auth.has_permission('usuarios.visualizar') AND
        (auth.user_cargo() = 'COORDENADOR' AND regional_id = auth.user_regional())
    );

-- Políticas para veículos
CREATE POLICY "Usuários podem ver veículos da regional" ON veiculos
    FOR SELECT USING (
        auth.has_permission('frota.visualizar') AND
        (regional_id = auth.user_regional() OR auth.user_cargo() = 'DIRETOR')
    );

CREATE POLICY "Supervisores podem gerenciar veículos da regional" ON veiculos
    FOR ALL USING (
        auth.has_permission('frota.gerenciar') AND
        (regional_id = auth.user_regional() OR auth.user_cargo() = 'DIRETOR')
    );

-- Políticas para ordens de serviço
CREATE POLICY "Usuários podem ver OS da regional" ON ordens_servico
    FOR SELECT USING (
        auth.has_permission('oficina.visualizar') AND
        (EXISTS (
            SELECT 1 FROM veiculos v 
            WHERE v.id = ordens_servico.veiculo_id 
            AND (v.regional_id = auth.user_regional() OR auth.user_cargo() = 'DIRETOR')
        ))
    );

CREATE POLICY "Supervisores podem gerenciar OS da regional" ON ordens_servico
    FOR ALL USING (
        auth.has_permission('oficina.gerenciar') AND
        (EXISTS (
            SELECT 1 FROM veiculos v 
            WHERE v.id = ordens_servico.veiculo_id 
            AND (v.regional_id = auth.user_regional() OR auth.user_cargo() = 'DIRETOR')
        ))
    );

-- Políticas para peças
CREATE POLICY "Usuários podem ver peças da regional" ON pecas
    FOR SELECT USING (
        auth.has_permission('estoque.visualizar') AND
        (regional_id = auth.user_regional() OR auth.user_cargo() = 'DIRETOR')
    );

CREATE POLICY "Analistas podem gerenciar peças da regional" ON pecas
    FOR ALL USING (
        auth.has_permission('estoque.gerenciar') AND
        (regional_id = auth.user_regional() OR auth.user_cargo() = 'DIRETOR')
    );

-- Políticas para peças usadas
CREATE POLICY "Usuários podem ver peças usadas da regional" ON pecas_usadas
    FOR SELECT USING (
        auth.has_permission('estoque.visualizar') AND
        (EXISTS (
            SELECT 1 FROM ordens_servico os
            JOIN veiculos v ON os.veiculo_id = v.id
            WHERE os.id = pecas_usadas.ordem_servico_id
            AND (v.regional_id = auth.user_regional() OR auth.user_cargo() = 'DIRETOR')
        ))
    );

CREATE POLICY "Mecânicos podem registrar uso de peças" ON pecas_usadas
    FOR INSERT WITH CHECK (
        auth.has_permission('estoque.movimentar') AND
        (EXISTS (
            SELECT 1 FROM ordens_servico os
            JOIN veiculos v ON os.veiculo_id = v.id
            WHERE os.id = pecas_usadas.ordem_servico_id
            AND (v.regional_id = auth.user_regional() OR auth.user_cargo() = 'DIRETOR')
        ))
    );

-- Políticas para oficinas externas
CREATE POLICY "Usuários podem ver oficinas externas da regional" ON oficinas_externas
    FOR SELECT USING (
        auth.has_permission('externas.visualizar') AND
        (regional_id = auth.user_regional() OR auth.user_cargo() = 'DIRETOR')
    );

CREATE POLICY "Analistas podem gerenciar oficinas externas da regional" ON oficinas_externas
    FOR ALL USING (
        auth.has_permission('externas.gerenciar') AND
        (regional_id = auth.user_regional() OR auth.user_cargo() = 'DIRETOR')
    );

-- Políticas para serviços externos
CREATE POLICY "Usuários podem ver serviços externos da regional" ON servicos_externos
    FOR SELECT USING (
        auth.has_permission('externas.visualizar') AND
        (EXISTS (
            SELECT 1 FROM ordens_servico os
            JOIN veiculos v ON os.veiculo_id = v.id
            WHERE os.id = servicos_externos.ordem_servico_id
            AND (v.regional_id = auth.user_regional() OR auth.user_cargo() = 'DIRETOR')
        ))
    );

CREATE POLICY "Analistas podem gerenciar serviços externos da regional" ON servicos_externos
    FOR ALL USING (
        auth.has_permission('externas.gerenciar') AND
        (EXISTS (
            SELECT 1 FROM ordens_servico os
            JOIN veiculos v ON os.veiculo_id = v.id
            WHERE os.id = servicos_externos.ordem_servico_id
            AND (v.regional_id = auth.user_regional() OR auth.user_cargo() = 'DIRETOR')
        ))
    );

-- =========================================
-- COMENTÁRIOS
-- =========================================

COMMENT ON TABLE estados IS 'Estados onde a empresa atua';
COMMENT ON TABLE regionais IS 'Regionais de cada estado';
COMMENT ON TABLE cargos IS 'Cargos/funções dos usuários no sistema com hierarquia';
COMMENT ON TABLE usuarios IS 'Usuários do sistema com hierarquia de supervisão';
COMMENT ON TABLE permissoes IS 'Permissões disponíveis no sistema';
COMMENT ON TABLE cargo_permissoes IS 'Relacionamento entre cargos e permissões';
COMMENT ON TABLE veiculos IS 'Veículos da frota';
COMMENT ON TABLE ordens_servico IS 'Ordens de serviço da oficina';
COMMENT ON TABLE pecas IS 'Peças em estoque';
COMMENT ON TABLE pecas_usadas IS 'Peças utilizadas nas ordens de serviço';
COMMENT ON TABLE oficinas_externas IS 'Oficinas externas credenciadas';
COMMENT ON TABLE servicos_externos IS 'Serviços realizados em oficinas externas';
