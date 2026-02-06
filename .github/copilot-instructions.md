# InvestLink AI Coding Instructions

## Project Overview

**InvestLink** is a full-stack financial analysis platform for Brazilian stocks (IBXX) and FIIs (Real Estate Investment Trusts). It features stock/FII filtering with Graham formula and magic formula indicators, user favorites with price alerts, and configurable UI layouts.

### Tech Stack
- **Backend:** Flask 3.0 + SQLAlchemy + PostgreSQL + JWT auth
- **Frontend:** React 18 + Material-UI + React Router
- **DevOps:** Docker Compose (PostgreSQL 13, Flask, React with Nginx)
- **Testing:** Pytest (backend), React Testing Library (frontend)

---

## Architecture & Data Flow

### Three-Tier Service Architecture

The backend uses a **routes → services → models** pattern with middleware protection:

1. **Routes** ([backend/app/routes/](backend/app/routes/)): Flask view functions that parse requests and call services. Route names follow `*_json()` convention (e.g., `list_stocks_json()`, `new_user_json()`).

2. **Services** ([backend/app/services/](backend/app/services/)): Business logic, validation, error handling, auth (password hashing with bcrypt). Each service has list, view, new, edit, delete functions.

3. **Models** ([backend/app/models/](backend/app/models/)): SQLAlchemy ORM with `to_json()` method for serialization.

**Example:** User creation flow: `routes/user_routes.py` → `services/user_services.py` → `models/user.py` → database.

### JWT & Role-Based Access

- Routes are wrapped with `protected_route()` decorator from [backend/app/utils.py](backend/app/utils.py) for auth enforcement
- Admin operations (e.g., bulk stock updates) require `required_profile="ADMIN"`
- Token issued on login/register, stored in sessionStorage on frontend
- 3-hour token expiration configured in [backend/app/services/user_services.py](backend/app/services/user_services.py)

### Frontend State Management

- User session (profile, token, name) stored in `sessionStorage` via [frontend/src/services/auth.service.js](frontend/src/services/auth.service.js)
- UI layout preferences (column visibility, sorting) persisted per-user in database via `user_layout_service.js`
- Dark/light theme toggled via React state, persisted to localStorage in [frontend/src/App.js](frontend/src/App.js)

### REST Endpoints Pattern

All routes use `/v1/{resource}` versioning:
- GET `/v1/{resource}s` - List all
- POST `/v1/{resource}s` - Create
- GET `/v1/{resource}/{id}` - View one
- PUT `/v1/{resource}/{id}` - Edit
- DELETE `/v1/{resource}/{id}` - Delete
- Special endpoints: `POST /v1/user/login`, `PUT /v1/stocks/update-stocks`

---

## Key Conventions & Patterns

### 1. Service Function Naming
Services consistently implement CRUD operations with predictable signatures:
```python
def list_users() -> jsonify(list)
def view_user(user_id) -> jsonify(dict) or 404
def new_user(user_data: dict) -> jsonify(dict) or error status
def edit_user(user_id, user_data: dict) -> jsonify(dict) or 404
def delete_user(user_id) -> jsonify(msg) or 404
```

When adding a new model (e.g., "Alert"), create corresponding service with these five functions.

### 2. Error Handling Pattern
Services return Flask `jsonify()` responses with consistent HTTP status codes:
- 200/201: Success
- 400: Validation error (missing/invalid fields)
- 404: Resource not found
- 403: Unauthorized (profile check failed)
- 500: Server error with logging

Example from [backend/app/services/user_services.py](backend/app/services/user_services.py):
```python
if not user_data.get("email"):
    return jsonify({"message": "Email is required"}), 400
```

### 3. Model Serialization
All models implement `to_json()` method. Never return SQLAlchemy model objects directly—always call `.to_json()` in services:
```python
users_json = [user.to_json() for user in all_users]
return jsonify(users_json)
```

### 4. Frontend Services Pattern
API calls abstracted in [frontend/src/services/](frontend/src/services/). Each service class wraps axios with:
- Hardcoded API_URL pointing to backend container name (`http://investlink-backend-1:5000/v1/`)
- Login/register managing token in sessionStorage
- Layout loading integrated with auth flow
- Error logging via console.error

### 5. Validation Patterns
Backend validates email format and username constraints (see [backend/app/services/user_services.py](backend/app/services/user_services.py) lines ~50-100). Frontend defers to backend for validation errors.

