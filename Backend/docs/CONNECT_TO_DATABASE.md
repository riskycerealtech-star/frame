# How to Connect to Google Cloud SQL Database

## Quick Connection Command

```bash
gcloud sql connect glass-db --user=glass_user --database=glass_db --project=glass-backend-api
```

**Note:** The `--database` flag specifies which database to connect to. Without it, it tries to connect to a database named after the user.

## Step-by-Step Connection

### 1. Connect to the Database

```bash
gcloud sql connect glass-db \
  --user=glass_user \
  --database=glass_db \
  --project=glass-backend-api
```

**Password:** `GlassUser2024Secure`

### 2. If the above doesn't work, use psql directly:

```bash
# First, get the connection name
gcloud sql instances describe glass-db --format="value(connectionName)"

# Then connect using psql (if you have the Cloud SQL Proxy set up)
psql -h 34.9.77.194 -U glass_user -d glass_db
```

### 3. Alternative: Use Cloud SQL Proxy

```bash
# Install Cloud SQL Proxy (if not already installed)
curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.0/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy

# Start the proxy in the background
./cloud-sql-proxy glass-backend-api:us-central1:glass-db &

# Connect using psql
psql -h 127.0.0.1 -U glass_user -d glass_db
```

## Verify Connection

Once connected, run these commands to verify:

```sql
-- List all databases
\l

-- Connect to glass_db (if not already connected)
\c glass_db

-- List all tables
\dt

-- Check users table
SELECT COUNT(*) FROM users;

-- View recent signups
SELECT 
    id,
    email,
    first_name,
    last_name,
    phone_number,
    created_at
FROM users
ORDER BY created_at DESC
LIMIT 10;
```

## Database Credentials

- **Instance Name:** `glass-db`
- **Database Name:** `glass_db`
- **Username:** `glass_user`
- **Password:** `GlassUser2024Secure`
- **Project ID:** `glass-backend-api`
- **Region:** `us-central1`
- **Connection Name:** `glass-backend-api:us-central1:glass-db`

## Troubleshooting

### Error: "password authentication failed"

1. **Verify the password:**
   ```bash
   # The password should be: GlassUser2024Secure
   ```

2. **Reset the password if needed:**
   ```bash
   gcloud sql users set-password glass_user \
     --instance=glass-db \
     --password=GlassUser2024Secure \
     --project=glass-backend-api
   ```

### Error: "database does not exist"

Make sure you're specifying the correct database name:
```bash
# Correct
gcloud sql connect glass-db --user=glass_user --database=glass_db

# Wrong (tries to connect to database named "glass_user")
gcloud sql connect glass-db --user=glass_user
```

### Error: Connection timeout

1. **Check if your IP is allowlisted:**
   ```bash
   gcloud sql instances describe glass-db --format="value(settings.ipConfiguration.authorizedNetworks)"
   ```

2. **Add your IP to authorized networks:**
   ```bash
   # Get your current IP
   curl ifconfig.me
   
   # Add it to authorized networks
   gcloud sql instances patch glass-db \
     --authorized-networks=YOUR_IP/32 \
     --project=glass-backend-api
   ```

## Quick Test Query

After connecting, test with:

```sql
-- Check if users table exists
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'users';

-- Count users
SELECT COUNT(*) as total_users FROM users;

-- View table structure
\d users
```



