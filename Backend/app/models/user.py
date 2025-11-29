"""
User model
"""
from sqlalchemy import Column, String, Boolean, Text, DateTime, JSON
from sqlalchemy.orm import relationship
from app.db.base import Base


class User(Base):
    """User model for authentication and profile management"""
    
    __tablename__ = "users"
    
    # Basic user information
    email = Column(String(255), unique=True, index=True, nullable=False)
    username = Column(String(100), unique=True, index=True, nullable=False)
    first_name = Column(String(100), nullable=True)
    last_name = Column(String(100), nullable=True)
    full_name = Column(String(255), nullable=True)
    hashed_password = Column(String(255), nullable=False)
    
    # Profile information
    phone_number = Column(String(20), nullable=True)
    bio = Column(Text, nullable=True)
    profile_image_url = Column(String(500), nullable=True)
    
    # Business information
    occupation = Column(String(50), nullable=True)  # EMPLOYED, UNEMPLOYED, STUDENT, etc.
    source_of_funds = Column(String(50), nullable=True)  # INVESTMENT, SALARY, BUSINESS, etc.
    additional_properties = Column(JSON, nullable=True)  # For gender, location, etc.
    
    # Account status
    is_verified = Column(Boolean, default=False, nullable=False)
    is_seller = Column(Boolean, default=False, nullable=False)
    is_admin = Column(Boolean, default=False, nullable=False)
    
    # Timestamps
    last_login = Column(DateTime, nullable=True)
    email_verified_at = Column(DateTime, nullable=True)
    
    # Relationships (commented out for now to avoid circular imports)
    # products = relationship("Product", back_populates="seller")
    # orders = relationship("Order", back_populates="buyer")
    # reviews = relationship("Review", back_populates="user")
