-- =====================================================
-- CORREÇÃO APENAS DO RLS - TABELA VEÍCULOS
-- =====================================================
-- Este script corrige apenas as políticas RLS, mantendo o campo criado_por obrigatório

-- 1. Remover políticas existentes que estão bloqueando
DROP POLICY
IF EXISTS "Veículos por regional" ON veiculos;
DROP POLICY
IF EXISTS "Veículos por regional - write" ON veiculos;

-- 2. Criar política permissiva para usuários autenticados
CREATE POLICY "Veículos - acesso para usuários autenticados" ON veiculos
    FOR ALL USING
(auth.role
() = 'authenticated');

-- 3. Verificar se as políticas foram criadas
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'veiculos';

-- 4. Verificar se RLS está habilitado
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

-- 5. Verificar se o campo criado_por ainda é obrigatório
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'veiculos'
    AND column_name = 'criado_por';
