# Beginner-Friendly Deployment Guide 🚀

## 👋 Welcome!

This guide is designed for **complete beginners**. No prior experience needed!

We'll use the **easiest method possible** - App Engine Flexible, which requires minimal command line usage.

---

## 🎯 What We'll Do (Simple Overview)

1. ✅ Set up Google Cloud (mostly clicking buttons)
2. ✅ Install one tool (I'll guide you)
3. ✅ Create 2 files (I'll create them for you)
4. ✅ Run 2 commands (I'll give you exact commands to copy)
5. ✅ Your API is live! 🎉

**Total time:** About 1-2 hours (mostly waiting for things to install)

---

## 📋 Step 1: Set Up Google Cloud Account

### 1.1 Go to Google Cloud Console

1. Open your web browser
2. Go to: **https://console.cloud.google.com/**
3. Sign in with your Google account

### 1.2 Create a New Project

1. Look at the **top left corner** - you'll see a dropdown that says "Select a project" or shows a project name
2. **Click on it**
3. Click **"New Project"** button
4. Fill in:
   - **Project name:** `glass-backend-api` (or any name you like)
   - Leave everything else as default
5. Click **"Create"**
6. Wait 10-20 seconds
7. **Click on your new project** in the dropdown to select it

**✅ Done!** You now have a Google Cloud project.

---

## 📋 Step 2: Enable Billing (Required, But Free Credits!)

**Don't worry!** Google gives you **$300 free credit for 90 days**. You won't be charged unless you use more than that.

1. In Google Cloud Console, click the **hamburger menu** (☰) on the top left
2. Go to **"Billing"**
3. Click **"Link a billing account"**
4. Follow the prompts to add a payment method
5. Select your project and link it

**✅ Done!** Billing is set up (but you have free credits!)

---

## 📋 Step 3: Install Google Cloud SDK (The Only Tool You Need)

### 3.1 On Mac (macOS):

**Option A: Using Homebrew (Easiest)**

1. **First, check if you have Homebrew:**
   - Open Terminal (Press `Command + Space`, type "Terminal", press Enter)
   - Type: `brew --version`
   - Press Enter
   
   - **If you see a version number:** You have Homebrew! Skip to step 2.
   - **If you see "command not found":** Install Homebrew first:
     - Go to: https://brew.sh
     - Copy the command shown on the website
     - Paste it in Terminal and press Enter
     - Wait for it to install (5-10 minutes)

2. **Install Google Cloud SDK:**
   - In Terminal, type:
     ```bash
     brew install --cask google-cloud-sdk
     ```
   - Press Enter
   - Wait for it to install (5-10 minutes)
   - When done, you'll see your prompt again

**Option B: Download Installer (If you don't want Homebrew)**

1. Go to: https://cloud.google.com/sdk/docs/install
2. Click **"Download for macOS"**
3. Download the installer
4. Open the downloaded file
5. Follow the installation wizard (just click "Next" on everything)
6. When done, close the installer

### 3.2 On Windows:

1. Go to: https://cloud.google.com/sdk/docs/install
2. Click **"Download for Windows"**
3. Download the installer
4. Open the downloaded `.exe` file
5. Follow the installation wizard:
   - Click "Next" on everything
   - Accept the terms
   - Choose installation location (default is fine)
   - Click "Install"
6. Wait for installation to complete
7. Click "Finish"

### 3.3 Verify Installation

1. **Open a NEW Terminal/Command Prompt** (important - close and reopen!)
2. Type:
   ```bash
   gcloud --version
   ```
3. Press Enter

**✅ Success if you see:** Version numbers (like `Google Cloud SDK 450.0.0`)

**❌ If you see "command not found":**
- On Mac: Restart Terminal
- On Windows: Restart Command Prompt
- If still not working, the installation might not have completed - try again

---

## 📋 Step 4: Sign In to Google Cloud (One Command)

1. Open Terminal/Command Prompt
2. Type this **exact command**:
   ```bash
   gcloud init
   ```
3. Press Enter

**What happens:**
- A browser window will open automatically
- Sign in with your Google account (the same one you used for Google Cloud)
- Click "Allow" to give permissions
- Go back to Terminal

**In Terminal, you'll see questions:**

**Question 1:** "Pick cloud project to use:"
- You'll see a list with numbers
- Type the **number** next to your project (`glass-backend-api`)
- Press Enter

**Question 2:** "Do you want to configure a default Compute Region and Zone?"
- Type: `Y`
- Press Enter

**Question 3:** "Which compute region would you like to use?"
- Type a number (I recommend `1` for `us-central1` - it's usually cheapest)
- Press Enter

**Question 4:** "Which compute zone would you like to use?"
- Type a number (any is fine, I recommend `1`)
- Press Enter

**✅ Done!** You're now signed in and configured!

---

## 📋 Step 5: Enable Required APIs (Copy These Commands)

**Just copy and paste these commands one by one.** Wait for each to finish before running the next.

Open Terminal/Command Prompt and run:

```bash
gcloud services enable run.googleapis.com
```

Wait for it to finish (says "Operation finished successfully"), then:

```bash
gcloud services enable appengine.googleapis.com
```

Wait, then:

```bash
gcloud services enable sqladmin.googleapis.com
```

Wait, then:

```bash
gcloud services enable cloudbuild.googleapis.com
```

Wait, then:

```bash
gcloud services enable vision.googleapis.com
```

Wait, then:

```bash
gcloud services enable secretmanager.googleapis.com
```

**✅ Done!** All APIs are enabled. This takes about 2-3 minutes total.

---

## 📋 Step 6: I'll Create the Files You Need

**You don't need to do anything here!** I'll create these files for you:

1. `app.yaml` - Configuration file
2. `requirements.txt` - List of Python packages

**Just tell me when you're ready, and I'll create them!**

---

## 📋 Step 7: Deploy Your App (Just One Command!)

Once I create the files, you'll:

1. Open Terminal/Command Prompt
2. Navigate to your Backend folder:
   ```bash
   cd /Users/apple/Glass/Backend
   ```
   (On Windows, it might be different - I'll help you find the right path)

3. Deploy:
   ```bash
   gcloud app deploy
   ```

**What happens:**
- It will ask: "Do you want to continue (Y/n)?"
- Type: `Y`
- Press Enter
- Wait 5-10 minutes (it's uploading and building)
- When done, you'll see a URL like: `https://your-project.appspot.com`

**✅ Done!** Your API is live! 🎉

---

## 🎯 Current Status Checklist

Let's track your progress:

- [ ] Step 1: Created Google Cloud project
- [ ] Step 2: Enabled billing (with free credits)
- [ ] Step 3: Installed Google Cloud SDK
- [ ] Step 4: Ran `gcloud init` and signed in
- [ ] Step 5: Enabled all required APIs
- [ ] Step 6: Waiting for me to create deployment files
- [ ] Step 7: Ready to deploy!

---

## 🆘 Troubleshooting

### Problem: "gcloud: command not found"

**Solution:**
1. Close and reopen Terminal/Command Prompt
2. If still not working, the installation might not have completed
3. Try installing again

---

### Problem: "Permission denied" when running gcloud

**Solution:**
- Make sure you ran `gcloud init` and signed in
- Try running `gcloud auth login` again

---

### Problem: "API not enabled"

**Solution:**
- Make sure you ran all the `gcloud services enable` commands
- Wait a few minutes and try again (APIs take time to enable)

---

### Problem: Can't find my project in the list

**Solution:**
- Make sure you created the project in Google Cloud Console
- Make sure you're signed in with the same Google account
- Try: `gcloud projects list` to see all projects

---

## 💡 Tips for Success

1. **Take your time** - Don't rush, read each step carefully
2. **Copy commands exactly** - Don't change anything
3. **Wait for commands to finish** - Don't run the next command until the previous one is done
4. **If stuck, ask!** - I'm here to help
5. **One step at a time** - Complete each step before moving to the next

---

## 🎓 What You've Learned

By the end of this, you'll know:
- ✅ How to use basic command line
- ✅ How to deploy applications to the cloud
- ✅ How to use Google Cloud
- ✅ How to manage your API

**Pretty cool, right?** 😊

---

## 📞 Next Steps

**Right now, you should:**

1. ✅ Complete Steps 1-5 above
2. ✅ Tell me when you're done
3. ✅ I'll create the deployment files for you
4. ✅ Then we'll deploy together!

**Let me know:**
- Which step you're on
- If you're stuck on anything
- If you need help with any command

**I'm here to help every step of the way!** 🚀

