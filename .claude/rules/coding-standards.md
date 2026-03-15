---
description: Padrões de qualidade de código aplicados a todo o projeto InvestLink
---

## SOLID

**SRP — Single Responsibility**
- Cada serviço Flask cuida de uma entidade (`stock_services`, `fii_services`, `user_services`)
- Rotas não têm lógica de negócio — só fazem parse do request e chamam o serviço
- Componentes React têm uma responsabilidade visual; lógica de API fica nos `services/`

**OCP — Open/Closed**
- Prefira adicionar novas funções a modificar as existentes quando o comportamento muda
- Evite ifs encadeados que crescem com novos casos — extraia funções específicas

**DIP — Dependency Inversion**
- Serviços dependem dos models via SQLAlchemy, não de implementações concretas de banco
- Frontend depende das funções dos `services/`, nunca de `axios` diretamente nas páginas

---

## Clean Code

**Funções**
- Uma responsabilidade por função, máximo ~20 linhas
- Nome descreve o que faz: `calculate_earnings_yield`, não `calc` ou `process`
- Sem side effects escondidos (uma função que lista não deve modificar dados)

**Nomes**
- Descritivos e sem abreviações: `user_id`, não `uid` ou `u`
- Booleanos com prefixo: `is_valid`, `has_permission`, `exists`
- Sem magic numbers: use constantes nomeadas ou parâmetros com default

**Duplicação**
- Se a mesma lógica aparece em 2+ lugares, extraia uma função
- No frontend, lógica de formatação repetida vai para um helper, não inline nos componentes

**Comentários**
- Comente o *porquê*, nunca o *o quê* (o código já diz o quê)
- Se precisa comentar o que uma linha faz, o nome está ruim — renomeie

---

## Design Patterns aplicados ao projeto

**Service Layer** (já usado — manter)
- Controllers (rotas) → Services (lógica) → Models (dados)
- Nunca pule uma camada: rota não acessa model direto, service não conhece `request`

**Repository implícito via SQLAlchemy**
- Queries ficam nos serviços, não nas rotas
- Evite queries espalhadas em múltiplos arquivos para a mesma entidade

**Guard Clauses** (prefira a nested ifs)
```python
# ✅ Bom
def view_stock(ticker):
    stock = Stock.query.get(ticker)
    if stock is None:
        return jsonify({"message": "Not found"}), 404
    return jsonify(stock.to_json()), 200

# ❌ Evitar
def view_stock(ticker):
    stock = Stock.query.get(ticker)
    if stock is not None:
        return jsonify(stock.to_json()), 200
    else:
        return jsonify({"message": "Not found"}), 404
```

---

## Regras específicas do projeto

- **Sem hardcode de URLs** no frontend — sempre via `services/`
- **Sem hardcode de credenciais** — usar variáveis de ambiente
- **Sem `print()` em produção** — usar `logging.error()` nos serviços
- **Sem funções com mais de 3 parâmetros** sem justificativa — use dict ou objeto
- **Componentes React > 200 linhas** devem ser candidatos a extração

---

## Formatação obrigatória antes de commitar (backend Python)

**SEMPRE executar antes de qualquer commit no backend:**

```bash
cd /d/Investlink/backend
python -m black .
python -m flake8 app/ tests/ migrations/
```

- O CI usa `black --check .` — qualquer arquivo fora do padrão quebra o pipeline
- `black` reformata automaticamente; `flake8` apenas reporta
- Arquivos de teste também são verificados — não apenas `app/`
- Se não tiver `black` instalado: `pip install black flake8`
