# Create GitHub Token with Workflow Scope

## The Problem
Your current token (`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`) doesn't have the `workflow` scope, which is required to push GitHub Actions workflow files.

## Solution: Create a New Token

### Step-by-Step Instructions:

1. **Go to GitHub Token Settings:**
   - Direct link: https://github.com/settings/tokens/new
   - Or navigate: GitHub → Your Profile → Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token (classic)

2. **Configure the Token:**
   - **Note:** `Frame API - Workflow Access`
   - **Expiration:** Choose your preference (90 days recommended)
   
3. **Select Scopes (IMPORTANT!):**
   - ✅ **repo** - Full control of private repositories
     - This includes: repo:status, repo_deployment, public_repo, repo:invite, security_events
   - ✅ **workflow** - Update GitHub Action workflows ← **THIS IS REQUIRED!**

4. **Generate Token:**
   - Click "Generate token" at the bottom
   - **Copy the token immediately** (it starts with `ghp_`)
   - You won't be able to see it again!

5. **Use the New Token:**
   ```bash
   git push
   # When prompted:
   # Username: riskycerealtech-star
   # Password: <paste your NEW token here>
   ```

## Alternative: Use GitHub CLI

If you prefer, you can use GitHub CLI which handles authentication automatically:

```bash
# Install GitHub CLI
brew install gh

# Authenticate (will open browser)
gh auth login

# Now git push will work
git push
```

## Security Note

⚠️ **Important:** 
- Never commit tokens to git
- Never share tokens publicly
- Revoke old tokens that don't have the right scopes
- The token I removed from your git remote URL should be revoked if it's still active

---

**After creating the new token with `workflow` scope, your push will work!** 🚀

