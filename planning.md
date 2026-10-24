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

### ✅ D1 · Portfolio com FIIs (já estava feito)
- Backend: model `PortfolioFii` (user_id, fii_ticker, quantity, average_price)
- Serviços e rotas sob `/v1/portfolio/fii`
- Frontend: tab separada em `Portfolio.js`

### ✅ D2 · Paginação em portfolio e predictions (concluído em 10/09/2026)
- `list_portfolio` e `list_predictions` retornam todos os registros sem paginação
- Padronizar `?page=&per_page=` como já feito em favorites

### D3 · Predições para FIIs
- DS Pipeline: adaptação do pipeline para FIIs (indicadores: DY, P/VP, cota CAGR)
- Backend: endpoint `GET /v1/fiis/<ticker>/prediction`
- Frontend: label ML em `ListaFiis.js` e `FiiDetalhe.js`

---

## Sprint E — Qualidade e Robustez

### ✅ E1 · Rate Limiting nos endpoints de Auth (já estava commitado)
`flask-limiter`: `5/minute` em `/v1/user/login` e `/v1/users` (registro)

### ✅ E2 · Schemas Marshmallow em uso real (concluído em 24/09/2026)
Padrão: `schemas.load_payload(Schema())` na rota. Registro no fim do arquivo.

### ✅ E3 · Testes de integração (concluído em 24/09/2026)
`tests/integration/` com Postgres descartável via `testcontainers`.
Registro no fim do arquivo.

### ✅ E4 · Extração de componentes grandes (concluído em 10/09/2026)
- `Portfolio.js` (390 linhas) → extrair `PositionTable`, `PortfolioSummaryCards`
- `AcaoDetalhe.js` (366 linhas) → verificar se ainda está grande

### ✅ E5 · Swagger atualizado (concluído em 10/09/2026)
`static/swagger.json` não documenta portfolio, predictions, auth/refresh nem password.
Migrar para `flask-smorest` ou `flasgger` com geração automática.

### ✅ E6 · Tratamento de tickers deslistados (concluído em 10/09/2026)
`update_all_stocks` não remove tickers que somem do StatusInvest.
Solução: comparar lista retornada e marcar `active = False` nos ausentes.

---

## Sprint F — Novas Funcionalidades

### F4 · Alertas de Preço por E-mail
Backend já calcula alertas (`GET /v1/favorites/alerts`).
Falta: job periódico (Celery ou cron) + envio de e-mail (Flask-Mail / SendGrid)

### F5 · Histórico de Portfólio
Snapshot diário do valor total → gráfico de evolução em `Portfolio.js`

### ✅ F6 · Comparador de Ativos (já estava commitado)
Página `/comparar?tickers=PETR4,VALE3` — tabela lado a lado dos fundamentos

### ✅ F7 · Deploy Automático (concluído em 18/09/2026)
Job `deploy` no `docker-release.yml`, desligado até `DEPLOY_ENABLED=true`.
Registro no fim do arquivo.

### ✅ F8 · Testes E2E (concluído em 18/09/2026)
Playwright cobrindo: login → listar → favoritar → ver portfolio → logout

---

## Sprint G — DS Pipeline Avançado

### ✅ G1 · Módulo de Análise (já estava commitado)
`analysis/` está vazio. Candidatos:
- Backtesting: testar se label BARATA realmente superou Ibovespa
- Análise setorial: comparativo de scores por setor
- Feature importance: quais indicadores mais influenciam o modelo

### ✅ G2 · NLP / Análise de Notícias (já estava commitado)
`weekly-predictions.yml` tem placeholder para `torch/transformers`.
Escopo: scraping de headlines financeiras + sentiment score integrado ao composite_score

---

## Decisões de Arquitetura Pendentes

1. **Validação no backend:** Marshmallow schemas ou validação inline? Escolher um padrão (Sprint E2).
2. **Predições de FII:** Pipeline ML completo (como ações) ou heurística de scores?
3. **Jobs assíncronos:** Celery + Redis para alertas/atualizações, ou cron jobs no docker-compose?
4. **TypeScript:** Migração incremental por módulo, ou manter JS com JSDoc?

---

# Roteiro "Encontrar Oportunidades" — 2026-09-05

> Decisões tomadas: público em **duas camadas** (cards para iniciante, tabela para avançado);
> CVM como **fonte primária** de fundamento, substituindo o scraper Selenium; escopo inclui
> **score próprio de FII**.

## Diagnóstico

O motor de scoring já existe (`feature_engineer.py`: value 30 / quality 35 / growth 20 /
dividend 15, com percentil **intra-setor+ano**, winsorização 1/99 e mediana setorial para nulos).
O que falta é (a) fundamento confiável e atual, (b) dimensão de risco no score, (c) produto em
cima do motor. A tabela de ~35 colunas não é uma porta de entrada usável.

Três problemas estruturais na abordagem "peso alto no Graham":
1. Graham Number contém LPA e VPA — somá-lo a P/L e ROE é contar a mesma informação 3 vezes.
2. Graham quebra em bancos (VPA alavancado), cíclicas no pico do lucro, empresas leves em ativo
   e empresas com prejuízo.
3. Nada no score mede risco de balanço nem liquidez — é o que produz *value trap*.

---

## Sprint H — Fundamento oficial via CVM (substitui o scraper)

### ✅ H0 · Correção rápida (concluído em 05/09/2026)
`backend/app/models/stock.py` — `get_graham_formula` devolve `0.0` para LPA negativo, e
`get_discount_to_graham` cai no `else` e também devolve `0.0`. Empresa com prejuízo fica
indistinguível de empresa no preço justo. Ambos devem devolver `None`, e o frontend
(`stockColumns.js`) deve renderizar "—".

### ✅ H1 · Ingestão CVM (concluído em 05/09/2026)
- Novo `data_science_pipeline/data_sources/cvm_client.py`
- Origem: `dados.cvm.gov.br/dados/CIA_ABERTA/DOC/DFP/DADOS/` e `.../ITR/DADOS/`
  (ZIPs anuais com BPA, BPP, DRE, DFC_MI) + `CAD/DADOS/cad_cia_aberta.csv`
- Nova tabela `cvm_financials`: `ticker, cd_cvm, period_end, period_type (ANUAL|TRIM),
  receita, lucro_liquido, ebit, ebitda, patrimonio_liquido, ativo_total, ativo_circulante,
  passivo_circulante, divida_bruta, caixa, acoes_circulacao`

> ⚠️ **Risco principal da migração:** a CVM identifica por `CD_CVM`/CNPJ, não por ticker.
> O mapa `CD_CVM → ticker` é a parte não-trivial. Ponte candidata: `Stock.companyid`
> (já vem do StatusInvest) ou a listagem da B3 em `sistemaswebb3-listados`. Resolver H1
> antes de tocar em qualquer outra coisa do sprint.

### ✅ H2 · Derivação LTM (concluído em 05/09/2026)
- Novo `data_science_pipeline/data_processing/ltm.py`
- Fluxo (receita, lucro, EBIT): soma dos 4 trimestres móveis. Estoque (PL, dívida, caixa):
  último ponto disponível.
- Deriva: `lpa_ltm, vpa, roe_ltm, roic_ltm, m_liquida_ltm, div_liq_ebitda, liq_corrente`

> ⚠️ **Armadilha conhecida:** a DRE dos ITRs vem **acumulada no ano** (o 3T é jan–set, não
> jul–set). É obrigatório diferenciar trimestres antes de somar, senão todo lucro LTM sai
> inflado. Teste unitário dedicado para isso.

### ✅ H3 · StatusInvest reduzido (concluído em 18/09/2026)
`get_all_stocks_from_statusinvest` (`backend/app/services/stock_services.py:235`) permanece,
mas só para **preço, valor de mercado, setor/subsetor/segmento e liquidez**.
`web_scraping/scraper_indicators.py` (Selenium) é aposentado — é hoje a peça mais frágil do
projeto.

### ✅ H4 · Reconciliação (concluído em 18/09/2026)
Job que compara LPA/VPA/ROE da CVM contra o StatusInvest por ticker; divergência > 10% vira log.
Rede de segurança durante a transição — manter por 2 ciclos antes de desligar H3 de vez.

---

## Sprint I — Score fundamentalista explicável (ações)

### ✅ I1 · Cinco pilares (concluído em 09/09/2026) (`data_processing/scoring.py`)
Mantém o percentil **intra-setor+ano** que já existe no `feature_engineer.py`.

| Pilar | Peso | Composição |
|---|---|---|
| Valuation | 30% | metade percentil setorial (EV/EBIT, P/L, P/VP) + metade **desvio do próprio histórico de 5 anos** |
| Qualidade | 25% | **ROIC** (não ROE — ROE infla com alavancagem), margem líquida, consistência de lucro |
| Saúde financeira | 15% | Dív.Líq/EBITDA, liquidez corrente, cobertura de juros |
| Crescimento | 15% | CAGR receita + CAGR lucro winsorizados; bônus por **consistência**, não por magnitude |
| Dividendos | 15% | DY penalizado se payout > 100% ou se veio de provento extraordinário |

**Graham vira selo binário**, não peso: chip "abaixo do Graham Number" exibido só onde é válido
(lucro positivo, VPA positivo, não-financeira).

### ✅ I2 · Guard rails (concluído em 09/09/2026) (`data_processing/eligibility.py`)
Eliminação **antes** do score, não penalização dentro dele:
liquidez mediana > R$ 1 mi/dia · lucro positivo em ≥3 dos últimos 5 anos · PL positivo ·
Dív.Líq/EBITDA < 3,5. O motivo da exclusão é persistido para poder ser exibido.

### ✅ I3 · Contexto histórico (concluído em 05/09/2026)
Mediana e percentil de 5 anos **do próprio ticker** para P/L, P/VP, EV/EBIT e DY, a partir de
`stock_indicators_history` (já povoado desde 2008). Produz a frase que o usuário quer ver:
*"P/L 8,2 — 35% abaixo da mediana de 5 anos da própria empresa (12,6)"*.

### ✅ I4 · Red flags nomeados (concluído em 09/09/2026)
Dívida alta · payout > 100% · lucro caindo 3 anos seguidos · DY inflado por extraordinário ·
liquidez baixa · margem em queda. É o diferencial da tela de oportunidades.

### ✅ I5 · Tabela `stock_scores` (concluído em 09/09/2026)
`ticker, run_date, profile, score_total, score_valuation, score_qualidade, score_saude,
score_crescimento, score_dividendos, reasons (json), red_flags (json), eligible, exclusion_reason`

### ✅ I6 · Endpoints (concluído em 09/09/2026)
`GET /v1/opportunities?profile=&asset_type=` · `GET /v1/stocks/<ticker>/score`

---

## Sprint J — Score próprio de FII

### ✅ J1 · Pilares de FII (concluído em 24/09/2026 — em `backend/app/services/fii_scoring_service.py`)
Graham/ROE/CAGR de lucro não se aplicam. Todos os campos já existem no model `Fii`:

| Pilar | Peso | Composição |
|---|---|---|
| Valuation | 30% | `p_vp` vs. **histórico do próprio fundo** e vs. o segmento |
| Renda | 30% | `dy` sustentável, `dividend_cagr`, consistência do `lastdividend` |
| Liquidez | 20% | `liquidezmediadiaria`, `numerocotistas` |
| Estrutura | 20% | `percentualcaixa`, `gestao_f`, `patrimonio`, `cota_cagr` |

### ✅ J2 · Nova tabela `fii_indicators_history` (concluído em 24/09/2026)
Não existe histórico de FII hoje — sem ela, J1 fica sem a metade "vs. próprio histórico".

> ⚠️ Não usar `adj_close` do yfinance para DY de FII: subestima proventos em ativos `.SA`
> (erro > 4 p.p. ao ano medido). Usar provento declarado do StatusInvest.

### ✅ J3 · `GET /v1/opportunities?asset_type=FII` (concluído em 24/09/2026)

---

## Sprint K — UX em duas camadas

### ✅ K1 · Página `/oportunidades` (concluído em 05/09/2026)
10–15 **cards**, não tabela. Cada card: ticker · score · **3 bullets "por que está aqui"** ·
**1–2 bullets "o que pode dar errado"**. Vira a home autenticada; rota nova em `Rotas.js`.

### ✅ K2 · `<ScoreChip>` com popover de decomposição (concluído em 05/09/2026)
Componente único reaproveitado em `ListaAcoes`, `ListaFiis`, `Favoritas`, `AcaoDetalhe` e
`Comparar`. Score sem explicação ninguém confia.

### ✅ K3 · Seletor de perfil (concluído em 09/09/2026)
Dividendos · Valor · Qualidade a Preço Justo · Crescimento. Cada perfil = conjunto de pesos +
guard rails. O usuário escolhe o perfil, nunca os pesos. Persistido via `user_layout`.

### ✅ K4 · Contexto histórico em `AcaoDetalhe.js` (concluído em 09/09/2026)
Sparkline de P/L de 5 anos com faixa de mediana destacada (consome I3).

### ✅ K5 · Camada avançada preservada (concluído em 10/09/2026)
Coluna de score + filtro por perfil na tabela existente; nada é removido de `ListaAcoes.js`.

### ✅ K6 · Backtest do score na tela (concluído em 18/09/2026)
Reaproveita `backtest_service`. *"Top decil deste score: X% a.a. vs. IBOV Y%"*.

> ⚠️ **Obrigatório exibir a ressalva:** a tabela `stocks` só contém tickers vivos, então há
> **viés de sobrevivência** e o número sai otimista. Sem esse aviso o backtest é enganoso.

---

## Ordem sugerida

