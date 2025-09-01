# FleetManager

Aplicativo móvel para digitalizar e gerenciar o fluxo de manutenção de veículos entre os setores de Operação e Oficina.

## 📱 Funcionalidades

### Perfil Operação
- ✅ Criar novas Ordens de Serviço (OS)
- ✅ Visualizar status e histórico das OS criadas
- ✅ Receber notificações sobre atualizações
- ✅ Registrar retirada de veículos
- ✅ Interface adaptada ao perfil
- ✅ Email salvo automaticamente

### Perfil Oficina
- ✅ Visualizar OS pendentes de aceite
- ✅ Aceitar ou rejeitar novas OS
- ✅ Atualizar status durante o processo
- ✅ Visualizar histórico completo
- ✅ Registrar responsáveis por cada etapa

## 🏗️ Arquitetura

- **Frontend**: Flutter
- **Backend**: Supabase
- **Banco de Dados**: PostgreSQL (via Supabase)
- **Autenticação**: Supabase Auth
- **Storage**: Supabase Storage (para fotos)
- **Armazenamento Local**: SharedPreferences (para email)

## 📋 Pré-requisitos

- Flutter SDK 3.8.1 ou superior
- Dart SDK
- Conta no Supabase
- Android Studio / VS Code

## 🚀 Configuração

### 1. Configurar Supabase

1. Crie uma conta em [supabase.com](https://supabase.com)
2. Crie um novo projeto
3. Vá para Settings > API e copie:
   - Project URL
   - anon public key

### 2. Configurar Banco de Dados

Execute os seguintes scripts SQL no SQL Editor do Supabase:

```sql
-- Habilitar extensões
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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

-- Políticas de segurança RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_defects ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_logs ENABLE ROW LEVEL SECURITY;

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

-- Função para criar perfil automaticamente
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
```

### 3. Configurar o Aplicativo

1. Abra o arquivo `lib/services/supabase_service.dart`
2. Substitua as constantes:
   ```dart
   static const String _supabaseUrl = 'SUA_URL_DO_SUPABASE';
   static const String _supabaseAnonKey = 'SUA_CHAVE_ANONIMA';
   ```

### 4. Instalar Dependências

```bash
cd fleet_manager
flutter pub get
```

### 5. Executar o Aplicativo

```bash
flutter run
```

## 📱 Como Usar

### Primeiro Acesso

1. Abra o aplicativo
2. Clique em "Cadastro"
3. Preencha:
   - Nome completo
   - E-mail
   - Senha
   - Perfil (Operação ou Oficina)
4. Clique em "Cadastrar"

### Funcionalidade de Email Salvo

- ✅ O email é salvo automaticamente após o primeiro login
- ✅ Na próxima vez que abrir o app, o email já estará preenchido
- ✅ O email é limpo automaticamente ao fazer logout
- ✅ Funciona tanto para login quanto para cadastro

### Fluxo de Trabalho

#### Operação - Criando uma OS

1. Faça login com perfil "Operação"
2. Clique no botão "+" para criar nova OS
3. Selecione ou cadastre um veículo
4. Marque os defeitos encontrados
5. Tire uma foto do veículo
6. Clique em "Criar Ordem de Serviço"

#### Oficina - Recebendo uma OS

1. Faça login com perfil "Oficina"
2. Na aba "Pendentes", veja as OS aguardando aceite
3. Clique em uma OS para ver detalhes
4. Clique em "Aceitar" e tire uma foto do veículo na oficina
5. Ou clique em "Rejeitar" e informe o motivo

#### Oficina - Atualizando Status

1. Na aba "Em Andamento", veja as OS em processo
2. Clique em uma OS
3. Use "Atualizar Status" para mudar o status:
   - Analisando Defeitos
   - Conserto Iniciado
   - Conserto Finalizado
   - Pronto para Retirada

#### Operação - Retirando Veículo

1. Quando uma OS estiver "Pronto para Retirada"
2. Vá até a aba "Prontas para Retirada"
3. Clique na OS
4. Clique em "Retirar Veículo"

## 🔧 Configurações Avançadas

### Notificações Push

Para implementar notificações push:

1. Configure Firebase Cloud Messaging
2. Adicione as dependências no `pubspec.yaml`
3. Implemente o serviço de notificações

### Upload de Fotos

Para produção, configure o Supabase Storage:

1. Crie um bucket no Supabase
2. Configure as políticas de acesso
3. Implemente upload de arquivos

## 🐛 Solução de Problemas

### Erro de Conexão
- Verifique se as credenciais do Supabase estão corretas
- Confirme se o projeto está ativo

### Erro de Permissão
- Verifique se as políticas RLS estão configuradas
- Confirme se o usuário está autenticado

### Erro de Câmera
- Verifique as permissões do aplicativo
- Teste em um dispositivo físico

### Problemas com Email Salvo
- Verifique se o SharedPreferences está funcionando
- Confirme se as permissões de armazenamento estão concedidas

## 📄 Licença

Este projeto está sob a licença MIT.

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📞 Suporte

Para dúvidas ou problemas:
- Abra uma issue no GitHub
- Entre em contato com a equipe de desenvolvimento
