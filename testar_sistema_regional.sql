-- =====================================================
-- TESTE DO SISTEMA DE REGRAS REGIONAIS
-- =====================================================

-- 1. Verificar dados atuais
SELECT '=== DADOS ATUAIS ===' as info;

-- Verificar usuários
SELECT 'USUÁRIOS:' as tabela;
SELECT
    u.id,
    u.nome,
    u.email,
    u.matricula,
    c.sigla as cargo,
    r.nome as regional,
    u.ativo
FROM usuarios u
    LEFT JOIN cargos c ON u.cargo_id = c.id
    LEFT JOIN regionais r ON u.regional_id = r.id
ORDER BY u.nome;

-- Verificar veículos
SELECT 'VEÍCULOS:' as tabela;
SELECT
    v.id,
    v.placa,
    v.modelo,
    v.tipo,
    v.status,
    r.nome as regional,
    u.nome as criado_por
FROM veiculos v
    LEFT JOIN regionais r ON v.regional_id = r.id
    LEFT JOIN usuarios u ON v.criado_por = u.id
ORDER BY v.placa;

-- 2. Inserir dados de teste se necessário
SELECT '=== INSERINDO DADOS DE TESTE ===' as info;

-- Inserir regionais se não existirem
INSERT INTO regionais
    (nome, sigla, ativo)
VALUES
    ('Metropolitana', 'MET', true),
    ('Norte', 'NORTE', true),
    ('Sul', 'SUL', true),
    ('Centro Sul', 'CENTRO_SUL', true),
    ('Noroeste', 'NOROESTE', true)
ON CONFLICT
(sigla) DO NOTHING;

-- Inserir veículos de teste para diferentes regionais
INSERT INTO veiculos
    (placa, modelo, tipo, ano, quilometragem, status, regional_id, criado_por)
VALUES
    -- Metropolitana
    ('ABC-1234', 'Fiat Strada', 'caminhao', 2020, 45000, 'ativo',
        (SELECT id
        FROM regionais
        WHERE sigla = 'MET'),
        (SELECT id
        FROM usuarios LIMIT
1)),
('DEF-5678', 'Ford Transit', 'van', 2019, 78000, 'ativo',
(SELECT id
FROM regionais
WHERE sigla = 'MET')
,
(SELECT id
FROM usuarios LIMIT
1)),

-- Norte
('GHI-9012', 'Honda Civic', 'carro', 2021, 25000, 'ativo',
(SELECT id
FROM regionais
WHERE sigla = 'NORTE')
,
(SELECT id
FROM usuarios LIMIT
1)),
('JKL-3456', 'Toyota Hilux', 'caminhonete', 2020, 35000, 'manutencao',
(SELECT id
FROM regionais
WHERE sigla = 'NORTE')
,
(SELECT id
FROM usuarios LIMIT
1)),

-- Sul
('MNO-7890', 'Volkswagen Golf', 'carro', 2022, 15000, 'ativo',
(SELECT id
FROM regionais
WHERE sigla = 'SUL')
,
(SELECT id
FROM usuarios LIMIT
1)),
('PQR-1234', 'Mercedes Sprinter', 'van', 2021, 40000, 'ativo',
(SELECT id
FROM regionais
WHERE sigla = 'SUL')
,
(SELECT id
FROM usuarios LIMIT
1))
ON CONFLICT
(placa) DO NOTHING;

-- 3. Verificar dados após inserção
SELECT '=== DADOS APÓS INSERÇÃO ===' as info;

-- Verificar veículos por regional
SELECT 'VEÍCULOS POR REGIONAL:' as tabela;
SELECT
    r.nome as regional,
    COUNT(v.id) as total_veiculos,
    STRING_AGG(v.placa, ', ') as placas
FROM regionais r
    LEFT JOIN veiculos v ON r.id = v.regional_id
GROUP BY r.id, r.nome
ORDER BY r.nome;

-- 4. Testar RLS (Row Level Security)
SELECT '=== TESTE DE RLS ===' as info;

-- Verificar políticas RLS ativas
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename IN ('veiculos', 'usuarios', 'regionais')
ORDER BY tablename, policyname;

-- 5. Verificar estrutura das tabelas
SELECT '=== ESTRUTURA DAS TABELAS ===' as info;

-- Estrutura da tabela veiculos
SELECT 'ESTRUTURA VEICULOS:' as tabela;
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'veiculos'
ORDER BY ordinal_position;

-- Estrutura da tabela usuarios
SELECT 'ESTRUTURA USUARIOS:' as tabela;
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'usuarios'
ORDER BY ordinal_position;

-- 6. Verificar relacionamentos
SELECT '=== RELACIONAMENTOS ===' as info;

-- Verificar foreign keys
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name IN ('veiculos', 'usuarios')
ORDER BY tc.table_name, kcu.column_name;