### 6. Protected Routes
Route protection applied declaratively:
```python
app.add_url_rule(
    "/v1/users",
    methods=["GET"],
    view_func=protected_route(list_users_json)  # Auth required
)
```
OR for public routes (registration):
```python
app.add_url_rule("/v1/users", methods=["POST"], view_func=new_user_json)  # No decorator
```

---

## Development Workflows

### Running the Project
```bash
# From root directory with docker-compose.yml
docker-compose up --build

# Services available at:
# - Backend: http://localhost:5000
# - Frontend: http://localhost:3000
# - Swagger UI: http://localhost:5000/swagger
# - DB: postgresql://postgres:123@localhost:5433/investlink
```

### Backend Testing
```bash
cd backend
pip install -r requirements.txt
pytest tests/unit/

# Test convention: test files mirror models
# tests/unit/test_user.py tests models/user.py
```

Tests directly instantiate models (no fixtures) as seen in [backend/tests/unit/test_user.py](backend/tests/unit/test_user.py).

### Frontend Testing
```bash
cd frontend
npm install
npm test

# Tests use React Testing Library
# Convention: Component.test.js co-located with Component.js
```

### Database Migrations
SQLAlchemy auto-creates tables on app startup via `db.create_all()` in [backend/app/app.py](backend/app/app.py). **No Alembic** currently—schema changes done directly in models.

---

## Backend Code Standards & Formatting

### Code Style Configuration
- **Linter:** Flake8 ([backend/.flake8](backend/.flake8))
  - Max line length: 88 characters
  - Extends ignore: E203 (whitespace before ':')
- **Python Version:** 3.9
- Format Python code to comply with Flake8 before committing

### Import Organization (Python Files)
```python
# Order: stdlib → third-party → local
import logging
from datetime import timedelta
from flask import jsonify, request
from flask_jwt_extended import create_access_token

from models.user import User
from config import db
```

### Function & Service Structure
```python
# Service file header
import logging
from flask import jsonify
from config import db
from models.{resource} import {Resource}

logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger(__name__)

# Each CRUD function must:
# 1. Have try/except with logging
# 2. Return jsonify() with status code
# 3. Include validation before database operations
# 4. Use query.filter_by()/first()/all() patterns

def list_resources():
    try:
        all_resources = Resource.query.all()
        resources_json = [r.to_json() for r in all_resources]
        return jsonify(resources_json)
    except Exception as e:
        logger.error(f"Error listing resources: {e}")
        return jsonify({"message": "Error listing resources"}), 500

def new_resource(resource_data):
    try:
        # Validation first
        if not resource_data.get("required_field"):
            return jsonify({"message": "Required field is required"}), 400
        
        # Check duplicates
        existing = Resource.query.filter_by(unique_field=resource_data.get("unique_field")).first()
        if existing:
            return jsonify({"message": "Resource already exists"}), 400
        
        # Create & commit
        resource = Resource(**resource_data)
        db.session.add(resource)
        db.session.commit()
        return jsonify(resource.to_json()), 201
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error creating resource: {e}")
        return jsonify({"message": "Error creating resource"}), 500
```

### Model Structure
```python
from config import db

class Resource(db.Model):
    __tablename__ = "resources"
    
    id = db.Column(db.Integer, primary_key=True)
    # Other columns...
    
    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)
    
    def __repr__(self):
        return f"<Resource(id={self.id})>"
    
    def to_json(self):
        return {
            "id": self.id,
            # Other fields...
        }
```

### Route Structure
```python
from flask import request
from services.{resource}_services import (
    list_resources,
    view_resource,
    new_resource,
    edit_resource,
    delete_resource,
)

def list_resources_json():
    return list_resources()

def new_resource_json():
    resource_data = request.get_json()
    return new_resource(resource_data)

def edit_resource_json(resource_id):
    resource_data = request.get_json()
    return edit_resource(resource_id, resource_data)
```

### Testing Conventions
```python
# tests/unit/test_{resource}.py
import sys
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "app"))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from models.{resource} import {Resource}

def test_{resource}_to_json_contains_expected_fields():
    data = {
        "id": 1,
        "field": "value",
    }
    resource = {Resource}(**data)
    json = resource.to_json()
    assert json["id"] == 1
    assert json["field"] == "value"
```

---

## Frontend Code Standards & Formatting

