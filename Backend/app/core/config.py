"""
Application configuration settings
"""
import os
from typing import Optional, Any
from pydantic_settings import BaseSettings
from pydantic import validator


class Settings(BaseSettings):
    """Application settings"""
    
    # API Settings
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Flame APIs"
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
    
    # Google Cloud Vision API
    GOOGLE_APPLICATION_CREDENTIALS: Optional[str] = None
    GOOGLE_CLOUD_PROJECT_ID: Optional[str] = None
    
    # File Upload Settings
    MAX_FILE_SIZE: int = 50 * 1024 * 1024  # 50MB
    ALLOWED_IMAGE_TYPES: list = ["image/jpeg", "image/png", "image/webp"]
    
    # AI Model Settings
    AI_CONFIDENCE_THRESHOLD: float = 0.1
    USE_AI_MODEL: bool = True
    USE_VISION_API: bool = True
    
    # Swagger UI Authentication
    SWAGGER_CLIENT_ID: str = "frame_api_admin"
    SWAGGER_CLIENT_SECRET: str = "frame_api_secret_2024"
    ENABLE_SWAGGER_AUTH: bool = False  # Set to True to enable Swagger authentication
    
    # Logging
    LOG_LEVEL: str = "INFO"
    
    @validator("DATABASE_URL", pre=True)
    def assemble_db_connection(cls, v: Optional[str], values: dict[str, Any]) -> str:
        """Assemble database URL from components"""
        if isinstance(v, str) and v:
            return v
        return f"postgresql://{values.get('POSTGRES_USER')}:{values.get('POSTGRES_PASSWORD')}@{values.get('POSTGRES_SERVER')}:{values.get('POSTGRES_PORT')}/{values.get('POSTGRES_DB')}"
    
    @validator("BACKEND_CORS_ORIGINS", pre=True)
    def assemble_cors_origins(cls, v: str | list[str]) -> list[str] | str:
        """Parse CORS origins"""
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)
    
    class Config:
        env_file = ".env"
        case_sensitive = True


# Global settings instance
settings = Settings()
