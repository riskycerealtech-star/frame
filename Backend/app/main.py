"""
Entry point (FastAPI/Flask initialization)
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import Base, engine
from middleware.error_handler import (
    validation_exception_handler,
    http_exception_handler,
    general_exception_handler
)
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException

# Create database tables
Base.metadata.create_all(bind=engine)

# Create FastAPI application
app = FastAPI(
    title=settings.PROJECT_NAME,
    description=settings.DESCRIPTION,
    version=settings.VERSION,
    docs_url="/docs/frame/swagger-ui/index.html",
    redoc_url="/docs/frame/redoc/index.html",
    openapi_url="/docs/frame/openapi.json",
    contact={
        "name": "Frame Backend APIs Support",
        "url": "https://frame.com",
    },
    tags_metadata=[
        {
            "name": "1. Authentication",
            "description": "**User Authentication APIs** - Sign up, sign in, token management, and account updates. Includes endpoints for user registration, authentication, JWT token refresh, and profile management.",
        },
        {
            "name": "2. AI Validation",
            "description": "**AI Validation APIs** - AI-powered image analysis using Google Cloud Vision API and Hugging Face models to detect and validate sunglasses in images. Supports multiple image formats and analysis methods.",
        },
    ],
)

# Set up CORS middleware
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

# Add exception handlers
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(StarletteHTTPException, http_exception_handler)
app.add_exception_handler(Exception, general_exception_handler)

# Import and include routers from app.routes
from app.routes import users, products, orders, auth, ai_validation

app.include_router(auth.router, prefix="/api/v1/auth", tags=["1. Authentication"])
app.include_router(users.router, prefix="/api/v1/users", tags=["1. Authentication"])
app.include_router(products.router, prefix="/api/v1/products", tags=["Products"])
app.include_router(orders.router, prefix="/api/v1/orders", tags=["Orders"])
app.include_router(ai_validation.router, prefix="/api/v1", tags=["2. AI Validation"])


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "GitHub Auto-Deploy is Working! 🚀 - Updated",
        "version": settings.VERSION,
        "docs": "/docs/frame/swagger-ui/index.html"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "version": settings.VERSION,
        "project": settings.PROJECT_NAME,
        "deployment": "GitHub Auto-Deploy Working! ✅",
        "last_updated": "2024-11-29"
    }
