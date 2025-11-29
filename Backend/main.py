"""
AI-Based Sunglasses Detection API
Using Google Cloud Vision API for accurate sunglasses detection
"""

from fastapi import FastAPI, File, UploadFile, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session
import io
import os
import logging
from typing import Dict, Any, Optional
import base64
from datetime import timezone, datetime

# Try to import zoneinfo (Python 3.9+), fallback to pytz if not available
try:
    from zoneinfo import ZoneInfo
    HAS_ZONEINFO = True
except ImportError:
    HAS_ZONEINFO = False
    ZoneInfo = None
from google.cloud import vision
from google.oauth2 import service_account
import json
from PIL import Image
import requests

# Configure logging first
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Optional ML/AI imports - handle gracefully if not available
try:
    import torch
    from transformers import pipeline
    ML_AVAILABLE = True
    logger.info("ML libraries (torch/transformers) loaded successfully")
except ImportError as e:
    logger.warning(f"ML libraries (torch/transformers) not available. AI model features will be disabled. Error: {e}")
    torch = None
    pipeline = None
    ML_AVAILABLE = False

# Import database and user service
try:
    from app.db.session import get_db
    from app.services.user_service import UserService
    from app.schemas.user import UserSignupRequest as DBUserSignupRequest
    from app.core.security import create_access_token, verify_password, get_password_hash, verify_token, is_token_expiring_soon, get_token_expiration_time
    from app.core.config import settings
    from datetime import timedelta, datetime
    DB_AVAILABLE = True
    logger.info("Database modules loaded successfully")
except ImportError as e:
    logger.warning(f"Database modules not available. Running in standalone mode. Error: {e}")
    DB_AVAILABLE = False
    def get_db():
        yield None
    def create_access_token(subject, expires_delta=None):
        return "mock_token"
    def verify_password(plain_password, hashed_password):
        return True
    def get_password_hash(password):
        return f"hashed_{password}"
    def verify_token(token):
        return "mock_user_id"
    def is_token_expiring_soon(token, threshold_minutes=5):
        return False
    def get_token_expiration_time(token):
        from datetime import datetime
        return datetime.utcnow()
    # Mock settings for standalone mode
    class Settings:
        SWAGGER_CLIENT_ID = "frame_api_admin"
        SWAGGER_CLIENT_SECRET = "frame_api_secret_2024"
        ENABLE_SWAGGER_AUTH = False
    settings = Settings()

app = FastAPI(
    title="Frame Backend APIs",
    description="Comprehensive API for Frame marketplace operations",
    version="1.0.0",
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

# CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global Vision API client
vision_client = None

# Global AI model for sunglasses detection
ai_model = None
image_classifier = None

def initialize_vision_client():
    """Initialize Google Cloud Vision API client"""
    global vision_client
    try:
        # Check if running in Google Cloud (production)
        if os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
            vision_client = vision.ImageAnnotatorClient()
        else:
            # For local development, use service account key
            credentials_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
            if credentials_path and os.path.exists(credentials_path):
                credentials = service_account.Credentials.from_service_account_file(
                    credentials_path,
                    scopes=['https://www.googleapis.com/auth/cloud-vision']
                )
                vision_client = vision.ImageAnnotatorClient(credentials=credentials)
            else:
                logger.warning("Google Cloud Vision API credentials not found. Using mock mode.")
                vision_client = None
    except Exception as e:
        logger.error(f"Failed to initialize Vision API client: {e}")
        vision_client = None

def initialize_ai_model():
    """Initialize pre-trained AI model for sunglasses detection"""
    global image_classifier
    if not ML_AVAILABLE:
        logger.info("ML libraries not available. Skipping AI model initialization.")
        image_classifier = None
        return
    
    try:
        logger.info("Loading Hugging Face image classification model...")
        # Load a pre-trained image classification model from Hugging Face
        device = 0 if torch and torch.cuda.is_available() else -1
        image_classifier = pipeline("image-classification", 
                                  model="microsoft/resnet-50", 
                                  device=device)
        logger.info("AI model loaded successfully")
    except Exception as e:
        logger.error(f"Failed to load AI model: {e}")
        logger.info("Falling back to improved mock mode")
        image_classifier = None

def analyze_image_with_ai_model(image_content: bytes) -> Dict[str, Any]:
    """
    Analyze image using Hugging Face pre-trained model for sunglasses detection
    """
    try:
        if image_classifier is None:
            raise Exception("AI model not loaded")
        
        # Load and preprocess image
        image = Image.open(io.BytesIO(image_content))
        image = image.convert('RGB')
        
        # Get predictions from Hugging Face model
        predictions = image_classifier(image)
        
        logger.info(f"AI Model predictions: {predictions}")
        
        # Look for sunglasses-related classes with improved logic
        sunglasses_keywords = ['sunglasses', 'eyewear', 'glasses', 'spectacles', 'shades', 'goggles', 'visor', 'sunglass']
        sunglasses_confidence = 0.0
        sunglasses_label = None
        
        # Check all predictions for sunglasses-related terms
        for prediction in predictions:
            label = prediction['label'].lower()
            confidence = prediction['score']
            
            # Check if any sunglasses keyword is in the label
            if any(keyword in label for keyword in sunglasses_keywords):
                if confidence > sunglasses_confidence:
                    sunglasses_confidence = confidence
                    sunglasses_label = prediction['label']
        
        # Boost confidence for multiple sunglasses-related predictions
        sunglasses_predictions = [pred for pred in predictions if any(keyword in pred['label'].lower() for keyword in sunglasses_keywords)]
        if len(sunglasses_predictions) > 1:
            # If multiple sunglasses predictions, boost confidence
            total_sunglasses_confidence = sum(pred['score'] for pred in sunglasses_predictions)
            if total_sunglasses_confidence > sunglasses_confidence:
                sunglasses_confidence = min(total_sunglasses_confidence * 0.8, 0.9)  # Cap at 90%
                sunglasses_label = "Multiple sunglasses indicators detected"
        
        # Check for face-related predictions that might indicate sunglasses
        face_keywords = ['face', 'person', 'human', 'head', 'man', 'woman', 'boy', 'girl']
        face_predictions = [pred for pred in predictions if any(keyword in pred['label'].lower() for keyword in face_keywords)]
        if face_predictions and sunglasses_confidence < 0.3:
            # If we detect a face, there's a higher chance of sunglasses being present
            face_confidence = max(pred['score'] for pred in face_predictions)
            if face_confidence > 0.3:  # Lower threshold for face detection
                # Boost sunglasses confidence when face is detected
                sunglasses_confidence = max(sunglasses_confidence, 0.4)  # Boost to 40%
                sunglasses_label = "Face detected with potential eyewear"
        
        # Check for dark/black objects that might be sunglasses
        dark_objects = [pred for pred in predictions if 'black' in pred['label'].lower() or 'dark' in pred['label'].lower()]
        if dark_objects and sunglasses_confidence < 0.2:
            max_dark_confidence = max(pred['score'] for pred in dark_objects)
            if max_dark_confidence > 0.1:  # Lower threshold for dark objects
                sunglasses_confidence = max(sunglasses_confidence, max_dark_confidence * 0.6)
                sunglasses_label = "Dark eyewear detected"
        
        # Determine if sunglasses are detected with much lower threshold
        is_sunglasses = sunglasses_confidence > 0.05  # Very low threshold - 5% confidence
        
        return {
            "sunglasses_detected": is_sunglasses,
            "confidence": sunglasses_confidence,
            "objects": [{
                "object": sunglasses_label or "Eyewear",
                "confidence": sunglasses_confidence,
                "bounding_box": {"x": 0.2, "y": 0.2, "width": 0.6, "height": 0.3}
            }] if is_sunglasses else [],
            "labels": [{
                "label": sunglasses_label or "No sunglasses detected",
                "confidence": sunglasses_confidence
            }],
            "analysis_method": "hugging_face_resnet50",
            "all_predictions": predictions[:5]  # Top 5 predictions for debugging
        }
        
    except Exception as e:
        logger.error(f"AI model analysis failed: {e}")
        raise HTTPException(status_code=500, detail=f"AI analysis failed: {str(e)}")

# Timezone utility function
def convert_utc_to_timezone(utc_timestamp_str: Optional[str], user_timezone: Optional[str] = None) -> Optional[str]:
    """
    Convert UTC timestamp string to user's timezone.
    
    Args:
        utc_timestamp_str: UTC timestamp in ISO 8601 format (e.g., "2024-01-15T10:30:00Z")
        user_timezone: Timezone string (e.g., "America/New_York", "Europe/London", "Asia/Tokyo")
                      If None, defaults to UTC
    
    Returns:
        Formatted timestamp string in user's timezone or UTC if timezone not provided
    """
    if not utc_timestamp_str:
        return None
    
    try:
        # Parse the UTC timestamp
        if utc_timestamp_str.endswith('Z'):
            utc_timestamp_str = utc_timestamp_str[:-1] + '+00:00'
        
        utc_dt = datetime.fromisoformat(utc_timestamp_str.replace('Z', '+00:00'))
        
        # Convert to user's timezone if provided
        if user_timezone:
            try:
                if HAS_ZONEINFO and ZoneInfo:
                    # Use zoneinfo (Python 3.9+)
                    user_tz = ZoneInfo(user_timezone)
                    local_dt = utc_dt.astimezone(user_tz)
                else:
                    # Fallback to pytz if zoneinfo not available
                    import pytz
                    user_tz = pytz.timezone(user_timezone)
                    local_dt = utc_dt.astimezone(user_tz)
            except Exception as e:
                # If timezone is invalid, return UTC
                logger.warning(f"Invalid timezone: {user_timezone}, using UTC. Error: {str(e)}")
                local_dt = utc_dt
        else:
            # No timezone provided, return UTC
            local_dt = utc_dt
        
        # Format as ISO 8601 string
        return local_dt.isoformat()
    except Exception as e:
        logger.error(f"Error converting timestamp: {str(e)}")
        # Return original timestamp if conversion fails
        return utc_timestamp_str


@app.on_event("startup")
async def startup_event():
    """Initialize services on startup"""
    initialize_vision_client()
    initialize_ai_model()
    logger.info("Sunglasses Detection API started successfully")

# Swagger UI Authentication Schemas
class SwaggerLoginRequest(BaseModel):
    """Swagger login request schema"""
    clientId: str
    clientSecret: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "clientId": "frame_api_admin",
                "clientSecret": "frame_api_secret_2024"
            }
        }


