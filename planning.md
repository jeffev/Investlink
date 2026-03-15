# InvestLink — Planejamento de Funcionalidades

> Atualizado em: 2026-03-15
> Baseado em: análise completa de backend, frontend, data science pipeline e CI/CD

---

## Estado Atual (pós Sprint C)

| Camada | Status |
|---|---|
| Backend | 165 testes · JWT refresh · owner validation · paginação · índices DB |
| Frontend | 102 testes · 11 páginas · paginação favoritas · painel admin · troca de senha |
| DS Pipeline | Sprints 1–3 prontos (scraping, feature engineering, treinamento, predições de ações) |
| CI/CD | test-backend + test-frontend obrigatórios antes do build · coverage ≥ 80% |

---

## ✅ Sprint A — Dívida Técnica Crítica (concluído)

| Item | Descrição |
|---|---|
| ✅ B1 | JWT refresh: `POST /v1/auth/refresh` + interceptor automático no frontend |
| ✅ B2 | Validação de unicidade de e-mail em `new_user` |
| ✅ B4 | Rota `DELETE /v1/user_layout/<layout>` registrada |
| ✅ B6 | CI: job `test-backend` obrigatório antes do build Docker |

---

## ✅ Sprint B — Completar o Produto (concluído)

| Item | Descrição |
|---|---|
| ✅ F1 | Página de detalhe do FII (`/fii/:ticker`) — 5 grupos de indicadores |
| ✅ F2 | Painel Admin (`/admin`) — manutenção e gestão de usuários |
| ✅ F3 | Troca de senha — `PUT /v1/user/<id>/password` + página Perfil |

---

## ✅ Sprint C — Segurança, Performance e Qualidade (concluído)

| Item | Descrição |
|---|---|
| ✅ C1 | Owner validation: view/edit/delete de favorites retorna 403 se não for do usuário |
| ✅ C2 | Whitelist em `edit_user`: bloqueia alteração de `profile` por não-admin |
| ✅ C3 | Migration de índices: `users.email`, `users.user_name`, `favorites.user_id` |
| ✅ C4 | Paginação em favorites e favorites_fii (backend + frontend) |
| ✅ C5 | CI: job `test-frontend` obrigatório antes do build Docker |
| ✅ C6 | CI: `--cov-fail-under=80` no backend |
| ✅ C7 | `Perfil.js`: padronizado com `FeedbackSnackbar` |
| ✅ C8 | Validação de força de senha (≥8 chars, 1 maiúscula, 1 número) |
| ✅ C9 | `user_layout_service`: corrigido 400→404 em layout não encontrado |

---

## Sprint D — Portfolio Completo + Predições FII

### D1 · Portfolio com FIIs
- Backend: model `PortfolioFii` (user_id, fii_ticker, quantity, average_price)
- Serviços e rotas sob `/v1/portfolio/fii`
- Frontend: tab separada em `Portfolio.js`

### D2 · Paginação em portfolio e predictions
- `list_portfolio` e `list_predictions` retornam todos os registros sem paginação
- Padronizar `?page=&per_page=` como já feito em favorites

### D3 · Predições para FIIs
- DS Pipeline: adaptação do pipeline para FIIs (indicadores: DY, P/VP, cota CAGR)
- Backend: endpoint `GET /v1/fiis/<ticker>/prediction`
- Frontend: label ML em `ListaFiis.js` e `FiiDetalhe.js`

---

## Sprint E — Qualidade e Robustez

### E1 · Rate Limiting nos endpoints de Auth
`flask-limiter`: `5/minute` em `/v1/user/login` e `/v1/users` (registro)

### E2 · Schemas Marshmallow em uso real
`AddPositionSchema`, `NewUserSchema` existem mas validação é inline.
Escolher um padrão e aplicar em todos os endpoints — eliminar duplicação.

### E3 · Testes de integração
Atualmente só há testes unitários (SQLite in-memory + mocks).
Adicionar testes de integração com PostgreSQL real via `testcontainers`.

### E4 · Extração de componentes grandes
- `Portfolio.js` (390 linhas) → extrair `PositionTable`, `PortfolioSummaryCards`
- `AcaoDetalhe.js` (366 linhas) → verificar se ainda está grande

### E5 · Swagger atualizado
`static/swagger.json` não documenta portfolio, predictions, auth/refresh nem password.
Migrar para `flask-smorest` ou `flasgger` com geração automática.

### E6 · Tratamento de tickers deslistados
`update_all_stocks` não remove tickers que somem do StatusInvest.
Solução: comparar lista retornada e marcar `active = False` nos ausentes.

---

## Sprint F — Novas Funcionalidades

### F4 · Alertas de Preço por E-mail
Backend já calcula alertas (`GET /v1/favorites/alerts`).
Falta: job periódico (Celery ou cron) + envio de e-mail (Flask-Mail / SendGrid)

### F5 · Histórico de Portfólio
Snapshot diário do valor total → gráfico de evolução em `Portfolio.js`

### F6 · Comparador de Ativos
Página `/comparar?tickers=PETR4,VALE3` — tabela lado a lado dos fundamentos

### F7 · Deploy Automático
`docker-release.yml` só publica imagens; não faz deploy.
Adicionar step para VPS (`docker compose pull && up -d`) ou Render/Fly.io

### F8 · Testes E2E
Playwright cobrindo: login → listar → favoritar → ver portfolio → logout

---

## Sprint G — DS Pipeline Avançado

### G1 · Módulo de Análise (DS Pipeline)
`analysis/` está vazio. Candidatos:
- Backtesting: testar se label BARATA realmente superou Ibovespa
- Análise setorial: comparativo de scores por setor
- Feature importance: quais indicadores mais influenciam o modelo

### G2 · NLP / Análise de Notícias
`weekly-predictions.yml` tem placeholder para `torch/transformers`.
Escopo: scraping de headlines financeiras + sentiment score integrado ao composite_score

---

## Decisões de Arquitetura Pendentes

1. **Validação no backend:** Marshmallow schemas ou validação inline? Escolher um padrão (Sprint E2).
2. **Predições de FII:** Pipeline ML completo (como ações) ou heurística de scores?
3. **Jobs assíncronos:** Celery + Redis para alertas/atualizações, ou cron jobs no docker-compose?
4. **TypeScript:** Migração incremental por módulo, ou manter JS com JSDoc?
