# Step-by-Step Deployment Guide - Starting Now! 🚀

## ✅ Step 1: You Have a Google Account - DONE!

Great! Now let's set up Google Cloud.

---

## 📋 Step 2: Create Google Cloud Account & Project

### 2.1 Sign Up for Google Cloud

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com/
   - Sign in with your Google account

2. **Activate Free Trial (if eligible):**
   - Google gives you **$300 free credit for 90 days**
   - Click "Get started for free" or "Try for free"
   - Enter billing information (required, but you won't be charged unless you exceed free tier)

3. **Accept Terms:**
   - Read and accept the terms of service

### 2.2 Create a New Project

1. **Click on the project dropdown** (top left, next to "Google Cloud")
2. **Click "New Project"**
3. **Fill in the details:**
   - **Project name**: `glass-backend-api` (or any name you like)
   - **Organization**: Leave as default (or select if you have one)
   - **Location**: Leave as default
4. **Click "Create"**
5. **Wait a few seconds** for the project to be created
6. **Select your new project** from the dropdown

**✅ Checkpoint:** You should now see your project name in the top left corner.

---

## 📋 Step 3: Install Google Cloud SDK (gcloud CLI)

You need the `gcloud` command-line tool to deploy your app.

### Option A: Install on macOS (Recommended)

**Using Homebrew (easiest):**
```bash
# Install Homebrew if you don't have it
# Visit: https://brew.sh

# Install Google Cloud SDK
brew install --cask google-cloud-sdk
```

**Or download manually:**
1. Visit: https://cloud.google.com/sdk/docs/install
2. Download the macOS installer
3. Run the installer
4. Follow the installation wizard

### Option B: Install on Windows

1. Visit: https://cloud.google.com/sdk/docs/install
2. Download the Windows installer
3. Run the installer
4. Follow the installation wizard

### Option C: Install on Linux

```bash
# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Update and install
sudo apt-get update && sudo apt-get install google-cloud-sdk
```

### 3.1 Verify Installation

Open a new terminal and run:
```bash
gcloud --version
```

You should see something like:
```
Google Cloud SDK 450.0.0
```

**✅ Checkpoint:** If you see the version, installation is successful!

---

## 📋 Step 4: Initialize and Authenticate gcloud

### 4.1 Initialize gcloud

```bash
gcloud init
```

This will:
1. **Ask you to log in:**
   - It will open a browser window
   - Sign in with your Google account
   - Allow permissions

2. **Ask you to select a project:**
   - Select the project you created (`glass-backend-api`)

3. **Ask about default region:**
   - Choose a region close to you (e.g., `us-central1`, `us-east1`, `europe-west1`)
   - This is where your app will run

### 4.2 Set Default Project (if needed)

```bash
# Replace with your actual project ID
gcloud config set project glass-backend-api
```

**To find your project ID:**
- Go to Google Cloud Console
- Look at the project dropdown (top left)
- The project ID is shown there (might be different from project name)

### 4.3 Verify Setup

```bash
# Check current configuration
gcloud config list

# You should see:
# project = your-project-id
# region = your-region
```

**✅ Checkpoint:** Your gcloud is now configured!

---

## 📋 Step 5: Enable Required APIs

Google Cloud requires you to enable APIs before using them. Let's enable what we need:

```bash
# Enable Cloud Run API (for serverless deployment)
gcloud services enable run.googleapis.com

# Enable App Engine API (if using App Engine)
gcloud services enable appengine.googleapis.com

# Enable Cloud SQL Admin API (for database)
gcloud services enable sqladmin.googleapis.com

# Enable Cloud Build API (for building containers)
gcloud services enable cloudbuild.googleapis.com

# Enable Vision API (you're already using this)
gcloud services enable vision.googleapis.com

# Enable Secret Manager API (for storing secrets)
gcloud services enable secretmanager.googleapis.com
```

**Wait for each command to complete** (takes 10-30 seconds each).

**✅ Checkpoint:** All APIs are now enabled!

---

## 📋 Step 6: Choose Your Deployment Method

Now you need to decide: **Which deployment method do you want to use?**

### Option A: App Engine Flexible (EASIEST - No Docker) ⭐

**Best if:**
- You want the easiest deployment
- You don't want to deal with Docker
- You're okay with ~$50/month minimum cost

**What you need:**
- `app.yaml` file (I'll create this)
- `requirements.txt` file (I'll create this)
- Run: `gcloud app deploy`

**Go to:** Step 7A below

---

### Option B: Cloud Run (CHEAPEST - Needs Dockerfile)

**Best if:**
- You want the cheapest option (~$5-20/month)
- You're okay with me creating a Dockerfile for you
- You want to scale to zero (no cost when idle)

**What you need:**
- `Dockerfile` (I'll create this)
- `requirements.txt` file (I'll create this)
- Run: `gcloud run deploy`

**Go to:** Step 7B (in the Cloud Run guide)

---

### Option C: Compute Engine VM (FULL CONTROL - No Docker)

**Best if:**
- You want full control
- You want to manage everything yourself
- You want predictable costs

**Go to:** Step 7C (in the VM guide)

---

## 📋 Step 7A: Prepare for App Engine Flexible Deployment

If you chose **App Engine Flexible**, let's prepare your app:

### 7A.1 Check Your Current App Structure

Let me check what files you have and what we need to create.

**Files we need:**
- ✅ `app.yaml` - Configuration file (I'll create this)
- ✅ `requirements.txt` - Python dependencies (I'll create this)
- ✅ Your existing code (you already have this)

### 7A.2 Next Steps

Once I create the files, you'll:
1. Review the files I create
2. Update any configuration (like project ID, database settings)
3. Run: `gcloud app deploy`
4. Done! 🎉

---

## 🎯 What's Next?

**Tell me which option you want:**

1. **"I want App Engine Flexible"** (easiest, no Docker)
   - I'll create `app.yaml` and `requirements.txt`
   - You deploy with one command

2. **"I want Cloud Run"** (cheapest, I'll create Dockerfile)
   - I'll create `Dockerfile` and `requirements.txt`
   - You deploy with one command

3. **"I want to use a VM"** (full control)
   - I'll guide you through VM setup

---

## ✅ Current Progress Checklist

- [x] Have Google account
- [ ] Create Google Cloud project
- [ ] Install gcloud CLI
- [ ] Initialize and authenticate gcloud
- [ ] Enable required APIs
- [ ] Choose deployment method
- [ ] Prepare deployment files
- [ ] Deploy application

---

## 🆘 Troubleshooting

### "gcloud: command not found"
- Make sure you installed gcloud CLI
- Restart your terminal
- Check if it's in your PATH

### "Permission denied" errors
- Make sure you're logged in: `gcloud auth login`
- Make sure billing is enabled for your project

### "API not enabled" errors
- Run the enable commands in Step 5
- Wait a few minutes and try again

---

## 📞 Need Help?

If you get stuck at any step, let me know:
- What step you're on
- What error message you see (if any)
- What command you ran

I'll help you troubleshoot! 🚀




