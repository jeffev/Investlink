---
paths:
  - "frontend/src/pages/**"
  - "frontend/src/components/**"
  - "frontend/src/services/**"
---

## Regras ao trabalhar com frontend

**Componentes são grandes — use Grep antes de Read:**
```bash
# Encontre a função antes de ler o arquivo inteiro
grep -n "function NomeDaFuncao\|const NomeDaFuncao" frontend/src/pages/ListaAcoes.js
```

**Padrão de chamada de API — nunca hardcode URL:**
```javascript
// ✅ Correto — usa os services
import { getStocks } from '../services/stock.service';
const data = await getStocks();

// ❌ Errado
const data = await axios.get('http://investlink-backend-1:5000/v1/stocks');
```

**Autenticação:**
```javascript
import authService from '../services/auth.service';
const user = authService.getCurrentUser(); // null se não logado
const token = localStorage.getItem('token');
```

**Imports Material-UI:**
```javascript
import { Box, Button, TextField, Typography, CircularProgress } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
```

**Sem TypeScript** — JavaScript puro, sem PropTypes.
