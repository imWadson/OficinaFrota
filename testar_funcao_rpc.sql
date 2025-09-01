-- Script para testar a função RPC
-- Execute este script no Supabase SQL Editor

-- 1. Verificar se a função existe
SELECT routine_name
FROM information_schema.routines
WHERE routine_name = 'criar_ordem_servico';

-- 2. Verificar dados disponíveis
SELECT 'VEÍCULOS' as tabela, COUNT(*) as total
FROM veiculos
WHERE status = 'ativo';
SELECT 'USUÁRIOS' as tabela, COUNT(*) as total
FROM usuarios
WHERE ativo = true;

-- 3. Pegar IDs para teste
SELECT id, placa
FROM veiculos
WHERE status = 'ativo'
LIMIT 1;
SELECT id, nome
FROM usuarios
WHERE ativo = true
LIMIT 1;

-- 4. Testar a função (descomente e ajuste os UUIDs)
/*
SELECT criar_ordem_servico(
    'UUID_DO_VEICULO_AQUI',
    'Problema de teste - freios',
    NULL,
    'UUID_DO_USUARIO_AQUI'
);
*/

-- 5. Verificar resultado
SELECT numero_os, status, data_entrada
FROM ordens_servico
ORDER BY data_entrada DESC
LIMIT 5;