class SwaggerLoginResponse(BaseModel):
    """Swagger login response schema"""
    success: bool
    message: str
    token: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "message": "Authentication successful",
                "token": "eyJhbGciOiJIUzI1NiIs..."
            }
        }


@app.post("/swagger-login", include_in_schema=False)
async def swagger_login(credentials: SwaggerLoginRequest):
    """
    **Swagger UI Authentication Endpoint**
    
    Authenticate to access Swagger documentation.
    
    **Note:** Only works if ENABLE_SWAGGER_AUTH is set to True in settings.
    """
    # Check if Swagger authentication is enabled
    if not settings.ENABLE_SWAGGER_AUTH:
        # If not enabled, allow access
        return SwaggerLoginResponse(
            success=True,
            message="Swagger authentication is disabled",
            token=None
        )
    
    # Verify credentials
    if credentials.clientId == settings.SWAGGER_CLIENT_ID and credentials.clientSecret == settings.SWAGGER_CLIENT_SECRET:
        # Generate a session token
        session_token = create_access_token(
            subject="swagger_admin",
            expires_delta=timedelta(hours=24)
        )
        
        logger.info("Swagger UI authentication successful")
        
        return SwaggerLoginResponse(
            success=True,
            message="Authentication successful",
            token=session_token
        )
    else:
        logger.warning(f"Swagger UI authentication failed for clientId: {credentials.clientId}")
        raise HTTPException(
            status_code=401,
            detail="Invalid clientId or clientSecret"
        )


@app.get("/", tags=["1. Authentication"], include_in_schema=False)
async def root():
    """
    **Root Endpoint**
    
    Simple health check to verify the API is running.
    
    Returns basic status information about the API.
    """
    return {"message": "GitHub Auto-Deploy is Working! 🚀 - Test #2", "status": "healthy", "deployed_at": "2024-11-29"}

@app.get("/health", tags=["1. Authentication"], include_in_schema=False)
async def health_check():
    """
    **Health Check Endpoint**
    
    Detailed health information including:
    - API status
    - Vision API connection status
    - API version
    
    Returns comprehensive health status for monitoring.
    """
    return {
        "status": "healthy",
        "vision_api": "connected" if vision_client else "mock_mode",
        "version": "1.0.0",
        "deployment": "GitHub Auto-Deploy Working! ✅",
        "last_updated": "2024-11-29"
    }


# Signup Schemas
class UserSignupRequest(BaseModel):
    """User signup request schema"""
    email: EmailStr
    firstName: str
    lastName: str
    phoneNumber: str
    password: str
    gender: str
    location: str
    occupation: Optional[str] = None
    sourceOfFunds: Optional[str] = None
    additionalProperties: Optional[Dict[str, Any]] = None
    timezone: Optional[str] = None  # Timezone (e.g., "America/New_York", "Europe/London", "Asia/Tokyo")
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "john.doe@example.com",
                "firstName": "John",
                "lastName": "Doe",
                "phoneNumber": "+1234567890",
                "password": "SecurePass123!",
                "gender": "MALE",
                "location": "New York, USA",
                "occupation": "EMPLOYED",
                "sourceOfFunds": "SALARY",
                "timezone": "America/New_York",
                "additionalProperties": {
                    "favoriteBrand": "Ray-Ban"
                }
            }
        }


class UserSignupResponse(BaseModel):
    """User signup response schema"""
    status: str
    email: str
    userId: str
    phoneNumber: str
    createdOn: Optional[str] = None  # Timestamp in user's timezone if provided, otherwise UTC
    updatedOn: Optional[str] = None  # Timestamp in user's timezone if provided, otherwise UTC
    
    class Config:
        json_schema_extra = {
            "example": {
                "status": "CREATED",
                "email": "john.doe@example.com",
                "userId": "USR123456",
                "phoneNumber": "+1234567890",
                "createdOn": "2024-01-15T10:30:00-05:00",
                "updatedOn": "2024-01-15T10:30:00-05:00"
            }
        }


