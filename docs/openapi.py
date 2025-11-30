"""
OpenAPI schema customization
"""
from fastapi import FastAPI


def setup_openapi_schema(app: FastAPI):
    """
    Customize OpenAPI schema to add security scheme
    """
    def custom_openapi():
        if app.openapi_schema:
            return app.openapi_schema
        from fastapi.openapi.utils import get_openapi
        openapi_schema = get_openapi(
            title=app.title,
            version=app.version,
            description=app.description,
            routes=app.routes,
            tags=app.openapi_tags if hasattr(app, 'openapi_tags') else None,
        )
        # Add security scheme
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
    
    app.openapi = custom_openapi



