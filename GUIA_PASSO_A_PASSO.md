# 🚀 GUIA PASSO A PASSO - SETUP COMPLETO

## 📋 **ORDEM DE EXECUÇÃO**

### **PASSO 1: Executar Script SQL no Supabase**
1. Acesse o **Supabase Dashboard**
2. Vá em **SQL Editor**
3. Cole o conteúdo do arquivo `SCRIPT_COMPLETO_SETUP.sql`
4. Clique em **RUN**

### **PASSO 2: Verificar Resultados**
Após executar o script, você deve ver:
- ✅ Estrutura das tabelas
- ✅ Função RPC criada
- ✅ Dados de teste inseridos
- ✅ Contadores de registros

### **PASSO 3: Testar no Frontend**
1. Acesse a aplicação
2. Faça login
3. Vá em **"Nova Ordem de Serviço"**
4. Teste criar uma OS

---

## 🔧 **O QUE O SCRIPT FAZ**

### **1. Verifica Estrutura**
- Confirma se as tabelas existem
- Verifica se os campos obrigatórios estão presentes

### **2. Corrige Tabelas**
- Adiciona `numero_os` se não existir
- Adiciona `criado_por` se não existir

### **3. Cria Função RPC**
- Remove função antiga (se existir)
- Cria nova função com geração automática de `numero_os`
- Inclui transação para atualizar status do veículo

### **4. Insere Dados de Teste**
- Regional "Metropolitana"
- Usuário de teste
- Veículos de teste (ABC-1234, XYZ-5678)

### **5. Verifica Resultado**
- Confirma se tudo foi criado corretamente
- Mostra contadores finais

---

## 🚨 **SE ALGO DER ERRADO**

### **Erro: "relation does not exist"**
Execute primeiro o script de setup básico:
```sql
-- Execute o arquivo database-clean-and-setup.sql primeiro
```

### **Erro: "function already exists"**
O script já remove a função antiga automaticamente.

### **Erro: "column already exists"**
O script verifica se as colunas existem antes de criar.

### **Erro: "foreign key constraint"**
O script insere dados na ordem correta (estados → regionais → cargos → usuarios → veiculos).

---

## 📊 **VERIFICAÇÃO FINAL**

Após executar o script, você deve ver algo assim:

```
tabela          | total | ativos
VEÍCULOS        | 2     | 2
USUÁRIOS        | 1     | 1
REGIONAIS       | 1     | -
ORDENS DE SERVIÇO| 0    | -
```

E a função deve aparecer:
```
routine_name        | routine_type | data_type
criar_ordem_servico | FUNCTION     | json
```

---

## 🎯 **PRÓXIMOS PASSOS**

1. **Teste a criação de OS** na aplicação
2. **Verifique se os veículos aparecem** no dropdown
3. **Confirme se a OS é criada** com número único
4. **Teste o fallback** (se a RPC falhar)

---

## 📞 **SUPORTE**

Se ainda houver problemas:
1. Verifique os logs do console do navegador
2. Confirme se o script SQL foi executado completamente
3. Verifique se há dados nas tabelas necessárias
