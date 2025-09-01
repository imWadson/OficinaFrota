# 🧪 **INSTRUÇÕES PARA TESTAR O SISTEMA DE REGRAS REGIONAIS**

## 📋 **PRÉ-REQUISITOS**

1. **Execute o script SQL** `testar_sistema_regional.sql` no Supabase para inserir dados de teste
2. **Certifique-se de que o usuário está logado** no sistema
3. **Verifique se o usuário tem dados completos** na tabela `usuarios`

## 🔍 **TESTES A SEREM REALIZADOS**

### **1. TESTE DE CARREGAMENTO DE VEÍCULOS**

**Objetivo:** Verificar se os filtros regionais estão funcionando

**Passos:**
1. Acesse a página **"Veículos"**
2. Verifique no console do navegador se aparece:
   ```
   Veículos carregados: X
   ```
3. Se aparecer erro, verifique:
   - Se o usuário está logado
   - Se o usuário tem `regional_id` na tabela `usuarios`
   - Se o usuário tem `cargo_id` na tabela `usuarios`

### **2. TESTE DE ESTATÍSTICAS**

**Objetivo:** Verificar se o dropdown de estatísticas mostra apenas veículos da regional do usuário

**Passos:**
1. Acesse a página **"Estatísticas"**
2. Verifique se o dropdown mostra veículos
3. Se não mostrar, verifique o console para erros

### **3. TESTE DE NOVO VEÍCULO**

**Objetivo:** Verificar se o modal de novo veículo aplica as regras regionais

**Passos:**
1. Acesse a página **"Veículos"**
2. Clique em **"Novo Veículo"**
3. Verifique se o dropdown de Regional:
   - **Para Diretores/Gerentes:** Mostra todas as regionais
   - **Para outros usuários:** Mostra apenas a regional do usuário

## 🐛 **DIAGNÓSTICO DE PROBLEMAS**

### **Problema: "Cannot read properties of undefined (reading 'value')"**

**Causa:** O `userRegional` ou `userCargo` está retornando `undefined`

**Solução:**
1. Verifique se o usuário está logado
2. Verifique se o `authStore` tem os dados do usuário
3. Execute no console do navegador:
   ```javascript
   // Verificar dados do usuário
   console.log('User:', user.value)
   console.log('User Regional:', userRegional.value)
   console.log('User Cargo:', userCargo.value)
   ```

### **Problema: "Erro ao carregar veículos"**

**Causa:** Problema na aplicação dos filtros RLS

**Solução:**
1. Verifique se as políticas RLS estão ativas no Supabase
2. Execute o script SQL para verificar as políticas:
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'veiculos';
   ```

### **Problema: Dropdown vazio**

**Causa:** Dados não estão sendo carregados corretamente

**Solução:**
1. Verifique se o `ESTADOS` tem dados
2. Verifique se o `userData` está sendo carregado
3. Execute no console:
   ```javascript
   console.log('User Data:', userData.value)
   console.log('Regionais Disponíveis:', regionaisDisponiveis.value)
   ```

## 🔧 **COMANDOS ÚTEIS PARA DEBUG**

### **No Console do Navegador:**

```javascript
// Verificar dados do usuário
const { user, userRegional, userCargo } = useAuth()
console.log('User:', user.value)
console.log('Regional:', userRegional.value)
console.log('Cargo:', userCargo.value)

// Verificar permissões
const { isDiretor, isGerente, canViewAllRegionais } = useUserContext()
console.log('É Diretor:', isDiretor.value)
console.log('É Gerente:', isGerente.value)
console.log('Pode ver todas regionais:', canViewAllRegionais.value)

// Testar carregamento de veículos
const veiculos = await veiculoRepository.findAll()
console.log('Veículos carregados:', veiculos)
```

### **No Supabase SQL Editor:**

```sql
-- Verificar dados do usuário atual
SELECT 
    u.id,
    u.nome,
    u.email,
    c.sigla as cargo,
    r.nome as regional
FROM usuarios u
LEFT JOIN cargos c ON u.cargo_id = c.id
LEFT JOIN regionais r ON u.regional_id = r.id
WHERE u.auth_user_id = 'SEU_AUTH_USER_ID';

-- Verificar veículos por regional
SELECT 
    v.placa,
    v.modelo,
    r.nome as regional
FROM veiculos v
LEFT JOIN regionais r ON v.regional_id = r.id
ORDER BY r.nome, v.placa;
```

## ✅ **CRITÉRIOS DE SUCESSO**

O sistema está funcionando corretamente quando:

1. ✅ **Usuários veem apenas veículos de sua regional** (exceto diretores/gerentes)
2. ✅ **Dropdown de Regional no modal mostra opções corretas**
3. ✅ **Estatísticas mostram apenas veículos da regional do usuário**
4. ✅ **Não há erros no console do navegador**
5. ✅ **Dados são persistidos corretamente no Supabase**

## 🚨 **SE OS PROBLEMAS PERSISTIREM**

1. **Verifique o arquivo `.env`** - certifique-se de que as variáveis do Supabase estão corretas
2. **Limpe o cache do navegador** e faça login novamente
3. **Verifique se o usuário tem permissões** na tabela `usuarios`
4. **Execute o script SQL completo** para garantir que todos os dados estão presentes

---

**📞 Se ainda houver problemas, forneça:**
- Screenshot do erro no console
- Dados do usuário logado
- Resultado das queries SQL de diagnóstico
