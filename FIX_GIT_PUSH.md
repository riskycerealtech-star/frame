# Fix GitHub Push Error - Workflow Scope Required

## Problem
You're getting this error:
```
refusing to allow a Personal Access Token to create or update workflow `.github/workflows/deploy-cloudbuild.yml` without `workflow` scope
```

## Solution: Update Your Personal Access Token

### Option 1: Create a New PAT with Workflow Scope (Recommended)

1. **Go to GitHub Settings:**
   - Visit: https://github.com/settings/tokens
   - Or: GitHub → Your Profile → Settings → Developer settings → Personal access tokens → Tokens (classic)

2. **Create a New Token:**
   - Click "Generate new token" → "Generate new token (classic)"
   - Give it a name: `Frame API Deployment`
   - Set expiration (recommend 90 days or custom)
   - **Select these scopes:**
     - ✅ `repo` (Full control of private repositories)
     - ✅ `workflow` (Update GitHub Action workflows) ← **This is required!**
   - Click "Generate token"
   - **Copy the token immediately** (you won't see it again!)

3. **Update Git Credentials:**
   ```bash
   # Remove old credentials
   git credential-osxkeychain erase
   host=github.com
   protocol=https
   # Press Enter twice
   
   # Push again - it will prompt for credentials
   git push
   # Username: your-github-username
   # Password: paste-your-new-token-here
   ```

### Option 2: Use GitHub CLI (Alternative)

```bash
# Install GitHub CLI if not installed
brew install gh

# Authenticate
gh auth login

# This will handle authentication properly
git push
```

### Option 3: Use SSH Instead of HTTPS

1. **Generate SSH Key (if you don't have one):**
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   # Press Enter to accept default location
   # Enter passphrase (optional)
   ```

2. **Add SSH Key to GitHub:**
   ```bash
   # Copy your public key
   cat ~/.ssh/id_ed25519.pub
   # Copy the output
   ```
   
   - Go to: https://github.com/settings/keys
   - Click "New SSH key"
   - Paste your public key
   - Save

3. **Change Remote URL to SSH:**
   ```bash
   git remote set-url origin git@github.com:riskycerealtech-star/frame.git
   git push
   ```

## Quick Fix (Recommended)

The fastest solution is Option 1 - create a new PAT with `workflow` scope:

1. Go to: https://github.com/settings/tokens/new
2. Check `repo` and `workflow` scopes
3. Generate and copy token
4. When pushing, use the token as your password

