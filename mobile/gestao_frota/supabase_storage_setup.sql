-- =====================================================
-- CONFIGURAÇÃO DO SUPABASE STORAGE - FOTOS DE VEÍCULOS
-- =====================================================

-- Criar bucket para fotos de veículos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'vehicle-photos',
  'vehicle-photos',
  true,
  10485760, -- 10MB
  ARRAY['image/jpeg', 'image/png', 'image/jpg']
) ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- POLÍTICAS DE ACESSO AO STORAGE
-- =====================================================

-- Política para permitir upload de fotos por usuários autenticados
CREATE POLICY "Users can upload vehicle photos" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'vehicle-photos' 
  AND auth.role() = 'authenticated'
);

-- Política para permitir visualização de fotos por usuários autenticados
CREATE POLICY "Users can view vehicle photos" ON storage.objects
FOR SELECT USING (
  bucket_id = 'vehicle-photos' 
  AND auth.role() = 'authenticated'
);

-- Política para permitir atualização de fotos pelo usuário que fez upload
CREATE POLICY "Users can update their own photos" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'vehicle-photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Política para permitir exclusão de fotos pelo usuário que fez upload
CREATE POLICY "Users can delete their own photos" ON storage.objects
FOR DELETE USING (
  bucket_id = 'vehicle-photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- =====================================================
-- FUNÇÕES ÚTEIS PARA GESTÃO DE FOTOS
-- =====================================================

-- Função para obter URL pública de uma foto
CREATE OR REPLACE FUNCTION get_photo_url(photo_path TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN storage.url('vehicle-photos', photo_path);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para limpar fotos antigas (opcional)
CREATE OR REPLACE FUNCTION cleanup_old_photos(days_old INTEGER DEFAULT 365)
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM storage.objects 
  WHERE bucket_id = 'vehicle-photos' 
    AND created_at < NOW() - INTERVAL '1 day' * days_old;
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- VIEWS ÚTEIS PARA CONSULTA DE FOTOS
-- =====================================================

-- View para fotos de entrega (dropoff)
CREATE OR REPLACE VIEW dropoff_photos AS
SELECT 
  so.id as order_id,
  so.dropoff_photo_url,
  v.license_plate,
  c.full_name as creator_name,
  so.dropoff_timestamp,
  get_photo_url(so.dropoff_photo_url) as photo_url
FROM service_orders so
JOIN vehicles v ON so.vehicle_id = v.id
JOIN profiles c ON so.creator_user_id = c.id
WHERE so.dropoff_photo_url IS NOT NULL 
  AND so.dropoff_photo_url != '';

-- View para fotos de recebimento na oficina
CREATE OR REPLACE VIEW workshop_photos AS
SELECT 
  so.id as order_id,
  so.workshop_received_photo_url,
  v.license_plate,
  wr.full_name as receiver_name,
  so.workshop_received_timestamp,
  get_photo_url(so.workshop_received_photo_url) as photo_url
FROM service_orders so
JOIN vehicles v ON so.vehicle_id = v.id
LEFT JOIN profiles wr ON so.workshop_receiver_user_id = wr.id
WHERE so.workshop_received_photo_url IS NOT NULL 
  AND so.workshop_received_photo_url != '';

-- =====================================================
-- TRIGGERS PARA LIMPEZA AUTOMÁTICA (OPCIONAL)
-- =====================================================

-- Trigger para limpar fotos quando uma ordem é deletada
CREATE OR REPLACE FUNCTION cleanup_order_photos()
RETURNS TRIGGER AS $$
BEGIN
  -- Limpar foto de entrega
  IF OLD.dropoff_photo_url IS NOT NULL AND OLD.dropoff_photo_url != '' THEN
    DELETE FROM storage.objects 
    WHERE bucket_id = 'vehicle-photos' 
      AND name LIKE '%dropoff_' || OLD.id::text || '%';
  END IF;
  
  -- Limpar foto de recebimento
  IF OLD.workshop_received_photo_url IS NOT NULL AND OLD.workshop_received_photo_url != '' THEN
    DELETE FROM storage.objects 
    WHERE bucket_id = 'vehicle-photos' 
      AND name LIKE '%workshop_' || OLD.id::text || '%';
  END IF;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger
CREATE TRIGGER cleanup_photos_on_order_delete
  AFTER DELETE ON service_orders
  FOR EACH ROW
  EXECUTE FUNCTION cleanup_order_photos();

-- =====================================================
-- ÍNDICES PARA MELHOR PERFORMANCE
-- =====================================================

-- Índice para consultas por data de criação
CREATE INDEX IF NOT EXISTS idx_service_orders_created_at 
ON service_orders(created_at);

-- Índice para consultas por status
CREATE INDEX IF NOT EXISTS idx_service_orders_status 
ON service_orders(status);

-- Índice para consultas por veículo
CREATE INDEX IF NOT EXISTS idx_service_orders_vehicle_id 
ON service_orders(vehicle_id);

-- =====================================================
-- CONFIGURAÇÕES DE SEGURANÇA
-- =====================================================

-- Habilitar RLS (Row Level Security) no storage
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Configurar CORS para o bucket (se necessário)
-- Isso pode ser feito via API do Supabase ou interface web

-- =====================================================
-- COMENTÁRIOS E DOCUMENTAÇÃO
-- =====================================================

COMMENT ON TABLE storage.objects IS 'Armazena fotos de veículos para evidências de manutenção';
COMMENT ON FUNCTION get_photo_url(TEXT) IS 'Retorna URL pública para uma foto no storage';
COMMENT ON FUNCTION cleanup_old_photos(INTEGER) IS 'Remove fotos antigas do storage';
COMMENT ON VIEW dropoff_photos IS 'View para consulta de fotos de entrega de veículos';
COMMENT ON VIEW workshop_photos IS 'View para consulta de fotos de recebimento na oficina'; 