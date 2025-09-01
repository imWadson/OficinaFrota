-- =====================================================
-- SCRIPT COMPLETO - SETUP DO SISTEMA
-- =====================================================
-- Execute este script NO SUPABASE SQL EDITOR
-- Este script corrige todos os problemas identificados

-- 1. VERIFICAR ESTRUTURA ATUAL
-- =====================================================

-- Verificar se as tabelas existem
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name IN ('ordens_servico', 'veiculos', 'usuarios')
ORDER BY table_name, ordinal_position;

-- 2. CORRIGIR TABELA ORDENS_SERVICO (se necessário)
-- =====================================================

-- Adicionar campo numero_os se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'ordens_servico'
        AND column_name = 'numero_os'
    ) THEN
    ALTER TABLE ordens_servico ADD COLUMN numero_os VARCHAR
    (50) UNIQUE;
END
IF;
END $$;

-- Adicionar campo criado_por se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'ordens_servico'
        AND column_name = 'criado_por'
    ) THEN
    ALTER TABLE ordens_servico ADD COLUMN criado_por UUID REFERENCES usuarios
    (id);
END
IF;
END $$;

-- 3. CRIAR FUNÇÃO RPC CORRIGIDA
-- =====================================================

-- Remover função existente se houver
DROP FUNCTION IF EXISTS criar_ordem_servico
(UUID, TEXT, UUID, UUID);

-- Criar função RPC completa
CREATE OR REPLACE FUNCTION criar_ordem_servico
(
  p_veiculo_id UUID,
  p_problema_reportado TEXT,
  p_supervisor_entrega_id UUID,
  p_criado_por UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_os_id UUID;
  v_numero_os VARCHAR
(50);
  v_result JSON;
BEGIN
    -- Gerar número da OS único
    SELECT 'OS-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(COALESCE(MAX(SUBSTRING(numero_os FROM 16))::INTEGER, 0) + 1::TEXT, 4, '0')
    INTO v_numero_os
    FROM ordens_servico
    WHERE numero_os LIKE 'OS-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-%';

    -- Se não encontrou nenhuma OS hoje, começar com 0001
    IF v_numero_os IS NULL THEN
    v_numero_os := 'OS-' || TO_CHAR
    (NOW
    (), 'YYYYMMDD') || '-0001';
END
IF;

  -- Inserir a ordem de serviço
  INSERT INTO ordens_servico
    (
    numero_os,
    veiculo_id,
    problema_reportado,
    supervisor_entrega_id,
    criado_por,
    status,
    data_entrada
    )
VALUES
    (
        v_numero_os,
        p_veiculo_id,
        p_problema_reportado,
        p_supervisor_entrega_id,
        p_criado_por,
        'em_andamento',
        NOW()
  )
RETURNING id INTO v_os_id;

-- Atualizar status do veículo para 'manutencao'
UPDATE veiculos 
  SET status = 'manutencao' 
  WHERE id = p_veiculo_id;

-- Retornar resultado
SELECT json_build_object(
    'id', v_os_id,
    'numero_os', v_numero_os,
    'veiculo_id', p_veiculo_id,
    'problema_reportado', p_problema_reportado,
    'status', 'em_andamento',
    'data_entrada', NOW(),
    'criado_por', p_criado_por,
    'success', true
  )
INTO v_result;

RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    -- Em caso de erro, fazer rollback automático
    RAISE EXCEPTION 'Erro ao criar ordem de serviço: %', SQLERRM;
END;
$$;

-- 4. VERIFICAR DADOS NECESSÁRIOS
-- =====================================================

-- Verificar se há veículos
SELECT
    'VEÍCULOS' as tabela,
    COUNT(*) as total,
    COUNT(CASE WHEN status = 'ativo' THEN 1 END) as ativos
FROM veiculos;

-- Verificar se há usuários
SELECT
    'USUÁRIOS' as tabela,
    COUNT(*) as total,
    COUNT(CASE WHEN ativo = true THEN 1 END) as ativos
FROM usuarios;

-- Verificar se há regionais
SELECT
    'REGIONAIS' as tabela,
    COUNT(*) as total
FROM regionais;

-- 5. INSERIR DADOS DE TESTE (se necessário)
-- =====================================================

-- Inserir regional se não existir
INSERT INTO regionais
    (id, nome, sigla, estado_id)
SELECT
    gen_random_uuid(),
    'Metropolitana',
    'MET',
    (SELECT id
    FROM estados
    WHERE sigla = 'PI' LIMIT
1)
WHERE NOT EXISTS
(SELECT 1
FROM regionais
WHERE sigla = 'MET');

-- Inserir usuário de teste se não existir
INSERT INTO usuarios
    (id, nome, email, cargo_id, regional_id, ativo)
SELECT
    gen_random_uuid(),
    'Usuário Teste',
    'teste@empresa.com',
    (SELECT id
    FROM cargos
    WHERE nome = 'Operador' LIMIT
1),
(SELECT id
FROM regionais
WHERE sigla = 'MET'
LIMIT 1),
    true
WHERE NOT EXISTS
(SELECT 1
FROM usuarios
WHERE email = 'teste@empresa.com');

-- Inserir veículos de teste se não existir
INSERT INTO veiculos
    (id, placa, modelo, tipo, ano, status, regional_id, criado_por)
SELECT
    gen_random_uuid(),
    'ABC-1234',
    'Fiat Strada',
    'Utilitário',
    2020,
    'ativo',
    (SELECT id
    FROM regionais
    WHERE sigla = 'MET' LIMIT
1),
(SELECT id
FROM usuarios
WHERE email = 'teste@empresa.com'
LIMIT 1)
WHERE NOT EXISTS
(SELECT 1
FROM veiculos
WHERE placa = 'ABC-1234');

INSERT INTO veiculos
    (id, placa, modelo, tipo, ano, status, regional_id, criado_por)
SELECT
    gen_random_uuid(),
    'XYZ-5678',
    'Ford Ranger',
    'Pickup',
    2021,
    'ativo',
    (SELECT id
    FROM regionais
    WHERE sigla = 'MET' LIMIT
1),
(SELECT id
FROM usuarios
WHERE email = 'teste@empresa.com'
LIMIT 1)
WHERE NOT EXISTS
(SELECT 1
FROM veiculos
WHERE placa = 'XYZ-5678');

-- 6. VERIFICAR FUNÇÃO CRIADA
-- =====================================================

SELECT
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_name = 'criar_ordem_servico';

-- 7. TESTAR FUNÇÃO (opcional)
-- =====================================================

-- Descomente as linhas abaixo para testar a função
/*
SELECT criar_ordem_servico(
    (SELECT id FROM veiculos WHERE placa = 'ABC-1234' LIMIT 1),
    'Problema de teste - freios',
    NULL,
    (SELECT id FROM usuarios WHERE email = 'teste@empresa.com' LIMIT 1)
);
*/

-- 8. VERIFICAR RESULTADO FINAL
-- =====================================================

SELECT
    'ORDENS DE SERVIÇO' as tabela,
    COUNT(*) as total
FROM ordens_servico;

SELECT
    'VEÍCULOS APÓS TESTE' as status,
    status,
    COUNT(*) as quantidade
FROM veiculos
GROUP BY status;

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
