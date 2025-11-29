# Testing Signup Data in Google Cloud Database

This guide explains how to verify that signup data is being saved to the Google Cloud PostgreSQL database.

## 🧪 Testing Methods

### Method 1: Check Console Logs (Flutter App)

When you complete a signup in the Flutter app, check the console logs. You should see:

```
✅ [SIGNUP] Registration successful!
   - User ID: USR123456
   - Email: user@example.com
   - Status: CREATED
   - Phone: +1234567890
   - Created On: 2024-11-22T10:30:00-05:00

🗄️  [SIGNUP] Database Verification:
   ✅ User data saved to Google Cloud Database
   ✅ User ID: USR123456
   ✅ Email: user@example.com stored in database
   ✅ Phone: +1234567890 stored in database
   ✅ Timestamp: 2024-11-22T10:30:00-05:00

📊 [SIGNUP] Signup Summary:
   - First Name: John
   - Last Name: Doe
   - Email: user@example.com
   - Phone: +1234567890
   - Gender: MALE
   - Location: New York, USA
   ✅ All data successfully saved to database!
```

### Method 2: Python Script Test

Run the Python test script:

```bash
cd /Users/apple/Glass/Backend
python3 scripts/test_signup_db.py
```

This will:
- Connect to the database
- Query all recent signups
- Display user information
- Test queries by email and phone

**Expected Output:**
```
============================================================
Testing Signup Data in Google Cloud Database
============================================================

✅ Database connection established

📊 Found 3 user(s) in database

------------------------------------------------------------
Recent Signups:
------------------------------------------------------------

👤 User #1:
   ID: 1
   Email: john.doe@example.com
   Username: john.doe
   First Name: John
   Last Name: Doe
   Phone: +1234567890
   Gender: MALE
   Location: New York, USA
   Occupation: EMPLOYED
   Source of Funds: SALARY
   Created At: 2024-11-22 10:30:00
   Updated At: 2024-11-22 10:30:00
   Verified: False
```

### Method 3: Direct SQL Query

Use the shell script to query the database directly:

```bash
cd /Users/apple/Glass/Backend
./scripts/verify_signup_db.sh
```

Or connect manually:

```bash
# For Cloud SQL
gcloud sql connect glass-db --user=glass_user --database=glass_db

# Then run:
SELECT 
    id,
    email,
    first_name,
    last_name,
    phone_number,
    additional_properties->>'gender' as gender,
    additional_properties->>'location' as location,
    occupation,
    source_of_funds,
    created_at
FROM users
ORDER BY created_at DESC
LIMIT 10;
```

### Method 4: Check via API

Query the API to verify user exists:

```bash
# Get user by email (if you have a GET endpoint)
curl -X GET "https://glass-api-750669515844.us-central1.run.app/v1/user/{userId}" \
  -H "Content-Type: application/json"
```

## 📋 What to Verify

After a successful signup, verify these fields are saved:

### Required Fields
- ✅ `email` - User's email address
- ✅ `first_name` - User's first name
- ✅ `last_name` - User's last name
- ✅ `phone_number` - User's phone number
- ✅ `hashed_password` - Hashed password (never plain text!)
- ✅ `gender` - Stored in `additional_properties->>'gender'`
- ✅ `location` - Stored in `additional_properties->>'location'`

### Optional Fields
- ✅ `occupation` - If provided
- ✅ `source_of_funds` - If provided
- ✅ `timezone` - If provided (may be in additional_properties)
- ✅ `additional_properties` - JSON object with extra data

### System Fields
- ✅ `id` - Auto-generated primary key
- ✅ `username` - Generated from email
- ✅ `created_at` - Timestamp when user was created
- ✅ `updated_at` - Timestamp when user was last updated
- ✅ `is_verified` - Should be `false` initially

## 🔍 Troubleshooting

### No Data in Database

If no users appear in the database:

1. **Check API Response:**
   - Look for 200 status code in console logs
   - Verify `status: "CREATED"` in response

2. **Check Database Connection:**
   ```bash
   # Test connection
   python3 scripts/test_signup_db.py
   ```

3. **Check API Logs:**
   - Look for database errors in Cloud Run logs
   - Check if `DB_AVAILABLE` is `True`

4. **Verify Database Credentials:**
   - Check `.env` file has correct database credentials
   - Verify Cloud SQL instance is running

### Data Not Complete

If some fields are missing:

1. **Check Request Body:**
   - Verify all required fields are sent in the API request
   - Check console logs for the request body

2. **Check Database Schema:**
   - Verify the `users` table has all required columns
   - Check if migrations have been run

3. **Check Service Code:**
   - Verify `user_service.signup_user()` is saving all fields
   - Check if any fields are being filtered out

## 📊 Database Table Structure

The signup data is saved in the `users` table with this structure:

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(255),
    hashed_password VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    occupation VARCHAR(50),
    source_of_funds VARCHAR(50),
    additional_properties JSONB,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

## ✅ Success Criteria

A successful signup test should show:

1. ✅ API returns 200 status code
2. ✅ Response contains `userId`, `email`, `status: "CREATED"`
3. ✅ Console logs show "Database Verification" with all fields
4. ✅ Database query returns the new user record
5. ✅ All required fields are present in the database
6. ✅ Timestamps are correctly set
7. ✅ Password is hashed (not plain text)

## 🚀 Quick Test

1. **Complete a signup** in the Flutter app
2. **Check console logs** for verification messages
3. **Run test script:**
   ```bash
   cd Backend
   python3 scripts/test_signup_db.py
   ```
4. **Verify** the new user appears in the results

---

**Note:** The signup data is saved to the `users` table in your Google Cloud SQL PostgreSQL database. The `signuptbl` table we created earlier is available if you want to use it for a separate signup tracking system.



