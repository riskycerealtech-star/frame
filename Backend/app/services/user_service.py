"""
User service for business logic
"""
from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate, UserSignupRequest
from app.core.security import get_password_hash, verify_password
from app.utils.user_id_generator import generate_unique_user_id
from typing import Optional


class UserService:
    """User service class"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_user_by_id(self, user_id: int) -> Optional[User]:
        """Get user by ID"""
        return self.db.query(User).filter(User.id == user_id).first()
    
    def get_user_by_email(self, email: str) -> Optional[User]:
        """Get user by email"""
        return self.db.query(User).filter(User.email == email).first()
    
    def get_user_by_username(self, username: str) -> Optional[User]:
        """Get user by username"""
        return self.db.query(User).filter(User.username == username).first()
    
    def create_user(self, user_data: UserCreate) -> User:
        """Create new user"""
        hashed_password = get_password_hash(user_data.password)
        db_user = User(
            email=user_data.email,
            username=user_data.username,
            full_name=user_data.full_name,
            phone=user_data.phone,
            bio=user_data.bio,
            hashed_password=hashed_password
        )
        self.db.add(db_user)
        self.db.commit()
        self.db.refresh(db_user)
        return db_user
    
    def update_user(self, user_id: int, user_update: UserUpdate) -> Optional[User]:
        """Update user"""
        db_user = self.get_user_by_id(user_id)
        if not db_user:
            return None
        
        update_data = user_update.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_user, field, value)
        
        self.db.commit()
        self.db.refresh(db_user)
        return db_user
    
    def authenticate_user(self, username: str, password: str) -> Optional[User]:
        """Authenticate user with username/email and password"""
        user = self.get_user_by_username(username) or self.get_user_by_email(username)
        if not user:
            return None
        if not verify_password(password, user.hashed_password):
            return None
        return user
    
    def signup_user(self, signup_data: UserSignupRequest) -> dict:
        """Create new user account with signup data"""
        # Check if user already exists by email
        existing_user = self.get_user_by_email(signup_data.email)
        if existing_user:
            raise ValueError("User with this email already exists")
        
        # Check if phone number already exists
        existing_phone_user = self.db.query(User).filter(User.phone_number == signup_data.phoneNumber).first()
        if existing_phone_user:
            raise ValueError("User with this phone number already exists")
        
        # Generate unique user ID
        existing_user_ids = {user.username for user in self.db.query(User).all()}
        user_id = generate_unique_user_id(existing_user_ids)
        
        # Store the user_id in the database for future reference
        # We'll add a user_id field to the User model later
        
        # Create username from email (before @ symbol)
        username = signup_data.email.split('@')[0]
        
        # Ensure username is unique
        original_username = username
        counter = 1
        while self.get_user_by_username(username):
            username = f"{original_username}{counter}"
            counter += 1
        
        # Hash password
        hashed_password = get_password_hash(signup_data.password)
        
        # Create full name
        full_name = f"{signup_data.firstName} {signup_data.lastName}"
        
        # Build additional_properties with gender and location
        additional_props = signup_data.additionalProperties or {}
        if signup_data.gender:
            additional_props['gender'] = signup_data.gender
        if signup_data.location:
            additional_props['location'] = signup_data.location
        
        # Create user
        db_user = User(
            email=signup_data.email,
            username=username,
            first_name=signup_data.firstName,
            last_name=signup_data.lastName,
            full_name=full_name,
            phone_number=signup_data.phoneNumber,
            hashed_password=hashed_password,
            occupation=signup_data.occupation,
            source_of_funds=signup_data.sourceOfFunds,
            additional_properties=additional_props
        )
        
        self.db.add(db_user)
        self.db.commit()
        self.db.refresh(db_user)
        
        # Format timestamps
        from datetime import datetime
        created_on = db_user.created_at.isoformat() + "Z" if db_user.created_at else None
        updated_on = db_user.updated_at.isoformat() + "Z" if db_user.updated_at else None
        
        return {
            "status": "CREATED",
            "email": signup_data.email,
            "userId": user_id,
            "phoneNumber": signup_data.phoneNumber,
            "createdOn": created_on,
            "updatedOn": updated_on
        }
    
    def delete_user(self, user_id: int) -> bool:
        """Delete user by ID"""
        db_user = self.get_user_by_id(user_id)
        if not db_user:
            return False
        
        self.db.delete(db_user)
        self.db.commit()
        return True