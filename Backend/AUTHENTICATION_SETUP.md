# Authentication & Authorization Setup Guide

## Overview

This document describes the comprehensive authentication and authorization system implemented for the FastAPI backend, including protection for Swagger API documentation.

## Features Implemented

### 1. User Authentication System

#### A. User Registration (`POST /v1/auth/register`)

- **Fields**: Email, First Name, Last Name, Phone Number, Password, Gender, Location
- **Password Requirements**:
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
  - Special characters recommended
- **Validation**: Email and phone number uniqueness checks
- **Response**: Returns user ID, email, phone number, and status

#### B. User Login (`POST /v1/auth/login`)

- **Supports**: Email, username, or phone number as identifier
- **Returns**: 
  - Access token (valid for 24 hours)
  - Refresh token (valid for 7 days)
- **Updates**: Last login timestamp

#### C. Token Management

- **Access Token**: JWT token, expires in 24 hours (1440 minutes)
- **Refresh Token**: Secure random token stored in database, expires in 7 days
- **Endpoints**:
  - `POST /v1/auth/refresh` - Refresh access token using refresh token
  - `POST /v1/auth/logout` - Logout and revoke refresh token
  - `POST /v1/auth/logout-all` - Logout from all devices

### 2. Protected Swagger Documentation

#### A. Authentication Middleware

The `SwaggerAuthMiddleware` protects all `/docs/*` routes:
- Intercepts requests to Swagger UI, ReDoc, and OpenAPI JSON
- Validates JWT token from:
  - `Authorization` header (Bearer token)
  - `access_token` cookie
- Redirects unauthenticated users to login page
- Returns 401 for API requests without valid token

#### B. Swagger Login Page

- **URL**: `/v1/auth/swagger-login`
- **Features**:
  - Beautiful, responsive login form
  - Supports email or phone number login
  - Sets `access_token` cookie on successful login
  - Redirects to Swagger UI after authentication

#### C. Dashboard Page

- **URL**: `/v1/auth/swagger-dashboard`
- **Features**:
  - Welcome message with user information
  - Links to Swagger UI, ReDoc, and OpenAPI spec
  - User profile information
  - Logout button

### 3. Rate Limiting

The `RateLimitMiddleware` implements different limits for different endpoints:

- **Login**: 5 attempts per 15 minutes per IP
- **Registration**: 3 attempts per hour per IP
- **API Requests**: 100 requests per minute per user
- **Headers**: Returns `X-RateLimit-*` headers with limit information

### 4. Database Schema

#### Users Table
- All fields from signup screen (firstName, lastName, phoneNumber, gender, location)
- Password hashed with bcrypt
- Account status flags (is_verified, is_seller, is_admin)
- Timestamps (created_at, updated_at, last_login)

#### Refresh Tokens Table
- Token storage with expiration
- User association
- Revocation support
- Automatic cleanup of expired tokens

### 5. Security Features

- **Password Hashing**: bcrypt with pbkdf2_sha256
- **JWT Security**: 
  - Strong secret key (configured in environment)
  - HS256 algorithm
  - Token expiration
  - Token blacklisting on logout
- **HTTPS Ready**: Secure cookie flags (set `secure=True` in production)
- **CORS Configuration**: Configurable allowed origins

## Configuration

### Environment Variables

Add to your `.env` file:

```env
# Enable Swagger authentication (set to True to protect /docs routes)
ENABLE_SWAGGER_AUTH=False

# JWT Settings
SECRET_KEY=your-strong-secret-key-change-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=1440  # 24 hours
REFRESH_TOKEN_EXPIRE_DAYS=7

# Database
DATABASE_URL=postgresql://postgres:password@localhost:5432/sunglass_db
```

### Enabling Swagger Protection

1. Set `ENABLE_SWAGGER_AUTH=True` in your `.env` file
2. Restart the FastAPI server
3. Accessing `/docs/frame/swagger-ui/index.html` will redirect to login page
4. Users must authenticate before accessing API documentation

## Usage

### 1. Register a New User

```bash
curl -X POST "http://localhost:8000/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "+1234567890",
    "password": "SecurePass123",
    "gender": "Male",
    "location": "New York"
  }'
```

### 2. Login

```bash
curl -X POST "http://localhost:8000/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "user@example.com",
    "password": "SecurePass123"
  }'
```

Response:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "abc123...",
  "token_type": "bearer"
}
```

### 3. Access Protected Endpoints

```bash
curl -X GET "http://localhost:8000/v1/auth/me" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 4. Refresh Token

```bash
curl -X POST "http://localhost:8000/v1/auth/refresh" \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "YOUR_REFRESH_TOKEN"
  }'
```

### 5. Access Swagger UI (When Protected)

1. Navigate to `http://localhost:8000/docs/frame/swagger-ui/index.html`
2. You'll be redirected to `/v1/auth/swagger-login`
3. Enter your credentials
4. You'll be redirected to Swagger UI with authentication cookie set

## API Endpoints

### Authentication Endpoints

- `POST /v1/auth/register` - Register new user
- `POST /v1/auth/login` - Login and get tokens
- `POST /v1/auth/refresh` - Refresh access token
- `POST /v1/auth/logout` - Logout (revoke refresh token)
- `POST /v1/auth/logout-all` - Logout from all devices
- `GET /v1/auth/me` - Get current user information

### Swagger UI Endpoints

- `GET /v1/auth/swagger-login` - Login page for Swagger UI
- `POST /v1/auth/swagger-login` - Handle login form submission
- `GET /v1/auth/swagger-dashboard` - Dashboard after login
- `GET /v1/auth/swagger-logout` - Logout from Swagger UI

## Database Migrations

After adding the new models, run Alembic migrations:

```bash
# Create migration
alembic revision --autogenerate -m "Add refresh tokens and update user model"

# Apply migration
alembic upgrade head
```

Or if using SQLAlchemy directly:

```python
from app.database import Base, engine
from app.models import User, RefreshToken

Base.metadata.create_all(bind=engine)
```

## Testing

### Test Registration

```bash
# Test with valid data
curl -X POST "http://localhost:8000/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "firstName": "Test",
    "lastName": "User",
    "phoneNumber": "+1234567890",
    "password": "TestPass123",
    "gender": "Male",
    "location": "Test Location"
  }'
```

### Test Login

```bash
curl -X POST "http://localhost:8000/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test@example.com",
    "password": "TestPass123"
  }'
```

### Test Rate Limiting

Try making more than 5 login requests in 15 minutes from the same IP to see rate limiting in action.

## Production Considerations

1. **HTTPS**: Set `secure=True` in cookie settings when using HTTPS
2. **Secret Key**: Use a strong, randomly generated secret key
3. **Database**: Use connection pooling and proper indexing
4. **Rate Limiting**: Consider using Redis for distributed rate limiting
5. **Token Storage**: Consider using Redis for token blacklisting
6. **Monitoring**: Add logging for authentication events
7. **Security Headers**: Add security headers (HSTS, CSP, etc.)

## Troubleshooting

### Swagger UI Not Redirecting to Login

- Check that `ENABLE_SWAGGER_AUTH=True` in `.env`
- Restart the FastAPI server
- Clear browser cookies and try again

### Token Expired Errors

- Access tokens expire after 24 hours
- Use refresh token endpoint to get new access token
- Refresh tokens expire after 7 days

### Rate Limit Errors

- Check `X-RateLimit-*` headers for limit information
- Wait for the reset time indicated in `Retry-After` header
- Consider using different IP or waiting for the window to reset

## Support

For issues or questions, please refer to the main README or contact the development team.

