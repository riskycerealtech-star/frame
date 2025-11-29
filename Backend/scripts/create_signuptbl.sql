-- Create signuptbl table for user signup data
-- This table stores all signup information matching the API /v1/user/signup endpoint

-- Drop table if exists (for development/testing)
-- DROP TABLE IF EXISTS signuptbl CASCADE;

-- Create signuptbl table
CREATE TABLE IF NOT EXISTS signuptbl (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    gender VARCHAR(50) NOT NULL,
    location VARCHAR(255) NOT NULL,
    occupation VARCHAR(50) NULL,
    source_of_funds VARCHAR(50) NULL,
    timezone VARCHAR(100) NULL,
    additional_properties JSONB NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'CREATED',
    created_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS ix_signuptbl_email ON signuptbl(email);
CREATE INDEX IF NOT EXISTS ix_signuptbl_phone_number ON signuptbl(phone_number);
CREATE INDEX IF NOT EXISTS ix_signuptbl_user_id ON signuptbl(user_id);
CREATE INDEX IF NOT EXISTS ix_signuptbl_created_on ON signuptbl(created_on);

-- Create function to automatically update updated_on timestamp
CREATE OR REPLACE FUNCTION update_signuptbl_updated_on()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_on = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_on on row update
CREATE TRIGGER trigger_update_signuptbl_updated_on
    BEFORE UPDATE ON signuptbl
    FOR EACH ROW
    EXECUTE FUNCTION update_signuptbl_updated_on();

-- Add comments to table and columns for documentation
COMMENT ON TABLE signuptbl IS 'Stores user signup information from /v1/user/signup API endpoint';
COMMENT ON COLUMN signuptbl.id IS 'Primary key, auto-incrementing integer';
COMMENT ON COLUMN signuptbl.user_id IS 'Unique user identifier (format: USR123456)';
COMMENT ON COLUMN signuptbl.email IS 'User email address (unique, required)';
COMMENT ON COLUMN signuptbl.first_name IS 'User first name (required)';
COMMENT ON COLUMN signuptbl.last_name IS 'User last name (required)';
COMMENT ON COLUMN signuptbl.phone_number IS 'User phone number with country code, e.g., +1234567890 (unique, required)';
COMMENT ON COLUMN signuptbl.hashed_password IS 'Hashed password (required)';
COMMENT ON COLUMN signuptbl.gender IS 'User gender: MALE, FEMALE, OTHER (required)';
COMMENT ON COLUMN signuptbl.location IS 'User location: City, State, Country (required)';
COMMENT ON COLUMN signuptbl.occupation IS 'User occupation: EMPLOYED, UNEMPLOYED, STUDENT, RETIRED, SELF_EMPLOYED (optional)';
COMMENT ON COLUMN signuptbl.source_of_funds IS 'Source of funds: SALARY, BUSINESS, INVESTMENT, GIFT, OTHER (optional)';
COMMENT ON COLUMN signuptbl.timezone IS 'User timezone, e.g., America/New_York, Europe/London (optional)';
COMMENT ON COLUMN signuptbl.additional_properties IS 'Additional user properties as JSON object (optional)';
COMMENT ON COLUMN signuptbl.status IS 'Signup status: CREATED, VERIFIED, etc. (default: CREATED)';
COMMENT ON COLUMN signuptbl.created_on IS 'Timestamp when record was created';
COMMENT ON COLUMN signuptbl.updated_on IS 'Timestamp when record was last updated (auto-updated)';

-- Example insert (for testing)
-- INSERT INTO signuptbl (
--     user_id, email, first_name, last_name, phone_number, hashed_password,
--     gender, location, occupation, source_of_funds, timezone, status
-- ) VALUES (
--     'USR123456',
--     'john.doe@example.com',
--     'John',
--     'Doe',
--     '+1234567890',
--     '$2b$12$hashedpasswordhere',
--     'MALE',
--     'New York, USA',
--     'EMPLOYED',
--     'SALARY',
--     'America/New_York',
--     'CREATED'
-- );



