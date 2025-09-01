-- Script de configuração da tabela de auditoria
-- Execute este script no Supabase SQL Editor

-- Criar tabela de logs de auditoria
CREATE TABLE IF NOT EXISTS auditoria_logs (
  id BIGSERIAL PRIMARY KEY,
  usuario_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  acao VARCHAR(50) NOT NULL,
  tabela VARCHAR(50) NOT NULL,
  registro_id VARCHAR(100) NOT NULL,
  dados_anteriores JSONB,
  dados_novos JSONB,
  ip_address INET,
  user_agent TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  detalhes TEXT
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_auditoria_logs_usuario_id ON auditoria_logs(usuario_id);
CREATE INDEX IF NOT EXISTS idx_auditoria_logs_acao ON auditoria_logs(acao);
CREATE INDEX IF NOT EXISTS idx_auditoria_logs_tabela ON auditoria_logs(tabela);
CREATE INDEX IF NOT EXISTS idx_auditoria_logs_registro_id ON auditoria_logs(registro_id);
CREATE INDEX IF NOT EXISTS idx_auditoria_logs_timestamp ON auditoria_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_auditoria_logs_usuario_timestamp ON auditoria_logs(usuario_id, timestamp);

-- Criar view para facilitar consultas
CREATE OR REPLACE VIEW auditoria_logs_view AS
SELECT 
  al.*,
  p.email as usuario_email,
  p.full_name as usuario_nome
FROM auditoria_logs al
LEFT JOIN profiles p ON al.usuario_id = p.id;

-- Habilitar RLS (Row Level Security)
ALTER TABLE auditoria_logs ENABLE ROW LEVEL SECURITY;

-- Política para usuários autenticados podem visualizar todos os logs
CREATE POLICY "Usuários autenticados podem visualizar logs de auditoria" ON auditoria_logs
  FOR SELECT USING (auth.role() = 'authenticated');

-- Política para usuários autenticados podem inserir logs
CREATE POLICY "Usuários autenticados podem inserir logs de auditoria" ON auditoria_logs
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Função para limpar logs antigos automaticamente
CREATE OR REPLACE FUNCTION limpar_logs_auditoria_antigos()
RETURNS void AS $$
BEGIN
  DELETE FROM auditoria_logs 
  WHERE timestamp < NOW() - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql;

-- Criar job para limpeza automática (executar diariamente)
-- Nota: No Supabase, você pode configurar isso via Edge Functions ou cron jobs

-- Função para obter estatísticas de auditoria
CREATE OR REPLACE FUNCTION obter_estatisticas_auditoria(
  p_data_inicio TIMESTAMPTZ DEFAULT NULL,
  p_data_fim TIMESTAMPTZ DEFAULT NULL,
  p_usuario_id UUID DEFAULT NULL
)
RETURNS TABLE (
  total_acoes BIGINT,
  acoes_por_tipo JSONB,
  acoes_por_tabela JSONB,
  acoes_por_usuario JSONB
) AS $$
BEGIN
  RETURN QUERY
  WITH logs_filtrados AS (
    SELECT *
    FROM auditoria_logs
    WHERE (p_data_inicio IS NULL OR timestamp >= p_data_inicio)
      AND (p_data_fim IS NULL OR timestamp <= p_data_fim)
      AND (p_usuario_id IS NULL OR usuario_id = p_usuario_id)
  ),
  contadores AS (
    SELECT 
      COUNT(*) as total,
      jsonb_object_agg(acao, contador) as por_tipo,
      jsonb_object_agg(tabela, contador) as por_tabela,
      jsonb_object_agg(usuario_id::text, contador) as por_usuario
    FROM (
      SELECT 
        acao,
        tabela,
        usuario_id,
        COUNT(*) as contador
      FROM logs_filtrados
      GROUP BY acao, tabela, usuario_id
    ) t
  )
  SELECT 
    c.total,
    COALESCE(c.por_tipo, '{}'::jsonb),
    COALESCE(c.por_tabela, '{}'::jsonb),
    COALESCE(c.por_usuario, '{}'::jsonb)
  FROM contadores c;
END;
$$ LANGUAGE plpgsql;

-- Função para buscar logs com paginação
CREATE OR REPLACE FUNCTION buscar_logs_auditoria_paginado(
  p_limit INTEGER DEFAULT 50,
  p_offset INTEGER DEFAULT 0,
  p_usuario_id UUID DEFAULT NULL,
  p_acao VARCHAR(50) DEFAULT NULL,
  p_tabela VARCHAR(50) DEFAULT NULL,
  p_data_inicio TIMESTAMPTZ DEFAULT NULL,
  p_data_fim TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE (
  logs JSONB,
  total_registros BIGINT
) AS $$
BEGIN
  RETURN QUERY
  WITH logs_filtrados AS (
    SELECT *
    FROM auditoria_logs
    WHERE (p_usuario_id IS NULL OR usuario_id = p_usuario_id)
      AND (p_acao IS NULL OR acao = p_acao)
      AND (p_tabela IS NULL OR tabela = p_tabela)
      AND (p_data_inicio IS NULL OR timestamp >= p_data_inicio)
      AND (p_data_fim IS NULL OR timestamp <= p_data_fim)
  ),
  total AS (
    SELECT COUNT(*) as total
    FROM logs_filtrados
  ),
  paginados AS (
    SELECT to_jsonb(l.*) as log
    FROM logs_filtrados l
    ORDER BY timestamp DESC
    LIMIT p_limit
    OFFSET p_offset
  )
  SELECT 
    jsonb_agg(p.log) as logs,
    t.total as total_registros
  FROM paginados p, total t
  GROUP BY t.total;
END;
$$ LANGUAGE plpgsql;

-- Trigger para limpar logs antigos automaticamente (opcional)
-- CREATE OR REPLACE FUNCTION trigger_limpar_logs_antigos()
-- RETURNS TRIGGER AS $$
-- BEGIN
--   -- Verificar se há mais de 1000 logs
--   IF (SELECT COUNT(*) FROM auditoria_logs) > 1000 THEN
--     PERFORM limpar_logs_auditoria_antigos();
--   END IF;
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE TRIGGER limpar_logs_antigos_trigger
--   AFTER INSERT ON auditoria_logs
--   FOR EACH ROW
--   EXECUTE FUNCTION trigger_limpar_logs_antigos();

-- Inserir dados de exemplo (opcional)
-- INSERT INTO auditoria_logs (usuario_id, acao, tabela, registro_id, detalhes)
-- VALUES 
--   ('00000000-0000-0000-0000-000000000000', 'SYSTEM', 'sistema', 'setup', 'Configuração inicial do sistema de auditoria');

-- Comentários na tabela
COMMENT ON TABLE auditoria_logs IS 'Tabela para armazenar logs de auditoria de todas as ações do sistema';
COMMENT ON COLUMN auditoria_logs.usuario_id IS 'ID do usuário que executou a ação';
COMMENT ON COLUMN auditoria_logs.acao IS 'Tipo de ação executada (CREATE, UPDATE, DELETE, etc.)';
COMMENT ON COLUMN auditoria_logs.tabela IS 'Tabela afetada pela ação';
COMMENT ON COLUMN auditoria_logs.registro_id IS 'ID do registro afetado';
COMMENT ON COLUMN auditoria_logs.dados_anteriores IS 'Dados antes da alteração (JSON)';
COMMENT ON COLUMN auditoria_logs.dados_novos IS 'Dados após a alteração (JSON)';
COMMENT ON COLUMN auditoria_logs.ip_address IS 'Endereço IP do usuário';
COMMENT ON COLUMN auditoria_logs.user_agent IS 'User Agent do navegador';
COMMENT ON COLUMN auditoria_logs.timestamp IS 'Data e hora da ação';
COMMENT ON COLUMN auditoria_logs.detalhes IS 'Descrição adicional da ação';

-- Verificar se tudo foi criado corretamente
SELECT 
  'auditoria_logs' as tabela,
  COUNT(*) as registros
FROM auditoria_logs
UNION ALL
SELECT 
  'auditoria_logs_view' as tabela,
  COUNT(*) as registros
FROM auditoria_logs_view;
