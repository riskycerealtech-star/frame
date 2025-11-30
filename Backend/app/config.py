"""
Environment variables, settings
"""
import os
from typing import Optional, Any
from pydantic_settings import BaseSettings
from pydantic import validator


class Settings(BaseSettings):
    """Application settings"""
    
    # API Settings
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Frame API Documentation"
    VERSION: str = "1.0.0"
    DESCRIPTION: str = "AI-powered sunglasses detection and marketplace API"
    
    # Database Settings
    DATABASE_URL: Optional[str] = "postgresql://postgres:password@localhost:5432/sunglass_db"
    POSTGRES_SERVER: str = "localhost"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "password"
    POSTGRES_DB: str = "sunglass_db"
    POSTGRES_PORT: str = "5432"
    
    # Security Settings
    SECRET_KEY: str = "your-secret-key-change-in-production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    ALGORITHM: str = "HS256"
    
    # CORS Settings
    BACKEND_CORS_ORIGINS: list = ["http://localhost:3000", "http://localhost:8080"]
    
    # Logging
    LOG_LEVEL: str = "INFO"
    DEBUG: bool = False
    
    # Google Cloud Settings
    GOOGLE_CLOUD_PROJECT_ID: Optional[str] = None
    GOOGLE_APPLICATION_CREDENTIALS: Optional[str] = None
    
    # Vision API Settings
    VISION_API_ENABLED: bool = True
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
