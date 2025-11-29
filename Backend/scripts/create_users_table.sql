-- Create users table for signup data
-- Run this in your Cloud SQL database

-- Drop table if exists (for development/testing)
-- DROP TABLE IF EXISTS users CASCADE;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(255),
    hashed_password VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    bio TEXT,
    profile_image_url VARCHAR(500),
    occupation VARCHAR(50),
    source_of_funds VARCHAR(50),
    additional_properties JSONB,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_seller BOOLEAN NOT NULL DEFAULT FALSE,
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    last_login TIMESTAMP,
    email_verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS ix_users_email ON users(email);
CREATE INDEX IF NOT EXISTS ix_users_username ON users(username);
CREATE INDEX IF NOT EXISTS ix_users_phone_number ON users(phone_number);
CREATE INDEX IF NOT EXISTS ix_users_created_at ON users(created_at);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at on row update
DROP TRIGGER IF EXISTS trigger_update_users_updated_at ON users;
CREATE TRIGGER trigger_update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_users_updated_at();

-- Add comments to table and columns for documentation
COMMENT ON TABLE users IS 'Stores user account information including signup data';
COMMENT ON COLUMN users.id IS 'Primary key, auto-incrementing integer';
COMMENT ON COLUMN users.email IS 'User email address (unique, required)';
COMMENT ON COLUMN users.username IS 'Unique username (required)';
COMMENT ON COLUMN users.first_name IS 'User first name';
COMMENT ON COLUMN users.last_name IS 'User last name';
COMMENT ON COLUMN users.full_name IS 'User full name (first + last)';
COMMENT ON COLUMN users.hashed_password IS 'Hashed password (required, never store plain text)';
COMMENT ON COLUMN users.phone_number IS 'User phone number with country code';
COMMENT ON COLUMN users.occupation IS 'User occupation: EMPLOYED, UNEMPLOYED, STUDENT, RETIRED, SELF_EMPLOYED';
COMMENT ON COLUMN users.source_of_funds IS 'Source of funds: SALARY, BUSINESS, INVESTMENT, GIFT, OTHER';
COMMENT ON COLUMN users.additional_properties IS 'Additional user properties as JSON object (gender, location, timezone, etc.)';
COMMENT ON COLUMN users.is_verified IS 'Whether the user email is verified';
COMMENT ON COLUMN users.is_seller IS 'Whether the user is a seller';
COMMENT ON COLUMN users.is_admin IS 'Whether the user is an admin';
COMMENT ON COLUMN users.created_at IS 'Timestamp when user account was created';
COMMENT ON COLUMN users.updated_at IS 'Timestamp when user account was last updated (auto-updated)';

-- Verify table was created
SELECT 'Users table created successfully!' as status;


 
