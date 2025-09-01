-- Script simples para verificar dados na tabela veiculos
-- Execute este script no Supabase SQL Editor

-- 1. Verificar se a tabela existe e tem dados
SELECT COUNT(*) as total_veiculos FROM veiculos;

-- 2. Verificar estrutura da tabela
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'veiculos' 
ORDER BY ordinal_position;

-- 3. Verificar se há pelo menos um veículo
SELECT 
    id,
    placa,
    modelo,
    tipo,
    status,
    regional_id
FROM veiculos 
LIMIT 5;

-- 4. Verificar se há veículos com status 'ativo'
SELECT COUNT(*) as veiculos_ativos 
FROM veiculos 
WHERE status = 'ativo';

-- 5. Verificar se há regionais
SELECT COUNT(*) as total_regionais FROM regionais;

-- 6. Verificar se há usuários
SELECT COUNT(*) as total_usuarios FROM usuarios;
