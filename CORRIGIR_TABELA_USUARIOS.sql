-- Script para corrigir a tabela usuarios
-- Execute este script no SQL Editor do Supabase

-- 1. Verificar se a tabela existe
SELECT EXISTS
(
  SELECT
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_name = 'usuarios'
);

-- 2. Se não existir, criar a tabela com tipos corretos
CREATE TABLE
IF NOT EXISTS usuarios
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid
(),
    auth_user_id UUID REFERENCES auth.users
(id) ON
DELETE CASCADE,
    nome VARCHAR(200)
NOT NULL,
    email VARCHAR
(255) NOT NULL UNIQUE,
    matricula VARCHAR
(50) NOT NULL UNIQUE,
    cargo_id VARCHAR
(100) NOT NULL, -- Mudado de UUID para VARCHAR
    regional_id VARCHAR
(100), -- Mudado de UUID para VARCHAR
    supervisor_id UUID REFERENCES usuarios
(id),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP
WITH TIME ZONE DEFAULT NOW
()
);

-- 3. Se a tabela já existir, alterar os tipos dos campos
DO $$ 
BEGIN
    -- Alterar cargo_id para VARCHAR se for UUID
    IF EXISTS (
        SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'usuarios'
        AND column_name = 'cargo_id'
        AND data_type = 'uuid'
    ) THEN
    ALTER TABLE usuarios ALTER COLUMN cargo_id TYPE
    VARCHAR
    (100);
END
IF;
    
    -- Alterar regional_id para VARCHAR se for UUID
    IF EXISTS (
        SELECT 1
FROM information_schema.columns
WHERE table_name = 'usuarios'
    AND column_name = 'regional_id'
    AND data_type = 'uuid'
    ) THEN
ALTER TABLE usuarios ALTER COLUMN regional_id TYPE
VARCHAR
(100);
END
IF;
END $$;

-- 4. Verificar a estrutura da tabela
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'usuarios'
ORDER BY ordinal_position;

-- 5. Habilitar RLS
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- 6. Criar políticas básicas
CREATE POLICY "Usuarios podem ver seus próprios dados" ON usuarios
    FOR
SELECT USING (auth.uid() = auth_user_id);

CREATE POLICY "Usuarios podem inserir seus próprios dados" ON usuarios
    FOR
INSERT WITH CHECK (auth.uid() =
auth_user_id);

CREATE POLICY "Usuarios podem atualizar seus próprios dados" ON usuarios
    FOR
UPDATE USING (auth.uid()
= auth_user_id);

-- 7. Verificar políticas criadas
SELECT *
FROM pg_policies
WHERE tablename = 'usuarios';

-- 8. Inserir dados de teste (opcional)
INSERT INTO usuarios
    (auth_user_id, nome, email, matricula, cargo_id, regional_id, ativo)
VALUES
    (
        (SELECT id
        FROM auth.users LIMIT
1), -- Substitua pelo ID real do usuário
    'Usuário Teste',
    'teste@empresa.com',
    'TEST001',
    'cargo-gerente',
    'regional-sp',
    true
) ON CONFLICT
(email) DO NOTHING;

-- 9. Verificar dados inseridos
SELECT *
FROM usuarios;
