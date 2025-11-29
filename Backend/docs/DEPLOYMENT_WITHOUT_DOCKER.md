# Deploying to Google Cloud WITHOUT Docker

## 🤔 Can You Deploy Without Docker?

**Short Answer: YES!** But it depends on which Google Cloud service you choose.

Let me explain your options:

---

## 📊 Deployment Options Comparison

| Option | Requires Docker? | Difficulty | Cost | Best For |
|--------|-----------------|------------|------|----------|
| **App Engine Flexible** | ❌ No (but uses Dockerfile behind scenes) | ⭐⭐ Easy | $$ Higher | No Docker knowledge |
| **App Engine Standard** | ❌ No | ⭐ Easy | $ Low | Simple apps (limited) |
| **Cloud Run** | ✅ Yes | ⭐⭐⭐ Medium | $ Low | Production APIs |
| **Compute Engine (VM)** | ❌ No | ⭐⭐⭐⭐ Hard | $$ Medium | Full control |

---

## 🎯 Option 1: App Engine Flexible Environment (EASIEST - No Docker Knowledge Needed)

### What is App Engine Flexible?

App Engine Flexible is Google's managed platform that:
- ✅ **Doesn't require Docker knowledge** - You just provide a simple config file
- ✅ **Handles Docker for you** - Google builds the container automatically
- ✅ **Automatic scaling** - Scales up/down based on traffic
- ✅ **Easy deployment** - Just run `gcloud app deploy`

### How It Works

Even though App Engine Flexible uses Docker behind the scenes, **you don't need to know Docker**. You just need:

1. **`app.yaml`** - A simple configuration file (like a settings file)
2. **`requirements.txt`** - Your Python dependencies
3. **Run command** - How to start your app

That's it! Google handles the Docker part automatically.

### Step-by-Step: Deploy to App Engine Flexible

#### Step 1: Create `app.yaml` Configuration File

Create this file in your `Backend/` directory:

```yaml
runtime: python
env: flex

runtime_config:
  python_version: 3.11

# Resources
resources:
  cpu: 1
  memory_gb: 1
  disk_size_gb: 10

# Environment variables
env_variables:
  PORT: 8080
  GOOGLE_CLOUD_PROJECT_ID: 'your-project-id'
  POSTGRES_SERVER: '/cloudsql/PROJECT:REGION:INSTANCE'
  POSTGRES_USER: 'glass_user'
  POSTGRES_DB: 'glass_db'
  # Add other env vars here

# Beta settings for Cloud SQL
beta_settings:
  cloud_sql_instances: 'PROJECT:REGION:INSTANCE'

# Health check
readiness_check:
  path: "/health"
  check_interval_sec: 5
  timeout_sec: 4
  failure_threshold: 2
  success_threshold: 2

liveness_check:
  path: "/health"
  check_interval_sec: 30
  timeout_sec: 4
  failure_threshold: 2
  success_threshold: 2

# Automatic scaling
automatic_scaling:
  min_num_instances: 1
  max_num_instances: 10
  cool_down_period_sec: 120
  cpu_utilization:
    target_utilization: 0.6
```

#### Step 2: Create `requirements.txt`

Create `requirements.txt` in your `Backend/` directory with all dependencies:

```txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
pydantic==2.5.0
pydantic-settings==2.1.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
google-cloud-vision==3.4.5
google-auth==2.23.4
pillow==10.1.0
alembic==1.12.1
gunicorn==21.2.0
```

#### Step 3: Create `main.py` Entry Point (if needed)

Make sure your `main.py` or `run.py` can read the PORT environment variable:

```python
import os
import uvicorn

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(
        "app.main:app",  # or "main:app" depending on your structure
        host="0.0.0.0",
        port=port,
        log_level="info"
    )
```

Or create a simple `app.yaml` startup script entry point.

#### Step 4: Update `app.yaml` with Entry Point

Add this to your `app.yaml`:

```yaml
entrypoint: gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app --bind 0.0.0.0:$PORT
```

Or if your app structure is different:

```yaml
entrypoint: gunicorn -w 4 -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:$PORT
```

#### Step 5: Deploy!

