"""
User routes
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from schemas import UserResponse
from auth import get_current_user, oauth2_scheme
from models import User

router = APIRouter()


@router.get(
    "/me",
    response_model=UserResponse,
    tags=["1. Authentication"],
    summary="Get current user information",
    description="""
    Get the profile information of the currently authenticated user.
    
    **Authentication Required:** Yes
    
    This endpoint requires a valid JWT token in the Authorization header.
    The user information is extracted from the token.
    """,
    dependencies=[Depends(oauth2_scheme)],
)
async def read_users_me(current_user: User = Depends(get_current_user)):
    """
    Get the current authenticated user's profile information.
    
    Requires a valid JWT token in the Authorization header.
    Returns the user's id, email, username, and account creation date.
    """
    return current_user


@router.delete(
    "/me",
    tags=["1. Authentication"],
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

