-- Script simples para criar a função RPC
-- Execute este script no Supabase SQL Editor

-- 1. Remover função existente
DROP FUNCTION IF EXISTS criar_ordem_servico
(UUID, TEXT, UUID, UUID);

-- 2. Criar função RPC corrigida
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
  v_ultimo_numero INTEGER;
BEGIN
  -- Gerar número da OS de forma mais simples
  SELECT COALESCE(MAX(CAST(SUBSTRING(numero_os FROM 16) AS INTEGER)), 0)
  INTO v_ultimo_numero
  FROM ordens_servico
  WHERE numero_os LIKE 'OS-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-%';

  v_numero_os := 'OS-' || TO_CHAR
  (NOW
  (), 'YYYYMMDD') || '-' || LPAD
  ((v_ultimo_numero + 1)::TEXT, 4, '0');

-- Inserir OS
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

-- Atualizar veículo
UPDATE veiculos SET status = 'manutencao' WHERE id = p_veiculo_id;

-- Retornar resultado
RETURN json_build_object(
    'id', v_os_id,
    'numero_os', v_numero_os,
    'success', true
  );
END;
$$;

-- 3. Verificar se foi criada
SELECT routine_name
FROM information_schema.routines
WHERE routine_name = 'criar_ordem_servico';