```bash
# Navigate to Backend directory
cd Backend

# Deploy to App Engine
gcloud app deploy

# That's it! 🎉
```

#### Step 6: Access Your App

```bash
# Get your app URL
gcloud app browse

# Or get the URL
gcloud app describe --format="value(defaultHostname)"
```

**Your API will be at:** `https://PROJECT_ID.REGION_ID.r.appspot.com`

---

### Pros of App Engine Flexible

✅ **No Docker knowledge needed** - Just config files
✅ **Automatic scaling** - Handles traffic automatically
✅ **Easy deployment** - One command: `gcloud app deploy`
✅ **Built-in health checks** - Automatic monitoring
✅ **Version management** - Easy rollbacks
✅ **HTTPS included** - Free SSL certificates

### Cons of App Engine Flexible

⚠️ **More expensive** - Minimum ~$50/month (even with no traffic)
⚠️ **Slower deployments** - Takes 5-10 minutes
⚠️ **Less flexible** - Can't customize as much as Cloud Run
⚠️ **Always running** - At least 1 instance always running (costs money)

---

## 🎯 Option 2: App Engine Standard (Limited - Not Recommended for FastAPI)

### What is App Engine Standard?

App Engine Standard is Google's original serverless platform:
- ✅ **No Docker** - Just upload your code
- ✅ **Very easy** - Simplest deployment
- ❌ **Limited** - Only supports specific Python versions
- ❌ **Restrictions** - Can't use some libraries (like psycopg2-binary easily)

### Why Not Recommended for Your App

Your FastAPI app uses:
- PostgreSQL (requires `psycopg2-binary` - hard to install on Standard)
- Complex dependencies
- File uploads (limited on Standard)

**Verdict:** App Engine Standard is too limited for your application.

---

## 🎯 Option 3: Compute Engine (VM) - No Docker, Full Control

### What is Compute Engine?

Compute Engine gives you a virtual machine (like a remote computer):
- ✅ **No Docker needed** - Just install Python directly
- ✅ **Full control** - Install anything you want
- ✅ **Predictable cost** - Fixed monthly price
- ❌ **You manage everything** - OS updates, security, scaling

### How to Deploy to Compute Engine (Without Docker)

#### Step 1: Create a VM Instance

```bash
# Create VM instance
gcloud compute instances create glass-api-vm \
    --zone=us-central1-a \
    --machine-type=e2-small \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB
```

#### Step 2: SSH into the VM

```bash
# SSH into VM
gcloud compute ssh glass-api-vm --zone=us-central1-a
```

#### Step 3: Install Python and Dependencies

```bash
# Update system
sudo apt-get update

# Install Python 3.11
sudo apt-get install -y python3.11 python3.11-venv python3-pip

# Install PostgreSQL client (for database connection)
sudo apt-get install -y postgresql-client

# Create app directory
mkdir -p /opt/glass-api
cd /opt/glass-api
```

#### Step 4: Upload Your Code

**Option A: Using Git**
```bash
# Install git
sudo apt-get install -y git

# Clone your repository
git clone YOUR_REPO_URL .
```

**Option B: Using gcloud (from your local machine)**
```bash
# From your local machine, copy files
gcloud compute scp --recurse Backend/* glass-api-vm:/opt/glass-api --zone=us-central1-a
```

#### Step 5: Set Up Python Environment

```bash
# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

#### Step 6: Set Up Environment Variables

```bash
# Create .env file
nano .env

# Add your environment variables:
# POSTGRES_SERVER=your-cloud-sql-ip
# POSTGRES_USER=glass_user
# POSTGRES_PASSWORD=your-password
# POSTGRES_DB=glass_db
# SECRET_KEY=your-secret-key
# GOOGLE_CLOUD_PROJECT_ID=your-project-id
```

#### Step 7: Run Database Migrations

```bash
# Run migrations
alembic upgrade head
```

#### Step 8: Set Up Systemd Service (Auto-start)

```bash
# Create systemd service file
sudo nano /etc/systemd/system/glass-api.service
```

Add this content:

```ini
[Unit]
Description=Glass API
After=network.target

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/opt/glass-api
Environment="PATH=/opt/glass-api/venv/bin"
ExecStart=/opt/glass-api/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable glass-api
sudo systemctl start glass-api

