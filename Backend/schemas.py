from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    email: EmailStr = Field(
        ...,
        description="User's email address",
        example="user@example.com"
    )
    username: str = Field(
        ...,
        description="Unique username",
        min_length=3,
        max_length=50,
        example="johndoe"
    )


class UserCreate(UserBase):
    password: str = Field(
        ...,
        description="User's password (minimum 8 characters recommended)",
        min_length=6,
        example="securepassword123"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "username": "johndoe",
                "password": "securepassword123"
            }
        }


class UserResponse(UserBase):
    id: int = Field(..., description="Unique user identifier", example=1)
    created_at: datetime = Field(..., description="Account creation timestamp", example="2025-01-15T10:30:00")

    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "id": 1,
                "email": "user@example.com",
                "username": "johndoe",
                "created_at": "2025-01-15T10:30:00"
            }
        }


class Token(BaseModel):
    access_token: str = Field(
        ...,
        description="JWT access token for authentication",
        example="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    )
    token_type: str = Field(
        default="bearer",
        description="Token type (always 'bearer')",
        example="bearer"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJqb2huZG9lIiwiZXhwIjoxNzA1MzI0MDAwfQ.example",
                "token_type": "bearer"
            }
        }


class TokenData(BaseModel):
    username: Optional[str] = None


class ErrorResponse(BaseModel):
    detail: str = Field(..., description="Error message", example="Email already registered")

    class Config:
        json_schema_extra = {
            "example": {
                "detail": "Email already registered"
            }
        }


class MessageResponse(BaseModel):
    message: str = Field(..., description="Response message", example="Welcome to Frame API")

    class Config:
        json_schema_extra = {
            "example": {
                "message": "Welcome to Frame API"
            }
        }

