"""
Main FastAPI application with proper Swagger UI configuration
"""
import os
from pathlib import Path
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import FileResponse
from starlette.exceptions import HTTPException as StarletteHTTPException
from app.core.config import settings
from app.database import Base, engine
from middleware.error_handler import (
    validation_exception_handler,
    http_exception_handler,
    general_exception_handler
)

# Create database tables
Base.metadata.create_all(bind=engine)

# FastAPI app configuration
app = FastAPI(
    title=settings.PROJECT_NAME,
    description=settings.DESCRIPTION,
    version=settings.VERSION,
    docs_url="/docs/frame/swagger-ui/index.html",
    redoc_url="/docs/frame/redoc/index.html",
    openapi_url="/docs/frame/openapi.json",
    tags_metadata=[
        {
            "name": "1. User Signup",
            "description": "**User Authentication APIs** - Sign up, sign in, token management, and account updates. Includes endpoints for user registration, authentication, JWT token refresh, and profile management.",
        },
        {
            "name": "Products",
            "description": "**Product Management APIs** - Create, read, update, and delete products. Manage product listings, categories, and inventory.",
        },
        {
            "name": "Orders",
            "description": "**Order Management APIs** - Create and manage orders. Track order status, payment, and fulfillment.",
        },
        {
            "name": "2. Flame Flow",
            "description": "**AI Validation APIs** - AI-powered image analysis using Google Cloud Vision API and Hugging Face models to detect and validate sunglasses in images. Supports multiple image formats and analysis methods.",
        },
        {
            "name": "Health",
            "description": "**Health Check APIs** - System health and status monitoring endpoints.",
        },
    ],
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Exception handlers
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(StarletteHTTPException, http_exception_handler)
app.add_exception_handler(Exception, general_exception_handler)

# Custom OpenAPI setup for Bearer authentication
def setup_openapi_schema():
    from fastapi.openapi.utils import get_openapi
    
    if app.openapi_schema:
        return app.openapi_schema
        
    openapi_schema = get_openapi(
        title=app.title,
        version=app.version,
        description=app.description,
        routes=app.routes,
        tags=app.openapi_tags if hasattr(app, 'openapi_tags') else None,
    )
    
    openapi_schema["components"]["securitySchemes"] = {
        "Bearer": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "description": "Enter JWT token obtained from /login endpoint. Format: Bearer <token>"
        }
    }
    
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = setup_openapi_schema

# Include routers
from app.routes import auth, users, products, orders, ai_validation, frame

app.include_router(auth.router, prefix="/v1/auth", tags=["1. User Signup"])
app.include_router(users.router, prefix="/v1/auth", tags=["1. User Signup"])
app.include_router(products.router, prefix="/v1/products", tags=["Products"])
app.include_router(orders.router, prefix="/v1/orders", tags=["Orders"])
app.include_router(ai_validation.router, prefix="/v1", tags=["2. Flame Flow"])
app.include_router(frame.router, prefix="/v1/frame", tags=["2. Flame Flow"])

# Health check endpoint
@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "version": settings.VERSION,
        "project": settings.PROJECT_NAME
    }

@app.get("/", tags=["Health"])
async def root():
    """Root endpoint"""
    return {
        "message": f"Welcome to {settings.PROJECT_NAME}",
        "version": settings.VERSION,
        "docs": "/docs/frame/swagger-ui/index.html"
    }

# Favicon endpoint - browsers and Swagger UI automatically request this
@app.get("/favicon.ico", include_in_schema=False)
async def favicon():
    """Serve favicon.ico for browser tabs and Swagger UI"""
    # Get the path to the static directory (Backend/static/)
    base_dir = Path(__file__).resolve().parent.parent
    favicon_path = base_dir / "static" / "favicon.ico"
    
    if favicon_path.exists():
        return FileResponse(
            path=str(favicon_path),
            media_type="image/x-icon",
            headers={"Cache-Control": "public, max-age=31536000"}
        )
    else:
        # Return 204 No Content if favicon not found (prevents 404 errors in browser console)
        from starlette.responses import Response
        return Response(status_code=204)