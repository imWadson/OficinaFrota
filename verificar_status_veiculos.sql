-- Script para verificar e corrigir status dos veículos
-- Execute este script no Supabase SQL Editor

-- 1. Verificar todos os veículos e seus status
SELECT 
    id,
    placa,
    modelo,
    tipo,
    status,
    regional_id,
    criado_em
FROM veiculos
ORDER BY placa;

-- 2. Verificar quantos veículos têm cada status
SELECT 
    status,
    COUNT(*) as total
FROM veiculos
GROUP BY status;

-- 3. Verificar se há veículos com status NULL ou inválido
SELECT 
    id,
    placa,
    modelo,
    status
FROM veiculos
WHERE status IS NULL OR status NOT IN ('ativo', 'inativo', 'manutencao');

-- 4. Corrigir veículos com status NULL para 'ativo'
UPDATE veiculos 
SET status = 'ativo' 
WHERE status IS NULL;

-- 5. Verificar se há veículos sem regional_id
SELECT 
    id,
    placa,
    modelo,
    regional_id
FROM veiculos
WHERE regional_id IS NULL;

-- 6. Verificar se as regionais existem
SELECT 
    v.id as veiculo_id,
    v.placa,
    v.regional_id,
    r.nome as regional_nome
FROM veiculos v
LEFT JOIN regionais r ON v.regional_id = r.id
WHERE r.id IS NULL;

-- 7. Listar veículos ativos após correções
SELECT 
    id,
    placa,
    modelo,
    tipo,
    status,
    regional_id
FROM veiculos
WHERE status = 'ativo'
ORDER BY placa;

-- 8. Contar veículos ativos por regional
SELECT 
    r.nome as regional,
    COUNT(v.id) as total_veiculos_ativos
FROM regionais r
LEFT JOIN veiculos v ON r.id = v.regional_id AND v.status = 'ativo'
GROUP BY r.id, r.nome
ORDER BY r.nome;
