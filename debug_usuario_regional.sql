-- =====================================================
-- DIAGNÓSTICO: USUÁRIO E VEÍCULOS REGIONAL
-- =====================================================

-- 1. Verificar dados do usuário logado
SELECT '=== DADOS DO USUÁRIO ===' as info;

SELECT
    u.id,
    u.nome,
    u.email,
    u.auth_user_id,
    c.sigla as cargo_sigla,
    c.nome as cargo_nome,
    c.nivel as cargo_nivel,
    r.id as regional_id,
    r.nome as regional_nome,
    r.sigla as regional_sigla,
    u.ativo
FROM usuarios u
    LEFT JOIN cargos c ON u.cargo_id = c.id
    LEFT JOIN regionais r ON u.regional_id = r.id
WHERE u.ativo = true
ORDER BY u.nome;

-- 2. Verificar todos os veículos cadastrados
SELECT '=== TODOS OS VEÍCULOS ===' as info;

SELECT
    v.id,
    v.placa,
    v.modelo,
    v.tipo,
    v.status,
    v.regional_id,
    r.nome as regional_nome,
    r.sigla as regional_sigla,
    u.nome as criado_por
FROM veiculos v
    LEFT JOIN regionais r ON v.regional_id = r.id
    LEFT JOIN usuarios u ON v.criado_por = u.id
ORDER BY v.placa;

-- 3. Verificar veículos da regional Metropolitana
SELECT '=== VEÍCULOS DA METROPOLITANA ===' as info;

SELECT
    v.id,
    v.placa,
    v.modelo,
    v.tipo,
    v.status,
    r.nome as regional_nome
FROM veiculos v
    LEFT JOIN regionais r ON v.regional_id = r.id
WHERE r.sigla = 'METRO' OR r.nome
ILIKE '%Metropolitana%'
ORDER BY v.placa;

-- 4. Verificar se existe regional Metropolitana
SELECT '=== REGIONAIS CADASTRADAS ===' as info;

SELECT
    id,
    nome,
    sigla,
    ativo
FROM regionais
ORDER BY nome;

-- 5. Verificar cargos cadastrados
SELECT '=== CARGOS CADASTRADOS ===' as info;

SELECT
    id,
    nome,
    sigla,
    nivel,
    ativo
FROM cargos
ORDER BY nivel;

-- 6. Teste de filtro: veículos que o usuário deveria ver
SELECT '=== TESTE DE FILTRO ===' as info;

-- Substitua 'SEU_AUTH_USER_ID' pelo ID real do usuário logado
-- SELECT 
--     v.id,
--     v.placa,
--     v.modelo,
--     r.nome as regional_nome
-- FROM veiculos v
-- LEFT JOIN regionais r ON v.regional_id = r.id
-- LEFT JOIN usuarios u ON u.regional_id = r.id
-- WHERE u.auth_user_id = 'SEU_AUTH_USER_ID'
-- ORDER BY v.placa;
