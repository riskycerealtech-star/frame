"""
Refresh Token Service for managing refresh tokens
"""
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from typing import Optional
from app.models.refresh_token import RefreshToken
from app.core.config import settings
from app.core.security import create_refresh_token


class RefreshTokenService:
    """Service for managing refresh tokens"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def create_refresh_token(self, user_id: int) -> RefreshToken:
        """Create a new refresh token for a user"""
        # Generate token
        token = create_refresh_token()
        
        # Calculate expiration
        expires_at = datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
        
        # Create refresh token record
        refresh_token = RefreshToken(
            token=token,
            user_id=user_id,
            expires_at=expires_at
        )
        
        self.db.add(refresh_token)
        self.db.commit()
        self.db.refresh(refresh_token)
        
        return refresh_token
    
    def get_refresh_token(self, token: str) -> Optional[RefreshToken]:
        """Get refresh token by token string"""
        return self.db.query(RefreshToken).filter(
            RefreshToken.token == token
        ).first()
    
    def revoke_token(self, token: str) -> bool:
        """Revoke a refresh token"""
        refresh_token = self.get_refresh_token(token)
        if not refresh_token:
            return False
        
        refresh_token.is_revoked = True
        refresh_token.revoked_at = datetime.utcnow()
        self.db.commit()
        return True
    
    def revoke_all_user_tokens(self, user_id: int) -> int:
        """Revoke all refresh tokens for a user"""
        tokens = self.db.query(RefreshToken).filter(
            RefreshToken.user_id == user_id,
            RefreshToken.is_revoked == False
        ).all()
        
        count = 0
        for token in tokens:
            token.is_revoked = True
            token.revoked_at = datetime.utcnow()
            count += 1
        
        self.db.commit()
        return count
    
    def is_token_valid(self, token: str) -> bool:
        """Check if a refresh token is valid"""
        refresh_token = self.get_refresh_token(token)
        if not refresh_token:
            return False
        return refresh_token.is_valid()
    
    def cleanup_expired_tokens(self) -> int:
        """Remove expired tokens from database"""
        expired_tokens = self.db.query(RefreshToken).filter(
            RefreshToken.expires_at < datetime.utcnow()
        ).all()
        
        count = len(expired_tokens)
        for token in expired_tokens:
            self.db.delete(token)
        
        self.db.commit()
        return count

