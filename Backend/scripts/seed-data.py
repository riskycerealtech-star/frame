#!/usr/bin/env python3
"""
Seed data script for local development
Creates sample data for testing
"""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.db.session import SessionLocal, engine
from app.db.base import Base
from app.core.config import settings
from passlib.context import CryptContext

# Create tables if they don't exist
Base.metadata.create_all(bind=engine)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str:
    """Hash a password"""
    return pwd_context.hash(password)

def seed_users(db: Session):
    """Seed sample users"""
    from app.models.user import User
    
    print("👤 Seeding users...")
    
    users = [
        {
            "email": "admin@glass.com",
            "hashed_password": get_password_hash("admin123"),
            "full_name": "Admin User",
            "is_active": True,
            "is_superuser": True,
        },
        {
            "email": "user@glass.com",
            "hashed_password": get_password_hash("user123"),
            "full_name": "Test User",
            "is_active": True,
            "is_superuser": False,
        },
        {
            "email": "seller@glass.com",
            "hashed_password": get_password_hash("seller123"),
            "full_name": "Seller User",
            "is_active": True,
            "is_superuser": False,
        },
    ]
    
    for user_data in users:
        existing_user = db.query(User).filter(User.email == user_data["email"]).first()
        if not existing_user:
            user = User(**user_data)
            db.add(user)
            print(f"   ✅ Created user: {user_data['email']}")
        else:
            print(f"   ⏭️  User already exists: {user_data['email']}")
    
    db.commit()
    print("✅ Users seeded!\n")

def seed_products(db: Session):
    """Seed sample products"""
    from app.models.product import Product
    
    print("🕶️  Seeding products...")
    
    products = [
        {
            "name": "Classic Aviator Sunglasses",
            "description": "Timeless aviator style with UV protection",
            "price": 99.99,
            "category": "Aviator",
            "brand": "GlassBrand",
            "is_active": True,
        },
        {
            "name": "Round Retro Sunglasses",
            "description": "Vintage round frame design",
            "price": 79.99,
            "category": "Round",
            "brand": "GlassBrand",
            "is_active": True,
        },
        {
            "name": "Sport Performance Sunglasses",
            "description": "Lightweight and durable for active wear",
            "price": 149.99,
            "category": "Sport",
            "brand": "GlassBrand",
            "is_active": True,
        },
    ]
    
    for product_data in products:
        existing_product = db.query(Product).filter(Product.name == product_data["name"]).first()
        if not existing_product:
            product = Product(**product_data)
            db.add(product)
            print(f"   ✅ Created product: {product_data['name']}")
        else:
            print(f"   ⏭️  Product already exists: {product_data['name']}")
    
    db.commit()
    print("✅ Products seeded!\n")

def main():
    """Main seeding function"""
    print("🌱 Starting database seeding...\n")
    
    db = SessionLocal()
    try:
        seed_users(db)
        seed_products(db)
        print("🎉 Database seeding completed successfully!")
    except Exception as e:
        print(f"❌ Error seeding database: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    main()



