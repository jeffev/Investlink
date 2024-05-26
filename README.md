# InvestLink - Super Projeto

O InvestLink é um projeto que visa analisar indicadores financeiros das ações do IBXX para prever se uma ação está cara, barata ou neutra, além de prever o valor da ação com base nesses indicadores. O projeto é composto por três partes principais: um frontend, um backend e um pipeline de dados para coleta, processamento e análise dos indicadores.

## Funcionalidades

- **Frontend:** Interface de usuário para visualização dos resultados da análise e interação com o sistema.
- **Backend:** Serviço responsável por receber as requisições do frontend, processá-las e retornar os resultados.
- **Pipeline de Dados:** Processo automatizado para coletar indicadores financeiros, processá-los análise e treinamento do modelo.

## Uso do Docker Compose

O projeto utiliza o Docker Compose para facilitar a execução e gerenciamento dos serviços. Para iniciar o projeto, execute o seguinte comando na raiz do repositório:

```bash
docker-compose up
```

Este comando iniciará os contêineres necessários para executar o frontend, backend e pipeline de dados.

## Scripts Personalizados

Na pasta `scripts`, você encontrará scripts personalizados para auxiliar em tarefas específicas do projeto. Certifique-se de revisar e entender cada script antes de executá-lo.

## Contato

Para mais informações sobre o InvestLink, entre em contato com Jefferson Valandro em [jeffev123@gmail.com](mailto:jeffev123@gmail.com).
