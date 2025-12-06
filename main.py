from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from datetime import timedelta
from database import engine, get_db, Base
from models import User
from schemas import UserCreate, UserResponse, Token, ErrorResponse, MessageResponse
from auth import (
    get_password_hash,
    authenticate_user,
    create_access_token,
    get_user_by_email,
    get_user_by_username,
    get_current_user,
    oauth2_scheme,
)
from config import settings

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Flame APIs",
    version="1.0.0",
    description="",
    contact={
        "name": "Frame API Support",
        "email": "support@example.com",
    },
    license_info={
        "name": "MIT",
    },
    tags_metadata=[
        {
            "name": "Authentication",
            "description": "User authentication endpoints. Register new users and login to get JWT tokens.",
        },

        {
            "name": "Users",
            "description": "User profile and information endpoints. Requires authentication.",
        },
        {
            "name": "General",
            "description": "General API information endpoints.",
        },
    ],
    servers=[
        {
            "url": "http://localhost:8000",
            "description": "Development server"
        },
        {
            "url": "https://your-cloud-run-url.run.app",
            "description": "Production server (Cloud Run)"
        }
    ],
)

# Customize OpenAPI schema to add security scheme
def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    from fastapi.openapi.utils import get_openapi
    openapi_schema = get_openapi(
        title=app.title,
        version=app.version,
        description=app.description,
        routes=app.routes,
        tags=app.openapi_tags if hasattr(app, 'openapi_tags') else None,
    )
    # Add security scheme
    openapi_schema["components"]["securitySchemes"] = {
        "Bearer": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "description": "Enter JWT token obtained from /login endpoint. Format: Bearer <token>"
        }
    }
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi


@app.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Authentication"],
    summary="Register a new user",
    description="""
    Register a new user account with email, username, and password.
    
    **Requirements:**
    - Email must be valid and unique
    - Username must be unique (3-50 characters)
    - Password should be at least 6 characters (8+ recommended)
    
    **Returns:**
    - User object with id, email, username, and creation timestamp
    - Password is never returned in the response
    """,
    responses={
        201: {
            "description": "User successfully created",
            "content": {
                "application/json": {
                    "example": {
                        "id": 1,
                        "email": "user@example.com",
                        "username": "johndoe",
                        "created_at": "2025-01-15T10:30:00"
                    }
                }
            }
        },
        400: {
            "description": "Bad request - Email or username already exists",
            "model": ErrorResponse,
            "content": {
                "application/json": {
                    "examples": {
                        "email_exists": {
                            "summary": "Email already registered",
                            "value": {"detail": "Email already registered"}
                        },
                        "username_exists": {
                            "summary": "Username already taken",
                            "value": {"detail": "Username already taken"}
                        }
                    }
                }
            }
        },
        422: {
            "description": "Validation error - Invalid input data",
        }
    }
)
def register(user: UserCreate, db: Session = Depends(get_db)):
    """
    Register a new user account.
    
    - **email**: Valid email address (must be unique)
    - **username**: Unique username (3-50 characters)
    - **password**: User password (minimum 6 characters)
    """
    # Check if user with email already exists
    db_user = get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Check if user with username already exists
    db_user = get_user_by_username(db, username=user.username)
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already taken"
        )
    
    # Create new user
    hashed_password = get_password_hash(user.password)
    db_user = User(
        email=user.email,
        username=user.username,
        hashed_password=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


@app.post(
    "/login",
    response_model=Token,
    tags=["Authentication"],
    summary="Login and get access token",
    description="""
    Authenticate a user and receive a JWT access token.
    
    **How to use:**
    1. Send username and password as form data (application/x-www-form-urlencoded)
    2. Receive a JWT access token in response
    3. Use the token in the `Authorization` header for protected endpoints:
       ```
       Authorization: Bearer <access_token>
       ```
    
    **Token Details:**
    - Token type: Bearer
    - Expiration: 30 minutes (configurable)
    - Contains: Username in the `sub` claim
    """,
    responses={
        200: {
            "description": "Successfully authenticated",
            "content": {
                "application/json": {
                    "example": {
                        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJqb2huZG9lIiwiZXhwIjoxNzA1MzI0MDAwfQ.example",
                        "token_type": "bearer"
                    }
                }
            }
        },
        401: {
            "description": "Authentication failed - Invalid credentials",
            "model": ErrorResponse,
            "headers": {
                "WWW-Authenticate": {
                    "description": "Bearer authentication scheme",
                    "schema": {"type": "string", "example": "Bearer"}
                }
            },
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Incorrect username or password"
                    }
                }
            }
        },
        422: {
            "description": "Validation error - Missing username or password",
        }
    }
)
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    """
    Login with username and password to get a JWT access token.
    
    - **username**: Your registered username
    - **password**: Your account password
    
    Returns a JWT token that can be used to authenticate requests to protected endpoints.
    """
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}


@app.get(
    "/me",
    response_model=UserResponse,
    tags=["Users"],
    summary="Get current user information",
    description="""
    Get the profile information of the currently authenticated user.
    
    **Authentication Required:** Yes
    
    This endpoint requires a valid JWT token in the Authorization header.
    The user information is extracted from the token.
    """,
    dependencies=[Depends(oauth2_scheme)],
    responses={
        200: {
            "description": "Current user information",
            "content": {
                "application/json": {
                    "example": {
                        "id": 1,
                        "email": "user@example.com",
                        "username": "johndoe",
                        "created_at": "2025-01-15T10:30:00"
                    }
                }
            }
        },
        401: {
            "description": "Unauthorized - Invalid or missing token",
            "model": ErrorResponse,
            "content": {
                "application/json": {
                    "examples": {
                        "missing_token": {
                            "summary": "No token provided",
                            "value": {"detail": "Not authenticated"}
                        },
                        "invalid_token": {
                            "summary": "Invalid token",
                            "value": {"detail": "Could not validate credentials"}
                        },
                        "expired_token": {
                            "summary": "Token expired",
                            "value": {"detail": "Token has expired"}
                        }
                    }
                }
            }
        }
    }
)
def read_users_me(current_user: User = Depends(get_current_user)):
    """
    Get the current authenticated user's profile information.
    
    Requires a valid JWT token in the Authorization header.
    Returns the user's id, email, username, and account creation date.
    """
    return current_user


@app.get(
    "/",
    response_model=MessageResponse,
    tags=["General"],
    summary="API root endpoint",
    description="""
    Welcome endpoint that provides basic API information.
    
    This is a public endpoint that doesn't require authentication.
    Use this to verify the API is running and accessible.
    """,
    responses={
        200: {
            "description": "API is running",
            "content": {
                "application/json": {
                    "example": {
                        "message": "Welcome to Frame API"
                    }
                }
            }
        }
    }
)
def root():
    """
    Root endpoint - Welcome message.
    
    Returns a welcome message confirming the API is running.
    No authentication required.
    """
    return {"message": "Welcome to Frame API"}


