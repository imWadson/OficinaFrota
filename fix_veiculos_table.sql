-- =====================================================
-- CORREÇÃO DA TABELA VEÍCULOS - DESENVOLVIMENTO
-- =====================================================

-- 1. Desabilitar RLS para permitir inserções
ALTER TABLE veiculos DISABLE ROW LEVEL SECURITY;

-- 2. Tornar o campo criado_por opcional temporariamente
ALTER TABLE veiculos ALTER COLUMN criado_por DROP NOT NULL;

-- 3. Verificar a estrutura da tabela
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'veiculos'
ORDER BY ordinal_position;

-- 4. Verificar se RLS está desabilitado
SELECT
    schemaname,
    tablename,
    rowsecurity,
    CASE 
        WHEN rowsecurity THEN 'RLS ATIVO'
        ELSE 'RLS DESATIVADO'
    END as status_rls
FROM pg_tables
WHERE tablename = 'veiculos';

-- =====================================================
-- ALTERNATIVA: Manter RLS mas criar política permissiva
-- =====================================================
/*
-- Se preferir manter RLS:
-- 1. Remover políticas existentes
DROP POLICY IF EXISTS "Veículos por regional" ON veiculos;
DROP POLICY IF EXISTS "Veículos por regional - write" ON veiculos;

-- 2. Criar política permissiva
CREATE POLICY "Veículos - acesso para usuários autenticados" ON veiculos
    FOR ALL USING (auth.role() = 'authenticated');

-- 3. Reabilitar RLS
ALTER TABLE veiculos ENABLE ROW LEVEL SECURITY;
*/
