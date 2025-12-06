"""
Database session management
"""
import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

# Support Cloud SQL Unix socket connections
# If POSTGRES_SERVER starts with /cloudsql/, use Unix socket connection
postgres_server = os.environ.get("POSTGRES_SERVER", settings.POSTGRES_SERVER)
postgres_user = os.environ.get("POSTGRES_USER", settings.POSTGRES_USER)
postgres_password = os.environ.get("POSTGRES_PASSWORD", settings.POSTGRES_PASSWORD)
postgres_db = os.environ.get("POSTGRES_DB", settings.POSTGRES_DB)

if postgres_server and postgres_server.startswith("/cloudsql/"):
    # Cloud SQL Unix socket connection
    DATABASE_URL = f"postgresql+psycopg2://{postgres_user}:{postgres_password}@{postgres_server}/{postgres_db}"
else:
    # Standard TCP connection (local development or IP-based)
    DATABASE_URL = settings.DATABASE_URL

# Create database engine
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    echo=settings.LOG_LEVEL == "DEBUG"
)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create base class for models
Base = declarative_base()


def get_db():
    """Dependency to get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
