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
    title="Frame APIs Documentation",
    version="1.0.0",
    description="Comprehensive APIs for Frame marketplace operations",
    docs_url="/docs/frame/swagger-ui/index.html",
    redoc_url="/docs/frame/redoc/index.html",
    openapi_url="/docs/frame/openapi.json",
    contact={
        "name": "Frame API Support",
        "url": "https://frame.com",
    },
    tags_metadata=[
        {
            "name": "1. User Signup",
            "description": "**User Signup & Auth APIs** - Sign up, sign in, token management, and account updates. Includes endpoints for user registration, authentication, JWT token refresh, and profile management.",
        },
        {
            "name": "2. Frame Validation",
            "description": "**Frame Validation APIs** - Submit frame data or images for validation and receive status/results.",
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
from routes import auth, users, health, frame

app.include_router(auth.router, prefix="/v1/auth", tags=["1. User Signup"])
app.include_router(users.router, prefix="/v1/auth", tags=["1. User Signup"])
app.include_router(frame.router, prefix="/v1/frame", tags=["2. Frame Validation"])
app.include_router(health.router, tags=["1. User Signup"])
