# Oficina Frota CRM

Sistema CRM para gerenciamento de oficina interna de frota do setor de energia elétrica.

## 🚀 Tecnologias

- **Frontend**: Vue 3 (Composition API), Vue Router, Pinia, TanStack Vue Query
- **UI**: TailwindCSS, Headless UI
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **Validação**: Zod
- **Testes**: Vitest, Cypress

## 📋 Funcionalidades

- **Gestão de Frota**: Cadastro e controle de veículos (guindauto, munck, Strada, Hilux, etc.)
- **Ordens de Serviço**: Entrada/saída, diagnóstico, solução
- **Estoque**: Controle de peças, compras, baixas, histórico
- **Oficinas Externas**: Cadastro e controle de serviços externos
- **Supervisores**: Gestão de usuários e responsáveis
- **Relatórios**: Gastos por veículo/peça/oficina, histórico

## 🛠️ Instalação

1. **Clone o repositório**
```bash
git clone <repository-url>
cd oficina-frota-crm
```

2. **Instale as dependências**
```bash
npm install
```

3. **Configure o Supabase**
   - Crie um projeto no [Supabase](https://supabase.com)
   - Copie a URL e chave anônima do projeto
   - Crie um arquivo `.env` baseado no `env.example`:

```env
VITE_SUPABASE_URL=sua_url_do_supabase
VITE_SUPABASE_ANON_KEY=sua_chave_anonima
```

4. **Configure a Edge Function**
   - No dashboard do Supabase, vá em "Edge Functions"
   - Crie uma nova função chamada `migrate`
   - Cole o código do arquivo `supabase/functions/migrate/index.ts`
   - Configure a variável de ambiente `SUPABASE_SERVICE_ROLE_KEY` no dashboard

5. **Execute a migração**
   - Inicie o projeto: `npm run dev`
   - Acesse `/admin` e clique em "Aplicar/Verificar Estrutura"

## 🚀 Como Rodar

```bash
# Desenvolvimento
npm run dev

# Build para produção
npm run build

# Preview da build
npm run preview

# Testes
npm run test
npm run test:e2e
```

## 📁 Estrutura do Projeto

```
src/
├── app/                 # Bootstrap, router, providers
├── entities/           # Modelos de domínio + validadores
├── features/           # Casos de uso (auth, veiculos, etc.)
├── pages/              # Telas compostas
├── services/           # Supabase client, repositories
└── shared/             # UI atoms, utils, hooks
```

## 🔧 Configuração do Banco

O sistema usa uma Edge Function para migração segura. A função:

- Executa SQL idempotente (`CREATE TABLE IF NOT EXISTS`)
- Cria todas as tabelas necessárias
- Configura índices e constraints
- Aplica políticas RLS básicas
- Pode ser executada múltiplas vezes sem problemas

## 📊 Modelo de Dados

### Tabelas Principais:
- `veiculos`: Frota de veículos
- `ordens_servico`: Ordens de manutenção
- `pecas`: Estoque de peças
- `pecas_usadas`: Histórico de uso de peças
- `oficinas_externas`: Oficinas terceirizadas
- `servicos_externos`: Serviços externos
- `supervisores`: Usuários responsáveis

## 🔐 Segurança

- Autenticação via Supabase Auth
- Row Level Security (RLS) habilitado
- Service Role usado apenas na Edge Function
- Validação de dados com Zod

## 🧪 Testes

```bash
# Testes unitários
npm run test

# Testes E2E
npm run test:e2e

# Interface do Cypress
npm run test:ui
```

## 📝 Licença

Este projeto é privado e de uso interno da empresa.

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request
