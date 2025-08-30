-- SQL para criar todas as tabelas do sistema
-- Execute este script no SQL Editor do Supabase

-- Tabela de veículos
CREATE TABLE IF NOT EXISTS public.veiculos (
  id bigserial PRIMARY KEY,
  placa text NOT NULL UNIQUE,
  modelo text NOT NULL,
  tipo text NOT NULL,
  ano int CHECK (ano >= 1980),
  quilometragem int DEFAULT 0 CHECK (quilometragem >= 0),
  status text NOT NULL DEFAULT 'ativo',
  criado_em timestamptz NOT NULL DEFAULT now()
);

-- Tabela de supervisores
CREATE TABLE IF NOT EXISTS public.supervisores (
  id bigserial PRIMARY KEY,
  nome text NOT NULL,
  cargo text,
  contato text
);

-- Tabela de ordens de serviço
CREATE TABLE IF NOT EXISTS public.ordens_servico (
  id bigserial PRIMARY KEY,
  veiculo_id bigint NOT NULL REFERENCES public.veiculos(id) ON DELETE RESTRICT,
  problema_reportado text NOT NULL,
  diagnostico text,
  status text NOT NULL DEFAULT 'em_andamento',
  data_entrada timestamptz NOT NULL DEFAULT now(),
  data_saida timestamptz,
  supervisor_entrega_id bigint REFERENCES public.supervisores(id),
  supervisor_retirada_id bigint REFERENCES public.supervisores(id)
);

-- Tabela de peças
CREATE TABLE IF NOT EXISTS public.pecas (
  id bigserial PRIMARY KEY,
  nome text NOT NULL,
  codigo text NOT NULL UNIQUE,
  fornecedor text,
  custo_unitario numeric(12,2) NOT NULL CHECK (custo_unitario >= 0),
  quantidade_estoque int NOT NULL DEFAULT 0 CHECK (quantidade_estoque >= 0)
);

-- Tabela de peças usadas
CREATE TABLE IF NOT EXISTS public.pecas_usadas (
  id bigserial PRIMARY KEY,
  ordem_servico_id bigint NOT NULL REFERENCES public.ordens_servico(id) ON DELETE CASCADE,
  peca_id bigint NOT NULL REFERENCES public.pecas(id) ON DELETE RESTRICT,
  quantidade int NOT NULL CHECK (quantidade > 0),
  data_uso timestamptz NOT NULL DEFAULT now(),
  supervisor_id bigint REFERENCES public.supervisores(id)
);

-- Tabela de oficinas externas
CREATE TABLE IF NOT EXISTS public.oficinas_externas (
  id bigserial PRIMARY KEY,
  nome text NOT NULL,
  cnpj text NOT NULL UNIQUE,
  endereco text,
  telefone text,
  contato text
);

-- Tabela de serviços externos
CREATE TABLE IF NOT EXISTS public.servicos_externos (
  id bigserial PRIMARY KEY,
  ordem_servico_id bigint NOT NULL REFERENCES public.ordens_servico(id) ON DELETE CASCADE,
  oficina_externa_id bigint NOT NULL REFERENCES public.oficinas_externas(id) ON DELETE RESTRICT,
  descricao text NOT NULL,
  valor numeric(12,2) NOT NULL CHECK (valor >= 0),
  data_envio timestamptz NOT NULL DEFAULT now(),
  data_retorno timestamptz
);

-- Índices úteis
CREATE INDEX IF NOT EXISTS idx_os_veiculo ON public.ordens_servico(veiculo_id);
CREATE INDEX IF NOT EXISTS idx_os_status ON public.ordens_servico(status);
CREATE INDEX IF NOT EXISTS idx_os_data_entrada ON public.ordens_servico(data_entrada);
CREATE INDEX IF NOT EXISTS idx_pu_os ON public.pecas_usadas(ordem_servico_id);
CREATE INDEX IF NOT EXISTS idx_pu_peca ON public.pecas_usadas(peca_id);
CREATE INDEX IF NOT EXISTS idx_pu_data_uso ON public.pecas_usadas(data_uso);
CREATE INDEX IF NOT EXISTS idx_veiculos_placa ON public.veiculos(placa);
CREATE INDEX IF NOT EXISTS idx_veiculos_status ON public.veiculos(status);
CREATE INDEX IF NOT EXISTS idx_pecas_codigo ON public.pecas(codigo);
CREATE INDEX IF NOT EXISTS idx_oficinas_cnpj ON public.oficinas_externas(cnpj);

