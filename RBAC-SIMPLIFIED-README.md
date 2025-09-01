# Sistema RBAC Simplificado - Frota Gestor

## 🎯 Objetivo

Sistema de controle de acesso baseado em roles (RBAC) **simplificado e eficiente**, evitando overengineering e complexidade desnecessária.

## 🏗️ Estrutura Hierárquica

### Cargos (6 níveis simples)
```
1. Mecânico (oficina)
2. Analista da Oficina (oficina)
3. Supervisor (operação)
4. Coordenador (operação)
5. Gerente (operação)
6. Diretor (admin)
```

### Hierarquia de Acesso
- **Mecânico**: Ve e registra uso de peças, conclui ordens de serviço
- **Analista da Oficina**: Gerencia estoque, oficinas externas, relatórios
- **Supervisor**: Gerencia veículos e ordens de serviço da sua regional
- **Coordenador**: Supervisiona supervisores, acesso a relatórios
- **Gerente**: Gerencia usuários da regional, acesso total à regional
- **Diretor**: Acesso total ao sistema

## 🔐 Sistema de Permissões

### Princípio: **Nível Hierárquico**
- Usuário pode acessar recursos de cargos com nível igual ou inferior
- Exemplo: Gerente (nível 5) pode acessar recursos de Supervisor (nível 3)

### Região de Acesso
- Cada usuário só vê dados da sua regional
- Diretor vê dados de todas as regionais
- Exceção: Relatórios podem ser acessados por coordenadores e acima

## 📊 Tabelas Principais

### Estrutura Hierárquica
- `estados` - Estados onde a empresa atua
- `regionais` - Regionais de cada estado
- `cargos` - Cargos com níveis hierárquicos
- `usuarios` - Usuários com hierarquia de supervisão

### Entidades de Negócio
- `veiculos` - Frota de veículos
- `ordens_servico` - Ordens de serviço da oficina
- `pecas` - Estoque de peças
- `pecas_usadas` - Peças utilizadas nas OS
- `oficinas_externas` - Oficinas credenciadas
- `servicos_externos` - Serviços em oficinas externas

## 🛡️ Segurança (RLS)

### Políticas Simples
```sql
-- Exemplo: Veículos por regional
CREATE POLICY "Veículos por regional" ON veiculos
    FOR SELECT USING (
        regional_id = auth.user_regional() OR 
        auth.user_cargo() = 'DIRETOR'
    );
```

### Funções de Acesso
- `auth.user_cargo()` - Retorna cargo do usuário
- `auth.user_regional()` - Retorna regional do usuário
- `auth.can_access(required_cargo)` - Verifica se pode acessar

## 🚀 Vantagens da Simplificação

### ✅ O que foi mantido
- Hierarquia clara e intuitiva
- Controle de acesso por regional
- Segurança robusta com RLS
- Performance otimizada

### ❌ O que foi removido
- Tabela de permissões complexa
- Relacionamentos cargo-permissão
- Triggers desnecessários
- Campos redundantes
- Interfaces complexas

## 📈 Performance

### Índices Essenciais
```sql
-- Hierarquia
CREATE INDEX idx_usuarios_cargo_regional ON usuarios(cargo_id, regional_id);

-- Veículos
CREATE INDEX idx_veiculos_regional_status ON veiculos(regional_id, status);

-- Ordens de serviço
CREATE INDEX idx_os_veiculo_status ON ordens_servico(veiculo_id, status);
```

### Consultas Otimizadas
- Filtros por regional são sempre rápidos
- Joins minimizados
- Índices compostos para consultas comuns

## 🔧 Implementação

### 1. Banco de Dados
```bash
# Executar script simplificado
psql -d seu_banco -f database-rbac-simplified.sql
```

### 2. Frontend
```typescript
// Usar entidades simplificadas
import { CARGOS, canAccess, isAdmin } from '@/entities/rbac-simplified'

// Verificar permissões
if (canAccess(userCargo, CARGOS.SUPERVISOR)) {
  // Pode acessar recursos de supervisor
}
```

### 3. Middleware de Acesso
```typescript
// Função simples para verificar acesso
export const checkAccess = (requiredCargo: CargoSigla) => {
  const userCargo = getUserCargo()
  return canAccess(userCargo, requiredCargo)
}
```

## 📱 Mobile (Futuro)

### Estrutura Preparada
- APIs RESTful simples
- Autenticação JWT
- Dados filtrados por regional
- Interface responsiva

### Flutter
- Usar mesma lógica de permissões
- Componentes reutilizáveis
- Sincronização offline básica

## 🎯 Benefícios

### Para Desenvolvedores
- Código mais limpo e legível
- Menos bugs de permissão
- Manutenção mais fácil
- Testes mais simples

### Para Usuários
- Interface mais intuitiva
- Menos confusão sobre permissões
- Performance melhor
- Menos cliques para acessar recursos

### Para Administradores
- Configuração mais simples
- Menos pontos de falha
- Auditoria mais clara
- Escalabilidade melhor

## 🚨 Anti-Padrões Evitados

### ❌ Overengineering
- Não criamos sistema de permissões complexo
- Não usamos múltiplas tabelas de relacionamento
- Não implementamos triggers desnecessários

### ❌ Dummy Slop
- Não deixamos código comentado
- Não mantivemos campos não utilizados
- Não criamos interfaces desnecessárias

### ❌ Complexidade Desnecessária
- Não usamos herança complexa
- Não implementamos padrões desnecessários
- Não criamos abstrações excessivas

## 📋 Checklist de Implementação

- [ ] Executar script do banco
- [ ] Configurar autenticação Supabase
- [ ] Implementar middleware de acesso
- [ ] Criar componentes de UI
- [ ] Testar permissões por cargo
- [ ] Testar filtros por regional
- [ ] Documentar APIs
- [ ] Preparar para mobile

## 🔄 Próximos Passos

1. **Implementar frontend** com as entidades simplificadas
2. **Criar componentes** de dashboard e listagens
3. **Implementar formulários** com validação
4. **Testar permissões** em diferentes cenários
5. **Preparar APIs** para mobile
6. **Documentar** funcionalidades

---

**Lembre-se**: Simplicidade é a sofisticação final. Mantenha o foco no essencial e evite adicionar complexidade desnecessária.