`H0` (minutos) → `H1` (destrava tudo) → `I3 + K1 + K2` (~80% do ganho percebido, não dependem
do resto de H) → `H2/H3/H4` → `I1/I2/I4/I5/I6` → `K3/K4/K5` → `J*` → `K6`

## Decisões de arquitetura resolvidas nesta rodada

| Antes | Agora |
|---|---|
| Predições de FII: ML completo ou heurística? | **Heurística de scores** (Sprint J) — o histórico de FII não sustenta ML |
| Fonte de fundamento | **CVM primária**, StatusInvest só para preço/setor/liquidez |

---

## Registro da entrega de 05/09/2026 — H0, I3, K1, K2

**Estado:** backend 223 testes verdes (`flake8` limpo, `black` sem pendências),
frontend 124 testes verdes, `npm run build` OK.

### H0 — o bug do Graham e dois primos dele
- `backend/app/models/stock.py`: `get_graham_formula` e `get_discount_to_graham` devolvem
  `None` quando a fórmula não se aplica (LPA ou VPA negativo, dado ausente, preço nulo).
- **Regressão que o `None` criava e foi tratada junto:** o Postgres ordena `NULLS FIRST` em
  `DESC`, então ordenar por um indicador abriria a lista numa página de "—".
  `_apply_filters_and_sort` passou a usar `nulls_last()` — em `stock_services.py` **e**
  `fii_services.py`, que têm cópias idênticas dessa função.
- **Dois bugs de sinal encontrados no caminho:** `discount_to_graham` é positivo quando a
  ação está **cara** (preço acima do valor de Graham), mas `Comparar.js` marcava
  `better: "max"` (destacava a mais cara como melhor) e o `colorBySign` do `AcaoDetalhe.js`
  pintava de verde valor positivo. Corrigidos — o `colorBySign` ganhou a flag
  `positiveIsGood`, porque Bazin e Gordon usam a convenção oposta no mesmo card.
- `stockColumns.js` renderiza "—" nas duas colunas de Graham.

> ⚠️ **Inconsistência deixada de propósito:** `discount_to_graham` continua com o sinal
> invertido em relação a Bazin/Gordon. Padronizar quebraria silenciosamente toda estratégia
> salva pelo usuário (`strategies.filters` guarda faixas numéricas em JSON). Se for
> padronizar, precisa de migração dos filtros salvos.

### I3 — contexto histórico
Implementado **no backend**, não no DS pipeline como o plano previa: os dados já estão em
`stock_indicators_history`, no mesmo Postgres, e a UI precisa disso por HTTP de qualquer forma.
Evita uma tabela nova e um estágio de pipeline.
- `models/stock_indicator_history.py` — espelha a tabela do DS pipeline (colunas completas,
  porque o backend roda `db.create_all()` no startup).
- `services/historical_context_service.py` — mediana, mín/máx, desvio, percentil e veredito
  por indicador (P/L, P/VP, EV/EBIT, DY), comparando a empresa **com ela mesma**.
  Exclui o ano corrente (ainda aberto) e exige `MIN_YEARS = 3` anos fechados.
- `GET /v1/stock/<ticker>/historical-context?years=5`

### K1 — página `/oportunidades`
12 cards com "POR QUE ESTÁ AQUI" e "O QUE PODE DAR ERRADO". Registrada em `Rotas.js` e no menu.
Ativo sem nenhum argumento a favor é **omitido** — card com score e sem motivo é pior que
nenhum card.

> ⚠️ **Dívida assumida:** os motivos e alertas são derivados **no frontend**
> (`src/utils/opportunityInsights.js`), porque `stock_scores.reasons` / `red_flags` só
> existem a partir do Sprint I5. O módulo está isolado para que a migração seja uma exclusão,
> não uma caça. Os limiares (dívida/EBIT 3,5 · liquidez corrente 1,0 · DY 15% · queda 50%)
> estão nomeados no topo do arquivo.

### K2 — `<ScoreChip>`
Chip clicável com popover de decomposição, usado em `stockColumns.js` (logo, `ListaAcoes` e
`Favoritas`), `AcaoDetalhe.js` e nos cards de `/oportunidades`. Já aceita a prop `pillars`,
que os 5 pilares do Sprint I1 preenchem sem tocar no componente.

### Achados fora do escopo, corrigidos para destravar a verificação
Não vieram desta entrega — já estavam no working tree ou no HEAD:
- Migração `requests` → `cloudscraper` inacabada: 6 testes ainda faziam patch em
  `services.*.requests`. Repontados para `cloudscraper.create_scraper`.
- `test_update_all_fiis_no_data` não conhecia a nova fonte `get_all_fiis_from_fundamentus`.
- `Home.test.js` estava **vermelho no HEAD**: o mock de `portfolio.service` não tinha
  `getProjectedIncome` nem `getBenchmarks`. Isso derrubava o job `test-frontend` do CI.

### Pendências que ficaram visíveis
- `_apply_filters_and_sort` está duplicado byte a byte entre `stock_services.py` e
  `fii_services.py` — extrair para um módulo compartilhado (`backtest_service.py` importa a
  versão de `stock_services`).
- `test_update_all_fiis_success` e `..._with_exception` só mocam o StatusInvest; a fonte
  Fundamentus é chamada de verdade. Teste dependente de rede.

---

## Registro do H1 — ingestão CVM (05/09/2026)

**Estado:** 76 testes verdes no DS pipeline (nenhum toca a rede). Validado ponta a ponta contra
dados reais: Petrobras FY2024 sai com receita R$ 490,8 bi, lucro R$ 37,0 bi, PL R$ 367,5 bi e
dívida líquida R$ 326,8 bi — todos batendo com o divulgado.

### O bloqueio foi resolvido — e não era onde o plano dizia

O plano apontava `Stock.companyid` ou o CNPJ como ponte candidata. **Medi as duas e as duas
falham.** O join por CNPJ contra `cad_cia_aberta.csv` casa só **17%** das listagens da B3 e,
pior, produz match **errado**: ITUB4 casa com um registro `CANCELADA` de CD_CVM diferente.

A ponte que funciona é a B3: `GetInitialCompanies` devolve `codeCVM` **junto** com o radical do
ticker (`issuingCompany`). Esse valor foi conferido contra os arquivos DFP para PETR, VALE,
ITUB, BBAS, WEGE, MGLU, TAEE e EGIE — 8/8.

### Dois erros meus, achados medindo

1. **Radical do ticker não é "4 letras".** `B3SA3` — a própria B3 — tem dígito no radical.
   A regra passou a ser 4 caracteres alfanuméricos.
2. **Ler só o consolidado (`_con_`) descarta um terço do mercado.** 242 das 709 companhias que
   entregaram em 2024 publicam **apenas** o individual — bancos e holdings em peso: Assaí,
   Banco ABC, Bradespar, Banco da Amazônia. Isso apareceu como "a B3 está dando código errado"
   quando era escopo que eu nunca pedi. O cliente agora lê os dois e prefere o consolidado.

### Cobertura medida contra o universo real do InvestLink

| Universo | Com demonstração da CVM |
|---|---|
| 617 tickers do StatusInvest | 489 (79,3%) |
| **274 tickers com liquidez > R$ 100 mil/dia** | **262 (95,6%)** |

Os 123 não resolvidos são quase todos cascas deslistadas (BIDI, BFRE, BLUT, BRGE) que os guard
rails do I2 excluiriam de qualquer forma. Entre os líquidos, os 10 que faltam foram
incorporados ou fecharam capital (AESB, CRFB, SOMA3, SULA11, NTCO3) — é o item **E6**
(tickers deslistados) aparecendo de novo, não uma falha da ponte.

### ⚠️ Correção da armadilha que eu mesmo registrei

O aviso anterior dizia que era "obrigatório diferenciar trimestres antes de somar". **Está
errado, e seguir isso complicaria o H2 à toa.** O ITR traz as **duas** linhas: a acumulada
(2025-01-01 → 2025-09-30) *e* a do trimestre isolado (2025-07-01 → 2025-09-30). A do Q1 já é
um trimestre sozinho.

Então a solução é **seleção, não subtração**: ficar com as linhas de `period_months == 3`.
Conferido na Petrobras 2025 — os três trimestres isolados somam 370,2 bi contra 370,2 bi do
acumulado declarado.

**A exceção é o Q4**, que nenhum ITR cobre: tem de sair do DFP anual menos o acumulado de nove
meses. Isso é do H2.

`period_months` é derivado das datas, não do mês de abertura da janela: 18 companhias abertas
fecham exercício fora do calendário e qualquer regra do tipo "começa em janeiro" as rotula
errado.

### O que ficou no repositório

| Arquivo | Papel |
|---|---|
| `data_sources/ticker_cvm_map.py` | ponte radical do ticker → CD_CVM, via B3 |
| `data_sources/cvm_client.py` | download, normalização e derivação de dívida líquida |
| `data_sources/run_cvm_ingestion.py` | CLI: `--map`, `--years`, `--from-year`, `--dry-run` |
| `database/models.py` | tabelas `ticker_cvm_map` e `cvm_financials` |
| `database/queries.py` | `save_ticker_cvm_map`, `save_cvm_financials`, `get_cvm_quarters` |
| `tests/test_ticker_cvm_map.py`, `tests/test_cvm_client.py` | 34 testes offline |

Chave de conflito de `cvm_financials`: `(cd_cvm, period_end, period_months, doc_type)` — o
`period_months` está lá para que a linha acumulada de nove meses nunca sobrescreva o trimestre
isolado que termina na mesma data. Upsert com update, não do-nothing: empresas refazem
demonstrações e a versão corrigida é a que interessa.

### ⚠️ Ainda não rodado contra o banco
Toda a validação foi via `--dry-run` e leitura direta da CVM. **O `docker compose` não foi
subido nesta sessão**, então `python database/migrations.py` e uma ingestão real ainda
precisam ser executados antes de considerar o H1 encerrado em produção.

### Próximo passo natural (H2)
`data_processing/ltm.py`: somar os `period_months == 3` das últimas quatro janelas, derivar o
Q4 por diferença, e produzir `lpa_ltm`, `roe_ltm`, `roic_ltm`, `div_liq_ebitda`. Falta ainda
a quantidade de ações — está em `dfp_cia_aberta_composicao_capital_<ano>.csv`, que **não tem
CD_CVM**, só CNPJ; o join ali terá de ser por CNPJ.

---

## Registro do H2 — LTM (05/09/2026)

**Estado:** 109 testes verdes no DS pipeline (nenhum toca a rede), 223 no backend.
`654 empresas` fecham doze meses completos. Conferido contra realidade: Petrobras LPA R$ 8,58
(declarado 8,54), Itaú ROE 20,5%, WEG ROE 31% / ROIC 40% / caixa líquido, Assaí LPA R$ 0,72.

### ⚠️ O bug mais grave da sessão: o plano de contas de banco

Casar conta por **código** produz número catastrófico, porque bancos e seguradoras entregam um
plano de contas diferente que **reaproveita os mesmos códigos para linhas completamente
distintas**:

| Código | Empresa comum | Banco (Itaú) |
|---|---|---|
| `3.05` | EBIT | Resultado Antes dos Tributos |
| `3.11` | Lucro/Prejuízo do Período | Reversão dos Juros sobre Capital Próprio |
| `1.01` | Ativo Circulante | Caixa e Equivalentes |
| `2.03` | **Patrimônio Líquido** | **Passivos Financeiros ao Custo Amortizado** |

O último é o assassino: ler `2.03` como patrimônio dava ao Itaú um PL de **R$ 2,35 trilhões** e
um VPA de **R$ 213.204 por ação**. Não é perder o setor financeiro — é encher o screener de
número fictício, justamente no setor de maior peso do Ibovespa.

**A correção foi trocar todo o mapeamento de código para descrição** (`_assign_fields`). Onde
não há correspondência, o campo fica **nulo — que é a resposta certa**: banco não tem EBIT,
liquidez corrente nem dívida líquida, porque o balanço dele não separa circulante de não
circulante nem resultado operacional de financeiro.

### Outros quatro erros encontrados medindo

1. **`3.99.01.01` não é sempre "ON".** A subconta de LPA é posicional: Petrobras põe ON ali, a
   Vale põe PNA (zerado) e o ON em `.02`. Agora pega a classe preenchida.
2. **LPA não pode ser escalado pelo `ESCALA_MOEDA`.** É valor por ação; escalar virava R$ 8.540.
3. **`composicao_capital` não tem coluna de unidade** e as empresas divergem: Petrobras informa
   12.888.732.761 ações (unidades), Vale informa 4.255.763 (milhares). Não dá para adivinhar por
   magnitude — a escala é **calibrada contra o LPA que a própria empresa publica**
   (`lucro / lpa_declarado` = número de ações que o balanço implica). 300 arquivos por rodada
   precisam de reescala.
4. **"Lucro ou Prejuízo" ≠ "Lucro/Prejuízo".** O Banco do Brasil entrega três linhas começando
   por "Lucro ou Prejuízo" (3.07, 3.09, 3.11); só a que diz "do Período" é o resultado.
5. **LPA e ROE usam o lucro dos controladores**, não o consolidado com minoritários — na Vale a
   diferença é 17% do lucro.

### ⚠️ Segunda correção da armadilha do acumulado

O H1 concluiu que bastava selecionar `period_months == 3`. **Isso vale para a DRE, mas não para
a DFC.** O fluxo de caixa é entregue **somente acumulado** — não existe DFC de trimestre
isolado — então a depreciação trimestral precisa mesmo ser **diferenciada** dos acumulados
consecutivos (`build_quarterly_depreciation`). Casar pela janela exata da DRE só encontrava D&A
no Q1 e no exercício fechado, e o EBITDA saía nulo para todo mundo.

