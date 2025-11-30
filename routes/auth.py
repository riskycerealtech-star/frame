"""
Authentication routes
"""
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta

from database import get_db
from schemas import UserCreate, UserResponse, Token
from services.user_service import UserService
from auth import authenticate_user, create_access_token, get_user_by_email
from config import settings

router = APIRouter()


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["1. User Signup"],
    summary="Create new account",
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
)
def register(user: UserCreate, db: Session = Depends(get_db)):
    """
    Register a new user account.
    
    - **email**: Valid email address (must be unique)
    - **username**: Unique username (3-50 characters)
    - **password**: User password (minimum 6 characters)
    """
    user_service = UserService(db)
    return user_service.create_user(user)


@router.post(
    "/login",
    response_model=Token,
    tags=["1. User Signup"],
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
)
async def login(
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


@router.get(
    "/status/{email}",
    response_model=UserResponse,
    tags=["1. User Signup"],
    summary="Get user by email",
    description="""
    Fetch a user's profile by email.

    Returns 404 if no user is found.
    """,
)
async def get_user_by_email_status(email: str, db: Session = Depends(get_db)):
    user = get_user_by_email(db, email=email)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user

