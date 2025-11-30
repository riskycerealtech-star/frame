# 🔍 API Structure Difference Explanation

## The Problem

You have **TWO different API structures** in your codebase:

### 1. **Root `main.py`** (What you see locally)
- **Location:** `/Users/apple/frame/Backend/main.py`
- **Endpoints:**
  - `POST /v1/user/signup`
  - `POST /v1/user/signin/{userId}`
  - `POST /v1/user/refresh-token/{userId}`
  - `POST /validate-sunglasses`
  - etc.

### 2. **App `main.py`** (What's deployed)
- **Location:** `/Users/apple/frame/Backend/app/main.py`
- **Endpoints:**
  - `POST /api/v1/auth/login`
  - `POST /api/v1/auth/register`
  - `GET /api/v1/auth/me`
  - Uses `/api/v1` prefix

---

## Why This Happened

Your **Dockerfile** currently says:
```dockerfile
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080}
```

This should use the root `main.py`, but your **deployed version** seems to be using `app/main.py` instead, which has a different structure.

---

## Solution: Choose One Structure

### Option 1: Use Root `main.py` (Recommended - Matches Your Local)

**Update Dockerfile to explicitly use root main.py:**
```dockerfile
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080}
```

**This will give you:**
- ✅ `/v1/user/signup`
- ✅ `/v1/user/signin/{userId}`
- ✅ `/validate-sunglasses`
- ✅ Matches your local development

---

### Option 2: Use App `main.py` (Current Deployed Version)

**Update Dockerfile to use app/main.py:**
```dockerfile
CMD exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080}
```

**This will give you:**
- ✅ `/api/v1/auth/login`
- ✅ `/api/v1/auth/register`
- ✅ `/api/v1/auth/me`
- ⚠️ Different from your local setup

---

## Quick Fix: Make Deployed Match Local

Since you want the deployed version to match your local setup, update your Dockerfile:

```dockerfile
# Run the application using uvicorn directly
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080}
```

Then redeploy:
```bash
./deploy.sh
```

---

## Current Deployed Endpoints (app/main.py structure)

Based on what's deployed, your endpoints are:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/auth/login` | POST | User login |
| `/api/v1/auth/register` | POST | User registration |
| `/api/v1/auth/me` | GET | Get current user |
| `/api/v1/users/*` | Various | User management |

**Base URL:** https://frame-750669515844.us-central1.run.app

**Full URLs:**
- Login: https://frame-750669515844.us-central1.run.app/api/v1/auth/login
- Register: https://frame-750669515844.us-central1.run.app/api/v1/auth/register
- Docs: https://frame-750669515844.us-central1.run.app/docs

---

## Recommendation

**Use the root `main.py`** because:
1. ✅ It matches your local development
2. ✅ It has more complete endpoints (signup, signin, refresh-token, etc.)
3. ✅ It includes AI validation endpoints
4. ✅ It's the file you've been working with

**Steps:**
1. Ensure Dockerfile uses `main:app` (not `app.main:app`)
2. Redeploy: `./deploy.sh`
3. Your deployed API will match your local API



