-- Script para verificar dados de veículos para estatísticas
-- Execute no SQL Editor do Supabase

-- 1. Verificar todos os veículos cadastrados
SELECT
    v.id,
    v.placa,
    v.modelo,
    v.tipo,
    v.status,
    v.regional_id,
    r.nome as regional_nome,
    r.sigla as regional_sigla,
    e.nome as estado_nome,
    v.created_at,
    v.updated_at
FROM veiculos v
    LEFT JOIN regionais r ON v.regional_id = r.id
    LEFT JOIN estados e ON r.estado_id = e.id
ORDER BY v.placa;

-- 2. Verificar usuário específico (substitua pelo ID do usuário logado)
-- SELECT 
--   u.id,
--   u.nome,
--   u.email,
--   u.matricula,
--   u.regional_id,
--   u.cargo_id,
--   r.nome as regional_nome,
--   r.sigla as regional_sigla,
--   c.nome as cargo_nome,
--   c.sigla as cargo_sigla,
--   e.nome as estado_nome
-- FROM usuarios u
-- LEFT JOIN regionais r ON u.regional_id = r.id
-- LEFT JOIN cargos c ON u.cargo_id = c.id
-- LEFT JOIN estados e ON r.estado_id = e.id
-- WHERE u.auth_user_id = '8d013f29-7cb8-4f6b-8978-e9c8770c1abb'; -- Substitua pelo ID real

-- 3. Verificar veículos da regional específica (substitua pelo regional_id do usuário)
-- SELECT 
--   v.id,
--   v.placa,
--   v.modelo,
--   v.tipo,
--   v.status,
--   v.regional_id,
--   r.nome as regional_nome,
--   r.sigla as regional_sigla
-- FROM veiculos v
-- LEFT JOIN regionais r ON v.regional_id = r.id
-- WHERE v.regional_id = 'd71f41d1-4e1f-4843-b4d6-404ea2808e3e' -- Substitua pelo regional_id real
-- ORDER BY v.placa;

-- 4. Verificar estrutura da tabela veiculos
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'veiculos'
ORDER BY ordinal_position;

-- 5. Verificar políticas RLS da tabela veiculos
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

-- 6. Contar veículos por regional
SELECT
    r.nome as regional_nome,
    r.sigla as regional_sigla,
    COUNT(v.id) as total_veiculos,
    COUNT(CASE WHEN v.status = 'ativo' THEN 1 END) as veiculos_ativos,
    COUNT(CASE WHEN v.status = 'manutencao' THEN 1 END) as veiculos_manutencao
FROM regionais r
    LEFT JOIN veiculos v ON r.id = v.regional_id
GROUP BY r.id, r.nome, r.sigla
ORDER BY r.nome;