-- Políticas RLS básicas
ALTER TABLE public.veiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.supervisores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pecas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pecas_usadas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.oficinas_externas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.servicos_externos ENABLE ROW LEVEL SECURITY;

-- Política para usuários autenticados (leitura)
CREATE POLICY "Usuários autenticados podem ler veículos" ON public.veiculos
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY  "Usuários autenticados podem ler supervisores" ON public.supervisores
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY  "Usuários autenticados podem ler ordens de serviço" ON public.ordens_servico
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuários autenticados podem ler peças" ON public.pecas
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY  "Usuários autenticados podem ler peças usadas" ON public.pecas_usadas
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY  "Usuários autenticados podem ler oficinas externas" ON public.oficinas_externas
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuários autenticados podem ler serviços externos" ON public.servicos_externos
  FOR SELECT USING (auth.role() = 'authenticated');

-- Política para usuários autenticados (escrita)
CREATE POLICY  "Usuários autenticados podem modificar veículos" ON public.veiculos
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Usuários autenticados podem modificar supervisores" ON public.supervisores
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Usuários autenticados podem modificar ordens de serviço" ON public.ordens_servico
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Usuários autenticados podem modificar peças" ON public.pecas
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Usuários autenticados podem modificar peças usadas" ON public.pecas_usadas
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Usuários autenticados podem modificar oficinas externas" ON public.oficinas_externas
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Usuários autenticados podem modificar serviços externos" ON public.servicos_externos
  FOR ALL USING (auth.role() = 'authenticated');

-- =========================================
-- DADOS PLACEHOLDER PARA DEMONSTRAÇÃO
-- =========================================

-- Supervisores
INSERT INTO public.supervisores (nome, cargo, contato) VALUES 
('João Silva', 'Supervisor de Frota', 'joao@empresa.com'),
('Maria Santos', 'Coordenadora de Manutenção', 'maria@empresa.com'),
('Carlos Pereira', 'Técnico Chefe', 'carlos@empresa.com'),
('Ana Costa', 'Supervisora de Estoque', 'ana@empresa.com'),
('Roberto Lima', 'Gerente de Oficina', 'roberto@empresa.com')
ON CONFLICT DO NOTHING;

-- Veículos da frota
INSERT INTO public.veiculos (placa, modelo, tipo, ano, quilometragem, status) VALUES 
-- Caminhonetes
('BRA-2E19', 'Hilux SRV 4x4', 'Caminhonete', 2020, 45000, 'ativo'),
('BRA-3F27', 'Ranger XLS 4x4', 'Caminhonete', 2019, 67000, 'ativo'),
('BRA-4G35', 'Strada Adventure', 'Caminhonete', 2021, 23000, 'ativo'),
('BRA-5H43', 'S10 LT 4x4', 'Caminhonete', 2018, 89000, 'manutencao'),
('BRA-6J51', 'Amarok Highline', 'Caminhonete', 2022, 15000, 'ativo'),

-- Veículos utilitários
('BRA-7K69', 'Sprinter 415 CDI', 'Van', 2020, 78000, 'ativo'),
('BRA-8L77', 'Master Chassi', 'Utilitário', 2019, 92000, 'ativo'),
('BRA-9M85', 'Ducato Cargo', 'Van', 2021, 34000, 'ativo'),

-- Veículos especiais
('BRA-1N93', 'Guindauto Munck', 'Guindauto', 2018, 56000, 'manutencao'),
('BRA-2P01', 'Caminhão Munck', 'Munck', 2020, 41000, 'ativo'),
('BRA-3Q19', 'Guincho Pesado', 'Guincho', 2019, 63000, 'ativo'),
('BRA-4R27', 'Escavadeira Hidráulica', 'Máquina', 2017, 12500, 'ativo'),
('BRA-5S35', 'Gerador Móvel 500KVA', 'Gerador', 2021, 8700, 'ativo')
ON CONFLICT DO NOTHING;

