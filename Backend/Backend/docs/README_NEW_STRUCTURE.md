# Glass Backend API - New Structure

A well-organized Python backend API for the Glass marketplace application with PostgreSQL database integration.

## 🏗️ Project Structure

```
Backend/
├── app/                          # Main application package
│   ├── __init__.py
│   ├── main.py                   # FastAPI application entry point
│   ├── api/                      # API layer
│   │   ├── __init__.py
│   │   └── v1/                   # API version 1
│   │       ├── __init__.py
│   │       ├── api.py            # Main API router
│   │       ├── dependencies.py   # API dependencies
│   │       └── endpoints/        # API endpoints
│   │           ├── __init__.py
│   │           ├── auth.py       # Authentication endpoints
│   │           ├── users.py      # User management endpoints
│   │           ├── products.py   # Product management endpoints
│   │           ├── orders.py     # Order management endpoints
│   │           └── ai_validation.py # AI validation endpoints
│   ├── core/                     # Core functionality
│   │   ├── __init__.py
│   │   ├── config.py             # Application configuration
│   │   └── security.py           # Security utilities
│   ├── db/                       # Database layer
│   │   ├── __init__.py
│   │   ├── base.py               # Database base classes
│   │   └── session.py            # Database session management
│   ├── models/                   # SQLAlchemy models
│   │   ├── __init__.py
│   │   ├── user.py               # User model
│   │   ├── product.py            # Product model
│   │   ├── order.py              # Order models
│   │   ├── review.py             # Review model
│   │   └── product_image.py      # Product image model
│   ├── schemas/                  # Pydantic schemas
│   │   ├── __init__.py
│   │   ├── user.py               # User schemas
│   │   ├── product.py            # Product schemas
│   │   ├── order.py              # Order schemas
│   │   └── ai_validation.py      # AI validation schemas
│   ├── services/                 # Business logic layer
│   │   ├── __init__.py
│   │   ├── user_service.py       # User business logic
│   │   ├── product_service.py    # Product business logic
│   │   ├── order_service.py      # Order business logic
│   │   └── ai_validation_service.py # AI validation logic
│   └── utils/                    # Utility functions
│       ├── __init__.py
│       ├── auth/                 # Authentication utilities
│       ├── validators/           # Validation utilities
│       └── helpers/              # Helper functions
├── tests/                        # Test files
│   ├── unit/                     # Unit tests
│   └── integration/              # Integration tests
├── migrations/                   # Database migrations
├── scripts/                      # Utility scripts
│   └── init_db.py               # Database initialization
├── docs/                         # Documentation
├── requirements.txt              # Python dependencies
├── env_example_new.txt          # Environment variables example
├── run.py                       # Application runner
└── README_NEW_STRUCTURE.md      # This file
```

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd Backend
pip install -r requirements.txt
```

### 2. Set Up PostgreSQL Database

```bash
# Install PostgreSQL (if not already installed)
# macOS with Homebrew:
brew install postgresql
brew services start postgresql

# Create database
createdb sunglass_db

# Or using psql:
psql -U postgres
CREATE DATABASE sunglass_db;
```

### 3. Configure Environment Variables

```bash
# Copy environment template
cp env_example_new.txt .env

# Edit .env file with your database credentials
# Update DATABASE_URL, SECRET_KEY, etc.
```

### 4. Initialize Database

```bash
# Run database initialization script
python scripts/init_db.py
```

### 5. Run the Application

```bash
# Development mode
python run.py

# Or using uvicorn directly
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at: `http://localhost:8000`

## 📚 API Documentation

Once the server is running, you can access:

- **Interactive API docs**: `http://localhost:8000/docs/frame/swagger-ui/index.html`
- **ReDoc documentation**: `http://localhost:8000/docs/frame/redoc/index.html`
- **OpenAPI schema**: `http://localhost:8000/docs/frame/openapi.json`

## 🔧 Key Features

### Database Integration
- **PostgreSQL** with SQLAlchemy ORM
- **Alembic** for database migrations
- **Connection pooling** for performance
- **Model relationships** properly defined