### Regras de recusa (o que o módulo se nega a fazer)

- **Menos de quatro trimestres → nenhum LTM.** Um P/L calculado sobre nove meses de lucro parece
  barato e está errado.
- **Um trimestre sem o campo → o total fica nulo**, não menor.
- **Janela fora de 330–400 dias → descartada** (buraco na série).
- **Denominador negativo ou zero → nulo.** PL negativo não é P/VP baixo; prejuízo não é EV/EBIT
  barato. Precisam ler como desconhecido, não como atrativo.
- **EBITDA sem linha de depreciação → nulo**, nunca igual ao EBIT — senão toda empresa intensiva
  em ativo aparece menos alavancada do que é.

### Cobertura dos indicadores (654 empresas)

| Indicador | Cobertura | | Indicador | Cobertura |
|---|---|---|---|---|
| `vpa` / `lpa_ltm` | 97% | | `ebitda_ltm` | 81% |
| `liq_corrente` | 95% | | `div_liq_ebitda` | 71% |
| `m_liquida_ltm` | 93% | | `graham_formula` | 57% |
| `roe_ltm` | 89% | | `roic_ltm` | 88% |

`graham_formula` a 57% é esperado: exige lucro e patrimônio positivos.

### O que ficou no repositório

| Arquivo | Papel |
|---|---|
| `data_processing/ltm.py` | trimestres isolados, Q4 derivado, LTM e indicadores |
| `data_sources/cvm_client.py` | mapeamento por descrição, D&A, ações e calibração de escala |
| `database/models.py` | tabela `cvm_fundamentals_ltm` (1 linha por empresa) |
| `database/queries.py` | `save_cvm_fundamentals_ltm` |
| `tests/test_ltm.py` | 26 testes |
| `tests/test_cvm_client.py` | +7 testes cobrindo o layout de banco |

Rodar: `python data_sources/run_cvm_ingestion.py --ltm`

### ⚠️ Continua sem rodar contra o banco
Como no H1, tudo foi validado por `--dry-run` e leitura direta da CVM. `python
database/migrations.py` e uma gravação real ainda não foram executados.

### Próximo passo (H3)
Ligar o `cvm_fundamentals_ltm` ao backend: o join vai por `ticker_cvm_map` (radical do ticker),
e o `stock_services.update_all_stocks` passa a preferir o valor da CVM ao do StatusInvest para
LPA, VPA, ROE, ROIC, margens e dívida — mantendo o StatusInvest para preço, setor e liquidez.

---

## Registro do H3 — CVM ligada ao backend (09/09/2026)

**Estado:** 240 testes no backend, 124 no frontend, 109 no DS pipeline. `flake8` limpo, build OK.
E, pela primeira vez, **rodado de verdade contra o banco**.

### O banco saiu do papel

`docker compose up -d db` reanimou o container parado havia três meses (volume intacto, 617 ações).
A partir daí:

| Tabela | Linhas |
|---|---|
| `ticker_cvm_map` | 3.522 |
| `cvm_financials` | 14.650 |
| `cvm_fundamentals_ltm` | **743 empresas** |
| `stocks` com fonte CVM | **488 de 618** |

### ⚠️ Dois bugs que só apareceram no banco real

1. **`database/migrations.py` do DS pipeline nunca funcionou.** Declarava FK para `stocks`, tabela
   que pertence ao backend e não está no metadata dele — `create_all` abortava com
   `NoReferencedTableError` antes de criar qualquer coisa. Corrigido com uma declaração de
   referência e uma lista explícita `pipeline_tables()`, para que o pipeline nunca crie nem
   derrube tabela que não é dele.
2. **`CardinalityViolation` na ingestão.** O Postgres aborta o `INSERT ... ON CONFLICT` inteiro
   quando o próprio lote traz duas linhas com a mesma chave. Acontece de verdade: uma
   securitizadora entrega o mesmo exercício com duas datas de início diferentes, e o
   `read_share_counts` deixava passar linhas duplicadas quando havia empate de `VERSAO`.
   Um único arquivo malformado derrubava o ano inteiro. Agora o writer deduplica antes de
   inserir — garantir a própria constraint é responsabilidade dele, não do upstream.

### O que o H3 entregou

| Arquivo | Papel |
|---|---|
| `app/models/cvm_fundamentals_ltm.py` | espelhos read-only de `ticker_cvm_map` e `cvm_fundamentals_ltm` |
| `app/services/cvm_fundamentals_service.py` | resolve ticker → CD_CVM → fundamento e aplica |
| `migrations/versions/d4e5f6a7b8c9_*` | colunas `fundamentals_source` e `fundamentals_date` em `stocks` |
| `stock_services.update_all_stocks` | chama `enrich_with_cvm` **antes** dos ranks |
| `stockColumns.js` | coluna "Fonte do Fundamento" com chip CVM · 12m |

**Regras de segurança do override:**
- Nulo da CVM **nunca** sobrescreve valor existente — nulo ali é "não se aplica" (banco não tem
  EBIT nem liquidez corrente), não "zero".
- **P/L e P/VP são recalculados** a partir do preço e do novo LPA/VPA. Deixar o P/L do
  StatusInvest ao lado de um LPA de doze meses mostraria 4,90 numa linha cujo próprio preço e
  LPA dão 3,95.
- A CVM entra **antes** do cálculo de `ey_rank` e `roic_rank` — a Fórmula Mágica passa a rankear
  sobre o dado auditado.
- Falha na CVM **não derruba o refresh**: o snapshot do StatusInvest é entregue mesmo assim.
- Preço, valor de mercado, setor, DY e liquidez continuam vindo do StatusInvest — são dado de
  mercado, não contábil.

### Efeito medido (banco real)

| ticker | LPA StatusInvest | LPA CVM LTM | P/L antes | P/L depois |
|---|---|---|---|---|
| PETR4 | 8,35 | **10,35** | 4,90 | 4,67 |
| VALE3 | 3,51 | **2,55** | 22,39 | 30,96 |
| MGLU3 | 0,18 | **0,11** | 30,90 | 49,60 |
| ASAI3 | 0,52 | **0,72** | 16,67 | 11,96 |

Não é ajuste cosmético: a Magalu sai de P/L 31 para 50 e o Assaí de 17 para 12. O exercício
fechado estava escondendo o que os últimos doze meses já mostram.

### Dois rótulos errados corrigidos no caminho
A coluna `dividaliquidaebit` estava intitulada "Dívida líquida/**EBITDA**" na tabela e no
glossário. Sempre esteve errada, mas passou a importar: agora o número é mesmo dívida sobre
**EBIT**, e o rótulo errado subestimaria a alavancagem pela depreciação inteira.

### E6 confirmado na prática
`TRAD3` está no banco mas sumiu do StatusInvest — 618 linhas em `stocks` contra 617 no payload.
Ficou com `fundamentals_source` nulo, delatando-se. É exatamente o item **E6** (tickers
deslistados) que `update_all_stocks` nunca tratou.

### Próximo passo
Com fundamento auditado em 488 ações, o **Sprint I** (score de 5 pilares) tem base para rodar.
O gargalo restante do produto é outro: `stock_predictions` está **vazia**, então a
`/oportunidades` mostra "nenhuma oportunidade" — ela ranqueia por previsão de ML que nunca
rodou. O I1 resolve isso ao dar à página um score determinístico que não depende do pipeline
de ML.

---

## Registro do Sprint I — score de 5 pilares (09/09/2026)

**Estado:** 286 testes no backend, 110 no frontend, 109 no DS pipeline. `flake8` limpo,
`black` aplicado, build OK. Rodado contra o banco real: **618 tickers pontuados, 128 elegíveis,
5 perfis, 3.090 linhas**.

### A `/oportunidades` deixou de estar vazia

O K1 entregou a página ranqueando por previsão de ML — e `stock_predictions` **nunca foi
populada**, então a tela mostrava "nenhuma oportunidade". O score agora é **determinístico e
calculado no backend, dentro do `update_all_stocks`**, e não em pipeline separado.

> **Desvio deliberado do plano.** O plano punha o score em
> `data_processing/scoring.py` (DS pipeline). Foi para o backend porque todos os insumos já
> estão em `stocks` depois do H3, o universo tem 618 linhas, e — decisivo — *depender de um
> pipeline separado é exatamente o que deixou a página vazia*.

### Dois campos que estavam sendo jogados fora

`liquidezmediadiaria` e `lucros_cagr5` **vêm em todo payload do StatusInvest** e não tinham
coluna no model — eram descartados a cada refresh. A liquidez é justamente o guard rail que
separa oportunidade de papel que o investidor não consegue vender.

### Guard rails: 490 de 618 excluídas

| Motivo | Empresas |
|---|---|
| Liquidez diária < R$ 1 mi | 404 |
| Patrimônio líquido negativo | 80 |
| Lucro positivo em < 3 dos últimos 5 exercícios | 75 |
| Dívida líquida > 3,5× EBIT | ~200 |

Exclusão é registrada, não escondida: a empresa fica em `stock_scores` com `eligible=false` e
o motivo, para que `GET /v1/stock/<ticker>/score` responda **"por que PETR4 não está na
lista?"** — pergunta que um screener que simplesmente oculta o ativo não consegue responder.

### Duas incoerências que só apareceram olhando a lista real

1. **O DY implausível era premiado pelo próprio pilar que o alerta desmente.** A VULC3 tinha
   DY de 34,4% marcado como "dificilmente se repete" e mesmo assim pontuava como se fosse
   quatro vezes melhor que um DY sólido de 8%. Agora o DY é **limitado ao teto de
   plausibilidade para efeito de score** — um provento extraordinário ranqueia junto com os
   melhores sustentáveis, nunca acima deles.
2. **Duas classes da mesma empresa ocupavam dois cards.** POMO3 e POMO4 pontuam quase igual;
   uma vitrine de 12 mostrava 11 ideias. A listagem agora mantém só a classe mais bem
   pontuada.

### Motivo agora é `{code, message}`, não string

O motivo de alavancagem embutia o valor e fragmentava em **70+ strings distintas** —
inagregável, infiltrável, intraduzível. Cada motivo e alerta carrega um código estável ao lado
do texto, que continua embutindo os números da própria empresa (é o que o torna digno de
leitura).

### Decisões de projeto do score

- **Percentil dentro do setor.** P/L 12 é barato em elétrica e caro em software; ranquear no
  mercado inteiro produz uma lista de elétricas e bancos e chama isso de descoberta. Setor com
  menos de 5 pares cai num balde "MERCADO".
- **Indicador ausente sai do ranking**, não entra como pior. E `0.0` conta como ausente — é
  assim que o StatusInvest reporta o que não tem.
- **Pilar sem dado é `None`, não zero**, e o peso é **renormalizado**: zerar saúde financeira
  expulsaria todo banco da lista por um fato contábil.
- **Perfis são conjuntos de peso, não fórmulas diferentes.** Os percentis são calculados uma
  vez; o perfil só muda a ponderação. O usuário escolhe perfil, nunca peso.

### O que ficou no repositório

| Arquivo | Papel |
|---|---|
| `app/services/scoring_service.py` | guard rails, percentis setoriais, pilares, motivos, alertas |
| `app/services/opportunity_service.py` | vitrine ranqueada, dedupe de classe, perfis |
| `app/models/stock_score.py` | `stock_scores`, com elegibilidade e motivos |
| `migrations/versions/e5f6a7b8c9d0_*` | `liquidezmediadiaria`, `lucros_cagr5`, `stock_scores` |
| `src/pages/Oportunidades.js` | reescrita sobre o score do backend, com abas de perfil |
| `src/utils/opportunityInsights.js` | **excluído** — a lógica migrou para o backend |

Endpoints: `GET /v1/opportunities?profile=&limit=` · `GET /v1/opportunities/profiles` ·
`GET /v1/stock/<ticker>/score?profile=`

### ⚠️ Observação para decisão do produto
A **RIAA3** aparece no topo do perfil DIVIDENDOS com o alerta "empresa com prejuízo". Não é
bug: o guard rail de consistência olha o **histórico** (ela teve ≥3 exercícios lucrativos) e o
alerta olha o **agora** (LTM negativo). Transformar prejuízo corrente em desqualificação é
julgamento de produto, não de engenharia — hoje ela entra na lista com o alerta bem visível.

### Ainda em aberto
- **I3 está implementado mas sem dado**: `stock_indicators_history` está vazia, então o
  contexto histórico ("P/L 35% abaixo da mediana de 5 anos") responde vazio. Preencher a partir
  de `cvm_financials` exige preço histórico, que também está vazio (`stock_prices_history`).
- **K4** (sparkline de P/L no detalhe) e **K6** (backtest do score, com o aviso de viés de
  sobrevivência) continuam abertos.
- O **Sprint J** (score de FII) não começou — `fiis` está vazia no banco.

---

## Registro — histórico de preços e múltiplos (09/09/2026)

**Estado:** 141 testes no DS pipeline, 286 no backend, 118 no frontend. `flake8` limpo em tudo
que é meu, build OK.

### A cadeia é de dois elos, não um

O I3 lê `stock_indicators_history` (P/L, P/VP, EV/EBIT, DY **por ano**), não
`stock_prices_history`. O preço é o insumo que faltava para **derivar** aquilo — ninguém publica
a série: um provedor mostra o P/L de hoje, e a CVM publica lucro sem preço. O múltiplo de 2022
só existe quando se põe o balanço de 2022 ao lado do preço de 2022.

| Passo | Módulo | O que destrava |
|---|---|---|
| 1. Preço semanal + eventos societários | `data_sources/price_history.py` | **"Queda do Topo"**, que era sempre nula |
| 2. Múltiplos anuais derivados | `data_processing/historical_indicators.py` | **I3** e o painel do **K4** |

