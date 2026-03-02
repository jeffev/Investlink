Adicione um novo serviço Flask ao backend InvestLink para: $ARGUMENTS

## Passos

1. Leia APENAS `backend/app/services/stock_services.py` como referência de padrão
2. Leia APENAS `backend/app/models/` para entender os models disponíveis
3. Crie `backend/app/services/$ARGUMENTS_services.py` seguindo o padrão:
   - Funções: list_, view_, new_, edit_, delete_
   - Sempre `try/except` com `db.session.rollback()` no except
   - Respostas via `jsonify({...}), status_code`
   - Sem type hints

4. Crie `backend/app/routes/$ARGUMENTS_routes.py` com blueprint:
   - Blueprint chamado `$ARGUMENTS_bp`
   - Rotas protegidas com `@jwt_required()`
   - Rotas apenas fazem parse do request e chamam o service

5. Registre o blueprint em `backend/app/app.py`

Não crie testes agora — use `/run-tests` após para verificar.
