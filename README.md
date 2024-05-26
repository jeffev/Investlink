# Super Projeto: InvestLink

Este repositório contém o código-fonte e a estrutura do projeto InvestLink, que inclui um frontend, um backend e um pipeline de dados para análise de indicadores financeiros das ações do IBXX.

## Estrutura do Repositório

```markdown
InvestLink/
│
├── frontend/
│   ├── public/
│   ├── src/
│   ├── package.json
│   ├── ...
│
├── backend/
│   ├── app/
│   ├── tests/
│   ├── requirements.txt
│   ├── ...
│
├── data_pipeline/
│   ├── web_scraping/
│   ├── data_processing/
│   ├── database/
│   ├── analysis/
│   ├── models/
│   ├── notebooks/
│   ├── utils/
│   ├── Dockerfile
│   ├── README.md
│   ├── ...
│
├── .gitignore
├── docker-compose.yml
├── README.md
└── ...
```

## Descrição dos Subprojetos

### Frontend

O frontend é uma aplicação React que fornece a interface de usuário para o InvestLink.

#### Funcionalidades

- Exibição de dados financeiros
- Visualização de classificações de ações (Cara, Barata, Neutra)
- Interação com o backend para obter e enviar dados

#### Instalação

1. Navegue até o diretório `frontend`:
    ```bash
    cd frontend
    ```

2. Instale as dependências:
    ```bash
    npm install
    ```

3. Inicie a aplicação:
    ```bash
    npm start
    ```

### Backend

O backend é uma API RESTful construída com Python e Flask que serve os dados e processa as solicitações do frontend.

#### Funcionalidades

- Gerenciamento de usuários
- Autenticação e autorização
- Manipulação e fornecimento de dados financeiros

#### Instalação

1. Navegue até o diretório `backend`:
    ```bash
    cd backend
    ```

2. Crie um ambiente virtual e ative-o:
    ```bash
    python -m venv venv
    venv\Scripts\activate  # No Windows
    source venv/bin/activate  # No macOS/Linux
    ```

3. Instale as dependências:
    ```bash
    pip install -r requirements.txt
    ```

4. Inicie a aplicação:
    ```bash
    flask run
    ```

### Data Pipeline

O data pipeline é responsável por coletar, processar, armazenar, analisar os dados financeiros e treinar modelos de machine learning.

#### Funcionalidades

- Web scraping dos indicadores financeiros das ações do IBXX
- Limpeza e processamento dos dados coletados
- Armazenamento dos dados em um banco de dados
- Análise exploratória e treinamento de modelos de machine learning

#### Instalação

1. Navegue até o diretório `data_pipeline`:
    ```bash
    cd data_pipeline
    ```

2. Construa e inicie os serviços com Docker Compose:
    ```bash
    docker-compose up --build
    ```

3. Para executar scripts individuais, utilize o comando `docker exec`:
    ```bash
    docker exec -it <container_id> python web_scraping/scraper.py
    ```

## Docker Compose

O arquivo `docker-compose.yml` na raiz do projeto pode ser usado para orquestrar todos os serviços (frontend, backend e data pipeline).

#### Passos

1. Construa e inicie todos os serviços:
    ```bash
    docker-compose up --build
    ```

2. Acesse a aplicação frontend em `http://localhost:3000` e a API backend em `http://localhost:5000`.

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues e pull requests.

## Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

## Contato

Para mais informações, entre em contato com Jefferson Valandro em [jeffev123@gmail.com](mailto:jeffev123@gmail.com).
```

Este `README.md` fornece uma visão geral clara do projeto, incluindo a estrutura do repositório, descrição dos subprojetos, instruções de instalação e uso, e informações de contribuição e contato.