### Code Style Configuration
- **Language:** JavaScript (ES6+)
- **Testing Library:** React Testing Library (user-centric queries)
- **UI Framework:** Material-UI v5
- **HTTP Client:** Axios
- **Routing:** React Router v6
- No ESLint config—rely on Create React App defaults

### Service Structure (API Layer)
```javascript
// src/services/{resource}.service.js
import axios from "axios";

const API_URL = "http://investlink-backend-1:5000/v1/";

class ResourceService {
  async list() {
    try {
      const response = await axios.get(`${API_URL}resources`);
      return response.data;
    } catch (error) {
      console.error("Error listing resources:", error);
      throw error;
    }
  }

  async create(resourceData) {
    try {
      const response = await axios.post(`${API_URL}resources`, resourceData);
      return response.data;
    } catch (error) {
      console.error("Error creating resource:", error);
      throw error;
    }
  }

  async update(resourceId, resourceData) {
    try {
      const response = await axios.put(`${API_URL}resource/${resourceId}`, resourceData);
      return response.data;
    } catch (error) {
      console.error("Error updating resource:", error);
      throw error;
    }
  }

  async delete(resourceId) {
    try {
      await axios.delete(`${API_URL}resource/${resourceId}`);
      return { message: "Resource deleted successfully" };
    } catch (error) {
      console.error("Error deleting resource:", error);
      throw error;
    }
  }
}

export default new ResourceService();
```

### Component Testing Pattern
```javascript
// src/components/Component.test.js
import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import Component from './Component';

jest.mock('../services/service.js');

describe('Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    sessionStorage.clear();
  });

  it('renders without crashing', () => {
    render(
      <MemoryRouter>
        <Component />
      </MemoryRouter>
    );
    expect(screen.getByText(/expected text/i)).toBeInTheDocument();
  });

  it('calls service on action', async () => {
    render(
      <MemoryRouter>
        <Component />
      </MemoryRouter>
    );
    const button = screen.getByRole('button', { name: /action/i });
    await userEvent.click(button);
    // Assert on service call or result
  });
});
```

### Query Best Practices for Testing
```javascript
// PREFER (user-centric)
screen.getByRole('button', { name: /submit/i })     // Accessible to users
screen.getByRole('link', { name: /home/i })         // Link elements
screen.getByRole('checkbox')                         // Input elements
screen.getByText(/expected text/i)                  // Visible text

// AVOID
screen.getByTestId('submit-btn')                     // Brittle, not accessible
screen.getByClassName('btn')                         // Implementation detail
document.querySelector('.form')                     // DOM queries
```

### Session & State Management
```javascript
// Session storage (API state - cleared on logout)
sessionStorage.setItem('user', JSON.stringify({
  profile: 'USER',
  name: 'John Doe',
  user_name: 'jdoe',
  access_token: 'jwt_token'
}));

// Local storage (UI state only - persists across sessions)
localStorage.setItem('darkMode', JSON.stringify(true));

// Never store sensitive data in localStorage
```

---

**Backend:**
- `/app/models/` - One file per domain (user.py, stock.py, fii.py, favorite.py, favorite_fii.py, portfolio.py, user_layout.py)
- `/app/services/` - One service file per model
- `/app/routes/` - One routes file per model
- `/app/utils.py` - Route registration, protected_route decorator, helpers
- `/app/config.py` - Flask app factory, db/jwt initialization

**Frontend:**
- `/src/components/` - Reusable UI components (BarraNavegacao, Footer, Rotas)
- `/src/pages/` - Page-level components (Home, ListaAcoes, ListaFiis, Login, Favorites)
- `/src/services/` - API service classes
- `/src/assets/` - Static images, icons

---

## Common Tasks for AI Agents

### Adding a New Endpoint
1. Add model in `backend/app/models/{resource}.py` with `to_json()`
2. Create `backend/app/services/{resource}_services.py` with 5 CRUD functions
3. Create `backend/app/routes/{resource}_routes.py` with 5 `*_json()` wrappers
4. Register routes in `backend/app/utils.py` `setup_routes()` function with `/v1/{resource}` paths and `protected_route()` decorator
5. Add axios service in `frontend/src/services/{resource}.service.js`

### Modifying Service Logic
- All business logic lives in services, not routes
- Validation in services returns proper error status codes
- Use SQLAlchemy `query.filter_by()` and `.first()` / `.all()` patterns
- Always wrap changes in try/except, log errors

### Frontend Form Handling
- Services handle API calls and sessionStorage updates
- Components call services on form submit
- No direct localStorage access for API state (only theme)—use sessionStorage or service methods

