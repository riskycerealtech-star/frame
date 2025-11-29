"""
Main application entry point
This file should only:
- Create the FastAPI app
- Register routers
- Apply global configuration
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import settings
from docs.openapi import setup_openapi_schema
from database_init import init_db

# Initialize database tables
init_db()

# Create FastAPI application
app = FastAPI(
    title="Frame API Documentation",
    version="1.0.0",
    description="Comprehensive API for Frame marketplace operations",
    docs_url="/docs/frame/swagger-ui/index.html",
    redoc_url="/docs/frame/redoc/index.html",
    openapi_url="/docs/frame/openapi.json",
    contact={
        "name": "Frame API Support",
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
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Setup custom OpenAPI schema
setup_openapi_schema(app)

# Register routers
from routes import auth, users, health

app.include_router(auth.router, prefix="/api/v1", tags=["1. Authentication"])
app.include_router(users.router, prefix="/api/v1", tags=["1. Authentication"])
app.include_router(health.router, tags=["1. Authentication"])
