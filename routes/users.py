"""
User routes
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from schemas import UserResponse
from auth import get_user_by_username
from models import User

router = APIRouter()


@router.get(
    "/status/{phoneNumber}",
    response_model=UserResponse,
    tags=["1. User Signup"],
    summary="Get user by phone number",
    description="""
    Fetch a user's profile by phone number.
    
    Note: Phone number is currently mapped to the `username` field.
    Returns 404 if no user is found.
    """,
)
async def get_user_status_by_phone(
    phoneNumber: str,
    db: Session = Depends(get_db),
):
    """Return the user that matches the provided phone number (stored as username)."""
    user = get_user_by_username(db, username=phoneNumber)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user

