-- =====================================================
-- CONFIGURAÇÃO DA TABELA DE CORREÇÃO DE DEFEITOS
-- =====================================================

-- Criar tabela de correção de defeitos
CREATE TABLE IF NOT EXISTS defect_corrections (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT REFERENCES service_orders(id) ON DELETE CASCADE,
  defect_id BIGINT REFERENCES order_defects(id) ON DELETE CASCADE,
  corrected_by_user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  corrected_at TIMESTAMPTZ DEFAULT NOW(),
  notes TEXT,
  UNIQUE(order_id, defect_id)
);

-- Habilitar RLS na tabela
ALTER TABLE defect_corrections ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "All users can view defect corrections" ON defect_corrections
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert defect corrections" ON defect_corrections
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update defect corrections" ON defect_corrections
  FOR UPDATE USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete defect corrections" ON defect_corrections
  FOR DELETE USING (auth.uid() IS NOT NULL);

-- Comentários
COMMENT ON TABLE defect_corrections IS 'Registro de correções de defeitos por ordem de serviço';
COMMENT ON COLUMN defect_corrections.order_id IS 'ID da ordem de serviço';
COMMENT ON COLUMN defect_corrections.defect_id IS 'ID do defeito corrigido';
COMMENT ON COLUMN defect_corrections.corrected_by_user_id IS 'ID do usuário que corrigiu o defeito';
COMMENT ON COLUMN defect_corrections.corrected_at IS 'Data/hora da correção';
COMMENT ON COLUMN defect_corrections.notes IS 'Observações sobre a correção';

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_defect_corrections_order_id ON defect_corrections(order_id);
CREATE INDEX IF NOT EXISTS idx_defect_corrections_defect_id ON defect_corrections(defect_id);
CREATE INDEX IF NOT EXISTS idx_defect_corrections_corrected_by ON defect_corrections(corrected_by_user_id);
CREATE INDEX IF NOT EXISTS idx_defect_corrections_corrected_at ON defect_corrections(corrected_at);

-- Função para verificar se todos os defeitos de uma ordem foram corrigidos
CREATE OR REPLACE FUNCTION check_all_defects_corrected(order_id_param BIGINT)
RETURNS BOOLEAN AS $$
DECLARE
  total_defects INTEGER;
  corrected_defects INTEGER;
BEGIN
  -- Contar total de defeitos
  SELECT COUNT(*) INTO total_defects
  FROM order_defects
  WHERE order_id = order_id_param;
  
  -- Se não há defeitos, considerar como todos corrigidos
  IF total_defects = 0 THEN
    RETURN TRUE;
  END IF;
  
  -- Contar defeitos corrigidos
  SELECT COUNT(*) INTO corrected_defects
  FROM defect_corrections
  WHERE order_id = order_id_param;
  
  -- Retornar true se todos foram corrigidos
  RETURN corrected_defects = total_defects;
END;
$$ LANGUAGE plpgsql;

-- Função para obter progresso de correção de defeitos
CREATE OR REPLACE FUNCTION get_defect_correction_progress(order_id_param BIGINT)
RETURNS TABLE(
  total_defects INTEGER,
  corrected_defects INTEGER,
  progress_percentage NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE(total.total_count, 0)::INTEGER as total_defects,
    COALESCE(corrected.corrected_count, 0)::INTEGER as corrected_defects,
    CASE 
      WHEN total.total_count = 0 THEN 100.0
      ELSE ROUND((corrected.corrected_count::NUMERIC / total.total_count::NUMERIC) * 100, 2)
    END as progress_percentage
  FROM 
    (SELECT COUNT(*) as total_count FROM order_defects WHERE order_id = order_id_param) total,
    (SELECT COUNT(*) as corrected_count FROM defect_corrections WHERE order_id = order_id_param) corrected;
END;
$$ LANGUAGE plpgsql;

-- View para facilitar consultas de correção de defeitos
CREATE OR REPLACE VIEW defect_corrections_view AS
SELECT 
  dc.id,
  dc.order_id,
  dc.defect_id,
  od.description as defect_description,
  dc.corrected_by_user_id,
  p.full_name as corrected_by_name,
  p.role as corrected_by_role,
  dc.corrected_at,
  dc.notes,
  so.status as order_status
FROM defect_corrections dc
JOIN order_defects od ON dc.defect_id = od.id
JOIN profiles p ON dc.corrected_by_user_id = p.id
JOIN service_orders so ON dc.order_id = so.id
ORDER BY dc.corrected_at DESC;

-- Trigger para atualizar logs quando um defeito é marcado como corrigido
CREATE OR REPLACE FUNCTION log_defect_correction()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO order_logs (
    order_id,
    user_id,
    previous_status,
    new_status,
    log_message
  ) VALUES (
    NEW.order_id,
    NEW.corrected_by_user_id,
    'defect_pending',
    'defect_corrected',
    'Defeito "' || (SELECT description FROM order_defects WHERE id = NEW.defect_id) || '" marcado como corrigido'
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_defect_correction
  AFTER INSERT ON defect_corrections
  FOR EACH ROW
  EXECUTE FUNCTION log_defect_correction();

-- Trigger para atualizar logs quando um defeito é desmarcado como corrigido
CREATE OR REPLACE FUNCTION log_defect_uncorrection()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO order_logs (
    order_id,
    user_id,
    previous_status,
    new_status,
    log_message
  ) VALUES (
    OLD.order_id,
    OLD.corrected_by_user_id,
    'defect_corrected',
    'defect_pending',
    'Defeito "' || (SELECT description FROM order_defects WHERE id = OLD.defect_id) || '" desmarcado como corrigido'
  );
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_defect_uncorrection
  AFTER DELETE ON defect_corrections
  FOR EACH ROW
  EXECUTE FUNCTION log_defect_uncorrection();

-- Verificar se a tabela foi criada corretamente
SELECT 
  'Tabela defect_corrections criada com sucesso!' as status,
  COUNT(*) as total_records
FROM defect_corrections; 