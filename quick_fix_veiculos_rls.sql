-- =====================================================
-- CORREÇÃO RÁPIDA DAS POLÍTICAS RLS PARA VEÍCULOS
-- =====================================================

-- Opção 1: Desabilitar RLS completamente (mais simples)
ALTER TABLE veiculos DISABLE ROW LEVEL SECURITY;

-- Opção 2: Se preferir manter RLS, criar políticas permissivas
-- DROP POLICY IF EXISTS "Veículos por regional" ON veiculos;
-- DROP POLICY IF EXISTS "Veículos por regional - write" ON veiculos;

-- CREATE POLICY "Veículos - acesso total para usuários autenticados" ON veiculos
--     FOR ALL USING (auth.role() = 'authenticated');

-- Verificar se funcionou
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
