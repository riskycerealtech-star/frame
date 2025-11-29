"""
Health check routes
"""
from fastapi import APIRouter
from config import settings

router = APIRouter()


@router.get("/", tags=["1. Authentication"], include_in_schema=False)
async def root():
    """
    **Root Endpoint**
    
    Simple health check to verify the API is running.
    
    Returns basic status information about the API.
    """
    return {
        "message": "GitHub Auto-Deploy is Working! 🚀 - Test #2",
        "status": "healthy",
        "deployed_at": "2024-11-29"
    }


@router.get("/health", tags=["1. Authentication"], include_in_schema=False)
async def health_check():
    """
    **Health Check Endpoint**
    
    Detailed health information including:
    - API status
    - API version
    
    Returns comprehensive health status for monitoring.
    """
    return {
        "status": "healthy",
        "version": "1.0.0",
        "project": "Frame Backend APIs",
        "deployment": "GitHub Auto-Deploy Working! ✅",
        "last_updated": "2024-11-29"
    }

