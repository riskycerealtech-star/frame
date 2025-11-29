"""
User routes
"""
from fastapi import APIRouter, Depends
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

