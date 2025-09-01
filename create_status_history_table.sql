-- Tabela para rastrear histórico de status das ordens de serviço
CREATE TABLE
IF NOT EXISTS ordens_servico_status_history
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid
(),
    ordem_servico_id UUID NOT NULL REFERENCES ordens_servico
(id) ON
DELETE CASCADE,
    status_anterior VARCHAR(20),
    status_novo VARCHAR
(20) NOT NULL,
    observacao TEXT,
    criado_por UUID NOT NULL REFERENCES usuarios
(id),
    criado_em TIMESTAMP
WITH TIME ZONE DEFAULT NOW
()
);

-- Índices para performance
CREATE INDEX
IF NOT EXISTS idx_os_status_history_os_id ON ordens_servico_status_history
(ordem_servico_id);
CREATE INDEX
IF NOT EXISTS idx_os_status_history_criado_em ON ordens_servico_status_history
(criado_em);

-- Atualizar a tabela de ordens de serviço para incluir novos status
ALTER TABLE ordens_servico 
DROP CONSTRAINT IF EXISTS ordens_servico_status_check;

ALTER TABLE ordens_servico 
ADD CONSTRAINT ordens_servico_status_check 
CHECK (status IN ('em_andamento', 'concluida', 'cancelada', 'oficina_externa', 'aguardando_peca', 'diagnostico', 'aguardando_aprovacao'));

-- Função para registrar mudança de status automaticamente
CREATE OR REPLACE FUNCTION registrar_mudanca_status_os
()
RETURNS TRIGGER AS $$
BEGIN
    -- Se o status mudou, registrar no histórico
    IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO ordens_servico_status_history
        (
        ordem_servico_id,
        status_anterior,
        status_novo,
        observacao,
        criado_por
        )
    VALUES
        (
            NEW.id,
            OLD.status,
            NEW.status,
            CASE 
                WHEN NEW.status = 'aguardando_peca' THEN 'Aguardando peça no estoque'
                WHEN NEW.status = 'diagnostico' THEN 'Em processo de diagnóstico'
                WHEN NEW.status = 'aguardando_aprovacao' THEN 'Aguardando aprovação do supervisor'
                WHEN NEW.status = 'em_andamento' THEN 'Trabalho iniciado'
                WHEN NEW.status = 'concluida' THEN 'Ordem finalizada'
                WHEN NEW.status = 'cancelada' THEN 'Ordem cancelada'
                WHEN NEW.status = 'oficina_externa' THEN 'Enviado para oficina externa'
                ELSE 'Mudança de status'
            END,
            COALESCE(NEW.criado_por, (SELECT id FROM usuarios WHERE auth_user_id = auth.uid()
    LIMIT 1))
        );
END
IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para registrar mudanças de status automaticamente
DROP TRIGGER IF EXISTS trigger_registrar_mudanca_status_os
ON ordens_servico;
CREATE TRIGGER trigger_registrar_mudanca_status_os
    AFTER
UPDATE ON ordens_servico
    FOR EACH ROW
EXECUTE FUNCTION registrar_mudanca_status_os
();

-- Função para obter estatísticas de tempo por status
CREATE OR REPLACE FUNCTION calcular_tempo_por_status
(p_ordem_servico_id UUID)
RETURNS TABLE
(
    status VARCHAR
(20),
    tempo_total INTERVAL,
    inicio_status TIMESTAMP
WITH TIME ZONE,
    fim_status TIMESTAMP
WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    WITH
        status_periods
        AS
        (
                            SELECT
                    h.status_novo,
                    h.criado_em as inicio_status,
                    LEAD(h.criado_em) OVER (PARTITION BY h.ordem_servico_id ORDER BY h.criado_em) as fim_status
                FROM ordens_servico_status_history h
                WHERE h.ordem_servico_id = p_ordem_servico_id

            UNION ALL

                -- Incluir o status atual se não foi registrado no histórico ainda
                SELECT
                    os.status,
                    COALESCE(
                (SELECT MAX(criado_em) FROM ordens_servico_status_history WHERE ordem_servico_id = os.id),
                os.data_entrada
            ) as inicio_status,
                    CASE 
                WHEN os.status IN ('concluida', 'cancelada') THEN os.data_saida
                ELSE NOW()
            END as fim_status
                FROM ordens_servico os
                WHERE os.id = p_ordem_servico_id
        )
    SELECT
        sp.status_novo as status,
        (sp.fim_status - sp.inicio_status) as tempo_total,
        sp.inicio_status,
        sp.fim_status
    FROM status_periods sp
    WHERE sp.fim_status IS NOT NULL
    ORDER BY sp.inicio_status;
END;
$$ LANGUAGE plpgsql;

-- Função para obter tempo total da OS
CREATE OR REPLACE FUNCTION calcular_tempo_total_os
(p_ordem_servico_id UUID)
RETURNS INTERVAL AS $$
DECLARE
    v_tempo_total INTERVAL;
BEGIN
    SELECT
        COALESCE(
            (SELECT data_saida FROM ordens_servico WHERE id = p_ordem_servico_id),
            NOW()
        ) - data_entrada
    INTO v_tempo_total
    FROM ordens_servico
    WHERE id = p_ordem_servico_id;

    RETURN v_tempo_total;
END;
$$ LANGUAGE plpgsql;

-- Comentários
COMMENT ON TABLE ordens_servico_status_history IS 'Histórico de mudanças de status das ordens de serviço para rastreamento de tempo';
COMMENT ON FUNCTION registrar_mudanca_status_os
() IS 'Função para registrar automaticamente mudanças de status no histórico';
COMMENT ON FUNCTION calcular_tempo_por_status
(UUID) IS 'Calcula o tempo gasto em cada status de uma ordem de serviço';
COMMENT ON FUNCTION calcular_tempo_total_os
(UUID) IS 'Calcula o tempo total de uma ordem de serviço';