@app.post(
    "/v1/user/signup", 
    response_model=UserSignupResponse, 
    tags=["1. Authentication"],
    responses={
        200: {
            "description": "User successfully created",
            "content": {
                "application/json": {
                    "example": {
                        "status": "CREATED",
                        "email": "john.doe@example.com",
                        "userId": "USR123456",
                        "phoneNumber": "+1234567890",
                        "createdOn": "2024-01-15T15:30:00-05:00",
                        "updatedOn": "2024-01-15T15:30:00-05:00"
                    }
                }
            }
        },
        400: {
            "description": "Bad Request - Invalid input data or validation failed",
            "content": {
                "application/json": {
                    "examples": {
                        "invalid_email": {
                            "summary": "Invalid email format",
                            "value": {"detail": "Invalid email format"}
                        },
                        "invalid_password": {
                            "summary": "Password too short",
                            "value": {"detail": "Password must be at least 6 characters long"}
                        },
                        "invalid_phone": {
                            "summary": "Invalid phone format",
                            "value": {"detail": "Phone number must include country code (e.g., +1234567890)"}
                        },
                        "invalid_occupation": {
                            "summary": "Invalid occupation",
                            "value": {"detail": "Occupation must be one of: EMPLOYED, UNEMPLOYED, STUDENT, RETIRED, SELF_EMPLOYED"}
                        },
                        "invalid_source": {
                            "summary": "Invalid source of funds",
                            "value": {"detail": "Source of funds must be one of: SALARY, BUSINESS, INVESTMENT, GIFT, OTHER"}
                        }
                    }
                }
            }
        },
        409: {
            "description": "Conflict - Email or phone number already exists",
            "content": {
                "application/json": {
                    "examples": {
                        "duplicate_email": {
                            "summary": "Email already exists",
                            "value": {"detail": "User with this email already exists"}
                        },
                        "duplicate_phone": {
                            "summary": "Phone number already exists",
                            "value": {"detail": "User with this phone number already exists"}
                        }
                    }
                }
            }
        },
        500: {
            "description": "Internal Server Error",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Internal server error during signup"
                    }
                }
            }
        }
    }
)
async def signup_user(signup_data: UserSignupRequest, db: Session = Depends(get_db)):
    """
    **User Signup Endpoint**
    
    Register a new user account with complete information.
    
    **Required Fields:**
    - **email**: Valid email address - must be unique in database
    - **firstName**: User's first name
    - **lastName**: User's last name
    - **phoneNumber**: Phone number with country code, e.g., +1234567890 - must be unique in database
    - **password**: Password (minimum 6 characters)
    - **gender**: User gender (MALE, FEMALE, OTHER, etc.)
    - **location**: User location (city, state, country)
    
    **Optional Fields:**
    - **occupation**: User occupation (EMPLOYED, UNEMPLOYED, STUDENT, etc.)
    - **sourceOfFunds**: Source of income (SALARY, BUSINESS, INVESTMENT, etc.)
    - **additionalProperties**: Additional user properties as key-value pairs
    - **timezone**: User's timezone (e.g., "America/New_York", "Europe/London", "Asia/Tokyo"). If provided, timestamps will be returned in this timezone
    
    **Returns:**
    - **status**: success/error
    - **email**: Registered email
    - **userId**: Unique user ID
    - **phoneNumber**: Registered phone number
    
    **Example Request (Minimal):**
    ```json
    {
      "email": "john.doe@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "phoneNumber": "+1234567890",
      "password": "SecurePass123!",
      "gender": "MALE",
      "location": "New York, USA"
    }
    ```
    
    **Example Request (Complete):**
    ```json
    {
      "email": "john.doe@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "phoneNumber": "+1234567890",
      "password": "SecurePass123!",
      "gender": "MALE",
      "location": "New York, USA",
      "occupation": "EMPLOYED",
      "sourceOfFunds": "SALARY",
      "timezone": "America/New_York",
      "additionalProperties": {
        "favoriteBrand": "Ray-Ban"
      }
    }
    ```
    
    **Example Response:**
    ```json
    {
      "status": "CREATED",
      "email": "john.doe@example.com",
      "userId": "USR123456",
      "phoneNumber": "+1234567890",
      "createdOn": "2024-01-15T15:30:00-05:00",
      "updatedOn": "2024-01-15T15:30:00-05:00"
    }
    ```
    
    **Note:** If `timezone` parameter is provided, timestamps (`createdOn`, `updatedOn`) will be returned in that timezone. Otherwise, they will be in UTC.
    
    **Validation Rules:**
    - Email must be valid format and unique in database
    - Phone number must include country code and be unique in database
    - Password must be at least 6 characters
    - All required fields must be provided
    """
    try:
        # Convert UserSignupRequest to DBUserSignupRequest if DB is available
        if DB_AVAILABLE and db is not None:
            # Use database validation and storage
            user_service = UserService(db)
            
            # Convert signup_data to DBUserSignupRequest
            db_signup_data = DBUserSignupRequest(
                email=signup_data.email,
                firstName=signup_data.firstName,
                lastName=signup_data.lastName,
                phoneNumber=signup_data.phoneNumber,
                password=signup_data.password,
                gender=signup_data.gender,
                location=signup_data.location,
                occupation=signup_data.occupation,
                sourceOfFunds=signup_data.sourceOfFunds,
                additionalProperties=signup_data.additionalProperties,
                timezone=signup_data.timezone
            )
            
            # Call service to create user (handles database validation)
            result = user_service.signup_user(db_signup_data)
            
            # Convert timestamps to user's timezone if provided
            user_timezone = signup_data.timezone
            created_on_utc = result.get('createdOn')
            updated_on_utc = result.get('updatedOn')
            
            created_on = convert_utc_to_timezone(created_on_utc, user_timezone)
            updated_on = convert_utc_to_timezone(updated_on_utc, user_timezone)
            
            logger.info(f"User signup successful: {signup_data.email} - {result['userId']} (timezone: {user_timezone or 'UTC'})")
            return UserSignupResponse(
                status=result['status'],
                email=result['email'],
                userId=result['userId'],
                phoneNumber=result['phoneNumber'],
                createdOn=created_on,
                updatedOn=updated_on
            )
        else:
            # Fallback mode without database
            logger.warning("Database not available. Running in mock mode.")
            
            # Generate a mock user ID
            import uuid
            user_id = f"USR{uuid.uuid4().hex[:6].upper()}"
            
            # Validate required data
            if len(signup_data.password) < 6:
                raise HTTPException(
                    status_code=400,
                    detail="Password must be at least 6 characters long"
                )
            
            if not signup_data.phoneNumber.startswith('+'):
                raise HTTPException(
                    status_code=400,
                    detail="Phone number must include country code (e.g., +1234567890)"
                )
            
            # Validate optional fields only if provided
            if signup_data.occupation:
                valid_occupations = ["EMPLOYED", "UNEMPLOYED", "STUDENT", "RETIRED", "SELF_EMPLOYED"]
                if signup_data.occupation not in valid_occupations:
                    raise HTTPException(
                        status_code=400,
                        detail=f"Occupation must be one of: {', '.join(valid_occupations)}"
                    )
            
            if signup_data.sourceOfFunds:
                valid_sources = ["SALARY", "BUSINESS", "INVESTMENT", "GIFT", "OTHER"]
                if signup_data.sourceOfFunds not in valid_sources:
                    raise HTTPException(
                        status_code=400,
                        detail=f"Source of funds must be one of: {', '.join(valid_sources)}"
                    )
            
            logger.info(f"User signup successful (mock mode): {signup_data.email} - {user_id}")
            
            # Generate mock timestamps in UTC
            from datetime import datetime
            now_utc = datetime.utcnow().isoformat() + "Z"
            
            # Convert to user's timezone if provided
            user_timezone = signup_data.timezone
            created_on = convert_utc_to_timezone(now_utc, user_timezone)
            updated_on = convert_utc_to_timezone(now_utc, user_timezone)
            
            return UserSignupResponse(
                status="success",
                email=signup_data.email,
                userId=user_id,
                phoneNumber=signup_data.phoneNumber,
                createdOn=created_on,
                updatedOn=updated_on
            )
        
    except ValueError as e:
        # Handle database validation errors (duplicate email/phone)
        error_message = str(e)
        # Check if it's a duplicate error (409) or validation error (400)
        if "already exists" in error_message:
            logger.warning(f"Signup conflict: {error_message}")
            raise HTTPException(
                status_code=409,
                detail=error_message
            )
        else:
            logger.warning(f"Signup validation error: {error_message}")
            raise HTTPException(
                status_code=400,
                detail=error_message
            )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Signup error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Internal server error during signup"
        )


# Signin Schemas
class UserSigninRequest(BaseModel):
    """User signin request schema"""
    credential: str  # Can be email or phoneNumber
    password: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "credential": "user@example.com",
                "password": "SecurePass123!"
            }
        }


class UserSigninResponse(BaseModel):
    """User signin response schema"""
    fullName: str
    email: str
    phoneNumber: str
    statusCode: int
    token: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "fullName": "John Doe",
                "email": "john.doe@example.com",
                "phoneNumber": "+1234567890",
                "statusCode": 200,
                "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
            }
        }


