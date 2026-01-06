"""
Authentication endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import JSONResponse
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from app.db.session import get_db
from app.schemas.user import (
    UserCreate, UserResponse, Token, LoginRequest, 
    RefreshTokenRequest, UserSignupRequest, UserSignupResponse
)
from app.services.user_service import UserService
from app.services.refresh_token_service import RefreshTokenService
from app.core.security import (
    create_access_token, verify_password, validate_password
)
from app.api.v1.dependencies import get_current_user

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="v1/auth/login")


@router.post(
    "/register",
    response_model=UserSignupResponse,
    summary="Create new account",
    description="""
    Register a new user with required signup fields.
    
    **Required Fields:**
    - `email`: Valid email address
    - `firstName`: First name (minimum 2 characters)
    - `lastName`: Last name (minimum 2 characters)
    - `phoneNumber`: Phone number starting with + (e.g., +1234567890)
    - `password`: Password meeting security requirements
    - `rePassword`: Re-enter password (must match password)
    - `gender`: Must be "Male", "Female", or "N/A"
    
    **Password Requirements:**
    - Minimum 8 characters
    - At least one uppercase letter (A-Z)
    - At least one lowercase letter (a-z)
    - At least one number (0-9)
    
    **Response Body:**
    Returns user ID, email, phone number, and status upon successful registration:
    - `status`: Account creation status
    - `email`: User's email address
    - `userId`: Unique user identifier
    - `phoneNumber`: User's phone number
    
    **Response Headers:**
    - `createdOn`: Timestamp when the account was created (ISO 8601 format, e.g., "2019-10-11T08:00:00Z")
    - `updatedOn`: Timestamp when the account was last updated (ISO 8601 format, e.g., "2019-10-11T08:00:00Z")
    """
)
async def register(user_data: UserSignupRequest, db: Session = Depends(get_db)):
    """
    Register a new user with all signup fields.
    Returns user data in body and createdOn/updatedOn in response headers.
    """
    user_service = UserService(db)
    
    # Validate password strength
    is_valid, error_msg = validate_password(user_data.password)
    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_msg
        )
    
    try:
        # Create user using signup_user method (includes duplicate checks)
        result = user_service.signup_user(user_data)
        
        # Extract timestamps for headers
        created_on = result.get("createdOn", "")
        updated_on = result.get("updatedOn", "")
        
        # Remove timestamps from body (they'll be in headers)
        response_body = {
            "status": result["status"],
            "email": result["email"],
            "userId": result["userId"],
            "phoneNumber": result["phoneNumber"]
        }
        
        # Return JSONResponse with timestamps in headers
        return JSONResponse(
            content=response_body,
            status_code=status.HTTP_201_CREATED,
            headers={
                "createdOn": created_on,
                "updatedOn": updated_on
            }
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(e)
        )


@router.post("/login", response_model=Token, summary="Login and get access token")
async def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    """
    Login user with email/phone and password.
    Returns access token (24 hours) and refresh token (7 days).
    Supports email or phone number as username.
    """
    user_service = UserService(db)
    refresh_token_service = RefreshTokenService(db)
    
    # Authenticate user (supports email or phone number)
    user = user_service.authenticate_user(login_data.username, login_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email/phone or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Update last login
    user.last_login = datetime.utcnow()
    db.commit()
    
    # Create access token (24 hours - configured in settings)
    access_token = create_access_token(subject=str(user.id))
    
    # Create refresh token (7 days)
    refresh_token_obj = refresh_token_service.create_refresh_token(user.id)
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token_obj.token,
        "token_type": "bearer"
    }


@router.post("/refresh", response_model=Token, summary="Refresh access token")
async def refresh_token(
    refresh_data: RefreshTokenRequest,
    db: Session = Depends(get_db)
):
    """
    Refresh access token using refresh token.
    Returns new access token and refresh token.
    """
    refresh_token_service = RefreshTokenService(db)
    user_service = UserService(db)
    
    # Validate refresh token
    if not refresh_token_service.is_token_valid(refresh_data.refresh_token):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Get refresh token object
    refresh_token_obj = refresh_token_service.get_refresh_token(refresh_data.refresh_token)
    if not refresh_token_obj:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token not found",
        )
    
    # Get user
    user = user_service.get_user_by_id(refresh_token_obj.user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    
    # Revoke old refresh token
    refresh_token_service.revoke_token(refresh_data.refresh_token)
    
    # Create new access token
    access_token = create_access_token(subject=str(user.id))
    
    # Create new refresh token
    new_refresh_token_obj = refresh_token_service.create_refresh_token(user.id)
    
    return {
        "access_token": access_token,
        "refresh_token": new_refresh_token_obj.token,
        "token_type": "bearer"
    }


@router.post("/logout", summary="Logout and revoke tokens")
async def logout(
    refresh_data: RefreshTokenRequest,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Logout user and revoke refresh token.
    Optionally revoke all user tokens.
    """
    refresh_token_service = RefreshTokenService(db)
    
    # Revoke the provided refresh token
    if refresh_token_service.revoke_token(refresh_data.refresh_token):
        return {"message": "Logged out successfully"}
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid refresh token"
        )


@router.post("/logout-all", summary="Logout from all devices")
async def logout_all(
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Logout user from all devices by revoking all refresh tokens.
    """
    refresh_token_service = RefreshTokenService(db)
    count = refresh_token_service.revoke_all_user_tokens(current_user.id)
    
    return {
        "message": f"Logged out from {count} device(s)",
        "revoked_tokens": count
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