# Check status
sudo systemctl status glass-api
```

#### Step 9: Set Up Firewall Rules

```bash
# Allow HTTP traffic
gcloud compute firewall-rules create allow-http \
    --allow tcp:8000 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server

# Add tag to VM
gcloud compute instances add-tags glass-api-vm \
    --tags http-server \
    --zone us-central1-a
```

#### Step 10: Get Your VM's IP

```bash
# Get external IP
gcloud compute instances describe glass-api-vm \
    --zone us-central1-a \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
```

**Your API will be at:** `http://YOUR_VM_IP:8000`

### Pros of Compute Engine

✅ **No Docker** - Direct Python installation
✅ **Full control** - Install anything
✅ **Predictable cost** - ~$25-50/month
✅ **No restrictions** - Run any code

### Cons of Compute Engine

❌ **You manage everything** - OS, security, updates
❌ **Manual scaling** - You handle load balancing
❌ **More setup** - Takes more time
❌ **Always running** - Costs money even when idle
❌ **No auto-scaling** - Need to set up load balancer manually

---

## 💡 My Recommendation

### If You Want EASIEST (No Docker Knowledge):

**→ Use App Engine Flexible**

**Why:**
- ✅ No Docker knowledge needed
- ✅ Just create `app.yaml` and `requirements.txt`
- ✅ One command to deploy: `gcloud app deploy`
- ✅ Automatic scaling and monitoring

**Trade-off:**
- ⚠️ More expensive (~$50/month minimum)
- ⚠️ Slower deployments

### If You Want CHEAPEST:

**→ Use Cloud Run (requires Docker, but I can help you)**

**Why:**
- ✅ Pay per request (very cheap)
- ✅ Scales to zero (no cost when idle)
- ✅ Fast deployments

**Trade-off:**
- ⚠️ Need to create Dockerfile (but I can create it for you!)

### If You Want FULL CONTROL:

**→ Use Compute Engine (VM)**

**Why:**
- ✅ No Docker
- ✅ Full control
- ✅ Predictable cost

**Trade-off:**
- ❌ You manage everything
- ❌ More complex setup

---

## 🚀 Quick Start: App Engine Flexible (Easiest Option)

If you want the easiest option without Docker, here's what to do:

1. **Create `app.yaml`** (I can create this for you)
2. **Create `requirements.txt`** (I can create this for you)
3. **Run:** `gcloud app deploy`
4. **Done!** 🎉

---

## ❓ FAQ

### Q: Do I really need Docker for Cloud Run?

**A:** Yes, Cloud Run requires a Docker container. But I can create the Dockerfile for you - you don't need to understand Docker, just use the file I provide.

### Q: Can App Engine Flexible work without me knowing Docker?

**A:** Yes! App Engine Flexible uses Docker behind the scenes, but you just provide config files. You never interact with Docker directly.

### Q: Which is cheapest?

**A:** Cloud Run is cheapest (pay per request, scales to zero). App Engine Flexible has minimum costs (~$50/month).

### Q: Which is easiest?

**A:** App Engine Flexible is easiest if you don't want to deal with Docker at all.

### Q: Can you help me set up App Engine Flexible?

**A:** Yes! I can create the `app.yaml` and `requirements.txt` files for you, and guide you through deployment.

---

## 📝 Summary

| Your Goal | Recommended Option | Docker Needed? |
|-----------|-------------------|----------------|
| **Easiest deployment** | App Engine Flexible | ❌ No (handled automatically) |
| **Cheapest** | Cloud Run | ✅ Yes (but I can create Dockerfile) |
| **Full control** | Compute Engine | ❌ No (direct Python install) |

**Bottom Line:** You CAN deploy without Docker knowledge using **App Engine Flexible**. Just need config files, not Docker knowledge!

Would you like me to:
1. Create the `app.yaml` file for App Engine Flexible?
2. Create the `requirements.txt` file?
3. Help you deploy to App Engine Flexible?

Let me know which option you prefer! 🚀