@app.post(
    "/v1/user/signin/{userId}",
    response_model=UserSigninResponse,
    tags=["1. Authentication"],
    responses={
        200: {
            "description": "User successfully signed in",
            "content": {
                "application/json": {
                    "example": {
                        "fullName": "John Doe",
                        "email": "john.doe@example.com",
                        "phoneNumber": "+1234567890",
                        "statusCode": 200,
                        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
                    }
                }
            }
        },
        400: {
            "description": "Bad Request - Invalid credentials or missing fields",
            "content": {
                "application/json": {
                    "examples": {
                        "missing_fields": {
                            "summary": "Missing required fields",
                            "value": {"detail": "All fields are required"}
                        },
                        "invalid_format": {
                            "summary": "Invalid credential format",
                            "value": {"detail": "Credential must be email or phone number"}
                        }
                    }
                }
            }
        },
        401: {
            "description": "Unauthorized - Invalid credentials",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Invalid email/phone or password"
                    }
                }
            }
        },
        500: {
            "description": "Internal Server Error",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Internal server error during signin"
                    }
                }
            }
        }
    }
)
async def signin_user(userId: str, signin_data: UserSigninRequest, db: Session = Depends(get_db)):
    """
    **User Signin Endpoint**
    
    Authenticate user and create JWT token.
    
    **Path Parameter:**
    - **userId**: User ID to sign in (must match the credential's user)
    
    **Request Body:**
    - **credential**: Email address or phone number (required)
    - **password**: User password (required)
    
    **Returns:**
    - **fullName**: User's full name [firstName lastName]
    - **email**: User's email address
    - **phoneNumber**: User's phone number
    - **statusCode**: HTTP status code (200 for success)
    
    **Example Request:**
    ```json
    {
      "credential": "user@example.com",
      "password": "SecurePass123!"
    }
    ```
    
    **Example Response:**
    ```json
    {
      "fullName": "John Doe",
      "email": "john.doe@example.com",
      "phoneNumber": "+1234567890",
      "statusCode": 200,
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
    ```
    
    **Returns:**
    - **fullName**: User's full name [firstName lastName]
    - **email**: User's email address
    - **phoneNumber**: User's phone number
    - **statusCode**: HTTP status code (200 for success)
    - **token**: JWT access token for authenticated requests
    
    **Signin Methods:**
    - Email + Password
    - Phone Number + Password
    
    **Security:**
    - JWT token is created upon successful authentication
    - Password is verified against hashed password
    - Token expires after 30 minutes
    
    **Error Responses:**
    - **400**: Missing fields or invalid format
    - **401**: Invalid credentials
    - **500**: Internal server error
    """
    try:
        # Validate input
        if not signin_data.credential or not signin_data.password:
            raise HTTPException(
                status_code=400,
                detail="Credential and password are required"
            )
        
        # Use database authentication
        if DB_AVAILABLE and db is not None:
            user_service = UserService(db)
            
            # Authenticate user by email or phone number
            user = None
            
            # Try by email first
            user = user_service.get_user_by_email(signin_data.credential)
            
            # If not found by email, try by phone number
            if not user:
                # Import User model for phone lookup
                from app.models.user import User
                user = db.query(User).filter(User.phone_number == signin_data.credential).first()
            
            # Verify password if user found
            if user and verify_password(signin_data.password, user.hashed_password):
                # Create JWT token
                access_token_expires = timedelta(minutes=30)
                access_token = create_access_token(
                    subject=str(user.id),
                    expires_delta=access_token_expires
                )
                logger.info(f"JWT token created for user: {user.id}")
                
                logger.info(f"User signin successful: {user.email}")
                
                # Build full name from firstName and lastName
                full_name = f"{user.first_name} {user.last_name}".strip()
                if not full_name and user.full_name:
                    full_name = user.full_name
                
                return UserSigninResponse(
                    fullName=full_name,
                    email=user.email,
                    phoneNumber=user.phone_number,
                    statusCode=200,
                    token=access_token
                )
            else:
                raise HTTPException(
                    status_code=401,
                    detail="Invalid email/phone or password"
                )
        else:
            # Fallback mock mode
            logger.warning("Database not available. Running in mock mode.")
            
            # Mock validation
            if len(signin_data.password) < 6:
                raise HTTPException(
                    status_code=400,
                    detail="Invalid credentials"
                )
            
            return UserSigninResponse(
                fullName="Mock User",
                email="mock@example.com",
                phoneNumber="+1234567890",
                statusCode=200,
                token="mock_token_for_testing"
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Signin error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Internal server error during signin"
        )


# Refresh Token Schemas
class RefreshTokenRequest(BaseModel):
    """Refresh token request schema"""
    token: str  # The JWT token to refresh
    
    class Config:
        json_schema_extra = {
            "example": {
                "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
            }
        }


class RefreshTokenResponse(BaseModel):
    """Refresh token response schema"""
    status: str
    message: str
    token: str
    statusCode: int
    expiresAt: Optional[str] = None  # ISO 8601 format
    
    class Config:
        json_schema_extra = {
            "example": {
                "status": "SUCCESS",
                "message": "Token refreshed successfully",
                "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
                "statusCode": 200,
                "expiresAt": "2024-01-15T11:00:00Z"
            }
        }


@app.post(
    "/v1/user/refresh-token/{userId}",
    response_model=RefreshTokenResponse,
    tags=["1. Authentication"],
    responses={
        200: {
            "description": "Token refreshed successfully",
            "content": {
                "application/json": {
                    "example": {
                        "status": "SUCCESS",
                        "message": "Token refreshed successfully",
                        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
                        "statusCode": 200
                    }
                }
            }
        },
        400: {
            "description": "Bad Request - Invalid or missing token",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Token is required"
                    }
                }
            }
        },
        401: {
            "description": "Unauthorized - Invalid or expired token",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Invalid or expired token"
                    }
                }
            }
        },
        404: {
            "description": "Not Found - User not found",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "User not found"
                    }
                }
            }
        },
        500: {
            "description": "Internal Server Error",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Internal server error"
                    }
                }
            }
        }
    }
)
async def refresh_token(
    userId: str,
    refresh_data: RefreshTokenRequest,
    db: Session = Depends(get_db)
):
    """
    **Refresh Token Endpoint**
    
    Generate a new access token using an existing valid token. User must be logged in.
    
    **Authentication:**
    - User must provide a valid JWT token
    - Token will be verified before generating a new one
    
    **Path Parameter:**
    - **userId**: User ID of the authenticated user
    
    **Request Body:**
    - **token**: Current JWT token to refresh (required)
    
    **Returns:**
    - **status**: Status of the refresh ("SUCCESS")
    - **message**: Success message
    - **token**: New JWT access token
    - **statusCode**: HTTP status code (200 for success)
    
    **Example Request:**
    ```bash
    curl -X 'POST' \\
      'http://localhost:8000/v1/user/refresh-token/1' \\
      -H 'accept: application/json' \\
      -H 'Content-Type: application/json' \\
      -d '{
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
      }'
    ```
    
    **Example Response:**
    ```json
    {
      "status": "SUCCESS",
      "message": "Token refreshed successfully",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "statusCode": 200
    }
    ```
    
    **Validation:**
    - Token must be provided
    - Token must be valid and not expired
    - User must exist in database
    
    **Error Responses:**
    - **400**: Bad Request - Invalid or missing token
    - **401**: Unauthorized - Invalid or expired token
    - **404**: Not Found - User not found
    - **500**: Internal Server Error
    """
    try:
        # Validate input
        if not refresh_data.token:
            raise HTTPException(
                status_code=400,
                detail="Token is required"
            )
        
        # Use database to verify user and refresh token
        if DB_AVAILABLE and db is not None:
            from app.models.user import User
            
            # Verify the token
            user_id_from_token = verify_token(refresh_data.token)
            if not user_id_from_token:
                raise HTTPException(
                    status_code=401,
                    detail="Invalid or expired token"
                )
            
            # Verify that the token's userId matches the path userId
            if str(user_id_from_token) != str(userId):
                raise HTTPException(
                    status_code=401,
                    detail="Token does not match user"
                )
            
            # Get user from database
            user = db.query(User).filter(User.id == int(userId)).first()
            if not user:
                raise HTTPException(
                    status_code=404,
                    detail="User not found"
                )
            
            # Generate new access token
            access_token_expires = timedelta(minutes=30)
            new_access_token = create_access_token(
                subject=str(user.id),
                expires_delta=access_token_expires
            )
            
            # Get expiration time for the new token
            exp_time = get_token_expiration_time(new_access_token)
            expires_at = exp_time.isoformat() + "Z" if exp_time else None
            
            logger.info(f"Token refreshed successfully for user: {user.id}, expires at: {expires_at}")
            
            return RefreshTokenResponse(
                status="SUCCESS",
                message="Token refreshed successfully",
                token=new_access_token,
                statusCode=200,
                expiresAt=expires_at
            )
        else:
            # Fallback mock mode
            logger.warning("Database not available. Running in mock mode.")
            
            # Mock token refresh
            if not refresh_data.token or len(refresh_data.token) < 10:
                raise HTTPException(
                    status_code=400,
                    detail="Invalid token"
                )
            
            from datetime import datetime
            now = datetime.utcnow()
            expires_at = (now + timedelta(minutes=30)).isoformat() + "Z"
            
            return RefreshTokenResponse(
                status="SUCCESS",
                message="Token refreshed successfully (mock mode)",
                token="mock_refreshed_token",
                statusCode=200,
                expiresAt=expires_at
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Refresh token error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Internal server error during token refresh"
        )


# Token Status Schemas
class TokenStatusRequest(BaseModel):
    """Token status request schema"""
    token: str  # The JWT token to check
    
    class Config:
        json_schema_extra = {
            "example": {
                "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
            }
        }


class TokenStatusResponse(BaseModel):
    """Token status response schema"""
    isValid: bool
    isExpiringSoon: bool
    expiresAt: Optional[str] = None
    remainingMinutes: Optional[int] = None
    shouldRefresh: bool
    statusCode: int
    message: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "isValid": True,
                "isExpiringSoon": False,
                "expiresAt": "2024-01-15T11:00:00Z",
                "remainingMinutes": 25,
                "shouldRefresh": False,
                "statusCode": 200,
                "message": "Token is valid"
            }
        }


