---
paths:
  - "backend/tests/**"
---

## Regras ao trabalhar com testes do backend

**Fixtures disponíveis (conftest.py) — não reimplemente:**
`app`, `client`, `mock_db_session`, `sample_user`, `sample_stock`, `sample_fii`, `sample_favorite`, `sample_favorite_fii`, `sample_layout`, `auth_token`, `valid_user_data`, `invalid_user_data`

**Padrão de mock obrigatório:**
```python
# Sempre patch no módulo do serviço, não no modelo diretamente
with patch('services.stock_services.Stock.query') as mock_query, \
     patch('services.stock_services.db') as mock_db:
    mock_db.session = mock_db_session  # fixture como parâmetro do método
```

**Checklist antes de criar um teste:**
- [ ] O serviço correspondente existe em `app/services/`?
- [ ] O import está correto: `from services.<nome>_services import <func>`?
- [ ] Flask context: `with app.app_context():`?
- [ ] mock_db_session está como parâmetro do método quando db é usado?

**Não leia** models/, routes/ ou app.py — os testes mocam tudo.