---

## Integration Points & Dependencies

- **Backend ↔ Frontend:** JWT Bearer tokens in Authorization headers via axios default config
- **Frontend ↔ Database:** PostgreSQL accessed only via Flask backend
- **Data Science Pipeline:** Separate module (not yet integrated) in [data_science_pipeline/](data_science_pipeline/)—future work for ML model predictions
- **Swagger UI:** Auto-served from [backend/app/static/swagger.json](backend/app/static/swagger.json)

---

## Debugging Tips

- Check Django logs in docker-compose output for stack traces
- Frontend errors logged to browser console
- Database connection issues: verify `DATABASE_URL` env var matches docker-compose service names
- JWT errors: token expiration is 3 hours; logout clears multiple sessionStorage keys (user, stateListaAcoes, stateListaFiis, etc.)
- Route not found (404): check capitalization and `/v1/` prefix in route registration

---

## Code Quality Standards

### SOLID Principles

**Single Responsibility Principle (SRP)**
- Each service handles ONE domain (UserService only handles users, not stocks)
- Each component renders ONE feature (BarraNavegacao only handles navbar)
- Example: `user_services.py` handles user CRUD, never stock operations

**Open/Closed Principle (OCP)**
- Extend features without modifying existing code
- Use inheritance for models, decorators for routes (e.g., `protected_route()`)
- Add new endpoints via `setup_routes()` without modifying existing ones

**Liskov Substitution Principle (LSP)**
- All services implement the same CRUD interface (list, view, new, edit, delete)
- Models can be swapped without breaking code (User, Stock, FII share `to_json()`)
- Backend services work consistently regardless of resource type

**Interface Segregation Principle (ISP)**
- Frontend services only expose methods used by components
- Example: `AuthService` doesn't expose internal JWT logic, only `login()`, `logout()`
- Backend routes only return required fields via `to_json()`, not full ORM objects

**Dependency Inversion Principle (DIP)**
- Services depend on abstractions (config.db), not concrete implementations
- Example: Services import `from config import db` (abstraction), not direct psycopg2
- Frontend components depend on service interfaces, not axios directly

### Design Patterns

**Repository Pattern (Services as Data Layer)**
- Services (`user_services.py`, `stock_services.py`) act as repositories
- Hide SQLAlchemy complexity from routes
- Consistent CRUD operations across all resources

**Decorator Pattern (Protected Routes)**
```python
# backend/app/utils.py
def protected_route(view_func, required_profile=None):
    @wraps(view_func)
    @jwt_required()
    def decorated_view(*args, **kwargs):
        # Auth logic here
        return view_func(*args, **kwargs)
    return decorated_view

# Usage: app.add_url_rule("/v1/users", view_func=protected_route(list_users_json))
```

**Factory Pattern (Flask App Factory)**
```python
# backend/app/config.py
def create_app():
    app = Flask(__name__)
    # Configuration logic
    db.init_app(app)
    jwt.init_app(app)
    return app
```

**Service Locator Pattern (DI via sessionStorage)**
```javascript
// frontend - auth.service.js exposes singleton
sessionStorage.setItem('user', JSON.stringify(userData));
// Components retrieve user data from sessionStorage, not pass as props everywhere
```

**Strategy Pattern (Multiple Validation Strategies)**
```python
# backend/app/services/user_services.py
def validate_email(email):
    return re.match(r'^[^@]+@[^@]+\.[^@]+$', email)

def validate_username(username):
    return len(username) >= 3 and username.isalnum()

# Each validation is a different strategy
```

### Testing Strategy

**Unit Tests (Backend)**
```python
# tests/unit/test_user.py
# Test ONLY the model, no database calls
def test_user_to_json_contains_expected_fields():
    user = User(id=1, user_name="jdoe", name="John Doe", email="j@example.com", profile="USER")
    json = user.to_json()
    assert json["id"] == 1
    assert json["user_name"] == "jdoe"
```

**Unit Tests (Frontend)**
```javascript
// src/components/Component.test.js
// Test component behavior with mocked services
jest.mock('../services/auth.service.js');

it('renders login button when not authenticated', () => {
  render(<BarraNavegacao check={false} change={() => {}} />);
  expect(screen.getByRole('link', { name: /login/i })).toBeInTheDocument();
});
```

