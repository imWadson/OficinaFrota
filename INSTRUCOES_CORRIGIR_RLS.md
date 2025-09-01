# 🔧 CORREÇÃO DAS POLÍTICAS RLS - TABELA VEÍCULOS

## ❌ Problema Atual
A tabela `veiculos` tem RLS (Row Level Security) habilitado com políticas que estão bloqueando a inserção de novos veículos, retornando erro:
```
new row violates row-level security policy for table "veiculos"
```

## ✅ Solução

### Opção 1: Desabilitar RLS (Mais Simples)
Execute este comando no SQL Editor do Supabase:

```sql
ALTER TABLE veiculos DISABLE ROW LEVEL SECURITY;
```

### Opção 2: Criar Políticas Permissivas (Recomendado para Produção)
Execute estes comandos no SQL Editor do Supabase:

```sql
-- Remover políticas existentes
DROP POLICY IF EXISTS "Veículos por regional" ON veiculos;
DROP POLICY IF EXISTS "Veículos por regional - write" ON veiculos;

-- Criar política permissiva para usuários autenticados
CREATE POLICY "Veículos - acesso para usuários autenticados" ON veiculos
    FOR ALL USING (auth.role() = 'authenticated');
```

## 📍 Onde Executar

1. **Acesse o Supabase Dashboard**
2. **Vá em "SQL Editor"**
3. **Cole o comando escolhido**
4. **Clique em "Run"**

## 🔍 Verificar se Funcionou

Execute esta query para verificar o status:

```sql
SELECT 
    schemaname, 
    tablename, 
    rowsecurity,
    CASE 
        WHEN rowsecurity THEN 'RLS ATIVO'
        ELSE 'RLS DESATIVADO'
    END as status_rls
FROM pg_tables 
WHERE tablename = 'veiculos';
```

## 🚀 Após a Correção

1. **Teste o modal "Novo Veículo"**
2. **Tente inserir um veículo**
3. **Verifique se aparece na lista**
4. **Confirme se foi salvo no banco**

## ⚠️ Importante

- **Opção 1** é mais simples mas remove toda a segurança
- **Opção 2** mantém segurança básica (apenas usuários autenticados)
- Para produção, considere implementar o sistema de regionais completo