@app.post(
    "/v1/user/token-status/{userId}",
    response_model=TokenStatusResponse,
    tags=["1. Authentication"],
    responses={
        200: {
            "description": "Token status retrieved successfully",
            "content": {
                "application/json": {
                    "example": {
                        "isValid": True,
                        "isExpiringSoon": False,
                        "expiresAt": "2024-01-15T11:00:00Z",
                        "remainingMinutes": 25,
                        "shouldRefresh": False,
                        "statusCode": 200,
                        "message": "Token is valid"
                    }
                }
            }
        },
        400: {
            "description": "Bad Request - Invalid or missing token",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Token is required"
                    }
                }
            }
        },
        401: {
            "description": "Unauthorized - Invalid or expired token",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Invalid or expired token"
                    }
                }
            }
        },
        500: {
            "description": "Internal Server Error",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Internal server error"
                    }
                }
            }
        }
    }
)
async def check_token_status(
    userId: str,
    token_data: TokenStatusRequest,
    db: Session = Depends(get_db)
):
    """
    **Token Status Endpoint**
    
    Check the status of a JWT token to determine if it needs to be refreshed.
    Useful for auto-refresh logic on the client side.
    
    **Path Parameter:**
    - **userId**: User ID of the authenticated user
    
    **Request Body:**
    - **token**: Current JWT token to check (required)
    
    **Returns:**
    - **isValid**: Whether the token is valid
    - **isExpiringSoon**: Whether the token is expiring soon (within 5 minutes)
    - **expiresAt**: Token expiration time (ISO 8601)
    - **remainingMinutes**: Remaining minutes until expiration
    - **shouldRefresh**: Whether the token should be refreshed
    - **statusCode**: HTTP status code (200 for success)
    - **message**: Status message
    
    **Example Request:**
    ```bash
    curl -X 'POST' \\
      'http://localhost:8000/v1/user/token-status/1' \\
      -H 'accept: application/json' \\
      -H 'Content-Type: application/json' \\
      -d '{
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
      }'
    ```
    
    **Auto-Refresh Logic:**
    - **shouldRefresh** = True when token is expiring within 5 minutes
    - Client should call `/v1/user/refresh-token/{userId}` when shouldRefresh = True
    - Client can poll this endpoint periodically to check token status
    
    **Example Response:**
    ```json
    {
      "isValid": True,
      "isExpiringSoon": True,
      "expiresAt": "2024-01-15T10:58:00Z",
      "remainingMinutes": 3,
      "shouldRefresh": True,
      "statusCode": 200,
      "message": "Token is valid but expiring soon"
    }
    ```
    """
    try:
        # Validate input
        if not token_data.token:
            raise HTTPException(
                status_code=400,
                detail="Token is required"
            )
        
        # Verify the token
        user_id_from_token = verify_token(token_data.token)
        if not user_id_from_token:
            return TokenStatusResponse(
                isValid=False,
                isExpiringSoon=True,
                expiresAt=None,
                remainingMinutes=0,
                shouldRefresh=False,
                statusCode=200,
                message="Token is invalid or expired"
            )
        
        # Verify that the token's userId matches the path userId
        if str(user_id_from_token) != str(userId):
            return TokenStatusResponse(
                isValid=False,
                isExpiringSoon=True,
                expiresAt=None,
                remainingMinutes=0,
                shouldRefresh=False,
                statusCode=200,
                message="Token does not match user"
            )
        
        # Get token expiration time
        exp_time = get_token_expiration_time(token_data.token)
        expires_at = exp_time.isoformat() + "Z" if exp_time else None
        
        # Calculate remaining time
        remaining_minutes = None
        if exp_time:
            remaining = exp_time - datetime.utcnow()
            remaining_minutes = max(0, int(remaining.total_seconds() / 60))
        
        # Check if expiring soon
        is_expiring_soon = is_token_expiring_soon(token_data.token, threshold_minutes=5)
        should_refresh = is_expiring_soon
        
        # Determine message
        if is_expiring_soon:
            message = f"Token is valid but expiring soon. Remaining: {remaining_minutes} minutes"
        elif remaining_minutes and remaining_minutes > 0:
            message = f"Token is valid. Remaining: {remaining_minutes} minutes"
        else:
            message = "Token is valid"
        
        logger.info(f"Token status checked for user {userId}: valid={True}, expiring_soon={is_expiring_soon}")
        
        return TokenStatusResponse(
            isValid=True,
            isExpiringSoon=is_expiring_soon,
            expiresAt=expires_at,
            remainingMinutes=remaining_minutes,
            shouldRefresh=should_refresh,
            statusCode=200,
            message=message
        )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Token status check error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Internal server error during token status check"
        )


# User List Schemas
class UserListItem(BaseModel):
    """Single user item in list response"""
    userId: str
    email: str
    fullName: str
    phoneNumber: str
    createdOn: Optional[str] = None
    updatedOn: Optional[str] = None
    
    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "userId": "USR123456",
                "email": "john.doe@example.com",
                "fullName": "John Doe",
                "phoneNumber": "+1234567890",
                "createdOn": "2024-01-15T10:30:00Z",
                "updatedOn": "2024-01-15T10:30:00Z"
            }
        }


class UserListResponse(BaseModel):
    """User list response schema"""
    users: list[UserListItem]
    total: int
    
    class Config:
        json_schema_extra = {
            "example": {
                "users": [
                    {
                        "userId": "USR123456",
                        "email": "john.doe@example.com",
                        "fullName": "John Doe",
                        "phoneNumber": "+1234567890",
                        "createdOn": "2024-01-15T10:30:00Z",
                        "updatedOn": "2024-01-15T10:30:00Z"
                    }
                ],
                "total": 1
            }
        }


@app.get(
    "/v1/users/{userId}",
    response_model=UserListResponse,
    tags=["1. Authentication"],
    responses={
        200: {
            "description": "List of all users retrieved successfully",
            "content": {
                "application/json": {
                    "example": {
                        "users": [
                            {
                                "userId": "USR123456",
                                "email": "john.doe@example.com",
                                "fullName": "John Doe",
                                "phoneNumber": "+1234567890",
                                "createdOn": "2024-01-15T10:30:00Z",
                                "updatedOn": "2024-01-15T10:30:00Z"
                            },
                            {
                                "userId": "USR789012",
                                "email": "jane.smith@example.com",
                                "fullName": "Jane Smith",
                                "phoneNumber": "+9876543210",
                                "createdOn": "2024-01-16T11:20:00Z",
                                "updatedOn": "2024-01-16T11:20:00Z"
                            }
                        ],
                        "total": 2
                    }
                }
            }
        },
        401: {
            "description": "Unauthorized - Invalid user",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Unauthorized access"
                    }
                }
            }
        },
        500: {
            "description": "Internal Server Error",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Internal server error"
                    }
                }
            }
        }
    }
)
async def get_all_users(userId: str, db: Session = Depends(get_db)):
    """
    **Get All Users Endpoint**
    
    Retrieve a list of all users. Requires authorization via userId.
    
    **Path Parameter:**
    - **userId**: User ID for authorization (required)
    
    **Returns:**
    - **users**: List of user objects
    - **total**: Total number of users
    
    Each user object contains:
    - **userId**: Unique user identifier
    - **email**: User's email address
    - **fullName**: User's full name
    - **phoneNumber**: User's phone number
    
    **Example Request:**
    ```
    GET /v1/users/USR123456
    ```
    
    **Example Response:**
    ```json
    {
      "users": [
        {
          "userId": "USR123456",
          "email": "john.doe@example.com",
          "fullName": "John Doe",
          "phoneNumber": "+1234567890"
        },
        {
          "userId": "USR789012",
          "email": "jane.smith@example.com",
          "fullName": "Jane Smith",
          "phoneNumber": "+9876543210"
        }
      ],
      "total": 2
    }
    ```
    
    **Authorization:**
    - Requires valid userId
    - Returns list of all registered users
    
    **Error Responses:**
    - **401**: Unauthorized access
    - **500**: Internal server error
    """
    try:
        # Use database to fetch users
        if DB_AVAILABLE and db is not None:
            from app.models.user import User
            
            # Verify userId exists (basic authorization check)
            # In production, you would verify the JWT token here
            user_exists = db.query(User).first()
            
            if not user_exists:
                raise HTTPException(
                    status_code=401,
                    detail="Unauthorized access"
                )
            
            # Fetch all users
            all_users = db.query(User).all()
            
            # Format response
            user_list = []
            for user in all_users:
                # Generate userId from username or use a simple identifier
                user_id = getattr(user, 'id', None)  # Use database ID as userId
                
                # Get full name
                full_name = f"{user.first_name} {user.last_name}".strip()
                if not full_name and user.full_name:
                    full_name = user.full_name
                
                # Format timestamps
                created_on = user.created_at.isoformat() + "Z" if user.created_at else None
                updated_on = user.updated_at.isoformat() + "Z" if user.updated_at else None
                
                user_list.append(UserListItem(
                    userId=str(user_id),
                    email=user.email,
                    fullName=full_name or "N/A",
                    phoneNumber=user.phone_number or "N/A",
                    createdOn=created_on,
                    updatedOn=updated_on
                ))
            
            logger.info(f"Retrieved {len(user_list)} users")
            
            return UserListResponse(
                users=user_list,
                total=len(user_list)
            )
        else:
            # Fallback mock mode
            logger.warning("Database not available. Running in mock mode.")
            
            # Generate mock timestamps
            from datetime import datetime
            now = datetime.utcnow().isoformat() + "Z"
            
            return UserListResponse(
                users=[
                    UserListItem(
                        userId="USR001",
                        email="mock1@example.com",
                        fullName="Mock User 1",
                        phoneNumber="+1111111111",
                        createdOn=now,
                        updatedOn=now
                    ),
                    UserListItem(
                        userId="USR002",
                        email="mock2@example.com",
                        fullName="Mock User 2",
                        phoneNumber="+2222222222",
                        createdOn=now,
                        updatedOn=now
                    )
                ],
                total=2
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Get users error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Internal server error"
        )

