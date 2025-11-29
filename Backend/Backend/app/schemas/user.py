"""
User schemas for request/response models
"""
from pydantic import BaseModel, EmailStr
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
    timezone: Optional[str] = None


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
    token_type: str


class TokenData(BaseModel):
    """Token data schema"""
    user_id: Optional[int] = None
