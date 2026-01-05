# User Registration Input Fields

## Endpoint
```
POST /v1/auth/register
```

## Content-Type
```
application/json
```

## Required Input Fields

### JSON Request Body Structure

```json
{
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "+1234567890",
  "password": "SecurePass123",
  "rePassword": "SecurePass123",
  "gender": "Male",
  "location": "New York"
}
```

## Field Details

### Required Fields

| Field | Type | Description | Example | Validation |
|-------|------|-------------|---------|------------|
| `email` | string | User's email address | `"user@example.com"` | Must be valid email format |
| `firstName` | string | User's first name | `"John"` | Minimum 2 characters |
| `lastName` | string | User's last name | `"Doe"` | Minimum 2 characters |
| `phoneNumber` | string | User's phone number | `"+1234567890"` | Must start with + and have at least 10 digits |
| `password` | string | User's password | `"SecurePass123"` | See password requirements below |
| `rePassword` | string | Re-enter password for confirmation | `"SecurePass123"` | Must match the password field |
| `gender` | string | User's gender | `"Male"`, `"Female"`, or `"N/A"` | Must be one of the options |
| `location` | string | User's location | `"New York"` | Any string value |

### Optional Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `occupation` | string | User's occupation | `"EMPLOYED"`, `"UNEMPLOYED"`, `"STUDENT"` |
| `sourceOfFunds` | string | Source of funds | `"INVESTMENT"`, `"SALARY"`, `"BUSINESS"` |
| `additionalProperties` | object | Additional user properties | `{"key": "value"}` |
| `timezone` | string | User's timezone | `"America/New_York"` |

## Password Requirements

The password **must** meet all of the following criteria:

- ✅ **Minimum 8 characters** long
- ✅ **At least one uppercase letter** (A-Z)
- ✅ **At least one lowercase letter** (a-z)
- ✅ **At least one number** (0-9)
- ⚠️ Special characters are **recommended** but not required

### Valid Password Examples
- ✅ `SecurePass123`
- ✅ `MyP@ssw0rd`
- ✅ `Test1234`
- ✅ `HelloWorld2024`

### Invalid Password Examples
- ❌ `password` (no uppercase, no number)
- ❌ `PASSWORD` (no lowercase, no number)
- ❌ `Pass123` (too short, less than 8 characters)
- ❌ `password123` (no uppercase letter)

## Phone Number Format

Phone numbers must follow this format:
- Must start with `+` (plus sign)
- Followed by country code and number
- Minimum 10 digits after the `+`
- Example: `+1234567890`

## Gender Options

Valid gender values:
- `"Male"`
- `"Female"`
- `"N/A"`

## Example cURL Request

```bash
curl -X POST "http://localhost:8000/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "+1234567890",
    "password": "SecurePass123",
    "rePassword": "SecurePass123",
    "gender": "Male",
    "location": "New York",
    "occupation": "EMPLOYED",
    "sourceOfFunds": "SALARY"
  }'
```

## Example Python Request

```python
import requests

url = "http://localhost:8000/v1/auth/register"
data = {
    "email": "john.doe@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "+1234567890",
    "password": "SecurePass123",
    "rePassword": "SecurePass123",
    "gender": "Male",
    "location": "New York",
    "occupation": "EMPLOYED",
    "sourceOfFunds": "SALARY"
}

response = requests.post(url, json=data)
print(response.json())
```

## Example JavaScript/TypeScript Request

```javascript
const registerUser = async () => {
  const response = await fetch('http://localhost:8000/v1/auth/register', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      email: 'john.doe@example.com',
      firstName: 'John',
      lastName: 'Doe',
      phoneNumber: '+1234567890',
      password: 'SecurePass123',
      rePassword: 'SecurePass123',
      gender: 'Male',
      location: 'New York',
      occupation: 'EMPLOYED',
      sourceOfFunds: 'SALARY'
    })
  });
  
  const data = await response.json();
  console.log(data);
};
```

## Success Response

```json
{
  "status": "CREATED",
  "email": "john.doe@example.com",
  "userId": "USER123456",
  "phoneNumber": "+1234567890",
  "createdOn": "2024-01-05T12:00:00Z",
  "updatedOn": "2024-01-05T12:00:00Z"
}
```

## Error Responses

### 400 Bad Request - Password Validation Failed
```json
{
  "detail": "Password must be at least 8 characters long"
}
```

### 409 Conflict - Email Already Exists
```json
{
  "detail": "User with this email already exists"
}
```

### 409 Conflict - Phone Number Already Exists
```json
{
  "detail": "User with this phone number already exists"
}
```

## Validation Rules Summary

1. **Email**: Must be a valid email format
2. **First Name**: Minimum 2 characters
3. **Last Name**: Minimum 2 characters
4. **Phone Number**: Must start with `+` and have at least 10 digits
5. **Password**: 
   - Minimum 8 characters
   - At least one uppercase letter
   - At least one lowercase letter
   - At least one number
6. **Re-Password**: Must match the password field exactly
7. **Gender**: Must be "Male", "Female", or "N/A"
7. **Location**: Any string value (required)

## Notes

- All required fields must be provided
- Email and phone number must be unique (not already registered)
- Password is hashed using bcrypt before storage
- User ID is automatically generated
- Timestamps (createdOn, updatedOn) are automatically set

