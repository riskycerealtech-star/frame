# Custom Domain Configuration Guide

## Setting up www.frameflea.com for Frame Backend API

This guide walks you through configuring the custom domain `www.frameflea.com` for your Cloud Run service.

---

## Prerequisites

1. ✅ Cloud Run service deployed and running
2. ✅ Domain `frameflea.com` registered with a domain registrar
3. ✅ Access to your domain registrar's DNS management panel
4. ✅ Google Cloud project with billing enabled

---

## Step 1: Map Domain to Cloud Run Service

### Option A: Using the Script (Recommended)

```bash
cd Backend
chmod +x configure-domain.sh
./configure-domain.sh
```

### Option B: Manual Configuration

```bash
# Set your project
gcloud config set project glass-backend-api

# Map the domain
gcloud run domain-mappings create \
    --service glass-api \
    --domain www.frameflea.com \
    --region us-central1
```

---

## Step 2: Get DNS Records

After mapping the domain, Google Cloud will provide DNS records that need to be added to your domain registrar.

```bash
# Get the DNS records
gcloud run domain-mappings describe www.frameflea.com \
    --region us-central1
```

You'll see output like:

```yaml
resourceRecords:
- name: www.frameflea.com
  rrdata: ghs.googlehosted.com
  type: CNAME
```

Or for root domain:

```yaml
resourceRecords:
- name: frameflea.com
  rrdata: 216.239.32.21
  type: A
- name: frameflea.com
  rrdata: 216.239.36.21
  type: A
- name: frameflea.com
  rrdata: 216.239.38.21
  type: A
- name: frameflea.com
  rrdata: 216.239.34.21
  type: A
```

---

## Step 3: Add DNS Records to Your Domain Registrar

### For www.frameflea.com (Subdomain)

1. Log in to your domain registrar (GoDaddy, Namecheap, Google Domains, etc.)
2. Navigate to DNS Management / DNS Settings
3. Add a **CNAME** record:
   - **Name/Host**: `www`
   - **Value/Target**: `ghs.googlehosted.com`
   - **TTL**: 3600 (or default)

### For frameflea.com (Root Domain - Optional)

If you also want to map the root domain:

1. Add **A** records (use the IP addresses from Step 2):
   - **Name/Host**: `@` or leave blank
   - **Value/Target**: `216.239.32.21` (and other IPs from Google)
   - **TTL**: 3600

2. Map the root domain in Cloud Run:
   ```bash
   gcloud run domain-mappings create \
       --service glass-api \
       --domain frameflea.com \
       --region us-central1
   ```

---

## Step 4: Wait for DNS Propagation

- DNS changes can take **5 minutes to 48 hours** to propagate
- Usually takes **15-30 minutes** for most registrars
- You can check propagation status: https://www.whatsmydns.net/

---

## Step 5: Verify Domain is Active

```bash
# Check domain mapping status
gcloud run domain-mappings describe www.frameflea.com \
    --region us-central1

# List all domain mappings
gcloud run domain-mappings list --region us-central1
```

Status should show `ACTIVE` when DNS is properly configured.

---

## Step 6: Test Your API

Once DNS is propagated and domain is active:

```bash
# Test health endpoint
curl https://www.frameflea.com/health

# Test root endpoint
curl https://www.frameflea.com/

# Test Swagger docs
curl https://www.frameflea.com/docs
```

---

## Step 7: Update CORS Settings

Update your Cloud Run service to allow requests from your domain:

```bash
# Redeploy with updated CORS settings
gcloud run services update glass-api \
    --region us-central1 \
    --update-env-vars "BACKEND_CORS_ORIGINS=https://www.frameflea.com,https://frameflea.com"
```

Or update in your code (`app/core/config.py`):

```python
BACKEND_CORS_ORIGINS: list = [
    "https://www.frameflea.com",
    "https://frameflea.com",
    "http://localhost:3000",  # Keep for local development
    "http://localhost:8080"
]
```

---

## Troubleshooting

### Domain Status Shows "Pending"

- **Cause**: DNS records not yet propagated
- **Solution**: Wait 15-30 minutes and check again

### SSL Certificate Not Provisioned

- **Cause**: DNS not fully propagated
- **Solution**: Google automatically provisions SSL certificates once DNS is active. Wait 10-15 minutes after DNS is active.

### 404 Not Found

- **Cause**: Domain not properly mapped or service name incorrect
- **Solution**: Verify service name and region match your deployment

### CORS Errors

- **Cause**: CORS settings not updated for new domain
- **Solution**: Update `BACKEND_CORS_ORIGINS` environment variable

---

## Useful Commands

```bash
# List all domain mappings
gcloud run domain-mappings list --region us-central1

# Describe specific domain
gcloud run domain-mappings describe www.frameflea.com --region us-central1

# Delete domain mapping (if needed)
gcloud run domain-mappings delete www.frameflea.com --region us-central1

# Check service URL
gcloud run services describe glass-api --region us-central1 --format="value(status.url)"
```

---

## Additional Resources

- [Google Cloud Run Custom Domains Documentation](https://cloud.google.com/run/docs/mapping-custom-domains)
- [DNS Propagation Checker](https://www.whatsmydns.net/)
- [SSL Certificate Status](https://transparencyreport.google.com/https/certificates)

---

## Summary

After completing these steps:

✅ Domain mapped: `www.frameflea.com` → Cloud Run service  
✅ DNS records configured  
✅ SSL certificate automatically provisioned  
✅ API accessible at: `https://www.frameflea.com`  
✅ Swagger docs at: `https://www.frameflea.com/docs`





