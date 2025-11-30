"""
User service - Business logic for user operations
"""
from sqlalchemy.orm import Session
from models import User
from schemas import UserCreate
from auth import get_password_hash, get_user_by_email, get_user_by_username
from fastapi import HTTPException, status


class UserService:
    """Service for user-related business logic"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def create_user(self, user_data: UserCreate) -> User:
        """
        Create a new user account
        
        Args:
            user_data: User creation data
            
        Returns:
            Created user object
            
        Raises:
            HTTPException: If email or username already exists
        """
        # Check if user with email already exists
        db_user = get_user_by_email(self.db, email=user_data.email)
        if db_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
        
        # Check if user with username already exists
        db_user = get_user_by_username(self.db, username=user_data.username)
        if db_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already taken"
            )
        
        # Create new user
        hashed_password = get_password_hash(user_data.password)
        db_user = User(
            email=user_data.email,
            username=user_data.username,
            hashed_password=hashed_password
        )
        self.db.add(db_user)
        self.db.commit()
        self.db.refresh(db_user)
        return db_user



