"""
Security utilities for authentication and authorization
"""
from datetime import datetime, timedelta
from typing import Any, Union, Optional
from jose import jwt
from passlib.context import CryptContext
from app.core.config import settings

# Password hashing
pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")


def create_access_token(
    subject: Union[str, Any], expires_delta: timedelta = None
) -> str:
    """Create JWT access token"""
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )
    to_encode = {"exp": expire, "sub": str(subject)}
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash"""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Generate password hash"""
    return pwd_context.hash(password)


def verify_token(token: str) -> Optional[str]:
    """Verify JWT token and return subject"""
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        return payload.get("sub")
    except jwt.JWTError:
        return None


def decode_token(token: str) -> Optional[dict]:
    """Decode JWT token without verification to read payload"""
    try:
        # Decode without verification to get payload (including expiration)
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM], options={"verify_signature": True}
        )
        return payload
    except jwt.JWTError:
        return None


def is_token_expiring_soon(token: str, threshold_minutes: int = 5) -> bool:
    """Check if token is expiring within threshold_minutes"""
    try:
        payload = decode_token(token)
        if not payload:
            return True
        
        exp = payload.get("exp")
        if not exp:
            return True
        
        # Convert exp (Unix timestamp) to datetime
        exp_datetime = datetime.fromtimestamp(exp)
        remaining_time = exp_datetime - datetime.utcnow()
        
        # Check if remaining time is less than threshold
        return remaining_time.total_seconds() < (threshold_minutes * 60)
    except Exception:
        return True


def get_token_expiration_time(token: str) -> Optional[datetime]:
    """Get the expiration datetime of a JWT token"""
    try:
        payload = decode_token(token)
        if not payload:
            return None
        
        exp = payload.get("exp")
        if not exp:
            return None
        
        return datetime.fromtimestamp(exp)
    except Exception:
        return None
