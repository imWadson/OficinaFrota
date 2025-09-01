-- Script para verificar e corrigir RLS da tabela veículos
-- Execute este script no Supabase SQL Editor

-- 1. Verificar se RLS está habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'veiculos';

-- 2. Verificar políticas existentes
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'veiculos';

-- 3. Desabilitar RLS temporariamente para teste
ALTER TABLE veiculos DISABLE ROW LEVEL SECURITY;

-- 4. Ou criar política permissiva para todos os usuários autenticados
-- (Descomente as linhas abaixo se quiser manter RLS mas permitir acesso)
/*
DROP POLICY IF EXISTS "Permitir acesso a veículos para usuários autenticados" ON veiculos;

CREATE POLICY "Permitir acesso a veículos para usuários autenticados"
ON veiculos
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
*/

-- 5. Verificar se a tabela tem dados após desabilitar RLS
SELECT COUNT(*) as total_veiculos_apos_rls FROM veiculos;

-- 6. Listar veículos após desabilitar RLS
SELECT 
    id,
    placa,
    modelo,
    tipo,
    status,
    regional_id
FROM veiculos
ORDER BY placa;
