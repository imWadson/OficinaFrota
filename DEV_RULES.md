# Regras de Desenvolvimento - Oficina Frota

## Princípios Fundamentais

### 1. Evitar Dummy AI SLOP
- **Não criar códigos desnecessários e verbosos**
- Manter implementações diretas e objetivas
- Evitar abstrações desnecessárias
- Priorizar simplicidade sobre complexidade
- Remover código morto e comentários óbvios

### 2. Evitar Overengineering
- **Quantidade**: Não criar mais código do que o necessário
- **Qualidade**: Não implementar funcionalidades que não são requisitadas
- **Ferramentas**: Não adicionar bibliotecas ou dependências desnecessárias
- **Arquitetura**: Manter estrutura simples e direta
- **Padrões**: Aplicar padrões apenas quando realmente necessário

## Diretrizes Práticas

### Antes de Implementar
- ✅ A funcionalidade é realmente necessária?
- ✅ Existe uma solução mais simples?
- ✅ Precisamos de uma nova dependência?

### Durante o Desenvolvimento
- ✅ Código é legível e direto?
- ✅ Evitamos abstrações desnecessárias?
- ✅ Mantemos a implementação enxuta?

### Após a Implementação
- ✅ Removemos código de teste/debug?
- ✅ Limpamos imports não utilizados?
- ✅ Verificamos se não há duplicação?

## Exemplos do que EVITAR

❌ **AI Slop:**
```typescript
// Não fazer isso
function processData(data: any): any {
  console.log("Processing data..."); // Desnecessário
  const processedData = data.map((item: any) => {
    // Lógica desnecessariamente complexa
    return {
      ...item,
      processed: true,
      timestamp: new Date().toISOString(),
      metadata: {
        processed: true,
        processedAt: new Date().toISOString()
      }
    };
  });
  console.log("Data processed successfully"); // Desnecessário
  return processedData;
}
```

✅ **Implementação Limpa:**
```typescript
// Fazer isso
function processData(data: any[]): any[] {
  return data.map(item => ({
    ...item,
    processed: true,
    timestamp: new Date().toISOString()
  }));
}
```

❌ **Overengineering:**
```typescript
// Não criar interfaces desnecessárias
interface DataProcessorConfig {
  enableLogging: boolean;
  enableValidation: boolean;
  enableCaching: boolean;
  cacheTimeout: number;
  validationRules: ValidationRule[];
}

// Quando uma simples função resolve
function processData(data: any[]): any[] {
  return data.map(item => ({ ...item, processed: true }));
}
```

## Lembre-se
**Simplicidade é sofisticação.** Sempre pergunte: "Esta é a forma mais simples de resolver o problema?"