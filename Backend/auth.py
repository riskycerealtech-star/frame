"""
Authentication utilities
"""
from datetime import datetime, timedelta
from typing import Any, Union, Optional
from jose import jwt
from passlib.context import CryptContext
from app.config import settings

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
    """Hash a password"""
    return pwd_context.hash(password)


def verify_token(token: str) -> Optional[str]:
    """Verify and decode JWT token"""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload.get("sub")
    except jwt.ExpiredSignatureError:
        return None
    except jwt.JWTError:
        return None


def is_token_expiring_soon(token: str, minutes: int = 5) -> bool:
    """Check if token is expiring soon"""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM], options={"verify_exp": False})
        exp = payload.get("exp")
        if exp:
            exp_time = datetime.fromtimestamp(exp)
            return (exp_time - datetime.utcnow()).total_seconds() < (minutes * 60)
        return False
    except jwt.JWTError:
        return False


def get_token_expiration_time(token: str) -> Optional[datetime]:
    """Get token expiration time"""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM], options={"verify_exp": False})
        exp = payload.get("exp")
        if exp:
            return datetime.fromtimestamp(exp)
        return None
    except jwt.JWTError:
        return None



