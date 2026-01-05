# GitHub Secrets Setup Guide

## Quick Setup for GitHub Actions Deployment

Go to: https://github.com/riskycerealtech-star/frame/settings/secrets/actions

Click **"New repository secret"** for each of the following:

---

## Secret 1: GCP_PROJECT_ID

**Name:** `GCP_PROJECT_ID`

**Value:** 
```
test-deploy-project-479618
```

**Description:** Your Google Cloud project ID

---

## Secret 2: GCP_SA_KEY

**Name:** `GCP_SA_KEY`

**Value:** (Service Account JSON key - see below to generate)

**How to get it:**

Run this command in your terminal:

```bash
cd /Users/apple/frame
./setup-github-deploy.sh
```

The script will:
1. Create a service account
2. Grant necessary permissions
3. Generate a key file: `github-actions-key-test-deploy-project-479618.json`
4. Display the JSON content

**Copy the ENTIRE JSON content** (including `{` and `}`) and paste it as the value.

**Example format:**
```json
{
  "type": "service_account",
  "project_id": "test-deploy-project-479618",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "...",
  ...
}
```

---

## Secret 3: SECRET_KEY

**Name:** `SECRET_KEY`

**Value:** (Generate a secure random key)

**How to generate:**

Run this command:

```bash
openssl rand -hex 32
```

**Example output:**
```
a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456
```

Copy the entire output and paste it as the value.

---

## Secret 4: DATABASE_URL (Optional)

**Name:** `DATABASE_URL`

**Value:** 
```
sqlite:///./app.db
```

**Description:** Database connection string. Defaults to SQLite. You can change this later if you set up Cloud SQL.

---

## Quick Command to Generate All Values

Run these commands to get everything you need:

```bash
# 1. Generate SECRET_KEY
echo "SECRET_KEY:"
openssl rand -hex 32

# 2. Run setup script to get GCP_SA_KEY
./setup-github-deploy.sh
```

---

## After Adding Secrets

1. ✅ All 4 secrets added
2. Go to: https://github.com/riskycerealtech-star/frame/actions
3. Push a commit or manually trigger the workflow
4. Watch it deploy! 🚀

---

## Verify Secrets Are Set

After adding secrets, you should see:
- ✅ GCP_PROJECT_ID
- ✅ GCP_SA_KEY  
- ✅ SECRET_KEY
- ✅ DATABASE_URL (optional)

---

## Troubleshooting

**If setup script fails:**
- Make sure you're authenticated: `gcloud auth login`
- Make sure project is set: `gcloud config set project test-deploy-project-479618`

**If deployment fails:**
- Check the Actions tab for error messages
- Verify all secrets are set correctly
- Make sure service account has correct permissions















































