-- Função RPC para criar ordem de serviço com transação
-- Execute este script no Supabase SQL Editor

CREATE OR REPLACE FUNCTION criar_ordem_servico
(
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
    INSERT INTO ordens_servico
        (
        veiculo_id,
        problema_reportado,
        supervisor_entrega_id,
        criado_por,
        status,
        data_entrada
        )
    VALUES
        (
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

-- Verificar se a função foi criada
SELECT
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_name = 'criar_ordem_servico';
