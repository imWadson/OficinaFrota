-- =====================================================
-- CONFIGURAÇÃO DO BANCO DE DADOS - GESTÃO DE FROTA
-- =====================================================

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABELAS PRINCIPAIS
-- =====================================================

-- Tabela de perfis de usuário
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('operacao', 'oficina')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de veículos
CREATE TABLE vehicles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  license_plate TEXT UNIQUE NOT NULL,
  type TEXT NOT NULL,
  model TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de ordens de serviço
CREATE TABLE service_orders (
  id BIGSERIAL PRIMARY KEY,
  vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'aguardando_aceite' CHECK (
    status IN (
      'aguardando_aceite',
      'recebido',
      'rejeitado',
      'analisando',
      'conserto_iniciado',
      'finalizado_conserto',
      'pronto_retirada',
      'concluido'
    )
  ),
  creator_user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  dropoff_timestamp TIMESTAMPTZ NOT NULL,
  dropoff_photo_url TEXT NOT NULL,
  workshop_receiver_user_id UUID REFERENCES profiles(id),
  workshop_received_timestamp TIMESTAMPTZ,
  workshop_received_photo_url TEXT,
  pickup_user_id UUID REFERENCES profiles(id),
  pickup_timestamp TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de defeitos da ordem
CREATE TABLE order_defects (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT REFERENCES service_orders(id) ON DELETE CASCADE,
  description TEXT NOT NULL
);

-- Tabela de correção de defeitos (nova)
CREATE TABLE defect_corrections (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT REFERENCES service_orders(id) ON DELETE CASCADE,
  defect_id BIGINT REFERENCES order_defects(id) ON DELETE CASCADE,
  corrected_by_user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  corrected_at TIMESTAMPTZ DEFAULT NOW(),
  notes TEXT,
  UNIQUE(order_id, defect_id)
);

-- Tabela de logs de auditoria
CREATE TABLE order_logs (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT REFERENCES service_orders(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  previous_status TEXT,
  new_status TEXT NOT NULL,
  log_message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para service_orders
CREATE INDEX idx_service_orders_creator_user_id ON service_orders(creator_user_id);
CREATE INDEX idx_service_orders_status ON service_orders(status);
CREATE INDEX idx_service_orders_created_at ON service_orders(created_at DESC);
CREATE INDEX idx_service_orders_vehicle_id ON service_orders(vehicle_id);

-- Índices para order_defects
CREATE INDEX idx_order_defects_order_id ON order_defects(order_id);

-- Índices para order_logs
CREATE INDEX idx_order_logs_order_id ON order_logs(order_id);
CREATE INDEX idx_order_logs_user_id ON order_logs(user_id);
CREATE INDEX idx_order_logs_created_at ON order_logs(created_at DESC);

-- Índices para vehicles
CREATE INDEX idx_vehicles_license_plate ON vehicles(license_plate);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_defects ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_logs ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS DE SEGURANÇA
-- =====================================================

-- Políticas para profiles
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Políticas para vehicles
CREATE POLICY "All users can view vehicles" ON vehicles
  FOR SELECT USING (true);

CREATE POLICY "All users can insert vehicles" ON vehicles
  FOR INSERT WITH CHECK (true);

-- Políticas para service_orders
CREATE POLICY "All users can view service orders" ON service_orders
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert service orders" ON service_orders
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update service orders" ON service_orders
  FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Políticas para order_defects
CREATE POLICY "All users can view order defects" ON order_defects
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert order defects" ON order_defects
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Políticas para order_logs
CREATE POLICY "All users can view order logs" ON order_logs
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert order logs" ON order_logs
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Políticas para defect_corrections
CREATE POLICY "All users can view defect corrections" ON defect_corrections
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert defect corrections" ON defect_corrections
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update defect corrections" ON defect_corrections
  FOR UPDATE USING (auth.uid() IS NOT NULL);

-- =====================================================
-- FUNÇÕES E TRIGGERS
-- =====================================================

-- Função para criar perfil automaticamente quando um usuário se registra
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'role'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar perfil automaticamente
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- =====================================================
-- DADOS INICIAIS (OPCIONAL)
-- =====================================================

-- Inserir alguns tipos de veículos comuns
INSERT INTO vehicles (license_plate, type, model) VALUES
  ('ABC1234', 'Caminhão Munck', 'Mercedes-Benz 710'),
  ('DEF5678', 'Carro de Apoio', 'Fiat Strada'),
  ('GHI9012', 'Caminhão Pipa', 'Volkswagen Delivery'),
  ('JKL3456', 'Van', 'Fiat Ducato'),
  ('MNO7890', 'Moto', 'Honda CG 160')
ON CONFLICT (license_plate) DO NOTHING;

-- =====================================================
-- VIEWS ÚTEIS
-- =====================================================

-- View para ordens de serviço com informações completas
CREATE OR REPLACE VIEW service_orders_complete AS
SELECT 
  so.*,
  v.license_plate,
  v.type as vehicle_type,
  v.model as vehicle_model,
  c.full_name as creator_name,
  wr.full_name as workshop_receiver_name,
  pu.full_name as pickup_user_name,
  array_agg(od.description) as defects
FROM service_orders so
LEFT JOIN vehicles v ON so.vehicle_id = v.id
LEFT JOIN profiles c ON so.creator_user_id = c.id
LEFT JOIN profiles wr ON so.workshop_receiver_user_id = wr.id
LEFT JOIN profiles pu ON so.pickup_user_id = pu.id
LEFT JOIN order_defects od ON so.id = od.order_id
GROUP BY so.id, v.license_plate, v.type, v.model, c.full_name, wr.full_name, pu.full_name;

-- =====================================================
-- FUNÇÕES ÚTEIS
-- =====================================================

-- Função para obter estatísticas das ordens de serviço
CREATE OR REPLACE FUNCTION get_service_order_stats()
RETURNS TABLE (
  total_orders BIGINT,
  pending_orders BIGINT,
  in_progress_orders BIGINT,
  completed_orders BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*) as total_orders,
    COUNT(*) FILTER (WHERE status = 'aguardando_aceite') as pending_orders,
    COUNT(*) FILTER (WHERE status IN ('recebido', 'analisando', 'conserto_iniciado', 'finalizado_conserto')) as in_progress_orders,
    COUNT(*) FILTER (WHERE status = 'concluido') as completed_orders
  FROM service_orders;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTÁRIOS DAS TABELAS
-- =====================================================

COMMENT ON TABLE profiles IS 'Perfis dos usuários do sistema';
COMMENT ON TABLE vehicles IS 'Veículos da frota';
COMMENT ON TABLE service_orders IS 'Ordens de serviço de manutenção';
COMMENT ON TABLE order_defects IS 'Defeitos reportados em cada ordem';
COMMENT ON TABLE order_logs IS 'Log de auditoria das ações nas ordens';

COMMENT ON COLUMN service_orders.status IS 'Status da ordem: aguardando_aceite, recebido, rejeitado, analisando, conserto_iniciado, finalizado_conserto, pronto_retirada, concluido';
COMMENT ON COLUMN profiles.role IS 'Perfil do usuário: operacao ou oficina';

-- =====================================================
-- FIM DA CONFIGURAÇÃO
-- ===================================================== 