**Integration Test Guidelines (NOT YET IMPLEMENTED)**
- Test service ↔ database interaction (requires test database)
- Test route ↔ service ↔ model flow with actual DB
- Mock only external APIs (email services, stock data feeds)
- Example structure:
```python
# tests/integration/test_user_flow.py (future)
def test_user_registration_flow(test_db):
    # 1. Register user
    response = client.post('/v1/users', json={...})
    assert response.status_code == 201
    
    # 2. Login with credentials
    response = client.post('/v1/user/login', json={...})
    assert response.status_code == 200
    
    # 3. Access protected route
    response = client.get('/v1/stocks', headers={'Authorization': f'Bearer {token}'})
    assert response.status_code == 200
```

**Test Coverage Goals**
- Models: 100% (all fields, methods tested)
- Services: 80%+ (happy path + error cases)
- Routes: No direct testing (covered by integration tests)
- Frontend components: 80%+ (user interactions, state changes)

### Clean Code Principles

**Meaningful Names**
```python
# GOOD
def list_user_favorites():
    return [f.to_json() for f in user.favorites]

# AVOID
def get_stuff():
    return all_data
```

**Functions Should Do One Thing**
```python
# GOOD: Single responsibility
def validate_email(email):
    return re.match(r'^[^@]+@[^@]+\.[^@]+$', email)

# AVOID: Multiple concerns
def create_user_and_send_email(user_data):
    # Creates user AND sends email - too many responsibilities
    pass
```

**DRY (Don't Repeat Yourself)**
```python
# GOOD: Extracted to helper
def validate_user_data(user_data):
    if not user_data.get("email"):
        return False, "Email is required"
    if not validate_email(user_data["email"]):
        return False, "Invalid email format"
    return True, None

# Usage in both new_user and edit_user
is_valid, error = validate_user_data(user_data)
if not is_valid:
    return jsonify({"message": error}), 400
```

**Comments Should Explain WHY, Not WHAT**
```python
# GOOD: Explains business logic
# Admin-only endpoint to prevent bulk data manipulation by regular users
@protected_route(required_profile="ADMIN")
def update_all_stocks():
    pass

# AVOID: Obvious from code
# Get all users
def list_users():
    all_users = User.query.all()
```

**Error Messages Should Be Descriptive**
```python
# GOOD
return jsonify({"message": "Email format invalid. Expected: user@example.com"}), 400

# AVOID
return jsonify({"message": "Error"}), 400
```

**Keep Functions Short**
- Aim for < 20 lines per function
- Extract logic to helper functions
- Example: `new_user()` should validate, check duplicates, create, return (4 logical steps max)

### Code Smells to Avoid

**Backend (Python)**
- Functions with 3+ responsibilities → Extract to new function
- Service functions without try/except → Add error handling
- Hardcoded values → Move to config or constants
- Repeated validation logic → Create validator helper
- Long parameter lists → Use data objects/dicts
- Magic numbers/strings → Define constants

**Frontend (JavaScript)**
- Components with multiple useState → Consider Context API
- Repeated API calls in components → Move to service
- Deeply nested JSX → Extract to sub-components
- No error handling on API calls → Add try/catch
- Hardcoded URLs → Use .env or config file
- No prop validation → Add PropTypes or JSDoc

### Refactoring Checklist

Before committing code:
- ✓ Functions have single responsibility
- ✓ Names are clear and descriptive
- ✓ No duplicated logic (DRY)
- ✓ Error handling present (try/except)
- ✓ Logging for debugging added
- ✓ Comments explain "why", not "what"
- ✓ Test coverage ≥ 80% (backend) or 70% (frontend)
- ✓ No console.log() or print() left in production code
- ✓ No hardcoded credentials or secrets
- ✓ Code passes linter (Flake8 for Python, ESLint rules for JS)

---

## Code Review Checklist

- ✓ New models implement `to_json()` method
- ✓ New services follow CRUD function naming (list, view, new, edit, delete)
- ✓ All service functions return `jsonify()` with appropriate status codes
- ✓ Routes are wrapped with `protected_route()` unless public (registration, login)
- ✓ Validation happens in services, not routes
- ✓ Frontend components import services, not making direct API calls
- ✓ Tests in `tests/unit/` mirror model names
- ✓ SOLID principles followed (SRP, OCP, LSP, ISP, DIP)
- ✓ Design patterns applied appropriately (Repository, Decorator, Factory)
- ✓ Clean code standards met (meaningful names, single responsibility, DRY)
- ✓ No code smells (duplication, magic numbers, missing error handling)