### A base de ajuste é onde isso erra em silêncio

O yfinance oferece três séries. `auto_adjust=True` (o default da versão 1.x, que o
`scraper_prices.py` estava usando) reescreve o Close por split **e por provento**. Guardar essa
série estraga os dois usos: a queda do topo seria medida contra um preço que ninguém pagou, e o
P/L histórico dividiria um preço já descontado de dividendo por um lucro que não foi. A
Petrobras mostra o tamanho do buraco: fim de 2019 fechou a **R$ 30,81**, e a série ajustada põe
a mesma semana em **R$ 8,32**.

O que se guarda é o Close com `auto_adjust=False` — ajustado por split, não por provento.

**E o split precisa entrar, nas duas direções.** O preço vem na base de hoje; a contagem de
ações vem do balanço daquele ano. Multiplicar um pelo outro sem o fator acumulado erra o valor
de mercado por exatamente a razão do split. Os grupamentos são o caso extremo e são reais:
GFSA3 acumula três (fator 1:2.427) e CTAX3 chega a 1:10.000.

### Três campos que a ingestão calculava e jogava fora

`acoes_circulacao`, `lucro_controladores` e `depreciacao` já eram computados pelo `cvm_client`
mas não constavam do `RECORD_COLUMNS`. Sem número de ações por ano **não existe múltiplo
histórico**. A `cvm_financials` foi recriada (é dado derivado, reproduzível) e reingerida.

### ⚠️ O bug que mantinha a tabela vazia desde sempre

`stock_prices_history` é **criada pela migração do backend** e **escrita pelo DS pipeline**,
cujo model declara `UNIQUE (ticker, date)` e cujo insert usa `ON CONFLICT` contra isso. A
constraint nunca esteve no `CREATE TABLE`. Todo insert de preço falhava com *"there is no unique
or exclusion constraint matching the ON CONFLICT specification"* — é por isso que a tabela
estava vazia e a "Queda do Topo" era nula. Terceira aparição do mesmo problema de dois donos
para a mesma tabela.

### Outro: um ticker não pode derrubar a corrida inteira

O yfinance devolveu um dividendo como a **string `'3.33 BRL'`** e matou uma carga de 618 tickers
no quinquagésimo quinto. O parser agora extrai o número, e — mais importante — o laço isola cada
ticker. Mesma lição do `CardinalityViolation` da CVM.

> Também deixei registrado um erro meu de método: filtrei a saída da carga com
> `grep -E "INFO|WARNING"` e o traceback, que não casa com nenhum dos dois, foi engolido. A
> corrida "terminou com código 0" e zero linhas.

### Validação contra a realidade

| ticker | ano | P/L | DY% | leitura |
|---|---|---|---|---|
| PETR4 | 2022 | **1,70** | **61,9** | o ano dos dividendos históricos |
| VALE3 | 2021 | 3,14 | 18,6 | super-ciclo do minério, ROE 61,5% |
| WEGE3 | 2020–25 | 27–68 | 0,6–5,1 | prêmio constante, como se espera |
| ITUB4 | todos | 7–16 | 3,7–11,4 | **EV/EBIT nulo** — banco não tem EBIT |

E o I3 finalmente responde a frase prometida na primeira análise:

```
PETR4  P/VP 1.29 — 35% acima da mediana de 5 anos da própria empresa (0.95)  [CARO]
WEGE3  P/L 34.78 —  5% abaixo da mediana de 5 anos da própria empresa (36.43) [EM_LINHA]
ITUB4  Dividend Yield 7.6 — 76% acima da mediana de 5 anos (4.33)  [BARATO]
```

### Bônus: os guard rails do Sprint I passam no pior caso do mercado

| ticker | elegível | motivo |
|---|---|---|
| AMER3 (fraude) | não | lucro inconsistente + alavancagem |
| BHIA3 | não | patrimônio líquido negativo |
| GFSA3, CTAX3, IFCM3 | não | liquidez baixa + lucro inconsistente |

### O que ficou no repositório

| Arquivo | Papel |
|---|---|
| `data_sources/price_history.py` | preço semanal, splits e proventos, com a base de ajuste certa |
| `data_processing/historical_indicators.py` | múltiplos anuais a partir de balanço + preço |
| `data_sources/run_price_history.py` | CLI `--prices --indicators --tickers --dry-run` |
| `migrations/versions/f6a7b8c9d0e1_*` | a constraint única que faltava |
| `src/components/HistoricalContextCard.js` | painel "Contra o próprio histórico" com faixa mín–máx |

### Ainda em aberto
- **2018 e 2019 não têm contagem de ações** na CVM (`composicao_capital` não aparece nesses
  arquivos), então a série começa em 2020 — 6 anos, acima dos 5 que o I3 usa.
- **K6** (backtest do score com aviso de viés de sobrevivência) e o **Sprint J** (FII, com a
  tabela `fiis` ainda vazia) continuam abertos.

---

## Registro — varredura e dívidas fechadas (10/09/2026)

**Estado:** 300 testes no backend, 119 no frontend, 141 no DS pipeline. `flake8` limpo,
`black` aplicado, build OK.

### A varredura corrigiu o próprio `planning.md`

O arquivo listava como pendente o que já estava commitado: **E1, F6, G1 e G2**. E eu tinha
afirmado, de memória, duas coisas erradas na resposta anterior:
- **F5 não estava feito** — o `HistoricoTab` chama `getTransactions`, é lista de transações, não
  evolução do valor da carteira.
- **K6 não estava feito** — o grep casou num arquivo `.pyc`; o `run_backtest` recebe
  `strategy_id`, é backtest de estratégia salva.

### ✅ K5 — o score de 5 pilares chegou na tabela

Era a dívida mais incoerente: a `/oportunidades` ranqueava pelo score novo enquanto a tabela —
a camada do investidor avançado — mostrava o `ml_score` de um pipeline que **nunca rodou**.

- `list_stocks` faz `outerjoin` com `stock_scores` no perfil escolhido, então **ordenar por
  score funciona no servidor**. Oferecer a coluna sem conseguir ordenar por ela seria pior que
  não oferecer.
- Seletor de perfil na barra da tabela, compartilhando a chave de sessão com a
  `/oportunidades` — as duas telas não podem discordar sobre qual perfil está em jogo.
- O `Score ML` virou coluna secundária, oculta por padrão.

### ✅ E5 — Swagger, com um teste que impede a defasagem

Catch-up manual volta a defasar: o arquivo estava **14 rotas atrás**, três delas adicionadas na
mesma semana por mim. Documentei as 14 e escrevi `test_swagger_coverage.py`, que compara o
`url_map` real do app com o `swagger.json` e falha quando:
- uma rota servida não está documentada;
- uma rota documentada não existe mais;
- um método servido não está descrito;
- uma operação está listada sem `summary` (inventário não é documentação).

O teste já encontrou 5 rotas e 3 métodos além dos que eu tinha visto na varredura manual.
Total: **42 caminhos documentados**.

> Detalhe que quase deixou o teste passar pelo motivo errado: o fixture `app` do `conftest` é
> um Flask **sem rotas registradas**. Precisou de um fixture próprio que roda `setup_routes`.

### ✅ E6 — tickers deslistados

`update_all_stocks` só escrevia o que a fonte devolvia, então uma empresa que saiu da bolsa
ficava na tabela com o último preço conhecido para sempre. **Marcado, nunca apagado** — o
usuário pode ter o papel na carteira, e apagar a linha levaria a posição junto.

- Colunas `active` e `delisted_at`.
- O que reaparece é **reativado**, senão o papel ficaria contradizendo o preço fresco ao lado.
- Payload vazio **não deslista ninguém** — é falha de busca, não mercado que fechou.
- A listagem do screener mostra só ativos; `view_stock` e `bulk_view_stocks` continuam
  servindo o deslistado para a carteira não perdê-lo.
- Guard rail novo no score: `DESLISTADA`.

### ✅ D2 — paginação

`list_portfolio`, `list_portfolio_fii` e `get_all_predictions` passaram a paginar no mesmo
envelope de favorites — mesma forma, mesmos parâmetros, para o chamador não ter de aprender
dois formatos. O `portfolio.service.js` desembrulha o envelope, então as páginas continuam
recebendo array.

### Ainda aberto

| Item | Nota |
|---|---|
| **E4** componentes grandes | `AcaoDetalhe.js` em 465 linhas — **eu piorei**, era 424 |
| **F4** alertas por e-mail | Backend calcula, nada envia |
| **F5** evolução do valor da carteira | Só existe a lista de transações |
| **F8** E2E das telas novas | Sem spec para `/oportunidades`, `/comparar`, `/noticias`, `/guias` |
| **K6** backtest do score | Com o aviso obrigatório de viés de sobrevivência |

### ⚠️ Nada commitado
Cinco sessões de trabalho seguem soltas no working tree dos três submódulos.

---

## Registro — E4, extração de componentes (10/09/2026)

**Estado:** 300 testes no backend, 141 no DS pipeline, **136 no frontend** (eram 119),
`eslint` limpo nas fontes, build OK.

### As duas páginas que o item nomeava

| Arquivo | Antes | Depois |
|---|---|---|
| `AcaoDetalhe.js` | **465** (eu tinha piorado de 424) | **181** |
| `Portfolio.js` | 441 | 331 |

O `AcaoDetalhe` tinha 309 linhas de helpers e cards antes da página começar — a página em si
era a menor parte do arquivo.

### O que saiu, e por quê

| Novo módulo | Motivo |
|---|---|
| `utils/formatters.js` | O mesmo `toLocaleString('pt-BR', …)` estava inline em **seis** arquivos |
| `utils/ceilingPrices.js` | Bazin e Gordon: a única conta de valuation que o frontend faz — e estava **sem teste** |
| `utils/mlLabels.js` | A tradução rótulo → cor estava duplicada em `AcaoDetalhe` e `Home` |
| `components/Acao/IndicatorCard.js` | Card + os grupos de indicadores como dado |
| `components/Acao/MLPredictionCard.js` | — |
| `components/Acao/FavoriteTargetsCard.js` | — |
| `columns/portfolioColumns.js` | 115 linhas de coluna dentro de uma página; o projeto já tem `columns/` |

### ⚠️ Uma mudança de comportamento, deliberada

As cópias locais usavam `toFixed(2)`, que produz **ponto** decimal; o `HistoricalContextCard`
usava `toLocaleString('pt-BR')`, que produz **vírgula**. O app mostrava `8.20` numa tela e
`8,20` na outra. A extração unificou em vírgula — correto para pt-BR, mas é mudança visível.

### O que a extração revelou

`utils/portfolioFormatters.js` já existia e suas duas funções eram **cópia byte a byte** do que
agora vive em `formatters.js`. Passou a delegar, mantendo só o `PnlCell`, que é a única parte
ali que não é formatação pura.

### Cobertura nova
17 testes para `formatters` e `ceilingPrices` — incluindo o teto de crescimento de Gordon, que
existe para o denominador não explodir quando o CAGR se aproxima do retorno exigido, e que
nunca tinha sido exercitado.

### Ainda acima de 200 linhas
`Portfolio.js` (331), `ListaAcoes.js` (395), `Home.js` (345) e os `components/Guias/*`. Os
guias são **conteúdo estático** — extrair ali não melhora nada, só espalha texto por mais
arquivos.

---

## Registro — H3 + H4, o Selenium aposentado (18/09/2026)

**Estado:** 317 testes no backend, 141 no DS pipeline. `flake8` limpo no backend; no
`pipeline.py` os achados caíram de 12 para 10 (os que sobraram são de estilo pré-existente).

Feitos juntos de propósito: a reconciliação existe **para** dar confiança de desligar o
scraper. Aposentar uma fonte sem nada olhando a substituta troca um risco conhecido por um
silencioso — se a ingestão da CVM quebrar num setor, o screener continua entregando número, só
que errado.

### ✅ H4 — reconciliação

`GET /v1/stocks/reconciliation` (somente ADMIN) confronta **LPA, VPA e ROE** entre as duas
fontes e lista quem diverge acima de 10%, pior primeiro.

Três decisões que fazem o relatório significar alguma coisa:

- **Compara contra o exercício fechado, não contra o LTM.** O StatusInvest reporta o último
  exercício encerrado; confrontar isso com doze meses móveis acusaria divergência em toda
  empresa que simplesmente teve um trimestre diferente do ano passado. Seria ruído, não erro.
- **Busca o StatusInvest na hora.** A tabela `stocks` já foi sobrescrita pelo valor da CVM no
  H3 anterior — ela deixou de servir de testemunha.
- **Base próxima de zero não é comparada.** Um centavo de arredondamento sobre um LPA de
  R$ 0,01 acusaria 200% de divergência.

E fonte fora do ar devolve **502**, nunca "zero divergências" — o silêncio de um serviço caído
não pode passar por aprovação.

> Divergência **não** significa erro da CVM. As fontes discordam legitimamente quando a empresa
> refez a demonstração, quando uma usa o individual e a outra o consolidado, ou por
> minoritários. O relatório serve para alguém olhar, não para decidir sozinho.

### ✅ H3 — o scraper saiu

| Removido | Por quê |
|---|---|
| `web_scraping/scraper_indicators.py` | Selenium lendo indicador do HTML de terceiro — a peça mais frágil do projeto |
| `web_scraping/scraper_prices.py` | Superado por `price_history.py`, que ainda corrige a base de ajuste |
| `web_scraping/run_scraping.py` | Entry point dos dois |
| `selenium`, `beautifulsoup4`, `webdriver-manager` | O scraper era o **único** usuário dos três |

