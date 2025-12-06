"""
Main API router
"""
from fastapi import APIRouter
from app.api.v1.endpoints import users, ai_validation

api_router = APIRouter()

# Include working endpoint routers
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(ai_validation.router, prefix="/ai", tags=["2. Publish Flame"])

# TODO: Add other routers once circular import issues are resolved
# api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
# api_router.include_router(products.router, prefix="/products", tags=["products"])
# api_router.include_router(orders.router, prefix="/orders", tags=["orders"])
