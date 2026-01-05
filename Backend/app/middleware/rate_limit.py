"""
Rate limiting middleware to prevent abuse
"""
from fastapi import Request, HTTPException, status
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.types import ASGIApp
from collections import defaultdict
from datetime import datetime, timedelta
from typing import Dict, Tuple


class RateLimitMiddleware(BaseHTTPMiddleware):
    """
    Rate limiting middleware with different limits for different endpoints:
    - Login: 5 attempts per 15 minutes per IP
    - Registration: 3 attempts per hour per IP
    - API requests: 100 requests per minute per user
    """
    
    def __init__(self, app: ASGIApp):
        super().__init__(app)
        
        # Rate limit configurations
        self.limits = {
            "/v1/auth/login": {
                "max_requests": 5,
                "window": timedelta(minutes=15),
                "key_prefix": "login"
            },
            "/v1/auth/register": {
                "max_requests": 3,
                "window": timedelta(hours=1),
                "key_prefix": "register"
            },
            "default": {
                "max_requests": 100,
                "window": timedelta(minutes=1),
                "key_prefix": "api"
            }
        }
        
        # In-memory storage (use Redis in production)
        self.request_counts: Dict[str, list[datetime]] = defaultdict(list)
    
    def get_client_identifier(self, request: Request) -> str:
        """Get client identifier (IP address)"""
        # Check for forwarded IP (behind proxy)
        forwarded_for = request.headers.get("X-Forwarded-For")
        if forwarded_for:
            return forwarded_for.split(",")[0].strip()
        
        # Check for real IP
        real_ip = request.headers.get("X-Real-IP")
        if real_ip:
            return real_ip
        
        # Fallback to client host
        return request.client.host if request.client else "unknown"
    
    def get_rate_limit_config(self, path: str) -> Dict:
        """Get rate limit configuration for path"""
        # Check exact match first
        if path in self.limits:
            return self.limits[path]
        
        # Check if path starts with any configured path
        for limit_path, config in self.limits.items():
            if limit_path != "default" and path.startswith(limit_path):
                return config
        
        # Return default
        return self.limits["default"]
    
    def is_rate_limited(self, key: str, max_requests: int, window: timedelta) -> Tuple[bool, int, int]:
        """
        Check if request is rate limited.
        Returns: (is_limited, remaining_requests, reset_after_seconds)
        """
        now = datetime.utcnow()
        
        # Clean old entries
        self.request_counts[key] = [
            timestamp for timestamp in self.request_counts[key]
            if now - timestamp < window
        ]
        
        # Check if limit exceeded
        request_count = len(self.request_counts[key])
        is_limited = request_count >= max_requests
        
        # Calculate remaining requests
        remaining = max(0, max_requests - request_count)
        
        # Calculate reset time
        if self.request_counts[key]:
            oldest_request = min(self.request_counts[key])
            reset_after = (oldest_request + window - now).total_seconds()
        else:
            reset_after = window.total_seconds()
        
        return is_limited, remaining, int(reset_after)
    
    def record_request(self, key: str):
        """Record a request"""
        self.request_counts[key].append(datetime.utcnow())
    
    async def dispatch(self, request: Request, call_next):
        """Process request and apply rate limiting"""
        path = request.url.path
        
        # Skip rate limiting for health checks and static files
        if path in ["/health", "/", "/favicon.ico"] or path.startswith("/static"):
            return await call_next(request)
        
        # Get rate limit configuration
        config = self.get_rate_limit_config(path)
        
        # Get client identifier
        client_id = self.get_client_identifier(request)
        
        # Create rate limit key
        key = f"{config['key_prefix']}:{client_id}"
        
        # Check rate limit
        is_limited, remaining, reset_after = self.is_rate_limited(
            key,
            config["max_requests"],
            config["window"]
        )
        
        if is_limited:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=f"Rate limit exceeded. Try again in {reset_after} seconds.",
                headers={
                    "X-RateLimit-Limit": str(config["max_requests"]),
                    "X-RateLimit-Remaining": "0",
                    "X-RateLimit-Reset": str(reset_after),
                    "Retry-After": str(reset_after)
                }
            )
        
        # Record request
        self.record_request(key)
        
        # Continue with request
        response = await call_next(request)
        
        # Add rate limit headers
        response.headers["X-RateLimit-Limit"] = str(config["max_requests"])
        response.headers["X-RateLimit-Remaining"] = str(remaining - 1)
        response.headers["X-RateLimit-Reset"] = str(reset_after)
        
        return response

