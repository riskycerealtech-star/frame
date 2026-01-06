#!/usr/bin/env python3
"""
Script to verify and fix LoginRequest import issue
"""
import sys
import os

# Add the Backend directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    from app.schemas.user import LoginRequest
    print("✓ LoginRequest successfully imported")
    print(f"✓ LoginRequest class: {LoginRequest}")
    print(f"✓ LoginRequest fields: {list(LoginRequest.model_fields.keys())}")
    sys.exit(0)
except ImportError as e:
    print(f"✗ ImportError: {e}")
    print("\nAttempting to check the file directly...")
    
    schema_file = os.path.join(os.path.dirname(__file__), "app", "schemas", "user.py")
    if os.path.exists(schema_file):
        with open(schema_file, 'r') as f:
            content = f.read()
            if 'class LoginRequest' in content:
                print(f"✓ Found 'class LoginRequest' in {schema_file}")
                print("  But Python cannot import it - checking for syntax errors...")
                
                # Try to compile it
                try:
                    compile(content, schema_file, 'exec')
                    print("✓ File compiles without syntax errors")
                    print("\nPossible causes:")
                    print("  1. Python cache files (.pyc) need to be cleared")
                    print("  2. Module was modified but not reloaded")
                    print("  3. Circular import issue")
                except SyntaxError as se:
                    print(f"✗ Syntax error at line {se.lineno}: {se.msg}")
                    print(f"  {se.text}")
            else:
                print(f"✗ 'class LoginRequest' NOT FOUND in {schema_file}")
                print("\nThe LoginRequest class needs to be added to the file.")
    else:
        print(f"✗ Schema file not found: {schema_file}")
    
    sys.exit(1)

