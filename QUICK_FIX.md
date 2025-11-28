# Quick Fix for Git Push Error

## Your Current Issue
Your Personal Access Token doesn't have the `workflow` scope needed to push GitHub Actions files.

## Steps to Fix:

### 1. Revoke Your Old Token (Security)
⚠️ **IMPORTANT**: Your token was visible in the git remote URL. Revoke it immediately:

1. Go to: https://github.com/settings/tokens
2. Find your old token (check your git remote URL or token list)
3. Click "Revoke" to delete it

### 2. Create a New Token with Workflow Scope

1. **Go to:** https://github.com/settings/tokens/new
2. **Name:** `Frame API - Workflow Access`
3. **Expiration:** Choose your preference (90 days recommended)
4. **Select scopes:**
   - ✅ **repo** (Full control of private repositories)
   - ✅ **workflow** (Update GitHub Action workflows) ← **REQUIRED!**
5. Click **"Generate token"**
6. **Copy the token** (starts with `ghp_`)

### 3. Update Git Credentials

I've already removed the token from your remote URL. Now:

```bash
# Push again - it will prompt for credentials
git push

# When prompted:
# Username: riskycerealtech-star
# Password: <paste your new token here>
```

### 4. Save Credentials (Optional)

To avoid entering the token every time:

```bash
# macOS Keychain will save it
git push
# Enter username and token when prompted
# It will be saved automatically
```

## Alternative: Use SSH (More Secure)

If you prefer SSH (no tokens needed):

```bash
# Change to SSH URL
git remote set-url origin git@github.com:riskycerealtech-star/frame.git

# If you don't have SSH key set up:
ssh-keygen -t ed25519 -C "your_email@example.com"
# Then add ~/.ssh/id_ed25519.pub to GitHub: https://github.com/settings/keys

git push
```

---

**After fixing, your push should work!** 🚀