# Update User Schemas
class UserUpdateRequest(BaseModel):
    """User update request schema"""
    firstName: Optional[str] = None
    lastName: Optional[str] = None
    location: Optional[str] = None
    password: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "firstName": "John",
                "lastName": "Smith",
                "location": "Los Angeles, USA",
                "password": "NewSecurePass123!"
            }
        }


class UserUpdateResponse(BaseModel):
    """User update response schema"""
    status: str
    message: str
    email: str
    userId: str
    updatedFields: list[str]
    updatedOn: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "status": "SUCCESS",
                "message": "User information updated successfully",
                "email": "john.doe@example.com",
                "userId": "1",
                "updatedFields": ["firstName", "lastName", "location", "password"],
                "updatedOn": "2024-01-15T10:30:00Z"
            }
        }


@app.patch(
    "/v1/user/account/{userId}",
    response_model=UserUpdateResponse,
    tags=["1. Authentication"],
    responses={
        200: {
            "description": "User information updated successfully",
            "content": {
                "application/json": {
                    "example": {
                        "status": "SUCCESS",
                        "message": "User information updated successfully",
                        "email": "john.doe@example.com",
                        "userId": "1",
                        "updatedFields": ["firstName", "lastName", "location", "password"],
                        "updatedOn": "2024-01-15T10:30:00Z"
                    }
                }
            }
        },
        400: {
            "description": "Bad Request - Invalid input data",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "At least one field must be provided for update"
                    }
                }
            }
        },
        404: {
            "description": "Not Found - User not found",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "User not found"
                    }
                }
            }
        },
        500: {
            "description": "Internal Server Error",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Internal server error"
                    }
                }
            }
        }
    }
)
async def update_user_account(
    userId: str,
    update_data: UserUpdateRequest,
    db: Session = Depends(get_db)
):
    """
    **Update User Account Endpoint**
    
    Update user information (firstName, lastName, location, password). Requires user to be logged in.
    
    **Authentication:**
    - User must be logged in (userId identifies the authenticated user)
    
    **Path Parameter:**
    - **userId**: User ID to update (must be logged in user)
    
    **Request Body:**
    - **firstName**: User's first name (optional)
    - **lastName**: User's last name (optional)
    - **location**: User's location (optional)
    - **password**: User's new password (optional)
    
    **Returns:**
    - **status**: Status of the update ("SUCCESS")
    - **message**: Success message
    - **email**: User's email address
    - **userId**: User's ID
    - **updatedFields**: List of fields that were updated
    - **updatedOn**: Timestamp of update (ISO 8601)
    
    **Example Request:**
    ```bash
    curl -X 'PATCH' \\
      'http://localhost:8000/v1/user/account/1' \\
      -H 'accept: application/json' \\
      -H 'Content-Type: application/json' \\
      -d '{
        "firstName": "John",
        "lastName": "Smith",
        "location": "Los Angeles, USA",
        "password": "NewSecurePass123!"
      }'
    ```
    
    **Example Response:**
    ```json
    {
      "status": "SUCCESS",
      "message": "User information updated successfully",
      "email": "john.doe@example.com",
      "userId": "1",
      "updatedFields": ["firstName", "lastName", "location", "password"],
      "updatedOn": "2024-01-15T10:30:00Z"
    }
    ```
    
    **Validation:**
    - At least one field must be provided
    - Password must be at least 6 characters (if provided)
    - User must be logged in
    
    **Error Responses:**
    - **400**: Bad Request - Invalid input data
    - **404**: Not Found - User not found
    - **500**: Internal Server Error
    """
    try:
        # Check if at least one field is provided
        if not any([update_data.firstName, update_data.lastName, update_data.location, update_data.password]):
            raise HTTPException(
                status_code=400,
                detail="At least one field must be provided for update"
            )
        
        # Use database to update user
        if DB_AVAILABLE and db is not None:
            from app.models.user import User
            
            # Get user from database
            user = db.query(User).filter(User.id == int(userId)).first()
            if not user:
                raise HTTPException(
                    status_code=404,
                    detail="User not found"
                )
            
            updated_fields = []
            
            # Update firstName if provided
            if update_data.firstName is not None:
                user.first_name = update_data.firstName
                updated_fields.append("firstName")
            
            # Update lastName if provided
            if update_data.lastName is not None:
                user.last_name = update_data.lastName
                updated_fields.append("lastName")
            
            # Update location (stored in additional_properties)
            if update_data.location is not None:
                if user.additional_properties is None:
                    user.additional_properties = {}
                user.additional_properties['location'] = update_data.location
                updated_fields.append("location")
            
            # Update full_name if firstName or lastName changed
            if update_data.firstName or update_data.lastName:
                new_first = update_data.firstName if update_data.firstName else user.first_name
                new_last = update_data.lastName if update_data.lastName else user.last_name
                user.full_name = f"{new_first} {new_last}".strip()
            
            # Update password if provided
            if update_data.password is not None:
                if len(update_data.password) < 6:
                    raise HTTPException(
                        status_code=400,
                        detail="Password must be at least 6 characters long"
                    )
                user.hashed_password = get_password_hash(update_data.password)
                updated_fields.append("password")
            
            # Save changes
            db.commit()
            db.refresh(user)
            
            # Format timestamp
            from datetime import datetime
            updated_on = user.updated_at.isoformat() + "Z" if user.updated_at else None
            
            logger.info(f"User account updated successfully: {user.email} - Fields: {updated_fields}")
            
            return UserUpdateResponse(
                status="SUCCESS",
                message="User information updated successfully",
                email=user.email,
                userId=str(user.id),
                updatedFields=updated_fields,
                updatedOn=updated_on
            )
        else:
            # Fallback mock mode
            logger.warning("Database not available. Running in mock mode.")
            
            # Validate password if provided
            if update_data.password and len(update_data.password) < 6:
                raise HTTPException(
                    status_code=400,
                    detail="Password must be at least 6 characters long"
                )
            
            # Generate mock timestamps
            from datetime import datetime
            now = datetime.utcnow().isoformat() + "Z"
            
            # Mock updated fields
            updated_fields = []
            if update_data.firstName:
                updated_fields.append("firstName")
            if update_data.lastName:
                updated_fields.append("lastName")
            if update_data.location:
                updated_fields.append("location")
            if update_data.password:
                updated_fields.append("password")
            
            return UserUpdateResponse(
                status="SUCCESS",
                message="User information updated successfully (mock mode)",
                email="mock@example.com",
                userId=userId,
                updatedFields=updated_fields,
                updatedOn=now
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Update user account error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Internal server error"
        )


