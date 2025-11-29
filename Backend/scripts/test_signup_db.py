#!/usr/bin/env python3
"""
Test script to verify signup data is saved in Google Cloud Database
Usage: python scripts/test_signup_db.py
"""

import sys
import os
from pathlib import Path

# Add parent directory to path to import app modules
sys.path.insert(0, str(Path(__file__).parent.parent))

from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from datetime import datetime

def test_signup_data_in_db():
    """Test if signup data exists in the database"""
    print("=" * 60)
    print("Testing Signup Data in Google Cloud Database")
    print("=" * 60)
    print()
    
    try:
        # Get database session
        db_gen = get_db()
        db: Session = next(db_gen)
        
        print("✅ Database connection established")
        print()
        
        # Query all users
        users = db.query(User).order_by(User.created_at.desc()).limit(10).all()
        
        if not users:
            print("⚠️  No users found in database")
            print("   This could mean:")
            print("   1. No signups have been completed yet")
            print("   2. Database connection issue")
            print("   3. Users table is empty")
            return
        
        print(f"📊 Found {len(users)} user(s) in database")
        print()
        print("-" * 60)
        print("Recent Signups:")
        print("-" * 60)
        
        for i, user in enumerate(users, 1):
            print(f"\n👤 User #{i}:")
            print(f"   ID: {user.id}")
            print(f"   Email: {user.email}")
            print(f"   Username: {user.username}")
            print(f"   First Name: {user.first_name}")
            print(f"   Last Name: {user.last_name}")
            print(f"   Phone: {user.phone_number}")
            print(f"   Gender: {user.additional_properties.get('gender', 'N/A') if user.additional_properties else 'N/A'}")
            print(f"   Location: {user.additional_properties.get('location', 'N/A') if user.additional_properties else 'N/A'}")
            print(f"   Occupation: {user.occupation or 'N/A'}")
            print(f"   Source of Funds: {user.source_of_funds or 'N/A'}")
            print(f"   Created At: {user.created_at}")
            print(f"   Updated At: {user.updated_at}")
            print(f"   Verified: {user.is_verified}")
        
        print()
        print("-" * 60)
        print("✅ Database test completed successfully!")
        print("-" * 60)
        
        # Test query by email
        if users:
            test_email = users[0].email
            print(f"\n🔍 Testing query by email: {test_email}")
            found_user = db.query(User).filter(User.email == test_email).first()
            if found_user:
                print(f"   ✅ User found: {found_user.email}")
            else:
                print(f"   ❌ User not found")
        
        # Test query by phone
        if users and users[0].phone_number:
            test_phone = users[0].phone_number
            print(f"\n🔍 Testing query by phone: {test_phone}")
            found_user = db.query(User).filter(User.phone_number == test_phone).first()
            if found_user:
                print(f"   ✅ User found: {found_user.phone_number}")
            else:
                print(f"   ❌ User not found")
        
    except Exception as e:
        print(f"❌ Error testing database: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    finally:
        try:
            db.close()
        except:
            pass
    
    return True

if __name__ == "__main__":
    print()
    success = test_signup_data_in_db()
    print()
    sys.exit(0 if success else 1)



