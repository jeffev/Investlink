# InvestLink

Monorepo com 3 submodulos Git independentes (cada pasta tem seu próprio repositório).

## Estrutura
```
Investlink/
  backend/     → Flask 3.0.3 + SQLAlchemy + PostgreSQL  (repo próprio)
  frontend/    → React 18 + Material-UI 5              (repo próprio)
  data_science_pipeline/  → vazio por enquanto          (repo próprio)
  docker-compose.yml      → orquestra os três serviços
  .github/workflows/docker-release.yml  → build + push imagens GHCR
```

## Commits
Cada submodulo tem seu próprio commit. Nunca faça `git add backend/` no root — entre na pasta e commite lá.

```bash
# Backend
cd /d/Investlink/backend && git add <files> && git commit -m "mensagem"

# Frontend
cd /d/Investlink/frontend && git add <files> && git commit -m "mensagem"

# Root (só para docker-compose, .github/, .gitignore, .env.example)
cd /d/Investlink && git add <files> && git commit -m "mensagem"
```

## CI/CD
- `docker-release.yml` roda apenas em push para `main`, usa `GITHUB_TOKEN` nativo
- CIs dos submodulos rodam nos próprios repositórios (backend/.github/, frontend/.github/)
- Verificar status: `gh run list --limit 5`

## Subagentes disponíveis
Delegue para os agentes em `.claude/agents/` quando a tarefa for específica:
- `backend-tester` → rodar/corrigir testes
- `backend-developer` → serviços, rotas, models
- `frontend-developer` → React, páginas, serviços JS
- `ci-engineer` → workflows, Dockerfiles, docker-compose

## Variáveis de ambiente
Não existe `.env` commitado. Referência em `.env.example`.
Senha do banco: configurada no docker-compose.yml (desenvolvimento local).