O pacote `web_scraping/` deixou de existir. **Nada mais no projeto precisa de navegador
instalado** — some também o pré-requisito "Google Chrome" do README.

`pipeline.py` teve o `stage_scrape` trocado por `stage_collect`, que chama os coletores novos.
As flags `--no-headless` e `--force` saíram: a primeira era só do Selenium, e a segunda
controlava um re-scrape de preço que hoje é idempotente pelo upsert.

> Tudo estava versionado: `git checkout` restaura se alguma coisa der errado.

### ⚠️ Não validado contra o banco
O Docker Desktop segue fechado. A reconciliação **nunca rodou contra dado real** — é
exatamente o tipo de coisa que só prova o próprio valor rodando. Subir o banco e chamar
`/v1/stocks/reconciliation` é o primeiro passo da próxima sessão.

### Também corrigido no `planning.md`
**D1 (portfólio com FIIs) estava feito** — model, service, rotas e aba no frontend — e o
arquivo ainda marcava como pendente. Quinta defasagem do tipo, depois de E1, F6, G1 e G2.

---

## Registro — K6, backtest do score (18/09/2026)

**Estado:** 335 testes no backend, 144 no frontend, 141 no DS pipeline. `flake8` limpo, build OK.

`GET /v1/opportunities/backtest?profile=` e um painel recolhido na `/oportunidades`.

### ⚠️ O desenho teve de resolver um problema antes de existir

Um backtest que usa o **score de hoje** sobre preços do passado é **look-ahead** — produziria um
número espetacular e mentiroso, que é exatamente o tipo de falsa confiança que este projeto
existe para evitar.

Cada ano é pontuado com os múltiplos **daquele ano** (`stock_indicators_history`, derivado do
balanço entregue e do preço praticado à época). O score de 2021 não sabe nada de 2022. Isso só
foi possível porque a sessão anterior derivou a série anual — sem ela, o backtest honesto não
teria dado de entrada.

O histórico anual não tem CAGR, então o **pilar de crescimento não existe** na versão histórica;
`weighted_score` renormaliza os pesos sobre o que sobrou. Dizer isso é melhor que fingir um
crescimento que não se sabia na época.

### O comparador não é o Ibovespa — e está escrito na resposta

É a média igualmente ponderada do próprio universo pontuado no ano. Para um score que escolhe
ações, "bateu a ação média?" é mais direto que "bateu um índice ponderado por valor de mercado",
e não exige chamar fonte externa dentro de um endpoint.

### As ressalvas viajam com o número

`caveats` é campo de primeira classe da resposta, e o painel as mostra **acima** da tabela, não
num rodapé:

| Código | O que diz |
|---|---|
| `VIES_SOBREVIVENCIA` | O universo só tem quem existe hoje; quem quebrou está fora dos **dois** lados |
| `COMPARADOR_NAO_E_IBOV` | O comparador é a média do universo |
| `SEM_CUSTOS` | Sem corretagem, imposto ou custo de rebalanceamento |
| `AMOSTRA_CURTA` | A série começa em 2020 — poucos anos para concluir qualquer coisa |

Um backtest lido sem as próprias limitações vira promessa de retorno.

### Recusas embutidas
- Universo com menos de 30 ações no ano → o ano **não entra**: um decil de dez ações é uma
  ação, e isso é sorte, não resultado.
- Retornos **compõem**, não somam: dois anos de 10% dão 21%.
- Ano sem preço nas duas pontas é descartado, não estimado.

### Reaproveitamento
`percentile_ranks`, `compute_pillars` e `weighted_score` vieram do `scoring_service`. O
`compute_pillars` ganhou um parâmetro opcional de métricas em vez de eu duplicar o laço — o
backtest pontua a partir de um conjunto de colunas mais estreito.

### ⚠️ Nunca rodou contra dado real
O Docker Desktop segue fechado. Backtest é o tipo de código em que um erro passa despercebido
em teste mockado e aparece na primeira execução real. Junto com a reconciliação do H4, é o que
a próxima sessão precisa validar.

---

## Registro — F8, testes E2E (18/09/2026)

**Estado:** **71 de 71 specs E2E passando**, 144 testes unitários no frontend, 335 no backend,
141 no DS pipeline.

### ⚠️ A suíte E2E estava vermelha havia quatro meses

`portfolio.cy.js` procurava o botão "adicionar posição". A página passou a dizer **"Adicionar
ação"** no commit `2760fcb` (abas Ações/FIIs, Sprint D1) e o spec, de `e19f19e`, nunca foi
atualizado. **Cinco dos sete testes falhavam** — e ninguém percebeu, porque o Cypress não roda
no CI e falha no Git Bash, então só roda quando alguém lembra.

Bisequei antes de assumir culpa: com a paginação do D2 revertida, as mesmas cinco falhas
continuavam. Era defeito anterior a esta sessão.

### Dois mocks que se engoliam

`**/v1/portfolio**` estava registrado **depois** de `/summary`, e no Cypress o último registrado
ganha. O resumo da carteira recebia a lista de posições, e `/portfolio/fii` não tinha mock
nenhum. Os caminhos específicos foram para depois do wildcard — a mesma pegadinha que o
`frontend/CLAUDE.md` já documentava e que eu só respeitei ao registrar os mocks novos.

### Quatro telas que não tinham nenhuma cobertura

| Spec | Testes | O que protege |
|---|---|---|
| `oportunidades.cy.js` | 13 | Cards com motivo **e** alerta, procedência do fundamento, decomposição do score, troca de perfil, e as ressalvas do backtest aparecendo **antes** dos números |
| `comparar.cy.js` | 5 | URL como estado da comparação (é o que torna o link compartilhável), adicionar e remover ativo |
| `noticias.cy.js` | 4 | Inclui a fonte fora do ar — a NewsAPI exige chave e tem cota, indisponível é o caso comum |
| `guias.cy.js` | 4 | O conteúdo que torna o app usável por iniciante, incluindo a ressalva de que Graham não vale para empresa com prejuízo |

### ✅ Um defeito real encontrado pelo teste

A `/oportunidades` **pedia a vitrine duas vezes** a cada carregamento: uma antes de saber o
perfil e outra quando ele chegava. O `loadOpportunities` agora espera a lista de perfis
resolver — inclusive quando ela **falha**, senão a página ficaria carregando para sempre.

### Nota para quem for rodar
O Cypress falha no Git Bash no Windows 11: rodar em PowerShell, com o dev server no ar.
Um mock do `news_service` precisou nascer com `articles` (não `data`) e campos em camelCase,
espelhando o formato real da NewsAPI.


---

## Registro — F7, deploy automático (18/09/2026)

**Estado:** 338 testes no backend (eram 335), `flake8` limpo, `docker compose -f
docker-compose.prod.yml config` válido. **O que não foi verificado: nada disso rodou
em Docker** — o daemon está desligado nesta máquina. A imagem do backend mudou de
entrypoint e isso só se prova construindo.

### O contêiner servia com o servidor de desenvolvimento do Flask

O `Dockerfile` rodava `python app/app.py`, e a última linha desse arquivo era
`app.run(debug=True)`. Automatizar o deploy disso seria automatizar a publicação de um
**debugger do Werkzeug exposto na internet** — execução remota de código para quem
adivinhar o PIN — servido por um processo single-thread.

Trocado por gunicorn (`wsgi.py` + `docker-entrypoint.sh`). O `python app/app.py` continua
valendo para desenvolvimento local; só o contêiner mudou.

O `wsgi.py` insere `app/` na frente do `sys.path` de propósito: existe um `app/__init__.py`
vazio, e se o pacote fosse encontrado primeiro ele sequestraria o nome `app` e o módulo
`app/app.py` nunca carregaria.

### A senha do admin em produção

`seed_admin` usava `os.environ.get("ADMIN_PASSWORD", "admin")`. Num servidor exposto, esse
default é uma credencial pública de administrador. Agora, com `FLASK_ENV=production`, a
ausência da variável **derruba o boot** em vez de criar o usuário.

### `/health` — a pergunta que o deploy precisa fazer

Não existia. Contêiner de pé não é aplicação respondendo: o caso comum de deploy quebrado é
o processo vivo com o banco fora de alcance, e é por isso que a sonda faz `SELECT 1` e
responde **503** quando o banco não atende. Fica fora do `/v1` (é infraestrutura, não API
pública) e sem autenticação — se exigisse token, o orquestrador leria 401 como "de pé" e
nunca reiniciaria um contêiner quebrado.

### As decisões do deploy

| Decisão | Por quê |
|---|---|
| Desligado por default (`DEPLOY_ENABLED`) | Um merge em `main` não pode mexer num servidor que talvez ainda nem exista |
| Tag = SHA do commit, não `latest` | `latest` não diz qual versão está no ar **nem dá para onde voltar** |
| `docker-compose.prod.yml` separado | O compose de dev **constrói** no servidor; o que é construído no servidor não é o que passou pelos testes |
| Segredos no `.env` **do servidor** | O CI envia só o compose; credencial não trafega no deploy |
| `DEPLOY_KNOWN_HOSTS` obrigatório | `ssh-keyscan` na hora confia em qualquer coisa que responda no endereço |
| Token do GHCR pelo stdin | Como argumento, apareceria em qualquer `ps` rodado no servidor durante o deploy |
| `db` sem `ports` | Em produção o Postgres não precisa estar alcançável de fora |
| `concurrency` sem cancelar | Dois deploys no mesmo servidor disputam a mesma migração; a fila espera |

### Rollback: recupera o código, não o schema

Se `backend` ou `frontend` não ficarem `healthy` em ~3 minutos, o script imprime os logs e
volta para a tag registrada em `.deployed_tag`. **A migração já aplicada continua aplicada** —
está escrito no script e no README, porque é a hora em que alguém acha que reverteu tudo.

### Pendências que o deploy herda

- `flask-limiter` usa `memory://`: com 3 workers de gunicorn, o limite passa a valer por
  worker. Para valer no processo inteiro, precisa de Redis.
- O compose não termina TLS. Com um proxy na frente, o `backend` deve publicar em
  `127.0.0.1:5000`; hoje publica em `5000` porque o `REACT_APP_API_URL` é compilado no bundle
  e o navegador chama a API direto.
- `.gitattributes` novo (raiz e backend): `core.autocrlf=true` nesta máquina entregaria o
  `docker-entrypoint.sh` com CRLF no checkout, e aí o contêiner Linux morre com
  "bad interpreter".


---

## Registro — J1, J2 e J3: o score de FII (24/09/2026)

**Estado:** 392 testes no backend (eram 338), 148 no frontend (eram 144), 157 no pipeline de
dados (eram 141), 78 E2E (eram 71). `flake8` limpo. **O que não foi verificado: nada disso
tocou o Postgres** — o Docker segue desligado. Todas as fontes externas foram exercitadas ao
vivo, o banco não.

### O parser do Fundamentus lia cinco das catorze colunas

A tabela publica FFO Yield, Qtd de imóveis, Cap Rate e Vacância Média, e nada disso estava
sendo lido. Pior: a coluna 6 é **"Valor de Mercado"** e estava sendo gravada como
`patrimonio`. No ABCP11, que negocia a 0,72× o valor patrimonial, isso errava o patrimônio em
28% — exatamente o desconto que se queria medir. O patrimônio agora sai de valor de mercado
÷ P/VP, que é a definição do múltiplo.

Conferência contra a realidade: HGLG11 R$ 7,56 bi, KNRI11 R$ 4,60 bi, XPML11 R$ 7,09 bi.

### Os limiares foram medidos, não escolhidos

Sobre os 570 fundos publicados:

| Medida | Valor | O que decidiu |
|---|---|---|
| Mediana de liquidez | R$ 15,6 mil/dia | A maior parte do mercado listado é intransacionável |
| Fundos ≥ R$ 200 mil/dia | 178 | Virou o guard rail de liquidez |
| Fundos ≥ R$ 1 milhão/dia | 94 | O corte das ações deixaria a vitrine com uma dúzia de nomes |
| Mediana de DY | 8,4% · p90 17,1% · máx **129,9%** | Corte de plausibilidade em 20% |
| p90 de P/VP | 1,16 · máx **59.800** | Acima de 5 é dado quebrado, não oportunidade |

### O que ficou de fora dos pilares, de propósito

- **`percentualcaixa`**: caixa demais é capital parado derrubando o rendimento, caixa de menos
  é fundo sem folga. Não é monotônica, e percentil só sabe ordenar o que é monotônico.
- **`vacancia_media` como métrica**: entre os 289 fundos com imóvel, **145 declaram exatamente
  0,00%**, o que mistura "totalmente ocupado" com "não informado". Ela entra como **alerta**
  quando está alta, onde o zero ambíguo não atrapalha — e só em fundo com imóvel, porque no
  fundo de papel a vacância é zero por não existir imóvel.

### J2 — o "barato para ele mesmo"

Sem histórico, "está barato" só podia significar "mais barato que os vizinhos de segmento", o
que não distingue um fundo descontado de um segmento inteiro fora de moda. O Informe Mensal da
CVM (`dados.cvm.gov.br/dados/FII/DOC/INF_MENSAL/`) publica patrimônio líquido, cotas emitidas,
valor patrimonial da cota e número de cotistas, mês a mês, desde 2016.

**A ponte é o ISIN, não o CNPJ.** O informe não traz ticker, traz `Codigo_ISIN`, e para FII
brasileiro ele é `BR` + quatro caracteres do código de negociação + `CTF`: BRHGLGCTF004 é
HGLG11. Dos 1.399 fundos que entregam informe, 1.116 batem no padrão — o resto é fundo
exclusivo, que de fato não tem ticker. (O CNPJ é o mesmo caminho que falhou nas ações, com
17% de acerto e casamentos errados.)

