"""
User management endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.schemas.user import UserResponse, UserUpdate, UserSignupRequest, UserSignupResponse
from app.services.user_service import UserService
from app.api.v1.dependencies import get_current_user

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


@router.get("/status/phone/{phoneNumber}", response_model=UserResponse, summary="Get user by phone number")
async def get_user_by_phone(phoneNumber: str, db: Session = Depends(get_db)):
    """Get user information by phone number"""
    user_service = UserService(db)
    user = user_service.get_user_by_phone(phoneNumber)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user


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


@router.delete("/user/{user_id}", summary="Delete user by ID", status_code=status.HTTP_200_OK)
async def delete_user_by_id(
    user_id: int,
    db: Session = Depends(get_db)
):
    """Delete user account by ID"""
    user_service = UserService(db)
    
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
