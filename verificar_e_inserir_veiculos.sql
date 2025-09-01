-- Script completo para verificar e inserir veículos
-- Execute este script no Supabase SQL Editor

-- 1. Verificar se há veículos
SELECT 'Verificando veículos existentes...' as info;
SELECT COUNT(*) as total_veiculos FROM veiculos;

-- 2. Verificar se há regionais
SELECT 'Verificando regionais...' as info;
SELECT COUNT(*) as total_regionais FROM regionais;

-- 3. Verificar se há usuários
SELECT 'Verificando usuários...' as info;
SELECT COUNT(*) as total_usuarios FROM usuarios;

-- 4. Se não há regionais, criar algumas
INSERT INTO regionais (id, nome, estado) 
VALUES 
    ('550e8400-e29b-41d4-a716-446655440001', 'Regional São Paulo', 'SP'),
    ('550e8400-e29b-41d4-a716-446655440002', 'Regional Rio de Janeiro', 'RJ'),
    ('550e8400-e29b-41d4-a716-446655440003', 'Regional Minas Gerais', 'MG')
ON CONFLICT (id) DO NOTHING;

-- 5. Se não há usuários, criar um usuário padrão
INSERT INTO usuarios (id, nome, email, regional_id, cargo_id, auth_user_id) 
VALUES 
    ('550e8400-e29b-41d4-a716-446655440001', 'Usuário Padrão', 'admin@teste.com', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001')
ON CONFLICT (id) DO NOTHING;

-- 6. Se não há veículos, inserir veículos de teste
INSERT INTO veiculos (id, placa, modelo, tipo, ano, quilometragem, status, regional_id, criado_por) 
VALUES 
    ('550e8400-e29b-41d4-a716-446655440101', 'ABC-1234', 'Fiat Strada', 'Utilitário', 2020, 45000, 'ativo', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440102', 'DEF-5678', 'Ford Ranger', 'Caminhão', 2019, 32000, 'ativo', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440103', 'GHI-9012', 'Chevrolet Onix', 'Sedan', 2021, 15000, 'ativo', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440104', 'JKL-3456', 'Volkswagen Amarok', 'Utilitário', 2018, 78000, 'ativo', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440105', 'MNO-7890', 'Toyota Corolla', 'Sedan', 2022, 8000, 'ativo', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001')
ON CONFLICT (id) DO NOTHING;

-- 7. Verificar resultado final
SELECT 'Resultado final:' as info;
SELECT COUNT(*) as total_veiculos FROM veiculos;
SELECT COUNT(*) as total_regionais FROM regionais;
SELECT COUNT(*) as total_usuarios FROM usuarios;

-- 8. Listar veículos ativos
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