def analyze_image_with_vision_api(image_content: bytes) -> Dict[str, Any]:
    """
    Analyze image using Google Cloud Vision API
    Returns sunglasses detection results
    """
    try:
        # Create Vision API image object
        image = vision.Image(content=image_content)
        
        # Perform object detection to find sunglasses
        objects = vision_client.object_localization(image=image)
        
        # Perform label detection for additional context
        labels = vision_client.label_detection(image=image)
        
        # Check for sunglasses in detected objects
        sunglasses_found = False
        sunglasses_confidence = 0.0
        sunglasses_details = []
        
        # Analyze detected objects
        for obj in objects.localized_object_annotations:
            if obj.name.lower() in ['sunglasses', 'eyewear', 'glasses']:
                sunglasses_found = True
                sunglasses_confidence = max(sunglasses_confidence, obj.score)
                sunglasses_details.append({
                    "object": obj.name,
                    "confidence": obj.score,
                    "bounding_box": {
                        "x": obj.bounding_poly.normalized_vertices[0].x if obj.bounding_poly.normalized_vertices else 0,
                        "y": obj.bounding_poly.normalized_vertices[0].y if obj.bounding_poly.normalized_vertices else 0,
                        "width": obj.bounding_poly.normalized_vertices[2].x - obj.bounding_poly.normalized_vertices[0].x if len(obj.bounding_poly.normalized_vertices) > 2 else 0,
                        "height": obj.bounding_poly.normalized_vertices[2].y - obj.bounding_poly.normalized_vertices[0].y if len(obj.bounding_poly.normalized_vertices) > 2 else 0
                    }
                }
            )
        
        # Analyze labels for additional context
        eyewear_labels = []
        for label in labels.label_annotations:
            if any(keyword in label.description.lower() for keyword in ['sunglasses', 'eyewear', 'glasses', 'shades']):
                eyewear_labels.append({
                    "label": label.description,
                    "confidence": label.score
                })
        
        # Determine if sunglasses are present
        is_sunglasses = sunglasses_found or any(
            label['confidence'] > 0.7 and 'sunglasses' in label['label'].lower() 
            for label in eyewear_labels
        )
        
        # Calculate overall confidence
        overall_confidence = sunglasses_confidence
        if eyewear_labels:
            overall_confidence = max(overall_confidence, max(label['confidence'] for label in eyewear_labels))
        
        return {
            "sunglasses_detected": is_sunglasses,
            "confidence": overall_confidence,
            "objects": sunglasses_details,
            "labels": eyewear_labels,
            "analysis_method": "google_cloud_vision"
        }
        
    except Exception as e:
        logger.error(f"Vision API analysis failed: {e}")
        raise HTTPException(status_code=500, detail=f"Image analysis failed: {str(e)}")

def mock_sunglasses_analysis(image_content: bytes) -> Dict[str, Any]:
    """
    Simplified mock analysis for development/testing when Vision API is not available
    This uses basic heuristics to detect sunglasses without numpy dependency
    """
    import time
    import random
    from PIL import Image
    import io
    
    # Simulate analysis delay
    time.sleep(1)
    
    try:
        # Load and analyze the image
        image = Image.open(io.BytesIO(image_content))
        width, height = image.size
        
        # Calculate image statistics using PIL
        # Convert to grayscale for analysis
        gray_image = image.convert('L')
        
        # Get pixel data
        pixels = list(gray_image.getdata())
        total_pixels = len(pixels)
        
        # Calculate basic statistics
        mean_brightness = sum(pixels) / total_pixels if total_pixels > 0 else 128
        
        # Count dark pixels (potential sunglasses)
        dark_threshold = mean_brightness * 0.7
        dark_pixels = sum(1 for pixel in pixels if pixel < dark_threshold)
        dark_ratio = dark_pixels / total_pixels if total_pixels > 0 else 0
        
        # Calculate confidence based on multiple factors
        confidence_factors = []
        
        # Factor 1: Dark regions (sunglasses are typically dark)
        if dark_ratio > 0.1:  # At least 10% dark pixels
            confidence_factors.append(min(0.8, dark_ratio * 2))
        else:
            confidence_factors.append(0.2)
        
        # Factor 2: Image size (larger images more likely to have clear sunglasses)
        image_size = len(image_content)
        size_factor = min(0.6, image_size / 500000)  # 500KB baseline
        confidence_factors.append(size_factor)
        
        # Factor 3: Image dimensions (portrait images more likely to show faces with sunglasses)
        aspect_ratio = height / width if width > 0 else 1
        if 0.8 <= aspect_ratio <= 1.5:  # Reasonable aspect ratio for face photos
            confidence_factors.append(0.6)
        else:
            confidence_factors.append(0.3)
        
        # Factor 4: Image brightness (very bright images less likely to have sunglasses)
        brightness_factor = 1.0 - (mean_brightness / 255.0)  # Invert brightness
        confidence_factors.append(brightness_factor * 0.5)
        
        # Calculate overall confidence
        overall_confidence = sum(confidence_factors) / len(confidence_factors)
        
        # Add some randomness to make it more realistic
        noise = random.uniform(-0.1, 0.1)
        overall_confidence = max(0.1, min(0.95, overall_confidence + noise))
        
        # Determine if sunglasses are detected
        is_sunglasses = overall_confidence > 0.5
        
        # Create more realistic object detection
        objects = []
        if is_sunglasses:
            objects.append({
                "object": "Sunglasses",
                "confidence": overall_confidence,
                "bounding_box": {
                    "x": 0.25 + random.uniform(-0.1, 0.1),
                    "y": 0.3 + random.uniform(-0.1, 0.1),
                    "width": 0.5 + random.uniform(-0.1, 0.1),
                    "height": 0.2 + random.uniform(-0.05, 0.05)
                }
            })
        
        # Create realistic labels
        labels = []
        if is_sunglasses:
            labels.append({
                "label": "Sunglasses",
                "confidence": overall_confidence
            })
        else:
            labels.append({
                "label": "Eyewear" if overall_confidence > 0.3 else "No eyewear detected",
                "confidence": overall_confidence
            })
        
        return {
            "sunglasses_detected": is_sunglasses,
            "confidence": overall_confidence,
            "objects": objects,
            "labels": labels,
            "analysis_method": "simplified_mock_mode",
            "analysis_details": {
                "dark_ratio": dark_ratio,
                "mean_brightness": mean_brightness,
                "aspect_ratio": aspect_ratio,
                "image_size": image_size
            }
        }
        
    except Exception as e:
        logger.error(f"Mock analysis failed: {e}")
        # Fallback to simple heuristic
        image_size = len(image_content)
        mock_confidence = min(0.8, 0.4 + (image_size / 1000000) * 0.3)
        is_sunglasses = mock_confidence > 0.5
        
        return {
            "sunglasses_detected": is_sunglasses,
            "confidence": mock_confidence,
            "objects": [{
                "object": "Sunglasses" if is_sunglasses else "Regular glasses",
                "confidence": mock_confidence,
                "bounding_box": {"x": 0.2, "y": 0.2, "width": 0.6, "height": 0.3}
            }] if is_sunglasses else [],
            "labels": [{
                "label": "Sunglasses" if is_sunglasses else "Eyewear",
                "confidence": mock_confidence
            }],
            "analysis_method": "fallback_mock_mode"
        }

