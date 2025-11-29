# signuptbl Table Documentation

## Overview

The `signuptbl` table stores user signup information from the `/v1/user/signup` API endpoint. This table is designed to match all the parameters required and optional for user registration.

## Table Structure

### Columns

| Column Name | Type | Constraints | Description |
|-------------|------|-------------|-------------|
| `id` | SERIAL | PRIMARY KEY | Auto-incrementing primary key |
| `user_id` | VARCHAR(20) | UNIQUE, NOT NULL, INDEXED | Unique user identifier (format: USR123456) |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL, INDEXED | User email address |
| `first_name` | VARCHAR(100) | NOT NULL | User's first name |
| `last_name` | VARCHAR(100) | NOT NULL | User's last name |
| `phone_number` | VARCHAR(20) | UNIQUE, NOT NULL, INDEXED | Phone number with country code (e.g., +1234567890) |
| `hashed_password` | VARCHAR(255) | NOT NULL | Hashed password (bcrypt) |
| `gender` | VARCHAR(50) | NOT NULL | Gender: MALE, FEMALE, OTHER |
| `location` | VARCHAR(255) | NOT NULL | Location: City, State, Country |
| `occupation` | VARCHAR(50) | NULL | Occupation: EMPLOYED, UNEMPLOYED, STUDENT, RETIRED, SELF_EMPLOYED |
| `source_of_funds` | VARCHAR(50) | NULL | Source of funds: SALARY, BUSINESS, INVESTMENT, GIFT, OTHER |
| `timezone` | VARCHAR(100) | NULL | Timezone (e.g., America/New_York, Europe/London) |
| `additional_properties` | JSONB | NULL | Additional user properties as JSON object |
| `status` | VARCHAR(50) | NOT NULL, DEFAULT 'CREATED' | Signup status: CREATED, VERIFIED, etc. |
| `created_on` | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| `updated_on` | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Last update timestamp (auto-updated) |

## Indexes

1. **ix_signuptbl_email** - Unique index on `email` for fast email lookups
2. **ix_signuptbl_phone_number** - Unique index on `phone_number` for fast phone lookups
3. **ix_signuptbl_user_id** - Unique index on `user_id` for fast user ID lookups
4. **ix_signuptbl_created_on** - Index on `created_on` for date-based queries

## Triggers

- **trigger_update_signuptbl_updated_on** - Automatically updates `updated_on` timestamp when a row is updated

## API Mapping

### Required Fields (from API)

| API Field | Database Column | Type |
|-----------|----------------|------|
| `email` | `email` | VARCHAR(255) |
| `firstName` | `first_name` | VARCHAR(100) |
| `lastName` | `last_name` | VARCHAR(100) |
| `phoneNumber` | `phone_number` | VARCHAR(20) |
| `password` | `hashed_password` | VARCHAR(255) |
| `gender` | `gender` | VARCHAR(50) |
| `location` | `location` | VARCHAR(255) |

### Optional Fields (from API)

| API Field | Database Column | Type |
|-----------|----------------|------|
| `occupation` | `occupation` | VARCHAR(50) |
| `sourceOfFunds` | `source_of_funds` | VARCHAR(50) |
| `timezone` | `timezone` | VARCHAR(100) |
| `additionalProperties` | `additional_properties` | JSONB |

## Creating the Table

### Option 1: Using SQL Script

```bash
# Connect to your database and run:
psql -h <host> -U <user> -d <database> -f scripts/create_signuptbl.sql
```

### Option 2: Using Shell Script

```bash
# Make sure you have POSTGRES_PASSWORD set in your environment
export POSTGRES_PASSWORD='your_password'

# Run the script
./scripts/create_signuptbl.sh
```

### Option 3: Using Alembic Migration

```bash
# Run the migration
alembic upgrade head
```

### Option 4: Direct SQL (Cloud SQL)

```bash
# For Cloud SQL, connect and run:
gcloud sql connect glass-db --user=glass_user --database=glass_db

# Then paste the SQL from scripts/create_signuptbl.sql
```

## Example Queries

### Insert a new signup record

```sql
INSERT INTO signuptbl (
    user_id, email, first_name, last_name, phone_number, hashed_password,
    gender, location, occupation, source_of_funds, timezone, status
) VALUES (
    'USR123456',
    'john.doe@example.com',
    'John',
    'Doe',
    '+1234567890',
    '$2b$12$hashedpasswordhere',
    'MALE',
    'New York, USA',
    'EMPLOYED',
    'SALARY',
    'America/New_York',
    'CREATED'
);
```

### Query by email

```sql
SELECT * FROM signuptbl WHERE email = 'john.doe@example.com';
```

### Query by phone number

```sql
SELECT * FROM signuptbl WHERE phone_number = '+1234567890';
```

### Query by user_id

```sql
SELECT * FROM signuptbl WHERE user_id = 'USR123456';
```

### Update status

```sql
UPDATE signuptbl 
SET status = 'VERIFIED', updated_on = CURRENT_TIMESTAMP 
WHERE user_id = 'USR123456';
```

### Get recent signups

```sql
SELECT user_id, email, first_name, last_name, created_on 
FROM signuptbl 
ORDER BY created_on DESC 
LIMIT 10;
```

### Count signups by status

```sql
SELECT status, COUNT(*) as count 
FROM signuptbl 
GROUP BY status;
```

## Validation Rules

1. **Email**: Must be unique, valid email format
2. **Phone Number**: Must be unique, must start with `+` followed by country code
3. **Password**: Must be hashed using bcrypt before storage
4. **Gender**: Common values: MALE, FEMALE, OTHER
5. **Occupation**: Valid values: EMPLOYED, UNEMPLOYED, STUDENT, RETIRED, SELF_EMPLOYED
6. **Source of Funds**: Valid values: SALARY, BUSINESS, INVESTMENT, GIFT, OTHER

## Notes

- The `user_id` should be generated in the format `USR` + 6 alphanumeric characters (e.g., USR123456)
- Passwords should NEVER be stored in plain text - always hash using bcrypt
- The `updated_on` field is automatically updated by a database trigger
- The `additional_properties` JSONB column can store any extra data as key-value pairs
- All timestamps are stored in UTC by default

## Related Files

- **Migration**: `migrations/versions/002_create_signuptbl.py`
- **SQL Script**: `scripts/create_signuptbl.sql`
- **Shell Script**: `scripts/create_signuptbl.sh`
- **API Endpoint**: `/v1/user/signup` (see `docs/API_SIGNUP_ENDPOINT.md`)



