# InvestLink

Plataforma de análise de investimentos brasileiros — ações do IBXX e Fundos de Investimento Imobiliário (FIIs).

## Estrutura do Repositório

Monorepo com 3 submódulos Git independentes:

```
Investlink/
├── backend/               → API Flask 3.0 + PostgreSQL
├── frontend/              → React 18 + Material-UI 5
├── data_science_pipeline/ → pipeline de dados (em desenvolvimento)
├── docker-compose.yml     → orquestração dos serviços
└── .github/workflows/     → CI/CD (Docker Release)
```

## Funcionalidades

### Ações (IBXX)
- Listagem com indicadores: Fórmula de Graham e Fórmula Mágica
- Filtro em todos os campos da tabela
- Adição a lista de favoritas com preço teto e preço alvo
- Cores dinâmicas indicando oportunidade de compra/venda

### FIIs
- Listagem com indicadores fundamentalistas
- Filtro em todos os campos da tabela
- Adição a lista de favoritos com preço teto e preço alvo
- Cores dinâmicas indicando oportunidade de compra/venda

### Usuários
- Autenticação JWT (token expira em 3h)
- Perfis: `USER` e `ADMIN`
- Salvamento de layout de tabelas por usuário e por página

## Execução com Docker

### Pré-requisitos
- Docker e Docker Compose instalados

### Variáveis de ambiente

Crie um arquivo `.env` na raiz com base no `.env.example`:

```env
POSTGRES_PASSWORD=sua_senha
JWT_SECRET_KEY=sua_chave_secreta
REACT_APP_API_URL=http://localhost:5000/v1/
```

### Subir o projeto

```bash
docker compose up --build
```

| Serviço    | URL                           |
|------------|-------------------------------|
| Frontend   | http://localhost:3000         |
| Backend    | http://localhost:5000         |
| Swagger    | http://localhost:5000/swagger |
| PostgreSQL | localhost:5433                |

### Usuário padrão

Na primeira execução, um usuário administrador é criado automaticamente:

| Campo  | Valor |
|--------|-------|
| Login  | admin |
| Senha  | admin |
| Perfil | ADMIN |

## Desenvolvimento

Cada submódulo tem seu próprio repositório e pipeline de CI. Para commitar, entre na pasta do submódulo:

```bash
# Backend
cd backend && git add <arquivos> && git commit -m "mensagem"

# Frontend
cd frontend && git add <arquivos> && git commit -m "mensagem"

# Root (docker-compose, .github, .env.example)
git add <arquivos> && git commit -m "mensagem"
```

## Stack

| Camada   | Tecnologia                               |
|----------|------------------------------------------|
| Frontend | React 18, Material-UI 5, Axios           |
| Backend  | Flask 3.0.3, SQLAlchemy 2.0, Flask-JWT   |
| Banco    | PostgreSQL 13                            |
| Infra    | Docker Compose, Nginx, GitHub Actions    |

## Contato

Jefferson Valandro — [jeffev123@gmail.com](mailto:jeffev123@gmail.com)
