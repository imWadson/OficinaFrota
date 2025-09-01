-- =====================================================
-- CORREÇÃO DAS POLÍTICAS RLS PARA TABELA VEÍCULOS
-- =====================================================
-- Este script corrige as políticas RLS que estão bloqueando a inserção de veículos

-- 1. Desabilitar RLS temporariamente para permitir inserções
ALTER TABLE veiculos DISABLE ROW LEVEL SECURITY;

-- 2. Ou, alternativamente, criar uma política mais permissiva para desenvolvimento
-- Primeiro, remover as políticas existentes
DROP POLICY
IF EXISTS "Veículos por regional" ON veiculos;
DROP POLICY
IF EXISTS "Veículos por regional - write" ON veiculos;

-- 3. Criar políticas mais permissivas para desenvolvimento
-- Política para leitura: usuários autenticados podem ver todos os veículos
CREATE POLICY "Veículos - leitura para usuários autenticados" ON veiculos
    FOR
SELECT USING (auth.role() = 'authenticated');

-- Política para escrita: usuários autenticados podem inserir/editar veículos
CREATE POLICY "Veículos - escrita para usuários autenticados" ON veiculos
    FOR ALL USING
(auth.role
() = 'authenticated');

-- 4. Verificar se as políticas foram criadas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'veiculos';

-- 5. Verificar se RLS está habilitado
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'veiculos';

-- =====================================================
-- ALTERNATIVA: POLÍTICAS BASEADAS EM REGIONAL (quando implementar)
-- =====================================================
/*
-- Para quando implementar o sistema de regionais:
CREATE POLICY "Veículos por regional - leitura" ON veiculos
    FOR SELECT USING (
        regional_id IS NULL OR -- Veículos sem regional são visíveis para todos
        regional_id = COALESCE(auth.user_regional(), '00000000-0000-0000-0000-000000000000')
    );

CREATE POLICY "Veículos por regional - escrita" ON veiculos
    FOR ALL USING (
        regional_id IS NULL OR -- Veículos sem regional podem ser editados por usuários autenticados
        regional_id = COALESCE(auth.user_regional(), '00000000-0000-0000-0000-000000000000')
    );
*/
