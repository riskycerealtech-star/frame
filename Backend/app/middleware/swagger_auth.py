"""
Middleware to protect Swagger UI documentation with authentication
"""
from fastapi import Request, HTTPException, status
from fastapi.responses import HTMLResponse, RedirectResponse
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.types import ASGIApp
from app.core.security import verify_token
from app.db.session import SessionLocal
from app.services.user_service import UserService
import re


class SwaggerAuthMiddleware(BaseHTTPMiddleware):
    """
    Middleware to protect Swagger documentation routes.
    Requires valid JWT token in Authorization header or cookie.
    """
    
    def __init__(self, app: ASGIApp, protected_paths: list[str] = None):
        super().__init__(app)
        # Default protected paths
        self.protected_paths = protected_paths or [
            "/docs",
            "/docs/",
            "/docs/frame",
            "/docs/frame/",
            "/docs/frame/swagger-ui",
            "/docs/frame/swagger-ui/",
            "/docs/frame/swagger-ui/index.html",
            "/docs/frame/redoc",
            "/docs/frame/redoc/",
            "/docs/frame/openapi.json",
        ]
        
        # Public paths that don't require authentication
        self.public_paths = [
            "/v1/auth/login",
            "/v1/auth/register",
            "/health",
            "/",
            "/favicon.ico",
            "/static",
        ]
    
    def is_protected_path(self, path: str) -> bool:
        """Check if path requires authentication"""
        # Check if path matches any protected pattern
        for protected_path in self.protected_paths:
            if path.startswith(protected_path):
                return True
        return False
    
    def is_public_path(self, path: str) -> bool:
        """Check if path is public (no auth required)"""
        for public_path in self.public_paths:
            if path.startswith(public_path):
                return True
        return False
    
    def get_token_from_request(self, request: Request) -> str | None:
        """Extract JWT token from Authorization header or cookie"""
        # Try Authorization header first
        auth_header = request.headers.get("Authorization")
        if auth_header:
            # Format: "Bearer <token>"
            parts = auth_header.split()
            if len(parts) == 2 and parts[0].lower() == "bearer":
                return parts[1]
        
        # Try cookie
        token = request.cookies.get("access_token")
        if token:
            return token
        
        return None
    
    async def dispatch(self, request: Request, call_next):
        """Process request and check authentication for protected paths"""
        path = request.url.path
        
        # Skip authentication for public paths
        if self.is_public_path(path):
            return await call_next(request)
        
        # Check if path requires authentication
        if self.is_protected_path(path):
            # Get token from request
            token = self.get_token_from_request(request)
            
            if not token:
                # Redirect to login page if accessing Swagger UI
                if "swagger-ui" in path or path.endswith("/docs") or path.endswith("/docs/"):
                    return RedirectResponse(url="/v1/auth/swagger-login", status_code=302)
                # Return 401 for API requests
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Authentication required",
                    headers={"WWW-Authenticate": "Bearer"},
                )
            
            # Verify token
            user_id = verify_token(token)
            if not user_id:
                # Token invalid or expired
                if "swagger-ui" in path or path.endswith("/docs") or path.endswith("/docs/"):
                    return RedirectResponse(url="/v1/auth/swagger-login?error=invalid_token", status_code=302)
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid or expired token",
                    headers={"WWW-Authenticate": "Bearer"},
                )
            
            # Verify user exists
            db = SessionLocal()
            try:
                user_service = UserService(db)
                user = user_service.get_user_by_id(int(user_id))
                if not user:
                    if "swagger-ui" in path or path.endswith("/docs") or path.endswith("/docs/"):
                        return RedirectResponse(url="/v1/auth/swagger-login?error=user_not_found", status_code=302)
                    raise HTTPException(
                        status_code=status.HTTP_401_UNAUTHORIZED,
                        detail="User not found",
                    )
            finally:
                db.close()
        
        # Continue with request
        response = await call_next(request)
        return response

