-- Script para criar tabela de perfis de usuário
-- Execute este script no SQL Editor do Supabase

-- Tabela de perfis de usuário
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nome text NOT NULL,
  cargo text,
  departamento text,
  telefone text,
  avatar_url text,
  role text DEFAULT 'usuario' CHECK (role IN ('admin', 'supervisor', 'usuario')),
  ativo boolean DEFAULT true,
  criado_em timestamptz NOT NULL DEFAULT now(),
  atualizado_em timestamptz NOT NULL DEFAULT now()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_ativo ON public.profiles(ativo);

-- Habilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
CREATE POLICY "Usuários podem ver seu próprio perfil" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Usuários podem atualizar seu próprio perfil" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins podem ver todos os perfis" ON public.profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins podem modificar todos os perfis" ON public.profiles
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Função para criar perfil automaticamente quando usuário se registra
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, nome, role)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'nome', 'Usuário'),
    COALESCE(new.raw_user_meta_data->>'role', 'usuario')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar perfil automaticamente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Função para atualizar timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.atualizado_em = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar timestamp
DROP TRIGGER IF EXISTS on_profiles_updated ON public.profiles;
CREATE TRIGGER on_profiles_updated
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Inserir dados de exemplo para usuários existentes
INSERT INTO public.profiles (id, nome, cargo, departamento, role) VALUES 
-- Substitua os UUIDs pelos IDs reais dos usuários do seu sistema
('00000000-0000-0000-0000-000000000001', 'João Silva', 'Supervisor de Frota', 'Manutenção', 'supervisor'),
('00000000-0000-0000-0000-000000000002', 'Maria Santos', 'Coordenadora de Manutenção', 'Manutenção', 'supervisor'),
('00000000-0000-0000-0000-000000000003', 'Carlos Pereira', 'Técnico Chefe', 'Manutenção', 'usuario'),
('00000000-0000-0000-0000-000000000004', 'Ana Costa', 'Supervisora de Estoque', 'Logística', 'supervisor'),
('00000000-0000-0000-0000-000000000005', 'Roberto Lima', 'Gerente de Oficina', 'Manutenção', 'admin')
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  cargo = EXCLUDED.cargo,
  departamento = EXCLUDED.departamento,
  role = EXCLUDED.role;
