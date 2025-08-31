-- Script para inserir usuários de exemplo com metadados
-- Execute este script no SQL Editor do Supabase após criar os usuários

-- Atualizar metadados dos usuários existentes
-- Substitua os UUIDs pelos IDs reais dos usuários do seu sistema

-- Exemplo de como atualizar metadados de um usuário:
-- UPDATE auth.users 
-- SET raw_user_meta_data = jsonb_build_object(
--   'nome', 'João Silva',
--   'role', 'supervisor'
-- )
-- WHERE id = 'uuid-do-usuario-aqui';

-- Para ver os usuários existentes:
-- SELECT id, email, raw_user_meta_data FROM auth.users;

-- Para inserir um novo usuário com metadados via SQL (não recomendado, use a interface):
-- INSERT INTO auth.users (
--   id,
--   email,
--   encrypted_password,
--   raw_user_meta_data,
--   created_at,
--   updated_at
-- ) VALUES (
--   gen_random_uuid(),
--   'joao.silva@empresa.com',
--   crypt('senha123', gen_salt('bf')),
--   '{"nome": "João Silva", "role": "supervisor"}',
--   now(),
--   now()
-- );

-- Exemplo de dados de usuários para referência:
-- 1. João Silva - joao.silva@empresa.com - Supervisor de Frota - role: supervisor
-- 2. Maria Santos - maria.santos@empresa.com - Coordenadora de Manutenção - role: supervisor  
-- 3. Carlos Pereira - carlos.pereira@empresa.com - Técnico Chefe - role: usuario
-- 4. Ana Costa - ana.costa@empresa.com - Supervisora de Estoque - role: supervisor
-- 5. Roberto Lima - roberto.lima@empresa.com - Gerente de Oficina - role: admin

-- Para atualizar metadados via interface do Supabase:
-- 1. Vá para Authentication > Users
-- 2. Clique no usuário
-- 3. Em "User Metadata", adicione:
--    {
--      "nome": "Nome do Usuário",
--      "role": "usuario|supervisor|admin"
--    }
