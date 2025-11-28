# GitHub Token Setup - Step by Step

## Current Status
❌ Your token `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` **does NOT have the `workflow` scope**
- We tested it and got: "refusing to allow a Personal Access Token to create or update workflow without `workflow` scope"

## Solution: Create a NEW Token

### Step 1: Go to Token Creation Page
👉 **Click this link:** https://github.com/settings/tokens/new

### Step 2: Fill in the Form

**Note:** 
```
Frame API - Workflow Access
```

**Expiration:**
- Choose: `90 days` (or your preference)

### Step 3: Select Scopes (CRITICAL!)

Scroll down and check these boxes:

✅ **repo** (Full control of private repositories)
- This will auto-check: repo:status, repo_deployment, public_repo, repo:invite, security_events

✅ **workflow** (Update GitHub Action workflows)
- **THIS IS THE ONE YOU'RE MISSING!**

### Step 4: Generate Token

1. Scroll to bottom
2. Click **"Generate token"** (green button)
3. **IMMEDIATELY COPY THE TOKEN** (it starts with `ghp_`)
4. Save it somewhere safe - you won't see it again!

### Step 5: Use the New Token

Once you have the NEW token, run:

```bash
git push
```

When prompted:
- **Username:** `riskycerealtech-star`
- **Password:** `<paste your NEW token here>`

---

## Quick Visual Guide

```
GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
→ Generate new token (classic)

Form:
├─ Note: Frame API - Workflow Access
├─ Expiration: 90 days
└─ Select scopes:
   ├─ ✅ repo
   └─ ✅ workflow  ← YOU NEED THIS ONE!

→ Generate token → Copy it → Use it in git push
```

---

## Why Your Current Token Doesn't Work

GitHub requires the `workflow` scope to push files in `.github/workflows/` directory. Your current token only has `repo` scope, which is why it's being rejected.

---

**After you create the new token with `workflow` scope, let me know and I'll help you test it!** 🚀

