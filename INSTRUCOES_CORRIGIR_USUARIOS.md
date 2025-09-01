# 🔧 INSTRUÇÕES PARA CORRIGIR PROBLEMAS DA TABELA USUARIOS

## 🚨 PROBLEMAS IDENTIFICADOS:

1. **ERRO 404**: Tabela `usuarios` não encontrada no Supabase
2. **ERRO 406**: Problema com `.single()` quando não há resultados
3. **ERRO 400**: Problemas de autenticação

## 🛠️ SOLUÇÕES IMPLEMENTADAS NO CÓDIGO:

### ✅ 1. Corrigido NovoVeiculoModal.vue
- Removido `.single()` da query de usuário
- Adicionada verificação de array vazio
- Melhor tratamento de erros

### ✅ 2. Corrigido authStore.ts
- Removido `.single()` da query de usuário
- Adicionada verificação de array vazio
- Melhor tratamento de erros

## 📋 PASSOS PARA CORRIGIR NO SUPABASE:

### **PASSO 1: Verificar se a tabela usuarios existe**
Execute no SQL Editor do Supabase:

```sql
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'usuarios'
);
```

### **PASSO 2: Se não existir, criar a tabela**
```sql
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    matricula VARCHAR(50) NOT NULL UNIQUE,
    cargo_id UUID NOT NULL,
    regional_id UUID,
    supervisor_id UUID REFERENCES usuarios(id),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **PASSO 3: Verificar RLS (Row Level Security)**
```sql
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'usuarios';
```

### **PASSO 4: Se RLS estiver ativo, criar políticas básicas**
```sql
-- Habilitar RLS
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- Política para SELECT
CREATE POLICY "Usuarios podem ver seus próprios dados" ON usuarios
    FOR SELECT USING (auth.uid() = auth_user_id);

-- Política para INSERT
CREATE POLICY "Usuarios podem inserir seus próprios dados" ON usuarios
    FOR INSERT WITH CHECK (auth.uid() = auth_user_id);

-- Política para UPDATE
CREATE POLICY "Usuarios podem atualizar seus próprios dados" ON usuarios
    FOR UPDATE USING (auth.uid() = auth_user_id);
```

### **PASSO 5: Verificar se as políticas foram criadas**
```sql
SELECT * FROM pg_policies WHERE tablename = 'usuarios';
```

## 🔍 VERIFICAÇÕES ADICIONAIS:

### **1. Verificar se o usuário está logado**
- Confirme que o `auth.users` tem o usuário correto
- Verifique se o `auth_user_id` está correto

### **2. Verificar dados do usuário**
```sql
SELECT * FROM auth.users WHERE id = 'SEU_USER_ID_AQUI';
```

### **3. Verificar se há dados na tabela usuarios**
```sql
SELECT * FROM usuarios;
```

## 🎯 RESULTADO ESPERADO:

Após executar estes passos:
- ✅ Tabela `usuarios` deve existir
- ✅ RLS deve estar configurado corretamente
- ✅ Políticas devem permitir acesso do usuário autenticado
- ✅ Erros 404, 406 e 400 devem ser resolvidos

## 🚀 TESTE:

1. Faça logout e login novamente
2. Tente criar um novo veículo
3. Verifique se não há mais erros no console

## 📞 SUPORTE:

Se os problemas persistirem:
1. Verifique os logs do Supabase
2. Confirme que as políticas RLS estão corretas
3. Verifique se o usuário tem as permissões necessárias
