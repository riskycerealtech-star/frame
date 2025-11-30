"""
Database initialization
This module handles database table creation
"""
from database import engine, Base


def init_db():
    """Initialize database tables"""
    Base.metadata.create_all(bind=engine)