Validação cruzada, que é o que dá confiança sem banco: o P/VP derivado de CVM + Yahoo bateu
com o publicado pelo Fundamentus em **HGLG11 0,8929 vs 0,89**, **KNRI11 0,9674 vs 0,96**. Duas
cadeias independentes chegando ao mesmo número.

**A armadilha do desdobramento, de novo.** O Yahoo entrega a série já ajustada por split; o
valor patrimonial da cota da CVM é o que valia na data do informe. Sem trazer os dois para a
mesma base, um desdobramento de 1:10 faria o fundo aparecer com P/VP de 0,10 e liderar a
vitrine. Reaproveitado o `cumulative_split_factor` que já resolvia isso nas ações, e coberto
por teste nos dois sentidos (split antes e depois do mês).

A razão `p_vp_vs_historico` (P/VP de hoje ÷ mediana de 36 meses) é **pendurada no objeto em
memória**, sem coluna no banco: ela muda a cada cotação e só serve ao percentil daquela
execução — gravá-la criaria uma segunda verdade para envelhecer sozinha. Mediana e não média,
porque uma emissão de cotas desloca a média e deixa a mediana onde está. Fundo com menos de 12
meses fica de fora: recém-listado não tem "próprio histórico", e puni-lo por isso seria
confundir dado faltando com fundo caro.

### J3 — a mesma rota, um descritor por ativo

`asset_type=FII` troca tabela, pesos e campos do card. Um descritor em vez de duas cópias da
função: a consulta, o recorte e o formato da resposta são idênticos.

- **Perfis próprios**: EQUILIBRADO, RENDA, VALOR. CRESCIMENTO e QUALIDADE não existem para
  fundo, e aceitá-los em silêncio devolveria uma lista pontuada por pesos que não são os
  pedidos — agora responde 400 com os perfis válidos.
- **Sem dedupe de classe**: ON/PN é coisa de ação. ALZR11 e ALZM11 são fundos diferentes e as
  duas vagas são legítimas.
- **Card sem Graham, ROE ou P/L**, que não existem em fundo; no lugar entram P/VP, DY e
  vacância — e o teste garante que os campos de ação não vazem para lá.
- **Backtest escondido na aba de FII**: o histórico anual de fundo ainda não alimenta o
  `score_backtest_service`, e mostrar o card com os números da ação atribuiria ao fundo um
  desempenho que não é dele.

O `OpportunityCard` saiu da página para `components/`: a `Oportunidades.js` já passava das 200
linhas e o card é justamente a parte que muda entre os dois ativos.

### A camada densa recebeu o mesmo número

`GET /v1/fiis` agora faz `outerjoin` com `fii_scores` e aceita `sort_by=score_total`. Join à
esquerda: fundo sem score continua na tabela — sumir com ele esconderia o ativo em vez de
esconder a nota.

### Pendências assumidas

- **Nada rodou contra o Postgres.** `refresh_fii_scores`, a migração `b8c9d0e1f2a3`, a
  `c9d0e1f2a3b4` e a carga do `run_fii_history.py` esperam o banco de pé.
- A tabela de FII não tem o seletor de perfil que a de ações tem; usa o EQUILIBRADO. A vitrine
  tem as três abas.
- `Segmento_Atuacao` da CVM **não** é usado para pontuar: é declaração do administrador e
  diverge do mercado (o MXRF11, fundo de papel, aparece declarado como "Logística"). O
  segmento do score vem do Fundamentus.


---

## Registro — E2, validação de entrada de verdade (24/09/2026)

**Estado:** 429 testes no backend (eram 392), `flake8` limpo. Frontend e pipeline não foram
tocados. **Não rodou contra o Postgres** — o Docker continua desligado.

Os schemas existiam desde o sprint E e **não havia um único `.load()` no backend**. Cada
serviço repetia à mão um pedaço da checagem, com sua própria mensagem, e o que ninguém checava
entrava direto no model. Duas dessas coisas não eram questão de formato.

### 🔴 Escalação de privilégio no cadastro público

`POST /v1/users` não exige token — só limite de taxa. O serviço fazia `User(**user_data)`.
Então **`"profile": "ADMIN"` no corpo do cadastro saía com perfil de administrador**, que é o
mesmo perfil que libera `/v1/stocks/update` e `/v1/stocks/reconciliation`.

Confirmado antes de corrigir: os campos repassados ao model eram
`{'user_name': 'invasor', 'name': 'Invasor', 'email': ..., 'profile': 'ADMIN'}`.

Fechado em dois lugares, de propósito: `NewUserSchema` não declara `profile` (e `unknown =
EXCLUDE` descarta o que vier), e `new_user` passou a construir o `User` **campo a campo** com
`profile=DEFAULT_PROFILE`. O schema protege a rota; a construção explícita protege quem chamar
o serviço direto.

### 🔴 Favorita na conta de outro

`POST /v1/favorites` lia `user_id` do corpo e fazia `Favorite(**favorite_data)`, sem nunca
comparar com quem pediu. Um usuário autenticado criava favorita na conta alheia — e o
`PUT /v1/favorite/{id}` transferia a favorita depois de passar pela checagem de dono.

Agora o dono vem do token, como o portfólio já fazia, e `new_favorite` monta o `Favorite`
campo a campo. `EditFavoriteSchema` só aceita preço-teto e preço-alvo.

### Os schemas estavam errados para edição parcial

Todo campo de `Edit*Schema` tinha `load_default=None`. Como `edit_user` e `edit_favorite`
percorrem o que recebem e fazem `setattr`, ligar isso do jeito que estava **apagaria** o
e-mail de quem só quisesse trocar o nome; num usuário comum, o `profile` nulo ainda derrubaria
o pedido inteiro em "Field 'profile' is not editable". E `edit_position` faz
`position_data.get("quantity", position.quantity)`, onde uma chave nula vence o valor atual e
quebra a comparação seguinte com 500.

Sem `load_default`, só as chaves enviadas entram no dicionário. Foi um teste que pegou isso.

### ⚠️ O schema único de posição teria quebrado a carteira de FII

A carteira de ações manda `ticker`; a de fundos manda `fii_ticker` — no model, no serviço e no
`AddFiiPositionModal.js`. Reaproveitar `AddPositionSchema` nos dois, que foi a primeira versão,
recusaria **todo** pedido de FII com 400.

Pior: o primeiro teste que escrevi passou por acidente, porque afirmava um 400 para quantidade
zero e recebia o 400 do campo faltando. Agora há `AddFiiPositionSchema`, e um teste
parametrizado carrega **os payloads que o frontend manda de verdade** — sete deles, um por
tela — pelos schemas correspondentes. É o teste que teria pego isso na primeira execução.

### O resto

| Antes | Agora |
|---|---|
| Corpo ausente → `dados["user_id"] = ...` → TypeError → **500** | 400 com `{"errors": {"_body": [...]}}` |
| `quantity: "cem"` atravessava e quebrava em `quantity <= 0` → **500** | 400 antes de chegar ao serviço |
| `quantity: "100"` de formulário HTML | Convertido para 100.0 — recusar isso seria rigor sem ganho |
| Campo desconhecido no corpo | Descartado (`unknown = EXCLUDE`) |
| `validation_error_response` em `utils.py`, nunca chamada | Removida; quem devolve esse formato é o `load_payload` |

O 400 de validação está documentado no `swagger.json` com uma definição `ValidationError`, em
onze operações.

### Decisão que tomei e vale registrar

Os serviços **mantiveram** suas checagens de campo obrigatório. A linha do backlog pedia
"eliminar duplicação", e a duplicação que importava — cada rota lendo `request.get_json()` do
seu jeito e cada serviço inventando sua mensagem — acabou. As checagens que sobraram no
serviço são a segunda linha, para quem chamar a função fora de uma requisição HTTP; foi o que
manteve os sete testes de serviço existentes válidos em vez de reescrevê-los para provar o
mesmo em outro lugar.

### Pendências

- O frontend não mostra os erros de campo: em 4xx todas as telas caem num texto genérico
  ("Erro ao criar usuário"). O corpo `{"errors": {...}}` está lá para quando alguém quiser
  exibir campo a campo.
- Não há regra de senha forte em lugar nenhum — nem no schema, nem no serviço. O fixture
  `invalid_user_data` do conftest sugere que deveria haver.


---

## Registro — E3 e a primeira execução real do score de FII (24/09/2026)

**Estado:** 437 testes unitários no backend (eram 429), **29 de integração contra Postgres
13 de verdade**, 157 no pipeline. `flake8` limpo. O Docker voltou a ficar disponível nesta
sessão, então boa parte do que estava marcado como "não verificado" saiu dessa lista.

### O que os testes de integração encontraram no primeiro minuto

1. **O `flask db upgrade` não cria quatro tabelas que o backend consulta.**
   `cvm_financials`, `cvm_fundamentals_ltm`, `ticker_cvm_map` e `stock_indicators_history`
   pertencem ao pipeline. Num servidor novo — exatamente o que o F7 provisiona — o backend
   sobe, o `refresh_scores` consulta o histórico de lucro, leva `UndefinedTable`, o
   `except Exception` engole e devolve **zero ações pontuadas**. Um guard rail entre cinco
   derrubava o score inteiro.
   Duas correções: `get_profitable_years` degrada para "sem histórico" em vez de propagar
   (que é a regra que já valia para empresa sem histórico), e o `deploy_remote.sh` passou a
   rodar a migração do pipeline.

2. **Os dois docstrings que explicavam a lacuna estavam errados.** Diziam que o backend roda
   `db.create_all()` no startup. Ele não roda desde a mudança para o Alembic — e era essa
   crença que deixava as quatro tabelas sem dono no deploy.

3. **`wsgi.py` resolvia `app` para o pacote vazio quando `PYTHONPATH=app` estava setado.**
   Funcionava no contêiner e quebrava na linha de comando. Passou a carregar o módulo pelo
   caminho do arquivo, sem depender da ordem do `sys.path`.

Os testes cobrem o que o SQLite resolve ao contrário ou não resolve: NULLS LAST, `ON CONFLICT`,
a cadeia de migrações inteira, o `downgrade` das duas revisões novas, e a divisão de
propriedade das tabelas — esta última fixada como contrato, para a lacuna do item 1 não voltar
em silêncio.

### E aí o score de FII rodou contra o mercado de verdade — e a lista estava ruim

562 fundos carregados do Fundamentus, 177 elegíveis, 1.686 linhas de score. A `fiis` deixou de
estar vazia pela primeira vez. O topo dos três perfis:

```
URPR11  89.7  P/VP 0.21  DY 20.35%   HCTR11  89.3  P/VP 0.12  DY 25.33%
DEVA11  86.9  P/VP 0.18  DY 22.72%   TGAR11  85.8  P/VP 0.41  DY 21.98%
```

São os fundos de crédito mais descontados da bolsa. O screener não estava achando pechincha:
estava achando aflição. **Todos os meus pilares premiavam a mesma coisa** — P/VP baixo, DY alto
e FFO alto são o perfil de um fundo quebrado tanto quanto o de um fundo barato.

Mais três defeitos apareceram junto:

- Um fundo com **DY de 0,00%** (JGPX11) em quinto no perfil **RENDA**. O pilar de renda saía
  inteiro do FFO yield — apurando caixa e não repassando.
- **71% do universo elegível** estava em dois baldes de segmento que não são segmento:
  "Multicategoria" (72 fundos) e "Outros" (54), com fundo de papel e de tijolo no mesmo saco.
  A promessa de "ranqueado dentro do próprio segmento" não estava sendo cumprida para a maioria.
- O `weighted_score` renormaliza pesos quando um pilar falta. A regra nasceu para o banco que
  não tem EBIT, onde o pilar ausente é fato contábil. Num FII, o pilar de renda ausente é o
  motivo de se comprar o ativo.

### As cinco correções, todas medidas

| Correção | Medida que a sustenta |
|---|---|
| P/VP abaixo de 0,45 **não pontua** valuation | p5 do universo elegível é 0,44; só quatro fundos ficam abaixo de 0,30. Aparar empatava o fundo a 0,18× com o melhor da faixa saudável |
| Par de comparação separa **tijolo de papel** (`qtd_imoveis`) | P/VP de fundo de papel é CRI marcado a mercado; de tijolo é imóvel avaliado |
| Pilar de renda **exige DY** | FFO diz se o dividendo cabe no resultado; sozinho não é renda |
| Sem rendimento declarado → **não ranqueado**, com o motivo | 11 dos 177 elegíveis; a lista fica com 166 |
| Patrimônio por cota encolhendo → **alerta** | Na janela de 32 meses carregada: saudáveis entre -4% e +6%, os de crédito em aflição entre -7% e -13% |

O último é o sinal que o J2 existia para produzir e que só apareceu com o histórico no banco.
É o que separa fundo barato de fundo encolhendo, e vira a frase que mais importa no card:
*"o patrimônio por cota encolheu 12,1% em 32 meses — parte do que o fundo distribui é
devolução do seu próprio capital"*.

**Uma armadilha dentro da armadilha:** a primeira versão desse sinal usava a coluna
`valor_patrimonial_cota` da CVM, que não é ajustada por desdobramento. O ALZR11 aparecia com
**-89,9%** de erosão, que era só um desdobramento 1:10. O valor patrimonial ajustado sai de
`close_price / p_vp`, consistente entre as duas bases por construção — pelo ajustado o ALZR11
é **+0,6%**. Coberto por teste.

Depois das correções, o topo passou a ser fundo de tijolo com rendimento real (BBIG11, KORE11,
GTWR11) e os quatro fundos de crédito em aflição saíram do topo dos perfis EQUILIBRADO e RENDA.