-- Peças de estoque
INSERT INTO public.pecas (nome, codigo, fornecedor, custo_unitario, quantidade_estoque) VALUES 
-- Filtros
('Filtro de Óleo Motor - Hilux', 'FLT-001', 'Toyota Genuine Parts', 45.90, 25),
('Filtro de Ar - Ranger', 'FLT-002', 'Ford Original', 67.50, 18),
('Filtro Combustível - Sprinter', 'FLT-003', 'Bosch', 89.70, 12),
('Filtro Hidráulico - Escavadeira', 'FLT-004', 'Caterpillar', 234.80, 8),

-- Óleos e fluidos
('Óleo Motor 15W40 - 20L', 'OIL-001', 'Shell', 156.90, 15),
('Óleo Hidráulico ISO 68 - 20L', 'OIL-002', 'Mobil', 298.50, 10),
('Fluido Freio DOT4 - 500ml', 'OIL-003', 'Bosch', 23.90, 30),
('Aditivo Radiador - 1L', 'OIL-004', 'Valvoline', 34.50, 22),

-- Peças de motor
('Vela Ignição - Hilux', 'MOT-001', 'NGK', 28.90, 40),
('Correia Dentada - Ranger', 'MOT-002', 'Gates', 145.80, 6),
('Bomba Água - Sprinter', 'MOT-003', 'Febi', 387.60, 4),
('Junta Cabeçote - S10', 'MOT-004', 'Elring', 234.70, 5),

-- Freios
('Pastilha Freio Diant. - Hilux', 'FRE-001', 'Bosch', 189.90, 12),
('Disco Freio Traseiro - Ranger', 'FRE-002', 'TRW', 267.40, 8),
('Fluido Freio DOT4 - 1L', 'FRE-003', 'Texaco', 45.60, 15),
('Cilindro Freio - Sprinter', 'FRE-004', 'ATE', 156.80, 6),

-- Suspensão
('Amortecedor Diant. - Hilux', 'SUS-001', 'Monroe', 245.90, 10),
('Mola Traseira - Ranger', 'SUS-002', 'Eibach', 189.70, 8),
('Bucha Bandeja - S10', 'SUS-003', 'Cofap', 67.40, 20),
('Kit Amortecedor - Sprinter', 'SUS-004', 'Bilstein', 456.80, 4),

-- Pneus
('Pneu 265/65R17 - Hilux', 'PNE-001', 'Bridgestone', 389.90, 16),
('Pneu 235/85R16 - Sprinter', 'PNE-002', 'Michelin', 456.70, 12),
('Pneu 31x10.5R15 - Ranger', 'PNE-003', 'BFGoodrich', 567.80, 10),

-- Elétrica
('Bateria 60Ah - Hilux', 'ELE-001', 'Moura', 234.90, 8),
('Alternador - Ranger', 'ELE-002', 'Bosch', 678.50, 3),
('Motor Partida - Sprinter', 'ELE-003', 'Valeo', 567.90, 4),
('Relé 12V - Universal', 'ELE-004', 'Hella', 23.40, 25),

-- Hidráulico (para guindastes/muncks)
('Bomba Hidráulica - Munck', 'HID-001', 'Parker', 1567.80, 2),
('Cilindro Hidráulico 50ton', 'HID-002', 'Husco', 2345.60, 3),
('Mangueira Hidráulica 1/2"', 'HID-003', 'Gates', 45.90, 50),
('Filtro Retorno Hidráulico', 'HID-004', 'Hydac', 156.70, 8)
ON CONFLICT DO NOTHING;

-- Oficinas externas credenciadas
INSERT INTO public.oficinas_externas (nome, cnpj, endereco, telefone, contato) VALUES 
('Auto Mecânica Silva & Cia', '12.345.678/0001-90', 'Rua das Oficinas, 123 - Centro', '(11) 3456-7890', 'José Silva'),
('Freios & Suspensão Ltda', '23.456.789/0001-01', 'Av. Industrial, 456 - Distrito', '(11) 3567-8901', 'Maria Oliveira'),
('Diesel Tech Especializada', '34.567.890/0001-12', 'Rua dos Motores, 789 - Industrial', '(11) 3678-9012', 'Carlos Santos'),
('Hidráulica & Pneumática S/A', '45.678.901/0001-23', 'Av. das Máquinas, 321 - Zona Sul', '(11) 3789-0123', 'Ana Pereira'),
('Elétrica Automotiva Express', '56.789.012/0001-34', 'Rua da Energia, 654 - Vila Nova', '(11) 3890-1234', 'Roberto Costa')
ON CONFLICT DO NOTHING;

