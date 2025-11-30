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


@router.delete(
    "/me",
    tags=["1. User Signup"],
    summary="Delete Current User",
    description="""
    Delete the currently authenticated user's account.
    
    **Authentication Required:** Yes
    
    This permanently removes the user and cannot be undone.
    """,
    status_code=status.HTTP_200_OK,
    dependencies=[Depends(oauth2_scheme)],
)
async def delete_current_user(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Delete the current authenticated user account."""
    db_user = db.query(User).filter(User.id == current_user.id).first()
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    db.delete(db_user)
    db.commit()
    return {
        "status": "success",
        "message": "User account deleted successfully",
        "deleted_user_id": current_user.id,
    }

