"""
Refresh Token model for JWT token refresh mechanism
"""
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.db.base import Base
from datetime import datetime, timedelta


class RefreshToken(Base):
    """Refresh token model for managing JWT refresh tokens"""
    
    __tablename__ = "refresh_tokens"
    
    # Token information
    token = Column(String(500), unique=True, index=True, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    
    # Token status
    is_revoked = Column(Boolean, default=False, nullable=False)
    expires_at = Column(DateTime, nullable=False, index=True)
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    revoked_at = Column(DateTime, nullable=True)
    
    # Relationship
    user = relationship("User", backref="refresh_tokens")
    
    def is_expired(self) -> bool:
        """Check if token is expired"""
        return datetime.utcnow() > self.expires_at
    
    def is_valid(self) -> bool:
        """Check if token is valid (not revoked and not expired)"""
        return not self.is_revoked and not self.is_expired()

