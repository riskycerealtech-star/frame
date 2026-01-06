#!/bin/bash
# Script to fix LoginRequest import issue on the server

set -e

echo "=== Fixing LoginRequest Import Issue ==="
echo ""

BACKEND_DIR="/root/frame/Backend"
SCHEMA_FILE="$BACKEND_DIR/app/schemas/user.py"

# Check if file exists
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "✗ Error: Schema file not found at $SCHEMA_FILE"
    exit 1
fi

echo "1. Checking if LoginRequest exists in schema file..."
if grep -q "^class LoginRequest" "$SCHEMA_FILE"; then
    echo "   ✓ LoginRequest class found in file"
else
    echo "   ✗ LoginRequest class NOT found - adding it..."
    
    # Find the line number after Token class (which should be around line 155)
    TOKEN_END_LINE=$(grep -n "^class Token" "$SCHEMA_FILE" | head -1 | cut -d: -f1)
    
    if [ -z "$TOKEN_END_LINE" ]; then
        echo "   ✗ Could not find Token class to insert after"
        exit 1
    fi
    
    # Find where Token class ends (next empty line or next class)
    INSERT_LINE=$(awk -v start=$TOKEN_END_LINE '
        NR > start && /^$/ {print NR; exit}
        NR > start && /^class / {print NR-1; exit}
    ' "$SCHEMA_FILE")
    
    if [ -z "$INSERT_LINE" ]; then
        INSERT_LINE=$(wc -l < "$SCHEMA_FILE")
    fi
    
    # Create the LoginRequest class content
    LOGIN_REQUEST_CLASS="
class LoginRequest(BaseModel):
    \"\"\"
    Login request schema - supports email, username, or phone number as identifier.
    \"\"\"
    username: str = Field(
        ...,
        min_length=1,
        description=\"User's email address, username, or phone number\",
        example=\"user@example.com\"
    )
    password: str = Field(
        ...,
        min_length=8,
        description=\"User password\",
        example=\"SecurePass123\"
    )
    
    class Config:
        json_schema_extra = {
            \"example\": {
                \"username\": \"user@example.com\",
                \"password\": \"SecurePass123\"
            }
        }
"
    
    # Insert the class (using a temporary file for safety)
    TMP_FILE=$(mktemp)
    head -n $INSERT_LINE "$SCHEMA_FILE" > "$TMP_FILE"
    echo "$LOGIN_REQUEST_CLASS" >> "$TMP_FILE"
    tail -n +$((INSERT_LINE + 1)) "$SCHEMA_FILE" >> "$TMP_FILE"
    mv "$TMP_FILE" "$SCHEMA_FILE"
    
    echo "   ✓ LoginRequest class added to schema file"
fi

echo ""
echo "2. Clearing Python cache files..."
find "$BACKEND_DIR" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "$BACKEND_DIR" -name "*.pyc" -delete 2>/dev/null || true
find "$BACKEND_DIR" -name "*.pyo" -delete 2>/dev/null || true
echo "   ✓ Python cache cleared"

echo ""
echo "3. Verifying syntax..."
python3 -m py_compile "$SCHEMA_FILE" 2>&1
if [ $? -eq 0 ]; then
    echo "   ✓ Schema file syntax is valid"
else
    echo "   ✗ Schema file has syntax errors!"
    exit 1
fi

echo ""
echo "4. Testing import..."
cd "$BACKEND_DIR"
python3 -c "from app.schemas.user import LoginRequest; print('   ✓ LoginRequest imported successfully')" 2>&1
if [ $? -eq 0 ]; then
    echo ""
    echo "=== Fix Complete! ==="
    echo "You can now restart uvicorn:"
    echo "  uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"
else
    echo ""
    echo "✗ Import test failed - please check the error above"
    exit 1
fi

