"""
Authentication endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.db.session import get_db
from app.schemas.user import UserCreate, UserResponse, Token
from app.services.user_service import UserService
from app.core.security import create_access_token, verify_password
from app.api.v1.dependencies import get_current_user
from datetime import timedelta


class LoginRequest(BaseModel):
    """Login request schema"""
    username: str
    password: str

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="v1/auth/login")


@router.post("/register", response_model=UserResponse, summary="Create new account")
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """Register a new user"""
    user_service = UserService(db)
    
    # Check if user already exists
    if user_service.get_user_by_email(user_data.email):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    if user_service.get_user_by_username(user_data.username):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already taken"
        )
    
    # Create user
    user = user_service.create_user(user_data)
    return user


@router.post("/login", response_model=Token, summary="Login and get access token")
async def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    """Login user and return access token"""
    user_service = UserService(db)
    
    # Authenticate user
    user = user_service.authenticate_user(login_data.username, login_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Create access token
    access_token_expires = timedelta(minutes=30)
    access_token = create_access_token(
        data={"sub": str(user.id)}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer"
    }


@router.get("/status/email/{email}", response_model=UserResponse, summary="Get user by email")
async def get_user_by_email(email: str, db: Session = Depends(get_db)):
    """Get user information by email address"""
    user_service = UserService(db)
    user = user_service.get_user_by_email(email)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user