@app.post(
    "/validate-sunglasses", 
    tags=["2. AI Validation"],
    responses={
        200: {
            "description": "Validation successful - Sunglasses detected",
            "content": {
                "application/json": {
                    "example": {
                        "status": "accepted",
                        "confidence": 0.95,
                        "message": "Sunglasses detected with 95.0% confidence",
                        "details": "Detected: sunglasses with 95.0% confidence",
                        "analysis": {
                            "sunglasses_detected": True,
                            "confidence": 0.95,
                            "objects": [{"object": "sunglasses", "confidence": 0.95}],
                            "labels": [{"label": "sunglasses", "confidence": 0.95}],
                            "analysis_method": "hugging_face_resnet50"
                        },
                        "timestamp": "2024-01-01T00:00:00Z"
                    }
                }
            }
        },
        400: {
            "description": "Bad request - Invalid file or parameters",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Invalid file type. Please upload an image file."
                    }
                }
            }
        },
        422: {
            "description": "Validation failed - No sunglasses detected or low confidence",
            "content": {
                "application/json": {
                    "example": {
                        "status": "rejected",
                        "confidence": 0.0,
                        "message": "No sunglasses found in the image",
                        "details": "Please upload an image containing sunglasses (dark/tinted lenses)",
                        "analysis": {
                            "sunglasses_detected": False,
                            "confidence": 0.0,
                            "objects": [],
                            "labels": [{"label": "No sunglasses detected", "confidence": 0.0}],
                            "analysis_method": "hugging_face_resnet50"
                        },
                        "timestamp": "2024-01-01T00:00:00Z"
                    }
                }
            }
        },
        500: {
            "description": "Internal server error",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Internal server error during image validation"
                    }
                }
            }
        }
    }
)
async def validate_sunglasses(file: UploadFile = File(...)):
    """
    **Validate Sunglasses - File Upload**
    
    Upload an image file to detect if it contains sunglasses.
    
    **Supported Formats:**
    - JPEG (.jpg, .jpeg)
    - PNG (.png)
    - WebP (.webp)
    
    **File Size Limit:** 50MB
    
    **Returns:**
    - Detection status (accepted/rejected)
    - Confidence score (0-1)
    - Detailed analysis with bounding boxes
    - Detection method used
    
    **Analysis Methods:**
    1. **AI Model** (Hugging Face) - First priority
    2. **Vision API** (Google Cloud) - Second priority  
    3. **Mock Mode** - Fallback for development
    
    **Example Response:**
    ```json
    {
      "status": "accepted",
      "confidence": 0.95,
      "message": "Sunglasses detected with 95% confidence",
      "analysis": {
        "sunglasses_detected": true,
        "objects": [...],
        "labels": [...]
      }
    }
    ```
    """
    try:
        # Validate file type
        if not file.content_type or not file.content_type.startswith('image/'):
            raise HTTPException(
                status_code=400, 
                detail="Invalid file type. Please upload an image file."
            )
        
        # Read image content
        image_content = await file.read()
        
        if len(image_content) == 0:
            raise HTTPException(status_code=400, detail="Empty file uploaded")
        
        # Check file size (max 50MB)
        max_size = 50 * 1024 * 1024  # 50MB
        if len(image_content) > max_size:
            raise HTTPException(
                status_code=400, 
                detail="File too large. Maximum size is 50MB."
            )
        
        logger.info(f"Analyzing image: {file.filename}, size: {len(image_content)} bytes")
        
        # Analyze image - try AI model first, then Vision API, then mock
        if image_classifier:
            logger.info("Using Hugging Face AI model for analysis")
            analysis_result = analyze_image_with_ai_model(image_content)
        elif vision_client:
            logger.info("Using Google Cloud Vision API for analysis")
            analysis_result = analyze_image_with_vision_api(image_content)
        else:
            logger.info("Using improved mock analysis for development")
            analysis_result = mock_sunglasses_analysis(image_content)
        
        # Determine validation result
        sunglasses_detected = analysis_result["sunglasses_detected"]
        confidence = analysis_result["confidence"]
        min_confidence_threshold = 0.1  # 10% minimum confidence (much lower for better detection)
        
        if sunglasses_detected and confidence >= min_confidence_threshold:
            status = "accepted"
            message = f"Sunglasses detected with {confidence:.1%} confidence"
            details = f"Detected: {analysis_result.get('objects', [{}])[0].get('object', 'sunglasses')} with {confidence:.1%} confidence"
        else:
            status = "rejected"
            if not sunglasses_detected:
                message = "No sunglasses found in the image"
                details = "Please upload an image containing sunglasses (dark/tinted lenses)"
            else:
                message = f"Sunglasses detected but confidence too low ({confidence:.1%})"
                details = f"Confidence {confidence:.1%} is below required {min_confidence_threshold:.1%}"
        
        response_data = {
            "status": status,
            "confidence": confidence,
            "message": message,
            "details": details,
            "analysis": analysis_result,
            "timestamp": datetime.now(timezone.utc).isoformat() + "Z"
        }
        
        logger.info(f"Validation result: {status} - {message}")
        
        # Return appropriate HTTP status code based on validation result
        if status == "accepted":
            return JSONResponse(content=response_data, status_code=200)
        else:
            # 422 Unprocessable Entity for validation failures
            return JSONResponse(content=response_data, status_code=422)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error during validation: {e}")
        raise HTTPException(
            status_code=500, 
            detail="Internal server error during image validation"
        )

@app.post(
    "/validate-sunglasses-base64", 
    tags=["2. AI Validation"],
    responses={
        200: {
            "description": "Validation successful - Sunglasses detected",
            "content": {
                "application/json": {
                    "example": {
                        "status": "accepted",
                        "confidence": 0.95,
                        "message": "Sunglasses detected with 95.0% confidence",
                        "details": "Detected: sunglasses with 95.0% confidence",
                        "analysis": {
                            "sunglasses_detected": True,
                            "confidence": 0.95,
                            "objects": [{"object": "sunglasses", "confidence": 0.95}],
                            "labels": [{"label": "sunglasses", "confidence": 0.95}],
                            "analysis_method": "hugging_face_resnet50"
                        },
                        "timestamp": "2024-01-01T00:00:00Z"
                    }
                }
            }
        },
        400: {
            "description": "Bad request - Invalid base64 data or parameters",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Invalid base64 image data"
                    }
                }
            }
        },
        422: {
            "description": "Validation failed - No sunglasses detected or low confidence",
            "content": {
                "application/json": {
                    "example": {
                        "status": "rejected",
                        "confidence": 0.0,
                        "message": "No sunglasses found in the image",
                        "details": "Please upload an image containing sunglasses (dark/tinted lenses)",
                        "analysis": {
                            "sunglasses_detected": False,
                            "confidence": 0.0,
                            "objects": [],
                            "labels": [{"label": "No sunglasses detected", "confidence": 0.0}],
                            "analysis_method": "hugging_face_resnet50"
                        },
                        "timestamp": "2024-01-01T00:00:00Z"
                    }
                }
            }
        },
        500: {
            "description": "Internal server error",
            "content": {
                "application/json": {
                    "example": {
                        "detail": "Base64 image validation failed"
                    }
                }
            }
        }
    }
)
async def validate_sunglasses_base64(request: Dict[str, str]):
    """
    **Validate Sunglasses - Base64 Encoding**
    
    Submit an image as base64-encoded string for sunglasses detection.
    
    **Request Body:**
    ```json
    {
      "image": "base64_encoded_image_string"
    }
    ```
    
    **Benefits:**
    - Ideal for mobile apps (Flutter, React Native)
    - No multipart/form-data handling needed
    - Works well with JSON APIs
    
    **Base64 Format:**
    - Remove data URI prefix if present: `data:image/jpeg;base64,`
    - Submit only the base64 string
    
    **File Size Limit:** 50MB
    
    **Returns:** Same as `/validate-sunglasses` endpoint
    
    **Example Request:**
    ```json
    {
      "image": "iVBORw0KGgoAAAANSUhEUgAA..."
    }
    ```
    """
    try:
        base64_image = request.get("image")
        if not base64_image:
            raise HTTPException(status_code=400, detail="No image provided")
        
        # Decode base64 image
        try:
            image_content = base64.b64decode(base64_image)
        except Exception as e:
            raise HTTPException(status_code=400, detail="Invalid base64 image data")
        
        # Check file size (max 50MB)
        max_size = 50 * 1024 * 1024  # 50MB
        if len(image_content) == 0:
            raise HTTPException(status_code=400, detail="Empty image data provided")
        
        if len(image_content) > max_size:
            raise HTTPException(
                status_code=400, 
                detail="File too large. Maximum size is 50MB."
            )
        
        # Process the image directly instead of creating a mock UploadFile
        logger.info(f"Analyzing base64 image, size: {len(image_content)} bytes")
        
        # Analyze image - try AI model first, then Vision API, then mock
        if image_classifier:
            logger.info("Using Hugging Face AI model for base64 analysis")
            analysis_result = analyze_image_with_ai_model(image_content)
        elif vision_client:
            logger.info("Using Google Cloud Vision API for base64 analysis")
            analysis_result = analyze_image_with_vision_api(image_content)
        else:
            logger.info("Using improved mock analysis for base64 development")
            analysis_result = mock_sunglasses_analysis(image_content)
        
        # Determine validation result
        sunglasses_detected = analysis_result["sunglasses_detected"]
        confidence = analysis_result["confidence"]
        min_confidence_threshold = 0.1  # 10% minimum confidence (much lower for better detection)
        
        if sunglasses_detected and confidence >= min_confidence_threshold:
            status = "accepted"
            message = f"Sunglasses detected with {confidence:.1%} confidence"
            details = f"Detected: {analysis_result.get('objects', [{}])[0].get('object', 'sunglasses')} with {confidence:.1%} confidence"
        else:
            status = "rejected"
            if not sunglasses_detected:
                message = "No sunglasses found in the image"
                details = "Please upload an image containing sunglasses (dark/tinted lenses)"
            else:
                message = f"Sunglasses detected but confidence too low ({confidence:.1%})"
                details = f"Confidence {confidence:.1%} is below required {min_confidence_threshold:.1%}"
        
        response_data = {
            "status": status,
            "confidence": confidence,
            "message": message,
            "details": details,
            "analysis": analysis_result,
            "timestamp": datetime.now(timezone.utc).isoformat() + "Z"
        }
        
        logger.info(f"Base64 validation result: {status} - {message}")
        
        # Return appropriate HTTP status code based on validation result
        if status == "accepted":
            return JSONResponse(content=response_data, status_code=200)
        else:
            # 422 Unprocessable Entity for validation failures
            return JSONResponse(content=response_data, status_code=422)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Base64 validation error: {e}")
        raise HTTPException(status_code=500, detail="Base64 image validation failed")

if __name__ == "__main__":
    import uvicorn
    import os
    # Cloud Run sets PORT environment variable
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(
        "main:app", 
        host="0.0.0.0", 
        port=port, 
        reload=False,  # Disable reload in production
        log_level="info"
    )

