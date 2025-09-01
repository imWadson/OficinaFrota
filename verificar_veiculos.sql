-- Script para verificar veículos cadastrados
-- Execute este script no Supabase SQL Editor para verificar os dados

-- Verificar todos os veículos
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

-- Verificar veículos ativos
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

-- Verificar regionais
SELECT 
    id,
    nome,
    estado
FROM regionais
ORDER BY nome;

-- Verificar usuários e suas regionais
SELECT 
    u.id,
    u.nome,
    u.email,
    u.regional_id,
    r.nome as regional_nome
FROM usuarios u
LEFT JOIN regionais r ON u.regional_id = r.id
ORDER BY u.nome;

-- Contar veículos por status
SELECT 
    status,
    COUNT(*) as total
FROM veiculos
GROUP BY status;

-- Contar veículos por regional
SELECT 
    r.nome as regional,
    COUNT(v.id) as total_veiculos,
    COUNT(CASE WHEN v.status = 'ativo' THEN 1 END) as veiculos_ativos
FROM regionais r
LEFT JOIN veiculos v ON r.id = v.regional_id
GROUP BY r.id, r.nome
ORDER BY r.nome;
