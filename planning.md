# InvestLink — Planejamento de Funcionalidades

> Gerado em: 2026-03-15
> Baseado em: análise completa de backend, frontend, data science pipeline e CI/CD

---

## Estado Atual

| Camada | Status |
|---|---|
| Backend | Funcional — CRUD completo para Stocks, FIIs, Users, Favorites, Portfolio, Predictions |
| Frontend | Funcional — 10 páginas, sem página de detalhe de FII, sem painel admin |
| DS Pipeline | Sprints 1–3 prontos (scraping, feature engineering, treinamento, predições de ações) |
| CI/CD | Build + push GHCR funcionando; sem deploy automático, sem gate de testes no root |

---

## Prioridade 1 — Bugs e Dívida Técnica (fazer antes de novas features)

### B1 · Token JWT sem refresh
**Problema:** JWT expira em 3h sem renovação. Usuário é deslogado no meio do uso.
**Solução:**
- Backend: adicionar endpoint `POST /v1/auth/refresh` com `@jwt_required(refresh=True)`
- Frontend: interceptor no `api.service.js` para chamar refresh automaticamente no 401

### B2 · Sem validação de unicidade de e-mail
**Problema:** `new_user` valida apenas username. Dois usuários podem ter o mesmo e-mail.
**Solução:** adicionar `User.query.filter_by(email=email).first()` em `user_services.py`

### B3 · Schemas Marshmallow não usados
**Problema:** `AddPositionSchema`, `NewUserSchema` existem mas são bypassados nos services.
**Solução:** Escolher uma abordagem — ou usar os schemas em todos os endpoints, ou removê-los. Evitar duplicação de validação.

### B4 · Rota `delete_user_layout` inexistente
**Problema:** `delete_user_layout()` está implementada no service mas sem rota registrada.
**Solução:** adicionar `DELETE /v1/user_layout/<layout>` em `utils.py`

### B5 · `score_current_stocks.py` vs `predictor.py` (sobreposição)
**Problema:** Dois módulos escrevem na mesma tabela `stock_predictions` com metodologias diferentes.
**Solução:** Documentar claramente quando usar cada um, ou unificar em um único ponto de entrada via `pipeline.py`

### B6 · Root CI sem gate de testes
**Problema:** `docker-release.yml` builda e publica imagens sem rodar lint/test.
**Solução:** Adicionar job de teste que chama o CI dos submodules (ou roda testes inline) antes do build

---

## Prioridade 2 — Features Faltando (completar o produto atual)

### F1 · Página de Detalhe do FII
**Escopo:**
- Nova rota `/fii/:ticker` no frontend
- Componente `FiiDetalhe.js` espelhando `AcaoDetalhe.js`
- Cards: indicadores principais (DY, P/VP, vacância, liquidez), favorito com teto/alvo, histórico
- Link a partir de `ListaFiis.js` na linha da tabela

### F2 · Painel Admin
**Escopo:**
- Nova rota `/admin` (somente `profile === 'ADMIN'`)
- Cards de ação: "Atualizar Ações", "Atualizar FIIs", "Rodar Pipeline ML"
- Listagem de usuários com opção de deletar/promover
- Trigger do `update-stocks` / `update-fiis` via UI (já existe no backend)

### F3 · Troca de Senha
**Escopo:**
- Backend: `PUT /v1/user/<id>/password` — valida senha atual, aceita nova, re-hash
- Frontend: modal ou página de perfil com campos "senha atual / nova / confirmar"

### F4 · Portfolio com FIIs
**Escopo:**
- Backend: novo model `PortfolioFii` (user_id, fii_ticker, quantity, average_price)
- Serviços e rotas sob `/v1/portfolio/fii`
- Frontend: tab ou seção separada em `Portfolio.js`

### F5 · Paginação nos endpoints sem paginação
**Problema:** Endpoints de favorites, portfolio, predictions retornam todos os registros.
**Solução:** Padronizar `page` + `per_page` em todos os endpoints de listagem

### F6 · Predições para FIIs
**Escopo:**
- DS Pipeline: adaptação do `score_current_stocks.py` para FIIs (indicadores: DY, P/VP, vacância)
- Backend: endpoint `GET /v1/fiis/<ticker>/prediction`
- Frontend: exibir label ML em `ListaFiis.js` e `FiiDetalhe.js`

