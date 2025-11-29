"""
User ID generator utility
"""
import string
import random
from typing import Set


def generate_unique_user_id(existing_ids: Set[str] = None) -> str:
    """
    Generate a unique 5-character user ID
    
    Args:
        existing_ids: Set of existing user IDs to avoid duplicates
        
    Returns:
        str: Unique 5-character user ID
    """
    if existing_ids is None:
        existing_ids = set()
    
    # Characters to use for user ID (uppercase letters and numbers)
    characters = string.ascii_uppercase + string.digits
    
    while True:
        # Generate 5-character ID
        user_id = ''.join(random.choices(characters, k=5))
        
        # Check if ID is unique
        if user_id not in existing_ids:
            return user_id
