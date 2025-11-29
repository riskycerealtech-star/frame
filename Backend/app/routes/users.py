"""
User management endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from schemas.user import UserResponse, UserUpdate, UserSignupRequest, UserSignupResponse
from services.user_service import UserService
from app.dependencies import get_current_user

router = APIRouter()


@router.post("/signup/account", response_model=UserSignupResponse, status_code=status.HTTP_200_OK)
async def signup_user_account(
    signup_data: UserSignupRequest,
    db: Session = Depends(get_db)
):
    """Create a new user account"""
    user_service = UserService(db)
    
    try:
        result = user_service.signup_user(signup_data)
        return result
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: dict = Depends(get_current_user)
):
    """Get current user profile"""
    return current_user


@router.put("/me", response_model=UserResponse)
async def update_current_user_profile(
    user_update: UserUpdate,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update current user profile"""
    user_service = UserService(db)
    updated_user = user_service.update_user(current_user["id"], user_update)
    return updated_user


@router.get("/{user_id}", response_model=UserResponse)
async def get_user_profile(
    user_id: int,
    db: Session = Depends(get_db)
):
    """Get user profile by ID"""
    user_service = UserService(db)
    user = user_service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user


@router.delete("/me", status_code=status.HTTP_200_OK)
async def delete_current_user(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Delete current user account
    
    This endpoint allows authenticated users to delete their own account.
    Once deleted, the account and all associated data cannot be recovered.
    """
    user_service = UserService(db)
    user_id = current_user["id"]
    
    # Check if user exists
    user = user_service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Delete the user
    deleted = user_service.delete_user(user_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete user"
        )
    
    return {
        "status": "success",
        "message": "User account deleted successfully",
        "deleted_user_id": user_id
    }


@router.delete("/{user_id}", status_code=status.HTTP_200_OK)
async def delete_user_by_id(
    user_id: int,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Delete user account by ID
    
    This endpoint allows deleting a user account by ID.
    Users can only delete their own account (user_id must match current_user id).
    """
    user_service = UserService(db)
    current_user_id = current_user["id"]
    
    # Check if user is trying to delete their own account
    if user_id != current_user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only delete your own account"
        )
    
    # Check if user exists
    user = user_service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Delete the user
    deleted = user_service.delete_user(user_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete user"
        )
    
    return {
        "status": "success",
        "message": "User account deleted successfully",
        "deleted_user_id": user_id
    }