### A última correção: o perfil precisa do pilar que o define

O HCTR11 ainda aparecia em quarto no perfil **VALOR**. Com o valuation sem nota, o
`weighted_score` renormalizava os pesos e o fundo era ranqueado pelos 20% de renda — que
estavam altos justamente porque ele distribui capital. O perfil que existe para achar barato
não pode ranquear pelo que não conseguiu avaliar.

Regra nova: **o pilar de maior peso do perfil é obrigatório**. VALOR exige valuation, RENDA
exige renda, e o EQUILIBRADO — que pesa os dois em 30% — exige os dois, porque nenhum sozinho
descreve o perfil.

E faltava fechar o mesmo buraco por dentro: o fundo perdia a nota pelo P/VP absoluto e a
**recuperava pela comparação com o próprio passado**, que é ainda mais favorável justamente
porque ele está desabando. O `p_vp_vs_historico` passou a sair do `scoring_value`, então quem
decide que um P/VP não é interpretável é um lugar só.

Resultado: nenhum fundo em aflição no topo de nenhum dos três perfis. E perguntando direto
pelo HCTR11 no perfil VALOR, a API responde o que deveria — `score_total: null`,
`eligible: true`, e os três alertas explicando por quê. Não escondido: explicado.

### O que ainda não está bom
- "Multicategoria" e "Outros" continuam sendo 71% do universo; separar tijolo de papel ajudou,
  mas o rótulo do Fundamentus não descreve a estratégia do fundo.
- O histórico mensal foi carregado só para os 177 elegíveis (158 com série de preço no Yahoo),
  não para os 562.
- ~~O fundo não tem nome.~~ **Resolvido no mesmo dia** — ver abaixo.

### Rodou de verdade nesta sessão

`flask db upgrade` no banco de desenvolvimento (estava três revisões atrás), `update_all_fiis`,
`refresh_fii_scores`, `run_fii_history.py --years 3` e a vitrine de FII nos três perfis.


### Verificado por HTTP, com dado real

Backend de pé contra o banco de desenvolvimento, token JWT real:

- `GET /v1/opportunities/profiles?asset_type=FII` → `["EQUILIBRADO", "RENDA", "VALOR"]`
- `GET /v1/opportunities?asset_type=FII&profile=RENDA` → cards com exatamente os treze campos
  que o `OpportunityCard` consome, e nenhum campo de ação
- `GET /v1/opportunities?asset_type=FII&profile=CRESCIMENTO` → **400**
- `GET /health` → 200

**Suítes ao fim da sessão:** 441 unitários no backend, 29 de integração contra Postgres real,
149 no frontend, 157 no pipeline, 78 E2E. `flake8` limpo.


---

## Registro — o nome do fundo (24/09/2026)

O Fundamentus é a fonte primária de FII e **não publica o nome do fundo**: a coleta repetia o
ticker em `companyname` e o card mostrava "HGLG11" embaixo de "HGLG11". O Informe Mensal da
CVM publica `Nome_Fundo_Classe`, que o `cvm_fii_client` já lia e jogava fora.

O caminho segue o precedente do `enrich_with_cvm` das ações: o pipeline grava o dado da CVM na
tabela dele (`fii_indicators_history.fund_name`, migração `d0e1f2a3b4c5`) e o backend enriquece
a tabela dele a partir daí, dentro do `update_all_fiis`. Falha de leitura não derruba a
atualização — nome é enfeite, cotação não.

### O nome publicado não serve como vem

`KINEA RENDA IMOBILIARIA FII RESPONSABILIDADE LIMITADA` é caixa alta e jargão. O
`humanize_fund_name` tira o jargão e capitaliza, com três regras que só apareceram olhando o
dado:

| Caso | Por quê |
|---|---|
| `BB PREMIUM MALLS FII DE RESPONSABILIDADE LIMITADA` → **BB Premium Malls** | Tirar o miolo deixava um "de" pendurado no fim |
| `VBI PRIME FII RL` → **VBI Prime** | `.title()` faz o nome do gestor virar "Vbi", que parece erro de digitação |
| `PÁTRIA LOG - FUNDO DE INVESTIMENTO IMOBILIÁRIO` → **Pátria Log** | E "Log" não pode virar "LOG" |

Os dois últimos puxam em direções opostas, e a primeira tentativa — "token de até três letras é
sigla" — gritava `VIA Parque Shopping` e `Pátria LOG`. **A frequência no dado real decidiu:**
contando os tokens de três e quatro letras nos 1.106 nomes publicados, "RIO" aparece 373 vezes,
"REAL" 46 e "LOG" 26, contra 9 de "VBI" e 7 de "HSI". Palavra é a regra, sigla com vogal é a
exceção — e a exceção virou lista explícita de sete itens, levantada do próprio dado.

Regra final: sem vogal ou com até duas letras é sigla (CSHG, HGLG, BTG, RBR, XP, BB); as com
vogal vêm da lista; partícula do português fica minúscula no meio.

### Efeito colateral útil

O RBRY11 aparece no histórico com dois nomes — `RBR CREDITO IMOB FII` e, nos meses recentes,
`PATRIA CREDITO FII`. O fundo trocou de gestor. Como a consulta ordena por data e o informe
mais recente sobrescreve, o nome que a vitrine mostra é o atual, sem ninguém ter que cuidar
disso.

### A vitrine, agora

```
EQUILIBRADO                                      RENDA
BBIG11  BB Premium Malls        86.8  P/VP 0.53  BBIG11  BB Premium Malls       89.7
KORE11  Kinea Oportunidades…    83.6  P/VP 0.62  TGAR11  TG Ativo Real          87.1
OUJP11  Ourinvest JPP           82.3  P/VP 0.71  OUJP11  Ourinvest JPP          84.8
GTWR11  Green Towers            80.3  P/VP 0.77  GTWR11  Green Towers           84.8
PVBI11  VBI Prime               80.3  P/VP 0.63  KORE11  Kinea Oportunidades…   84.3
```

**Suítes:** 460 unitários no backend, 29 de integração, 149 no frontend, 157 no pipeline,
78 E2E.

### Nota de ferramenta, para a próxima sessão

Escrever regex via heredoc do bash para um script Python gerador **corrompe as escapes**: o
`` do `_NAME_BOILERPLATE` virou um byte 0x08 (backspace) literal no arquivo, invisível no
editor, e o regex simplesmente não casava nada. Arquivo com escape de regex vai pelo Write,
não pelo heredoc.


---

## Registro — revamp de design e UX (24/09/2026)

Pedido: "analise o design/UX e faça um revamp completo". Abri o app no navegador antes de
desenhar qualquer coisa — e a primeira metade do trabalho virou conserto, porque **três telas
não abriam**.

### O que estava quebrado (achado olhando, não lendo código)

| Tela | Sintoma | Causa |
|---|---|---|
| `/` (dashboard) | **Página em branco** depois do login | `getFavorites` passou a devolver `{data, pagination}` e a Home chamava `.slice` no objeto |
| `/acao/:ticker` | "Ação não encontrada ou erro ao carregar dados" para **todo** ativo | mesma resposta, `.find` no objeto, dentro de um `Promise.all` que derrubava a página inteira |
| `/fii/:ticker` | idem | idem |
| Login e cadastro | Levavam para **`/home`, que não é rota** | O destino certo é `/`; o teste unitário *afirmava* o destino errado |
| Menu | `/sentimento` sem rota e sem página | Item de menu que nunca existiu |

**Por que os testes não pegaram:** o mock do Cypress devolvia array puro — um contrato que o
backend não tem — e o teste de login só checava `url().should('not.include', '/login')`, que
uma página em branco satisfaz. Os dois foram corrigidos para falharem de verdade: o mock
espelha `{data, pagination}` e o teste de login exige ver o Dashboard.

### O design

**Tokens.** `primary` era azul-marinho e `secondary` era laranja, mas a marca, o logo e todos
os botões usavam laranja: a tela tinha link azul ao lado de botão laranja, e uma AppBar com
gradiente azul fixo que ignorava a paleta. Agora o laranja é o primary, a superfície é cinza
neutro levemente quente, e **verde e vermelho saíram de `success`/`error` para
`market.positive`/`market.negative`** — em tela de investimento eles querem dizer "subiu" e
"caiu", não "deu certo" e "deu errado".

A fonte `Inter` era pedida pelo tema **desde sempre e nunca foi carregada**: o app inteiro
renderizava em Roboto, com dígito de largura variável. Carregada, mais `tabular-nums` global.

**Navegação.** Tudo vivia atrás de um hambúrguer — inclusive num monitor de 3440px. Virou
barra com os destinos visíveis, agrupados (Ações, FIIs, Ferramentas), com estado ativo, e a
mesma estrutura alimenta a gaveta do celular. Conta, tema e alertas foram para a direita; o
sino agora fica sempre visível, porque item que aparece e some faz a barra dançar.

**Largura.** Cada página impunha o próprio `maxWidth: 1200`, dentro de um `Container xl` que
já travava em 1536. Num monitor de 3440 o conteúdo ficava numa coluna no meio com dois terços
da tela pretos. Passou a haver um `PageContainer` com três medidas — `narrow` para texto,
`default` para análise, `wide` para grade e tabela — e a grade da vitrine cresce com a tela
em vez de parar em três colunas.

### O card da vitrine

A nota era um chip de 22px no canto: o dado mais importante da tela era o menos visível dela.
Virou anel com a faixa escrita embaixo ("Forte", "Bom", "Médio", "Fraco"), porque **69 não diz
nada sem a régua** — e a régua agora vive em `utils/score`, um lugar só, lida tanto pelo anel
quanto pelo chip da tabela.

Preço, P/VP e DY eram chips de contorno na mesma linha do setor e da procedência — chip é
rótulo, não número: dava a "R$ 5,21" o mesmo peso de "Shoppings", e a partir do quarto a linha
quebrava e nenhum card ficava da mesma altura. Viraram faixa de valor sobre rótulo, alinhada
entre todos os cards.

### 🔴 A tabela densa mostrava `14.633095296724`

**Trinta e três das quarenta e uma colunas** da lista de ações não tinham formatação nenhuma.
A tela misturava `R$ 7,33` com `-1.61732250085` na mesma linha, ponto e vírgula decimais
disputando espaço, cabeçalhos cortados em "Tic...", "Que...", "Dee...", e barra de rolagem
horizontal enquanto dois terços do monitor estavam vazios.

A correção não foi escrever trinta e três `Cell`: o **tipo** da coluna passou a ser declarado
— percentual, múltiplo, moeda, contagem, compacto — e a formatação sai dele, com alinhamento à
direita, que é o que põe as casas decimais uma embaixo da outra. Coluna nova nasce formatada.
Mesma correção nas onze colunas cruas da tabela de FIIs, onde patrimônio aparecia como
`299231` e virou `R$ 299 mil`.

De quebra, dois cabeçalhos estavam errados: `passivo_ativo` rotulado "Ativo/Passivo" (invertido)
e a pílula de variação estava escrita duas vezes, com escalas de cor diferentes e hexadecimais
fixos que ignoravam o tema — no claro ficavam ilegíveis.

### Login e dashboard

O login era um cartão de 400px perdido numa tela preta, com o logo em 170px, campos
sublinhados e um "Esqueceu a senha?" apontando para `href="#"`. Agora a tela diz o que o
produto faz antes de pedir a senha, e o link morto saiu.

O dashboard pós-login mostrava dois cards vazios: "Nenhuma favorita adicionada" e "Sem
previsões disponíveis" — o card de ML existia só para anunciar a própria ausência, já que o
banco tem **zero previsões**. Ele só aparece quando há previsão, e no lugar entrou
"Oportunidades de hoje", que é o produto e não aparecia na primeira tela depois do login.

### Verificado

162 testes unitários no frontend (eram 149), **78 E2E**, todos passando, contra o backend real
com 618 ações e 562 FIIs. Os testes que afirmavam o comportamento quebrado foram corrigidos,
não apagados.

### O que ficou de fora

- Portfolio, Comparar, Notícias, Guias e as telas de detalhe receberam os tokens e a largura
  padronizada, mas **não** um redesenho de conteúdo.
- Na tabela, alguns cabeçalhos ainda cortam ("Queda ...", "Rank fórmul...") e as colunas de ML
  ficam cheias de travessão porque não há previsão no banco.
- `/login` aberto por quem já está autenticado mostra o formulário em vez de redirecionar.
- Não foi feita passagem de acessibilidade (contraste medido, navegação por teclado, foco
  visível) nem teste em viewport de celular real — a janela desta máquina não redimensiona
  abaixo do monitor.


---

## Registro — atualização automática e o pilar de ciclo (24/10/2026)

Pedido: dado atualizado sozinho todo dia, e a vitrine levar em conta o ciclo —
não comprar o que está em alta, preferir bom ativo com queda grande.

### A rotina diária, e o que ela denunciou na primeira execução

Até aqui o dado só mudava quando alguém abria a tela e clicava em "Atualizar
Ações". Agora um contêiner `scheduler` roda seg–sex às 21h de Brasília: ação,
FII, score, cotação do dia e o retrato diário.

Processo separado de propósito — o gunicorn sobe três workers e um agendador
dentro deles dispararia a mesma atualização três vezes, concorrendo pela mesma
tabela.

**Na primeira execução o status saiu `PARCIAL`: o StatusInvest devolvia 403.**
A coleta de ações estava parada havia semanas e ninguém tinha percebido,
porque nada rodava sozinho e nada registrava. A tabela mostrava o fechamento de
um mês atrás com cara de preço de hoje. O status parcial existe exatamente para
isso: uma etapa quebrada não derruba as outras, mas também não some.

