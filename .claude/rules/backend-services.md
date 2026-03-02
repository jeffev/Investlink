---
paths:
  - "backend/app/services/**"
  - "backend/app/routes/**"
  - "backend/app/models/**"
---

## Regras ao trabalhar com serviços, rotas e models do backend

**Estrutura de um serviço — padrão obrigatório:**
```python
from flask import jsonify
from models.xxx import Xxx
from config import db
import logging

def minha_funcao(param):
    try:
        # lógica aqui
        db.session.commit()
        return jsonify({"message": "ok"}), 200
    except Exception as e:
        db.session.rollback()
        logging.error(f"An error occurred: {e}")
        return jsonify({"message": "An error occurred, please try again later"}), 500
```

**Estrutura de uma rota — padrão obrigatório:**
```python
from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from services.xxx_services import minha_funcao

bp = Blueprint('xxx_bp', __name__)

@bp.route('/recurso', methods=['GET'])
@jwt_required()
def listar():
    user_id = get_jwt_identity()
    return minha_funcao(user_id)
```

**Regras críticas:**
- Sem type hints em nenhuma função
- Sem migrations — usa `db.create_all()` no startup
- Após criar uma rota, registrar o blueprint em `app/app.py`
- Para testar, usar o agente `backend-tester` após implementar