-- Ordens de serviço (algumas concluídas, outras em andamento)
INSERT INTO public.ordens_servico (veiculo_id, problema_reportado, diagnostico, status, data_entrada, data_saida, supervisor_entrega_id, supervisor_retirada_id) VALUES 
-- OS Concluídas
(4, 'Ruído estranho no motor e perda de potência', 'Correia dentada com desgaste excessivo. Substituída juntamente com tensor e bomba dágua preventivamente.', 'concluida', '2024-01-10 08:30:00', '2024-01-12 16:45:00', 1, 2),
(9, 'Sistema hidráulico com vazamento', 'Mangueira hidráulica rompida na conexão principal. Substituída mangueira e verificado sistema completo.', 'concluida', '2024-01-08 14:20:00', '2024-01-15 11:30:00', 2, 3),
(1, 'Troca de óleo e filtros - manutenção preventiva', 'Manutenção preventiva realizada conforme cronograma. Óleo motor, filtros de óleo, ar e combustível substituídos.', 'concluida', '2024-01-05 09:00:00', '2024-01-05 17:00:00', 1, 1),
(6, 'Ar condicionado não gelando', 'Sistema com baixa pressão de gás R134a. Realizada recarga e teste de estanqueidade. Sistema OK.', 'concluida', '2024-01-03 10:15:00', '2024-01-04 14:30:00', 3, 2),

-- OS Em andamento
(4, 'Freios fazendo ruído ao frear', 'Em análise. Pastilhas dianteiras com desgaste severo, discos riscados. Aguardando peças para substituição.', 'em_andamento', '2024-01-18 08:00:00', NULL, 2, NULL),
(9, 'Guincho não levanta carga máxima', 'Verificação do sistema hidráulico em andamento. Pressão abaixo do especificado, investigando bomba hidráulica.', 'em_andamento', '2024-01-16 13:45:00', NULL, 3, NULL),
(7, 'Motor aquecendo acima do normal', 'Termostato com funcionamento irregular. Radiador com obstrução parcial. Limpeza em andamento.', 'em_andamento', '2024-01-19 07:30:00', NULL, 1, NULL)
ON CONFLICT DO NOTHING;

-- Peças usadas nas ordens de serviço
INSERT INTO public.pecas_usadas (ordem_servico_id, peca_id, quantidade, supervisor_id) VALUES 
-- OS 1 (Correia dentada S10)
(1, 8, 1, 2),  -- Correia Dentada - Ranger (usada como compatível)
(1, 9, 1, 2),  -- Bomba Água - Sprinter (usada como compatível)
(1, 5, 1, 2),  -- Óleo Motor 15W40

-- OS 2 (Vazamento hidráulico Munck)
(2, 27, 2, 3), -- Mangueira Hidráulica
(2, 6, 1, 3),  -- Óleo Hidráulico

-- OS 3 (Manutenção preventiva Hilux)
(3, 1, 1, 1),  -- Filtro Óleo Motor - Hilux
(3, 11, 4, 1), -- Vela Ignição - Hilux
(3, 5, 1, 1),  -- Óleo Motor 15W40

-- OS 4 (Ar condicionado Van)
(4, 8, 1, 2),  -- Aditivo Radiador
(4, 7, 1, 2)   -- Fluido Freio (usado para sistema)
ON CONFLICT DO NOTHING;

-- Serviços externos realizados
INSERT INTO public.servicos_externos (ordem_servico_id, oficina_externa_id, descricao, valor, data_envio, data_retorno) VALUES 
(2, 4, 'Rebuild completo da bomba hidráulica principal do sistema Munck. Substituição de vedações e calibração de pressão.', 2850.00, '2024-01-10 08:00:00', '2024-01-14 17:00:00'),
(1, 2, 'Retífica do cabeçote do motor e substituição de válvulas. Serviço especializado não disponível internamente.', 1875.50, '2024-01-11 09:30:00', '2024-01-12 15:00:00')
ON CONFLICT DO NOTHING;