### Authentication & Security
- **JWT tokens** for authentication
- **Password hashing** with bcrypt
- **Role-based access control** (user, seller, admin)
- **CORS configuration** for frontend integration

### API Structure
- **RESTful API design**
- **Versioned API** (v1)
- **Comprehensive error handling**
- **Request/response validation** with Pydantic
- **Dependency injection** for database sessions

### Business Logic
- **Service layer** for business logic
- **Separation of concerns**
- **Reusable components**
- **Clean architecture**

## 🗄️ Database Models

### Core Models
- **User**: User accounts and profiles
- **Product**: Marketplace items
- **Order**: Customer orders
- **OrderItem**: Individual order items
- **Review**: Product reviews and ratings
- **ProductImage**: Product image metadata

### Key Features
- **Soft deletes** (is_active flag)
- **Audit timestamps** (created_at, updated_at)
- **Foreign key relationships**
- **Enum types** for status fields
- **JSON fields** for flexible data storage

## 🔐 Authentication Flow

1. **Register**: `POST /api/v1/auth/register`
2. **Login**: `POST /api/v1/auth/login`
3. **Get Token**: JWT token returned
4. **Use Token**: Include in `Authorization: Bearer <token>` header

## 📝 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user
- `GET /api/v1/auth/me` - Get current user

### Users
- `GET /api/v1/users/me` - Get current user profile
- `PUT /api/v1/users/me` - Update user profile
- `GET /api/v1/users/{user_id}` - Get user by ID

### Products
- `GET /api/v1/products/` - List products
- `GET /api/v1/products/{product_id}` - Get product details
- `POST /api/v1/products/` - Create product (seller only)
- `PUT /api/v1/products/{product_id}` - Update product (owner only)
- `DELETE /api/v1/products/{product_id}` - Delete product (owner only)

### Orders
- `GET /api/v1/orders/` - Get user orders
- `GET /api/v1/orders/{order_id}` - Get order details
- `POST /api/v1/orders/` - Create new order
- `PUT /api/v1/orders/{order_id}` - Update order

### AI Validation
- `POST /api/v1/ai/validate-sunglasses` - Validate image file
- `POST /api/v1/ai/validate-sunglasses-base64` - Validate base64 image

## 🧪 Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app

# Run specific test file
pytest tests/unit/test_user_service.py
```

## 🚀 Deployment

### Docker (Recommended)

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Run application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Environment Variables for Production

```bash
# Database
DATABASE_URL=postgresql://user:password@db-host:5432/sunglass_db

# Security
SECRET_KEY=your-production-secret-key

# CORS
BACKEND_CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# Google Cloud
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
GOOGLE_CLOUD_PROJECT_ID=your-project-id
```

## 🔄 Migration from Old Structure

The old `main.py` file has been preserved for reference. To migrate:

1. **Backup** your current `main.py` if needed
2. **Update** your environment variables
3. **Initialize** the new database structure
4. **Test** the new API endpoints
5. **Update** your frontend to use the new API structure

## 📖 Development Guidelines

### Code Organization
- **Models**: Database entities and relationships
- **Schemas**: Request/response validation
- **Services**: Business logic and data access
- **Endpoints**: API route handlers
- **Dependencies**: Reusable components

### Best Practices
- **Type hints** for all functions
- **Error handling** with proper HTTP status codes
- **Logging** for debugging and monitoring
- **Validation** of all inputs
- **Documentation** for all endpoints

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Check PostgreSQL is running
   - Verify DATABASE_URL in .env
   - Ensure database exists

2. **Import Errors**
   - Check Python path
   - Verify all dependencies installed
   - Run from correct directory

3. **Authentication Issues**
   - Check SECRET_KEY is set
   - Verify token format
   - Check token expiration

### Debug Mode

```bash
# Enable debug logging
export LOG_LEVEL=DEBUG
python run.py
```

## 📞 Support

For issues and questions:
1. Check the logs
2. Verify environment configuration
3. Test with API documentation
4. Check database connectivity

## 📄 License

MIT License - Feel free to use in your projects.
