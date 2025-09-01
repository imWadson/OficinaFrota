-- Atualizar função RPC para criar ordem de serviço com campo criado_por
-- Drop da função existente se ela existir
DROP FUNCTION IF EXISTS criar_ordem_servico;

-- Criar nova função com suporte ao campo criado_por
CREATE OR REPLACE FUNCTION criar_ordem_servico(
  p_veiculo_id UUID,
  p_problema_reportado TEXT,
  p_supervisor_entrega_id UUID DEFAULT NULL,
  p_criado_por UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_os_id UUID;
  v_result JSON;
BEGIN
  -- Inserir a ordem de serviço
  INSERT INTO ordens_servico (
    veiculo_id,
    problema_reportado,
    supervisor_entrega_id,
    criado_por,
    status,
    data_entrada
  ) VALUES (
    p_veiculo_id,
    p_problema_reportado,
    p_supervisor_entrega_id,
    p_criado_por,
    'em_andamento',
    NOW()
  ) RETURNING id INTO v_os_id;

  -- Atualizar status do veículo para manutenção
  UPDATE veiculos 
  SET status = 'manutencao' 
  WHERE id = p_veiculo_id;

  -- Retornar a OS criada
  SELECT json_build_object(
    'id', os.id,
    'veiculo_id', os.veiculo_id,
    'problema_reportado', os.problema_reportado,
    'status', os.status,
    'data_entrada', os.data_entrada,
    'supervisor_entrega_id', os.supervisor_entrega_id,
    'criado_por', os.criado_por
  ) INTO v_result
  FROM ordens_servico os
  WHERE os.id = v_os_id;

  RETURN v_result;
END;
$$;

-- Comentário da função
COMMENT ON FUNCTION criar_ordem_servico IS 'Cria uma nova ordem de serviço e atualiza o status do veículo para manutenção';
