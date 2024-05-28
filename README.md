# InvestLink - Super Projeto

O InvestLink é um projeto que visa analisar indicadores financeiros das ações do IBXX para prever se uma ação está cara, barata ou neutra, além de prever o valor da ação com base nesses indicadores. O projeto é composto por três partes principais: um frontend, um backend e um pipeline de dados para coleta, processamento e análise dos indicadores.

## Funcionalidades

- **Frontend:** Interface de usuário para visualização dos resultados da análise e interação com o sistema.
  - **Tema Dark e Light:** Alternância entre temas escuro e claro.
  - **Salvamento de Layout:** Possibilidade do usuário salvar o layout da lista de ações e FIIs, que possuem muitos campos.
- **Backend:** Serviço responsável por receber as requisições do frontend, processá-las e retornar os resultados.
- **Pipeline de Dados:** Processo automatizado para coletar indicadores financeiros, processá-los e treinar o modelo.

### Funcionalidades Desenvolvidas

#### Ações
- Lista de ações com a fórmula de Graham e a fórmula mágica (filtro em todos os campos).
- Possibilidade de adicionar ações a uma lista de favoritas, onde o usuário pode salvar um preço teto e um preço alvo.
- Preço teto e preço alvo mudam de cor quando estão em compra ou venda de acordo com o preço atual.

#### FIIs
- Lista de FIIs (filtro em todos os campos).
- Possibilidade de adicionar FIIs a uma lista de favoritas, onde o usuário pode salvar um preço teto e um preço alvo.
- Preço teto e preço alvo mudam de cor quando estão em compra ou venda de acordo com o preço atual.

### Funcionalidades a Serem Adicionadas
- Análise de Sentimento do Mercado: Análise de machine learning nas últimas notícias para determinar se o mercado está otimista, neutro ou negativo.
- Coluna com Resultados do Modelo de ML: Indicando se a ação está barata, cara ou neutra.

### Sugestões Futuras de Funcionalidades
- Alertas Personalizados: Notificações por e-mail ou SMS quando uma ação ou FII atinge o preço teto ou preço alvo definidos pelo usuário.
- Comparação de Ativos: Ferramenta para comparar diferentes ações ou FIIs com base em múltiplos indicadores financeiros.
- Dashboard Personalizado: Painel com resumo das ações e FIIs favoritos, incluindo gráficos e indicadores de performance.
- Análise Técnica: Gráficos interativos com indicadores técnicos como médias móveis, RSI, MACD, entre outros.
- Histórico de Preços e Indicadores: Visualização do histórico de preços e indicadores financeiros para cada ação ou FII.
- Recomendações Personalizadas: Sugestões de ações ou FIIs baseadas no perfil de investimento do usuário e nos dados de performance passada.
- Calculadora de Dividendos: Ferramenta para estimar o retorno em dividendos com base no número de ações ou cotas de FIIs que o usuário possui.
- Simulações de Carteira: Permitir que os usuários criem carteiras simuladas para testar diferentes estratégias de investimento.
- Integração com APIs Financeiras: Integração com APIs que fornecem dados financeiros em tempo real, como Yahoo Finance ou Alpha Vantage.
- Relatórios de Desempenho: Geração de relatórios periódicos sobre o desempenho da carteira do usuário, com análises e insights.
- Fórum ou Comunidade: Espaço para os usuários discutirem estratégias de investimento, compartilhar dicas e fazer perguntas.
- Análise de Risco: Ferramenta para avaliar o risco da carteira do usuário com base em métricas como volatilidade e beta.

## Uso do Docker Compose

O projeto utiliza o Docker Compose para facilitar a execução e gerenciamento dos serviços. Para iniciar o projeto, execute o seguinte comando na raiz do repositório:

```bash
docker-compose up --build
```

Este comando iniciará os contêineres necessários para executar o frontend, backend e pipeline de dados.

## Scripts Personalizados

Na pasta `scripts`, você encontrará scripts personalizados para auxiliar em tarefas específicas do projeto. Certifique-se de revisar e entender cada script antes de executá-lo.

## Contato

Para mais informações sobre o InvestLink, entre em contato com Jefferson Valandro em [jeffev123@gmail.com](mailto:jeffev123@gmail.com).