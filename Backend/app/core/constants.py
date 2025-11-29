"""
API Constants and Configuration
Contains base URLs and API endpoints
"""

# API Base URL - Production
API_BASE_URL = "https://glass-api-750669515844.us-central1.run.app"

# API Base URL - Local Development
API_BASE_URL_LOCAL = "http://localhost:8080"

# API Version Prefix
API_V1_PREFIX = "/v1"

# Full API Base URLs
API_V1_BASE_URL = f"{API_BASE_URL}{API_V1_PREFIX}"
API_V1_BASE_URL_LOCAL = f"{API_BASE_URL_LOCAL}{API_V1_PREFIX}"

# API Endpoints
class APIEndpoints:
    """API endpoint paths (without base URL)"""
    
    # Authentication endpoints
    USER_SIGNUP = "/v1/user/signup"
    USER_SIGNIN = "/v1/user/signin"
    USER_SIGNOUT = "/v1/user/signout"
    USER_REFRESH_TOKEN = "/v1/user/refresh-token"
    USER_UPDATE = "/v1/user/{user_id}"
    USER_GET = "/v1/user/{user_id}"
    USER_LIST = "/v1/users"
    
    # AI Validation endpoints
    AI_VALIDATE_IMAGE = "/v1/ai/validate-image"
    AI_DETECT_SUNGLASSES = "/v1/ai/detect-sunglasses"
    
    # Health check
    HEALTH_CHECK = "/health"
    API_DOCS = "/docs"
    API_REDOC = "/redoc"
    API_OPENAPI = "/openapi.json"

# Full API URLs (for external use)
class APIConstants:
    """Full API URLs with base URL"""
    
    @staticmethod
    def get_base_url(use_local: bool = False) -> str:
        """Get the base API URL"""
        return API_BASE_URL_LOCAL if use_local else API_BASE_URL
    
    @staticmethod
    def get_v1_base_url(use_local: bool = False) -> str:
        """Get the v1 API base URL"""
        return API_V1_BASE_URL_LOCAL if use_local else API_V1_BASE_URL
    
    @staticmethod
    def get_endpoint(endpoint: str, use_local: bool = False) -> str:
        """Get full URL for an endpoint"""
        base_url = APIConstants.get_base_url(use_local)
        return f"{base_url}{endpoint}"
    
    # Full endpoint URLs
    @staticmethod
    def user_signup(use_local: bool = False) -> str:
        return APIConstants.get_endpoint(APIEndpoints.USER_SIGNUP, use_local)
    
    @staticmethod
    def user_signin(use_local: bool = False) -> str:
        return APIConstants.get_endpoint(APIEndpoints.USER_SIGNIN, use_local)
    
    @staticmethod
    def user_get(user_id: str, use_local: bool = False) -> str:
        return APIConstants.get_endpoint(APIEndpoints.USER_GET.format(user_id=user_id), use_local)
    
    @staticmethod
    def user_update(user_id: str, use_local: bool = False) -> str:
        return APIConstants.get_endpoint(APIEndpoints.USER_UPDATE.format(user_id=user_id), use_local)
    
    @staticmethod
    def user_list(use_local: bool = False) -> str:
        return APIConstants.get_endpoint(APIEndpoints.USER_LIST, use_local)
    
    @staticmethod
    def ai_validate_image(use_local: bool = False) -> str:
        return APIConstants.get_endpoint(APIEndpoints.AI_VALIDATE_IMAGE, use_local)
    
    @staticmethod
    def health_check(use_local: bool = False) -> str:
        return APIConstants.get_endpoint(APIEndpoints.HEALTH_CHECK, use_local)



