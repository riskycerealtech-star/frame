"""
User schemas for request/response models
"""
from pydantic import BaseModel, EmailStr, Field, field_validator, model_validator
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    """Base user schema"""
    email: EmailStr
    username: str
    full_name: Optional[str] = None
    phone: Optional[str] = None
    bio: Optional[str] = None


class UserSignupRequest(BaseModel):
    """
    User signup request schema - Required fields only.
    
    Required fields:
    - email, firstName, lastName, phoneNumber, password, rePassword, gender, timezone
    """
    email: EmailStr = Field(
        ...,
        description="Valid email address",
        example="john.doe@example.com"
    )
    firstName: str = Field(
        ...,
        min_length=2,
        description="First name (minimum 2 characters)",
        example="John"
    )
    lastName: str = Field(
        ...,
        min_length=2,
        description="Last name (minimum 2 characters)",
        example="Doe"
    )
    phoneNumber: str = Field(
        ...,
        description="Phone number starting with + (e.g., +1234567890)",
        example="+1234567890",
        pattern=r"^\+\d{10,}$"
    )
    password: str = Field(
        ...,
        min_length=8,
        description="Password meeting security requirements: minimum 8 characters, at least one uppercase letter, one lowercase letter, and one number",
        example="SecurePass123"
    )
    rePassword: str = Field(
        ...,
        description="Re-enter password (must match password)",
        example="SecurePass123"
    )
    gender: str = Field(
        ...,
        description="Must be 'Male', 'Female', or 'N/A'",
        example="Male"
    )
    timezone: str = Field(
        ...,
        description="User's timezone",
        example="America/New_York"
    )
    
    @model_validator(mode='after')
    def passwords_match(self):
        """Validate that password and rePassword match"""
        if self.password != self.rePassword:
            raise ValueError('Passwords do not match')
        return self
    
    @field_validator('gender')
    @classmethod
    def validate_gender(cls, v):
        """Validate gender is one of the allowed values"""
        allowed = ['Male', 'Female', 'N/A']
        if v not in allowed:
            raise ValueError(f"Gender must be one of: {', '.join(allowed)}")
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "john.doe@example.com",
                "firstName": "John",
                "lastName": "Doe",
                "phoneNumber": "+1234567890",
                "password": "SecurePass123",
                "rePassword": "SecurePass123",
                "gender": "Male",
                "timezone": "America/New_York"
            }
        }


class UserSignupResponse(BaseModel):
    """User signup response schema"""
    status: str
    email: str
    userId: str
    phoneNumber: str


class UserCreate(UserBase):
    """User creation schema"""
    password: str


class UserUpdate(BaseModel):
    """User update schema"""
    full_name: Optional[str] = None
    phone: Optional[str] = None
    bio: Optional[str] = None
    profile_image_url: Optional[str] = None


class UserResponse(UserBase):
    """User response schema"""
    id: int
    is_verified: bool
    is_seller: bool
    is_admin: bool
    profile_image_url: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    last_login: Optional[datetime] = None
    
    class Config:
        from_attributes = True


class Token(BaseModel):
    """Token response schema"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class LoginRequest(BaseModel):
    """
    Login request schema - supports email, username, or phone number as identifier.
    """
    username: str = Field(
        ...,
        min_length=1,
        description="User's email address, username, or phone number",
        example="user@example.com"
    )
    password: str = Field(
        ...,
        min_length=8,
        description="User password",
        example="SecurePass123"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "username": "user@example.com",
                "password": "SecurePass123"
            }
        }


class RefreshTokenRequest(BaseModel):
    """Refresh token request schema"""
    refresh_token: str = Field(
        ...,
        description="Refresh token"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
            }
        }


class TokenData(BaseModel):
    """Token data schema"""
    user_id: Optional[int] = None


# Additional optional schemas for future use
class LoginResponse(BaseModel):
    """Schema for login response"""
    success: bool
    message: str
    access_token: str
    refresh_token: Optional[str] = None
    token_type: str = "bearer"
    user: dict
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "message": "Login successful",
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer",
                "user": {
                    "id": "123e4567-e89b-12d3-a456-426614174000",
                    "email": "user@example.com",
                    "username": "john_doe"
                }
            }
        }


class TokenVerifyResponse(BaseModel):
    """Schema for token verification response"""
    valid: bool
    user: Optional[dict] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "valid": True,
                "user": {
                    "id": "123e4567-e89b-12d3-a456-426614174000",
                    "email": "user@example.com",
                    "username": "john_doe"
                }
            }
        }