---

## Prioridade 3 — Melhorias de Qualidade

### Q1 · Rate Limiting nos endpoints de Auth
Usar `flask-limiter`: `5/minute` em `/v1/user/login` e `/v1/users` (registro)

### Q2 · Swagger atualizado
`static/swagger.json` não documenta portfolio nem predictions.
Migrar para `flask-smorest` ou `flasgger` com geração automática a partir dos schemas.

### Q3 · Testes de integração
Atualmente só há testes unitários (SQLite in-memory + mocks).
Adicionar testes de integração com banco PostgreSQL real (via `pytest-docker` ou `testcontainers`).

### Q4 · TypeScript no Frontend
Migração gradual: começar pelos `services/` e `columns/` que têm contratos mais estáveis.

### Q5 · Extração de componentes grandes
- `Portfolio.js` (390 linhas) → extrair `PositionTable`, `PortfolioSummaryCards`
- `AcaoDetalhe.js` (366 linhas) → extrair `MLPredictionCard`, `FundamentalIndicatorsCard`

### Q6 · Tratamento de Tickers Deslistados
`update_all_stocks` não remove tickers que sumam do StatusInvest.
Solução: marcar `active = False` ou comparar a lista retornada e deletar ausentes.

---

## Prioridade 4 — Novas Funcionalidades (produto futuro)

### N1 · Alertas de Preço por E-mail / Push
O backend já calcula alertas (`GET /v1/favorites/alerts`).
Falta: job periódico (Celery ou cron) + envio de e-mail (Flask-Mail / SendGrid)

### N2 · Histórico de Portfólio
Snapshot diário do valor total da carteira → gráfico de evolução em `Portfolio.js`

### N3 · Comparador de Ativos
Página `/comparar?tickers=PETR4,VALE3` — tabela lado a lado dos fundamentos

### N4 · Módulo de Análise (DS Pipeline)
`analysis/` está vazio. Candidatos:
- Backtesting simples: testar se label BARATA realmente superou Ibovespa
- Análise de setor: comparativo setorial de scores
- Feature importance: quais indicadores mais influenciam o modelo

### N5 · Sprint 4 DS — NLP / Análise de Notícias
`weekly-predictions.yml` já tem placeholder para `torch/transformers`.
Escopo: scraping de headlines de notícias financeiras + sentiment score integrado ao composite_score

### N6 · Deploy Automático
`docker-release.yml` só publica imagens; não faz deploy.
Adicionar step de deploy para um ambiente (VPS com `docker compose pull && up -d`, ou Render/Fly.io)

### N7 · Testes E2E
Playwright cobrindo fluxos críticos: login → ver lista → favoritar → ver portfolio → logout

---

## Resumo por Sprint Sugerido

| Sprint | Foco | Issues |
|---|---|---|
| **Sprint A** | Dívida técnica crítica | B1 (refresh JWT), B2 (email único), B4 (rota layout), B6 (CI gate) |
| **Sprint B** | Completar produto | F1 (FII detalhe), F2 (Admin), F3 (troca senha) |
| **Sprint C** | Portfolio e predições completas | F4 (portfolio FII), F5 (paginação), F6 (predições FII) |
| **Sprint D** | Qualidade | Q1 (rate limit), Q2 (swagger), Q3 (integration tests), Q5 (refactor) |
| **Sprint E** | Novas features | N1 (alertas email), N2 (histórico portfolio), N3 (comparador) |
| **Sprint F** | DS avançado + infra | N4 (análise), N5 (NLP), N6 (deploy auto), N7 (E2E) |

---

## Decisões de Arquitetura Pendentes

1. **Validação no backend:** Marshmallow schemas ou validação inline? Escolher um padrão e aplicar em todos os endpoints.
2. **Predições de FII:** Pipeline ML completo (como ações) ou apenas heurística de scores (como `score_current_stocks.py`)?
3. **Jobs assíncronos:** Usar Celery + Redis para alertas e atualizações, ou manter cron jobs simples no docker-compose?
4. **TypeScript:** Migração incremental (por módulo) ou manter JS e adicionar JSDoc?
