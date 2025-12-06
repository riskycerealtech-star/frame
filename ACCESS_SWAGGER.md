# How to Access Swagger Documentation from Google Cloud

## Method 1: From Google Cloud Console (Web UI)

### Step 1: Navigate to Cloud Run
1. Go to: https://console.cloud.google.com/run?project=test-deploy-project-479618
2. Or: Google Cloud Console → Cloud Run (in left menu)

### Step 2: Find Your Service
- Look for service named: `frame-api`
- Click on the service name

### Step 3: Get the Service URL
- In the service details page, you'll see the **Service URL**
- It looks like: `https://frame-api-xxxxx-uc.a.run.app`

### Step 4: Access Swagger
- **Swagger UI:** `https://your-service-url.run.app/docs`
- **ReDoc:** `https://your-service-url.run.app/redoc`
- **OpenAPI JSON:** `https://your-service-url.run.app/openapi.json`

---

## Method 2: From Command Line

### Get the Service URL:
```bash
gcloud run services describe frame-api \
  --project=test-deploy-project-479618 \
  --region=us-central1 \
  --format="value(status.url)"
```

### Then open in browser:
```bash
# Get URL and open Swagger docs
SERVICE_URL=$(gcloud run services describe frame-api \
  --project=test-deploy-project-479618 \
  --region=us-central1 \
  --format="value(status.url)")

echo "Swagger UI: ${SERVICE_URL}/docs"
echo "ReDoc: ${SERVICE_URL}/redoc"

# Open in browser (macOS)
open "${SERVICE_URL}/docs"
```

---

## Method 3: From GitHub Actions (After Deployment)

1. Go to: https://github.com/riskycerealtech-star/frame/actions
2. Click on the latest workflow run
3. Scroll to the bottom - the workflow outputs the service URL
4. Look for: `🌐 Service URL: https://...`
5. Add `/docs` to the URL to access Swagger

---

## Quick Access Links

Once deployed, your Swagger documentation will be at:

- **Swagger UI (Interactive):** `https://frame-api-xxxxx-uc.a.run.app/docs`
- **ReDoc (Alternative):** `https://frame-api-xxxxx-uc.a.run.app/redoc`
- **API Root:** `https://frame-api-xxxxx-uc.a.run.app/`

---

## Check Deployment Status

To see if your service is deployed:

```bash
gcloud run services list --project=test-deploy-project-479618 --region=us-central1
```

If the service exists, you'll see it in the list with its URL.

---

## Note

If the service doesn't exist yet, the GitHub Actions workflow might still be running. Check:
- https://github.com/riskycerealtech-star/frame/actions

Once the workflow completes successfully, the service will be available!













