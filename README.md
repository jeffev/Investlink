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

Em produção (`FLASK_ENV=production`) esse default não existe: sem `ADMIN_PASSWORD`
definido o backend não sobe, para não criar um administrador com senha pública.

## Deploy automático

Push em `main` → testes → imagens no GHCR (tag `latest` e a do commit) → deploy no servidor.

O job de deploy só roda quando a variável de repositório `DEPLOY_ENABLED` vale `true`.
Enquanto ela não existir, o workflow termina depois de publicar as imagens, como antes.

### Preparar o servidor (uma vez)

1. Docker e o plugin Compose instalados.
2. Criar o diretório do deploy e, **dentro dele**, o `.env` com os segredos — o CI
   envia só o `docker-compose.prod.yml`, nunca credenciais:

```bash
mkdir -p /opt/investlink && cd /opt/investlink
cat > .env <<'EOF'
GHCR_OWNER=jeffev
POSTGRES_PASSWORD=...
JWT_SECRET_KEY=...
ADMIN_PASSWORD=...
NEWS_API_KEY=...
EOF
chmod 600 .env
```

3. Gerar uma chave SSH dedicada (`ssh-keygen -t ed25519 -f deploy_key`): a pública vai
   para o `authorized_keys` do servidor, a privada vira o secret `DEPLOY_SSH_KEY`.
4. Se os pacotes no GHCR forem privados: rodar `docker login ghcr.io` uma vez no
   servidor **ou** configurar o secret `GHCR_READ_TOKEN` (PAT com `read:packages`).

### Segredos e variáveis do repositório

| Nome | Tipo | Obrigatório | O que é |
|------|------|-------------|---------|
| `DEPLOY_ENABLED` | variable | sim | `true` liga o job de deploy |
| `DEPLOY_PATH` | variable | sim | diretório no servidor (ex.: `/opt/investlink`) |
| `DEPLOY_SSH_PORT` | variable | não | porta SSH (default `22`) |
| `REACT_APP_API_URL` | variable | sim | URL da API, compilada no bundle do frontend |
| `DEPLOY_HOST` | secret | sim | host ou IP do servidor |
| `DEPLOY_USER` | secret | sim | usuário SSH |
| `DEPLOY_SSH_KEY` | secret | sim | chave privada do deploy |
| `DEPLOY_KNOWN_HOSTS` | secret | sim | saída de `ssh-keyscan -H <host>` |
| `GHCR_READ_TOKEN` | secret | não | PAT `read:packages`, se os pacotes forem privados |

`DEPLOY_KNOWN_HOSTS` é exigido de propósito: sem fixar a chave do host, o runner
aceitaria qualquer servidor que respondesse naquele endereço.

### O que acontece a cada deploy

1. `scp` do `docker-compose.prod.yml` para `DEPLOY_PATH`.
2. `docker compose pull` e `up -d` com `IMAGE_TAG` igual ao SHA do commit — não
   `latest`, porque `latest` não diz qual versão está no ar nem dá para onde voltar.
3. O entrypoint do backend aplica as migrações e só então sobe o gunicorn.
4. O deploy espera `backend` e `frontend` ficarem `healthy` (até ~3 minutos).
5. Se não ficarem: imprime os logs do backend, volta para a tag anterior
   (registrada em `.deployed_tag`) e falha o job.

Rollback manual, do servidor:

```bash
cd /opt/investlink
IMAGE_TAG=<sha-anterior> docker compose -f docker-compose.prod.yml up -d
```

**O rollback devolve o código, não o schema**: migração já aplicada continua
aplicada. Migração destrutiva exige intervenção manual.

### Limites conhecidos

- `flask-limiter` guarda os contadores em `memory://`; com 3 workers de gunicorn o
  limite passa a valer por worker. Para valer no processo inteiro, precisa de Redis.
- O compose de produção não termina TLS — o esperado é um proxy (nginx, Caddy ou
  Traefik) na frente, e aí `backend` deve publicar em `127.0.0.1:5000` em vez de `5000`.

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
