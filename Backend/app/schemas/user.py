"""
User schemas for request/response models
"""
from pydantic import BaseModel, EmailStr, Field, field_validator, model_validator
from typing import Optional, Dict, Any
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
    User signup request schema - All fields from the signup screen.
    
    Required fields match the mobile app signup form:
    - First Name, Last Name, Gender, Email, Phone Number, Password, Re-Password
    """
    email: EmailStr = Field(
        ...,
        description="User's email address",
        example="john.doe@example.com"
    )
    firstName: str = Field(
        ...,
        min_length=2,
        description="User's first name (minimum 2 characters)",
        example="John"
    )
    lastName: str = Field(
        ...,
        min_length=2,
        description="User's last name (minimum 2 characters)",
        example="Doe"
    )
    phoneNumber: str = Field(
        ...,
        description="User's phone number (must start with + and have at least 10 digits)",
        example="+1234567890",
        pattern=r"^\+\d{10,}$"
    )
    password: str = Field(
        ...,
        min_length=8,
        description="User's password. Must contain: minimum 8 characters, at least one uppercase letter, one lowercase letter, and one number",
        example="SecurePass123"
    )
    rePassword: str = Field(
        ...,
        description="Re-enter password for confirmation. Must match the password field.",
        example="SecurePass123"
    )
    gender: str = Field(
        ...,
        description="User's gender. Must be one of: 'Male', 'Female', or 'N/A'",
        example="Male"
    )
    location: str = Field(
        ...,
        description="User's location",
        example="New York"
    )
    occupation: Optional[str] = Field(
        None,
        description="User's occupation (optional)",
        example="EMPLOYED"
    )
    sourceOfFunds: Optional[str] = Field(
        None,
        description="Source of funds (optional)",
        example="SALARY"
    )
    additionalProperties: Optional[Dict[str, Any]] = Field(
        None,
        description="Additional user properties (optional)",
        example={"key": "value"}
    )
    timezone: Optional[str] = Field(
        None,
        description="User's timezone (optional)",
        example="America/New_York"
    )
    
    @model_validator(mode='after')
    def passwords_match(self):
        """Validate that password and rePassword match"""
        if self.password != self.rePassword:
            raise ValueError('Passwords do not match')
        return self
    
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
                "location": "New York",
                "occupation": "EMPLOYED",
                "sourceOfFunds": "SALARY"
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


class RefreshTokenRequest(BaseModel):
    """Refresh token request schema"""
    refresh_token: str


class TokenData(BaseModel):
    """Token data schema"""
    user_id: Optional[int] = None