O Fundamentus, que já era a fonte primária de FII, publica a mesma tabela para
ações — 995 papéis com P/L, P/VP, margens, ROE, ROIC, liquidez de dois meses e
crescimento de receita. Virou a fonte primária, com o StatusInvest de reserva,
espelhando a ordem que o lado dos fundos já usava.

### 🔴 E a troca de fonte quase matou a B3

Na execução seguinte, **71 papéis foram marcados como deslistados de uma vez —
entre eles a B3SA3, que é a própria bolsa.** Dois erros somados:

1. A regex do ticker exigia quatro **letras** na raiz, e "B3SA3" tem um dígito.
   É exatamente o mesmo erro que já tinha acontecido na ponte de tickers da
   CVM, um mês atrás, documentado no próprio planning.
2. Pior que o primeiro: `mark_delisted` tratava ausência de **um dia** como
   deslistagem. Trocar de fonte, ou a fonte publicar uma lista menor num dia,
   apagava o papel do produto.

A regex aceita raiz alfanumérica e sufixo de letra (ENMA3B), e a deslistagem
ganhou carência: a ausência é anotada em `missing_since` e só vira deslistagem
depois de cinco dias seguidos fora da fonte. A migração ainda reativou quem
tinha sido marcado no mesmo dia.

### O pilar de ciclo — "é hora?" ao lado de "é bom?"

O score comparava a empresa com as do setor. Com isso, a mesma ação no topo
histórico e 40% abaixo do pico recebia **exatamente a mesma nota**, sendo
decisões opostas.

Os limiares saíram da distribuição real, não de gosto. Entre as 204 ações
líquidas da base, medindo contra o topo de **12 meses**: mediana −10%, p25
−25%, p75 0%. Contra o topo histórico a mediana é −37% — número que não
discrimina nada, porque metade do mercado está lá.

| Estado | Regra | O que aparece no card |
|---|---|---|
| Oportunidade de ciclo | caiu ≥25% e o lucro **não** caiu junto | "Caiu 42% do topo de 12 meses e o lucro segue crescendo" |
| Perto do topo | a ≤5% da máxima de 12 meses | "Comprando no topo do próprio ciclo" |
| Queda com deterioração | caiu ≥25% **e** o lucro caiu junto | "Caiu 32%, mas o lucro caiu junto — queda com deterioração, não desconto" |

**O terceiro estado é o ponto todo.** Queda grande sozinha seleciona ativo
quebrado: foi o que aconteceu na primeira execução real do score de FII, com os
quatro fundos de crédito mais descontados da bolsa liderando os três perfis. O
discriminador para ação é a trajetória do lucro na CVM; para FII, o patrimônio
por cota, que já existia.

Resultado contra o mercado de verdade: **POMO4** (caiu 42%, lucro crescendo)
lidera com ciclo 89; **PETR4** e **ITUB4**, no topo de 12 meses, levam 36 e 32;
**VALE3**, que caiu 32% com o lucro junto, leva **16** e sai com o alerta de
armadilha.

### Duas armadilhas na implementação do próprio pilar

1. Anular a queda nos estados que não são oportunidade tirava a penalidade de
   quem está no topo: MILS3, colada na máxima, tirava 73 no pilar de ciclo.
2. Corrigido isso, a queda zero **continuava sumindo** — porque a convenção do
   projeto trata zero como "sem dado" (as fontes publicam ausência como zero),
   e queda zero é justamente o pior ponto de entrada.

A métrica virou razão `preço / topo`: o topo vale 1,0, participa do ranking e
pesa contra. Só a queda com deterioração fica de fora.

### A memória do produto

`refresh_scores` apaga e reescreve a tabela de nota a cada execução — correto
para o retrato atual e destrói o histórico. `score_snapshots` guarda uma linha
por ativo, perfil e dia, e com isso a vitrine passou a mostrar "Novo" e a
variação da nota. É a diferença entre catálogo e radar: o catálogo responde
"quais são os melhores agora", o radar responde "o que mudou desde a última vez
que você olhou", que é a razão de abrir o app amanhã.

`job_runs` registra cada execução, e a vitrine mostra "Atualizado há 14 min".
Lista de oportunidade sem data é lista em que não dá para confiar.

### A janela de 12 meses não pode envelhecer

O histórico de preço é carregado pelo pipeline, que roda sob demanda — e estava
parado havia um mês e meio quando o sinal de ciclo foi construído em cima dele.
A rotina diária passou a gravar o fechamento do dia na própria série (996
papéis por execução), então a janela anda sozinha.

### Filtros do investidor e comparação

A vitrine ganhou preço máximo ("a melhor oportunidade que não cabe no bolso não
é oportunidade"), "só quem caiu do topo" e "esconder o que já tenho". Os três
vão para o **servidor**: o recorte já é "os doze melhores", e peneirar o
resultado na tela deixaria três cards em vez de trazer os próximos da fila.

O comparador existia e vivia desconectado — era preciso copiar ticker na mão.
Agora dá para marcar até cinco cards e abrir a comparação direto.

### Verificado

513 testes unitários no backend (eram 460), 29 de integração contra Postgres
real, 171 no frontend (eram 162), 78 E2E. A rotina diária rodou de verdade
quatro vezes contra as fontes reais, e o fluxo completo foi conferido no
navegador: tarja de ciclo, filtros, barra de comparação e a ida para o
comparador.

### O que fica para depois

- O histórico mensal de FII cobre 158 fundos; quem não tem 12 meses carregados
  fica sem pilar de ciclo (a nota renormaliza).
- O alerta de preço continua sem enviar e-mail (F4).
- O `scheduler` roda as rotinas do backend; o pipeline de dados (CVM, histórico
  longo de preço, informe mensal de FII) continua manual.


---

## Registro — auditoria de imparcialidade da vitrine (24/10/2026)

Pedido: reavaliar a área de oportunidades inteira, porque **não se pode indicar
errado** — só o dado decide.

Auditei contra a base real, não lendo código. Sete defeitos, todos do tipo que
produz indicação errada.

### 🔴 1. Múltiplo negativo era lido como "o mais barato do setor"

O percentil ordena do menor para o maior. P/L de **−4,50** quer dizer prejuízo,
mas ficava à frente de um P/L de 5. Entre as 126 ações elegíveis: **10 com P/L
negativo, 8 com EV/EBIT negativo, 1 com patrimônio líquido negativo**.

A AZTE3 era **segundo lugar geral** com P/L −4,50, EV/EBIT −6,97, ROE 0 e DY 0,
tirando 86 no pilar de valuation.

Múltiplo de preço com denominador negativo sai do ranking daquela métrica. O
ativo continua na lista, avaliado pelo que se aplica a ele, com o alerta no
card.

### 🔴 2. Dívida líquida/EBIT negativa tinha duas leituras opostas

Negativo pode ser caixa líquido (ótimo) ou EBIT negativo com dívida (péssimo).
Como menor é melhor, os dois eram premiados igual — **25 das 126 elegíveis**. E
o guard rail de alavancagem lia a razão negativa como caixa e deixava passar
livre quem tem dívida sem resultado operacional.

A margem EBIT dá o sinal do denominador. Sem EBIT positivo, a razão sai do
ranking e entra um motivo de exclusão próprio.

### 🔴 3. Escala errada de ações na CVM punha banco grande como "mais barato"

O Santander está na base da CVM com **7,4 milhões de ações em vez de 7,4
bilhões**. O LPA sai mil vezes maior, o P/L mil vezes menor:

| Papel | P/L publicado | P/L que gravamos |
|---|---|---|
| SANB11 | 6,66 | **0,01** |
| SYNE3 | 11,02 | **0,01** |
| POSI3 | 57,79 | **0,06** |

Oito ações elegíveis estavam com P/VP abaixo de 0,05, que é impossível para
companhia listada — e chegavam ao topo do "mais barato" **com o selo de
auditado**, que é o que torna o erro perigoso.

A correção é uma trava de ordem de grandeza: quando o múltiplo recalculado pela
CVM diverge do publicado por mais de cinco vezes, o fundamento auditado é
descartado para aquela empresa. Não é desempate — discordar por 30% é normal
entre LTM e exercício fechado; discordar por mil vezes é defeito. A raiz está
no `_infer_share_scale` do pipeline e continua aberta.

### 🔴 4. A ausência de dado virava elogio no pilar de ciclo

A queda só devia pontuar quando se sabe que o fundamento resistiu. Eu tinha
implementado como "excluir apenas a deterioração comprovada" — então queda
profunda com tendência de lucro **desconhecida** recebia nota cheia. A AZTE3,
que tem prejuízo e nenhum histórico de lucro na CVM, tirava **100** no pilar de
ciclo.

Agora queda profunda só pontua com fundamento verificado. Queda rasa e papel no
topo continuam no ranking, porque ali a nota é penalidade e não depende de
afirmar nada.

### 🟡 5. "Está no topo de 12 meses" dito com um único preço

Nove ações eram classificadas como coladas na máxima tendo **dois ou menos
fechamentos** na janela — o "topo de 12 meses" era o preço de hoje. Passou a
exigir vinte observações antes de afirmar qualquer coisa.

### 🟡 6. O perfil ranqueava pelo pilar que não conseguiu avaliar

Sem dividendo declarado, os 30% do pilar eram redistribuídos e a empresa
competia no perfil **DIVIDENDOS** por aquilo que o perfil não pediu. Era a
mesma regra que o score de FII já tinha e faltava para ação: o pilar de maior
peso do perfil é obrigatório. Catorze ações saíram do ranking de dividendos.

### 🟡 7. O card anunciava uma procedência que o dado não tinha

Com a troca da coleta para o Fundamentus, o rótulo da fonte pública continuava
dizendo "StatusInvest". Virou "Fonte pública — último exercício fechado, não
auditado nesta base".

### Antes e depois do topo da vitrine

```
ANTES                                      DEPOIS
DIRR3  71,3                                POMO4  77,1  P/L 4,93  ROE 27,9%
AZTE3  71,0  P/L −4,50  ciclo 100          POMO3  76,5  P/L 4,55  ROE 27,9%
POMO4  70,9                                DIRR3  75,4  P/L 7,02  ROE 31,3%
```

Nenhum papel do top 10 tem múltiplo negativo, patrimônio negativo ou fundamento
com escala trocada.

### Também verificado e correto

- **Liquidez**: "Liq.2meses" do Fundamentus é média diária, não total do
  período — PETR4 R$ 2,37 bi/dia, VALE3 R$ 1,77 bi. O corte de R$ 1 milhão/dia
  mede o que diz medir.
- **Setor**: nenhum balde "sem setor" relevante; a comparação intrassetorial
  vale para os elegíveis.
- **Dado faltando não infla nota**: média 52,8 com todos os pilares contra 48,3
  com um pilar vazio.

### Continua aberto

- A escala de ações na CVM (`_infer_share_scale`) erra para algumas empresas; a
  trava protege a vitrine, mas o dado de origem segue errado.
- `_is_usable` trata zero como "sem dado". É verdade para as fontes, e esconde
  zeros legítimos — já mordeu duas vezes (queda zero, DY zero).
- 637 ações têm só o fechamento desta semana no histórico; o pilar de ciclo
  delas é nulo até a série crescer.

### Segunda passada: validação número a número contra a fonte

Comparei o que a vitrine mostra com o que o Fundamentus publica, papel por
papel do top 12. As diferenças de 1% a 25% são o LTM da CVM contra o exercício
fechado — esperado e documentado. Mas apareceram mais dois defeitos.

**🔴 8. O enriquecimento da CVM gravava zero por cima de dado bom.** A regra
era "nunca sobrescrever com nulo", e zero passava. Só que zero, nesta base,
quer dizer "componente faltou no cálculo" — a convenção vale no score inteiro.
O ALLD3 tinha **ROE de 23,06%** na fonte e ficou com 0; no total, 34 ações
perderam o ROE, 51 a margem líquida e 45 o ROIC, e **21 das elegíveis** eram
ranqueadas com menos indicadores do que tínhamos. Depois da correção sobraram 3
ROE e 17 margens zerados — esses são zero nas duas fontes.

**🟡 9. Um fundo com o alerta de deterioração tirava 100 no ciclo.** O TGAR11
exibia "o patrimônio por cota encolheu 12,7% em 32 meses" e, ao mesmo tempo,
"momento de entrada melhor que o do segmento (100/100)". A queda já era
barrada, mas o "barato para ele mesmo" continuava pontuando — e ele está barato
contra o próprio passado **porque** o patrimônio está afundando. Agora o
fundamento em deterioração tira as duas metades do pilar; o TGAR11 caiu de
segundo para terceiro e ficou sem nota de ciclo.

### O que a validação confirmou correto

- **Deduplicação de classe**: POMO3 é colapsada em POMO4 na vitrine (aparecem
  as duas só na consulta crua).
- **Queda do topo**: POMO4 a R$ 4,77 contra pico de R$ 8,17 em 46 observações
  no ano = −41,6%, exatamente o gravado. MILS3, na própria máxima, 0,0%.
- **Tendência de lucro**: ALLD 145,5 mi (2024) → 332,7 mi (2025) e DIRR 727,7 →
  979,7 confirmam o "o lucro segue crescendo" dos cards.
- **DY extremo é aparado e sinalizado**: ALLD3 com 39,4% não ganha o ranking
  por isso e leva o alerta de provento extraordinário.

**Verificado:** 523 testes unitários (eram 513), 29 de integração, 171 no
frontend, 157 no pipeline, 78 E2E. A rotina diária rodou de ponta a ponta com
status OK depois de cada correção.
