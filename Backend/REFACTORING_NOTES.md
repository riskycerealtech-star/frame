# Refactoring Notes

## Current Status

✅ **Root `main.py` is now clean** - It only imports from `app.main`

## Endpoints from Old main.py That Need to Be Extracted

The old `main.py` (2544 lines) contained these endpoints that need to be properly organized:

### Authentication Endpoints (should be in `app/routes/auth.py` or `app/routes/users.py`):
- `POST /v1/user/signup` - User signup
- `POST /v1/user/signin/{userId}` - User signin
- `POST /v1/user/refresh-token/{userId}` - Refresh token
- `POST /v1/user/token-status/{userId}` - Check token status
- `GET /v1/users/{userId}` - Get user by ID
- `PATCH /v1/user/account/{userId}` - Update user account
- `POST /swagger-login` - Swagger UI authentication

### AI Validation Endpoints (should be in `app/routes/ai_validation.py`):
- `POST /validate-sunglasses` - Validate sunglasses from file upload
- `POST /validate-sunglasses-base64` - Validate sunglasses from base64

### General Endpoints (should be in `app/main.py`):
- `GET /` - Root endpoint
- `GET /health` - Health check

## What Needs to Be Done

1. **Extract endpoints to routes/** - Move all endpoint definitions to appropriate route files
2. **Extract business logic to controllers/** - Move business logic from route handlers to controller functions
3. **Move schemas to schemas/** - Ensure all Pydantic models are in the schemas directory
4. **Update imports** - Fix all imports to use the new structure
5. **Test** - Ensure all endpoints work after refactoring

## Current Structure

```
Backend/
├── main.py                    # ✅ Clean entry point (imports from app.main)
├── app/
│   ├── main.py               # ✅ Clean FastAPI app initialization
│   ├── config.py             # ✅ Settings
│   ├── database.py           # ✅ Database setup
│   ├── dependencies.py       # ✅ Shared dependencies
│   └── routes/               # ⚠️ Needs endpoints from old main.py
│       ├── auth.py
│       ├── users.py
│       ├── ai_validation.py
│       ├── products.py
│       └── orders.py
├── controllers/              # ⚠️ Needs business logic from old main.py
├── services/                 # ✅ Business logic services
├── schemas/                  # ✅ Pydantic models
├── models/                   # ✅ Database models
└── middleware/               # ✅ Error handlers
```

## Next Steps

1. Extract `/v1/user/*` endpoints to `app/routes/users.py`
2. Extract `/validate-sunglasses*` endpoints to `app/routes/ai_validation.py`
3. Move business logic from route handlers to `controllers/`
4. Update all imports
5. Test the application



