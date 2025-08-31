-- =====================================================
-- FROTA GESTOR - USUÁRIOS DE EXEMPLO
-- =====================================================

-- Nota: Estes são apenas exemplos para desenvolvimento
-- Em produção, os usuários devem ser criados através do sistema de cadastro

-- Usuário Administrador (Coordenador - Metropolitana - PI)
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'admin@frotagestor.com',
    crypt('Admin@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{
        "nome": "Administrador do Sistema",
        "matricula": "ADM001",
        "regional_id": "1",
        "cargo_id": "4",
        "estado": "Piauí",
        "regional_nome": "Metropolitana",
        "cargo_nome": "Coordenador"
    }',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);

-- Usuário Gerente (Gerente - Norte - PI)
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'gerente.norte@frotagestor.com',
    crypt('Gerente@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{
        "nome": "João Silva Santos",
        "matricula": "GER001",
        "regional_id": "2",
        "cargo_id": "3",
        "estado": "Piauí",
        "regional_nome": "Norte",
        "cargo_nome": "Gerente"
    }',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);

-- Usuário Supervisor (Supervisor - Sul - PI)
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'supervisor.sul@frotagestor.com',
    crypt('Supervisor@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{
        "nome": "Maria Oliveira Costa",
        "matricula": "SUP001",
        "regional_id": "3",
        "cargo_id": "2",
        "estado": "Piauí",
        "regional_nome": "Sul",
        "cargo_nome": "Supervisor"
    }',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);

-- Usuário Oficina (Oficina - Centro Sul - PI)
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'oficina.centrosul@frotagestor.com',
    crypt('Oficina@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{
        "nome": "Pedro Santos Lima",
        "matricula": "OFI001",
        "regional_id": "4",
        "cargo_id": "1",
        "estado": "Piauí",
        "regional_nome": "Centro Sul",
        "cargo_nome": "Oficina"
    }',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);

-- Usuário Gerente MA (Gerente - Noroeste - MA)
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'gerente.noroeste@frotagestor.com',
    crypt('GerenteMA@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{
        "nome": "Ana Paula Ferreira",
        "matricula": "GER002",
        "regional_id": "5",
        "cargo_id": "3",
        "estado": "Maranhão",
        "regional_nome": "Noroeste",
        "cargo_nome": "Gerente"
    }',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);

-- Usuário Supervisor MA (Supervisor - Norte - MA)
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'supervisor.norte.ma@frotagestor.com',
    crypt('SupervisorMA@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{
        "nome": "Carlos Eduardo Rocha",
        "matricula": "SUP002",
        "regional_id": "6",
        "cargo_id": "2",
        "estado": "Maranhão",
        "regional_nome": "Norte",
        "cargo_nome": "Supervisor"
    }',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);

-- Usuário Oficina MA (Oficina - Sul - MA)
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'oficina.sul.ma@frotagestor.com',
    crypt('OficinaMA@123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{
        "nome": "Roberto Almeida Silva",
        "matricula": "OFI002",
        "regional_id": "7",
        "cargo_id": "1",
        "estado": "Maranhão",
        "regional_nome": "Sul",
        "cargo_nome": "Oficina"
    }',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);

-- =====================================================
-- RESUMO DOS USUÁRIOS DE EXEMPLO
-- =====================================================

/*
USUÁRIOS CRIADOS:

1. admin@frotagestor.com / Admin@123
   - Coordenador - Metropolitana - Piauí
   - Matrícula: ADM001

2. gerente.norte@frotagestor.com / Gerente@123
   - Gerente - Norte - Piauí
   - Matrícula: GER001

3. supervisor.sul@frotagestor.com / Supervisor@123
   - Supervisor - Sul - Piauí
   - Matrícula: SUP001

4. oficina.centrosul@frotagestor.com / Oficina@123
   - Oficina - Centro Sul - Piauí
   - Matrícula: OFI001

5. gerente.noroeste@frotagestor.com / GerenteMA@123
   - Gerente - Noroeste - Maranhão
   - Matrícula: GER002

6. supervisor.norte.ma@frotagestor.com / SupervisorMA@123
   - Supervisor - Norte - Maranhão
   - Matrícula: SUP002

7. oficina.sul.ma@frotagestor.com / OficinaMA@123
   - Oficina - Sul - Maranhão
   - Matrícula: OFI002

ESTRUTURA DE CARGOS:
- Nível 1: Oficina
- Nível 2: Supervisor
- Nível 3: Gerente
- Nível 4: Coordenador

REGIONAIS POR ESTADO:
Piauí:
- Metropolitana
- Norte
- Sul
- Centro Sul

Maranhão:
- Noroeste
- Norte
- Sul
*/
