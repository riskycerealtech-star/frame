# Next Steps After Creating Project ✅

## 🎉 Great Job! You've Created Your Project!

I can see you have **"glass-backend-api"** selected. Perfect!

Now let's continue with the next steps:

---

## 📋 Step 3: Install Google Cloud SDK (gcloud CLI)

This is a tool that lets you deploy your app from your computer.

### On Mac (macOS):

**Option A: Using Homebrew (Easiest - Recommended)**

1. **First, check if you have Homebrew:**
   - Open Terminal (Press `Command + Space`, type "Terminal", press Enter)
   - Type this command:
     ```bash
     brew --version
     ```
   - Press Enter
   
   - **If you see a version number:** ✅ You have Homebrew! Go to step 2.
   - **If you see "command not found":** ❌ Install Homebrew first:
     - Go to: **https://brew.sh**
     - You'll see a command that starts with `/bin/bash -c "$(curl...`
     - **Copy that entire command**
     - Paste it in Terminal
     - Press Enter
     - Wait 5-10 minutes (it will ask for your password)
     - When done, you'll see "Installation successful!"

2. **Install Google Cloud SDK:**
   - In Terminal, type this command:
     ```bash
     brew install --cask google-cloud-sdk
     ```
   - Press Enter
   - Wait 5-10 minutes
   - When done, you'll see your prompt again (no errors)

**Option B: Download Installer (If you don't want Homebrew)**

1. Go to: **https://cloud.google.com/sdk/docs/install**
2. Click **"Download for macOS"**
3. Download the installer file
4. Open the downloaded file
5. Follow the installation wizard:
   - Click "Next" on everything
   - Accept the terms
   - Choose installation location (default is fine)
   - Click "Install"
6. Wait for installation to complete
7. Click "Finish"

### On Windows:

1. Go to: **https://cloud.google.com/sdk/docs/install**
2. Click **"Download for Windows"**
3. Download the installer file (`.exe`)
4. Open the downloaded file
5. Follow the installation wizard:
   - Click "Next" on everything
   - Accept the terms
   - Choose installation location (default is fine)
   - Click "Install"
6. Wait for installation to complete
7. Click "Finish"

### Verify Installation:

1. **IMPORTANT:** Close and reopen Terminal/Command Prompt (so it recognizes the new tool)
2. Type this command:
   ```bash
   gcloud --version
   ```
3. Press Enter

**✅ Success if you see:** Version numbers (like `Google Cloud SDK 450.0.0`)

**❌ If you see "command not found":**
- Make sure you closed and reopened Terminal
- On Mac: Try restarting Terminal completely
- On Windows: Try restarting Command Prompt
- If still not working, the installation might not have completed - try installing again

---

## 📋 Step 4: Sign In to Google Cloud (One Command)

Once `gcloud` is installed, you need to sign in:

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
- You'll see a list with numbers like:
  ```
  [1] glass-backend-api
  [2] My First Project
  ```
- Type the **number** next to `glass-backend-api` (probably `1`)
- Press Enter

**Question 2:** "Do you want to configure a default Compute Region and Zone?"
- Type: `Y`
- Press Enter

**Question 3:** "Which compute region would you like to use?"
- You'll see a list with numbers
- Type: `1` (for `us-central1` - it's usually cheapest and fastest)
- Press Enter

**Question 4:** "Which compute zone would you like to use?"
- You'll see a list with numbers
- Type: `1` (any is fine)
- Press Enter

**✅ Done!** You'll see "Your Google Cloud SDK is configured and ready to use!"

---

## 📋 Step 5: Enable Required APIs

Google Cloud needs you to enable APIs before using them. Just copy and paste these commands **one by one**. Wait for each to finish before running the next.

Open Terminal/Command Prompt and run:

**Command 1:**
```bash
gcloud services enable run.googleapis.com
```
Wait for it to finish (says "Operation finished successfully"), then:

**Command 2:**
```bash
gcloud services enable appengine.googleapis.com
```
Wait, then:

**Command 3:**
```bash
gcloud services enable sqladmin.googleapis.com
```
Wait, then:

**Command 4:**
```bash
gcloud services enable cloudbuild.googleapis.com
```
Wait, then:

**Command 5:**
```bash
gcloud services enable vision.googleapis.com
```
Wait, then:

**Command 6:**
```bash
gcloud services enable secretmanager.googleapis.com
```

**✅ Done!** All APIs are enabled. This takes about 2-3 minutes total.

---

## ✅ Progress Checklist

Let's track where you are:

- [x] Created Google Cloud account
- [x] Created project "glass-backend-api"
- [ ] Installed Google Cloud SDK (gcloud)
- [ ] Ran `gcloud init` and signed in
- [ ] Enabled all required APIs
- [ ] Ready for me to create deployment files!

---

## 🆘 Troubleshooting

### "gcloud: command not found"
- Make sure you **closed and reopened** Terminal/Command Prompt
- Try restarting Terminal completely
- If still not working, try installing again

### "Permission denied" when running gcloud
- Make sure you ran `gcloud init` and signed in
- Try running `gcloud auth login` again

### "API not enabled" errors
- Make sure you ran all the `gcloud services enable` commands
- Wait a few minutes and try again (APIs take time to enable)

---

## 🎯 What's Next?

After you complete Steps 3-5 above:

1. **Tell me when you're done**
2. **I'll create the deployment files for you:**
   - `app.yaml` (configuration file)
   - `requirements.txt` (Python packages)
3. **Then we'll deploy your app!**

---

## 💡 Tips

- **Take your time** - Don't rush
- **Copy commands exactly** - Don't change anything
- **Wait for each command to finish** - Don't run the next one until the previous one is done
- **If stuck, ask!** - I'm here to help

---

**Ready to continue?** Start with Step 3 (Install Google Cloud SDK) and let me know when you're done! 🚀

