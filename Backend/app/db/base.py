"""
Database base configuration
"""
from sqlalchemy import Column, Integer, DateTime, Boolean
from sqlalchemy.ext.declarative import as_declarative, declared_attr
from datetime import datetime


@as_declarative()
class Base:
    """Base class for all database models"""
    
    __name__: str
    
    # Generate __tablename__ automatically
    @declared_attr
    def __tablename__(cls) -> str:
        return cls.__name__.lower()
    
    # Common fields for all models
    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
