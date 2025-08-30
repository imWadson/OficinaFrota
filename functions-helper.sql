-- Função opcional para criar OS com transação
-- Execute no Supabase SQL Editor se quiser usar transações
-- (O fallback manual já funciona)

CREATE OR REPLACE FUNCTION criar_ordem_servico(
  p_veiculo_id bigint,
  p_problema_reportado text,
  p_supervisor_entrega_id bigint
) RETURNS json AS $$
DECLARE
  nova_os public.ordens_servico;
BEGIN
  -- Verificar se veículo existe e está ativo
  IF NOT EXISTS (
    SELECT 1 FROM public.veiculos 
    WHERE id = p_veiculo_id AND status = 'ativo'
  ) THEN
    RAISE EXCEPTION 'Veículo não encontrado ou não está ativo';
  END IF;

  -- Criar ordem de serviço
  INSERT INTO public.ordens_servico (
    veiculo_id, 
    problema_reportado, 
    supervisor_entrega_id
  ) VALUES (
    p_veiculo_id, 
    p_problema_reportado, 
    p_supervisor_entrega_id
  ) RETURNING * INTO nova_os;

  -- Atualizar status do veículo para manutenção
  UPDATE public.veiculos 
  SET status = 'manutencao' 
  WHERE id = p_veiculo_id;

  -- Retornar OS criada
  RETURN row_to_json(nova_os);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
