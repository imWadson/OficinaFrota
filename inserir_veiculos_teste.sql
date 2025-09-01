-- Script para inserir veículos de teste
-- Execute este script no Supabase SQL Editor se não houver veículos cadastrados

-- Primeiro, vamos verificar se existem regionais
INSERT INTO regionais
    (id, nome, estado)
VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Regional São Paulo', 'SP'),
    ('550e8400-e29b-41d4-a716-446655440002', 'Regional Rio de Janeiro', 'RJ'),
    ('550e8400-e29b-41d4-a716-446655440003', 'Regional Minas Gerais', 'MG')
ON CONFLICT
(id) DO NOTHING;

-- Inserir veículos de teste
INSERT INTO veiculos
    (id, placa, modelo, tipo, ano, quilometragem, status, regional_id, criado_por)
VALUES
    ('550e8400-e29b-41d4-a716-446655440101', 'ABC-1234', 'Fiat Strada', 'Utilitário', 2020, 45000, 'ativo', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440102', 'DEF-5678', 'Ford Ranger', 'Caminhão', 2019, 32000, 'ativo', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440103', 'GHI-9012', 'Chevrolet Onix', 'Sedan', 2021, 15000, 'ativo', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440104', 'JKL-3456', 'Volkswagen Amarok', 'Utilitário', 2018, 78000, 'ativo', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440105', 'MNO-7890', 'Toyota Corolla', 'Sedan', 2022, 8000, 'ativo', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440106', 'PQR-1234', 'Honda Civic', 'Sedan', 2020, 25000, 'ativo', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440107', 'STU-5678', 'Hyundai HB20', 'Hatch', 2021, 18000, 'ativo', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440108', 'VWX-9012', 'Renault Kwid', 'Hatch', 2019, 35000, 'ativo', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001')
ON CONFLICT
(id) DO NOTHING;

-- Verificar se os veículos foram inseridos
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
