from pydantic_settings import BaseSettings
from typing import Optional
import os


class Settings(BaseSettings):
    # JWT Settings
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-change-this-in-production")
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
    
    # Database Settings
    # For Cloud SQL, use: postgresql://user:password@/dbname?host=/cloudsql/PROJECT_ID:REGION:INSTANCE_ID
    # For Cloud Run with Cloud SQL, the connection will be via Unix socket
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "sqlite:///./app.db"
    )
    
    # Cloud Run port
    PORT: int = int(os.getenv("PORT", "8080"))
    
    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()

