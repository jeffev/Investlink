Execute os testes unitários do backend InvestLink e reporte o resultado.

Rode o comando:
```
cd /d/Investlink/backend && PYTHONPATH=app python -m pytest tests/unit/ -v 2>&1
```

Mostre:
- Total de testes passando vs falhando
- Detalhes de cada falha (nome do teste + mensagem de erro)
- Se todos passarem, confirme com "✓ X/X testes passando"

Não leia nenhum arquivo de código — apenas execute e reporte.
