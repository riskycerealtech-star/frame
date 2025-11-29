# Google Cloud Deployment Checklist

Use this checklist to track your deployment progress.

## 📋 Pre-Deployment Checklist

### 1. Google Cloud Setup
- [ ] Create Google Cloud account
- [ ] Install Google Cloud SDK (`gcloud`)
- [ ] Install Docker Desktop
- [ ] Create GCP project: `glass-backend-api`
- [ ] Set default project: `gcloud config set project glass-backend-api`
- [ ] Enable billing (required for Cloud Run)

### 2. Enable Required APIs
- [ ] Cloud Run API: `gcloud services enable run.googleapis.com`
- [ ] Cloud SQL Admin API: `gcloud services enable sqladmin.googleapis.com`
- [ ] Cloud Build API: `gcloud services enable cloudbuild.googleapis.com`
- [ ] Vision API: `gcloud services enable vision.googleapis.com`
- [ ] Secret Manager API: `gcloud services enable secretmanager.googleapis.com`

### 3. Application Preparation
- [ ] Create `Dockerfile` in Backend directory
- [ ] Create `.dockerignore` file
- [ ] Create/update `requirements.txt` with all dependencies
- [ ] Test application locally with Docker
- [ ] Update database connection for Cloud SQL (Unix socket)
- [ ] Update CORS settings for production domains
- [ ] Review and update environment variables

### 4. Database Setup
- [ ] Create Cloud SQL instance: `glass-db`
- [ ] Choose instance tier (db-f1-micro for dev, db-g1-small for prod)
- [ ] Set root password securely
- [ ] Create database: `glass_db`
- [ ] Create database user: `glass_user`
- [ ] Get connection name: `PROJECT:REGION:glass-db`
- [ ] Test database connection locally (optional)

### 5. Secrets Management
- [ ] Store database password in Secret Manager
- [ ] Store database user in Secret Manager (optional)
- [ ] Store JWT secret key in Secret Manager
- [ ] Grant Cloud Run service account access to secrets
- [ ] Verify secret access permissions

### 6. Build & Deploy
- [ ] Build Docker image: `gcloud builds submit`
- [ ] Verify image in Container Registry
- [ ] Deploy to Cloud Run with all environment variables
- [ ] Configure Cloud SQL connection in Cloud Run
- [ ] Set memory and CPU limits appropriately
- [ ] Configure auto-scaling (min/max instances)
- [ ] Set request timeout (default 300 seconds)

### 7. Database Migrations
- [ ] Create Cloud Run Job for migrations
- [ ] Run initial migration: `alembic upgrade head`
- [ ] Verify database schema is created
- [ ] Test database operations

### 8. Post-Deployment
- [ ] Get Cloud Run service URL
- [ ] Test health endpoint: `/health`
- [ ] Test API endpoints
- [ ] Verify Swagger documentation is accessible
- [ ] Test authentication endpoints
- [ ] Test AI validation endpoints
- [ ] Check Cloud Run logs for errors
- [ ] Verify Cloud SQL connections in logs

### 9. Security & Configuration
- [ ] Review CORS settings (restrict to your domains)
- [ ] Enable authentication if needed (remove `--allow-unauthenticated`)
- [ ] Set up custom domain (optional)
- [ ] Configure SSL/TLS (automatic with Cloud Run)
- [ ] Review IAM permissions
- [ ] Set up firewall rules if needed

### 10. Monitoring & Alerts
- [ ] Set up Cloud Monitoring dashboard
- [ ] Create uptime check for health endpoint
- [ ] Configure error reporting
- [ ] Set up log-based alerts
- [ ] Monitor Cloud Run metrics (requests, latency, errors)
- [ ] Monitor Cloud SQL metrics (connections, CPU, memory)

### 11. Cost Optimization
- [ ] Review Cloud Run pricing (set min-instances to 0)
- [ ] Review Cloud SQL instance size
- [ ] Set up billing alerts
- [ ] Monitor daily costs
- [ ] Optimize container image size
- [ ] Review Cloud Vision API usage

### 12. Documentation
- [ ] Update API documentation with production URL
- [ ] Document environment variables
- [ ] Create runbook for common operations
- [ ] Document rollback procedure
- [ ] Share deployment guide with team

---

## 🚀 Quick Deployment Commands

### Initial Setup
```bash
# Set project
gcloud config set project glass-backend-api

# Enable APIs
gcloud services enable run.googleapis.com sqladmin.googleapis.com cloudbuild.googleapis.com vision.googleapis.com secretmanager.googleapis.com
```

### Database Setup
```bash
# Create Cloud SQL instance
gcloud sql instances create glass-db \
    --database-version=POSTGRES_15 \
    --tier=db-f1-micro \
    --region=us-central1 \
    --root-password=YOUR_SECURE_PASSWORD

# Create database
gcloud sql databases create glass_db --instance=glass-db

# Create user
gcloud sql users create glass_user \
    --instance=glass-db \
    --password=YOUR_DB_PASSWORD

# Get connection name
gcloud sql instances describe glass-db --format="value(connectionName)"
```

### Secrets Setup
```bash
# Store secrets
echo -n "YOUR_DB_PASSWORD" | gcloud secrets create db-password --data-file=-
echo -n "glass_user" | gcloud secrets create db-user --data-file=-
echo -n "your-jwt-secret-key" | gcloud secrets create jwt-secret --data-file=-

# Grant access
PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="${PROJECT_ID}@appspot.gserviceaccount.com"
gcloud secrets add-iam-policy-binding db-password \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/secretmanager.secretAccessor"
gcloud secrets add-iam-policy-binding jwt-secret \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/secretmanager.secretAccessor"
```

### Build & Deploy
```bash
# Build image
cd Backend
gcloud builds submit --tag gcr.io/$(gcloud config get-value project)/glass-api

# Deploy
CONNECTION_NAME=$(gcloud sql instances describe glass-db --format="value(connectionName)")
PROJECT_ID=$(gcloud config get-value project)

gcloud run deploy glass-api \
    --image gcr.io/${PROJECT_ID}/glass-api \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --add-cloudsql-instances ${CONNECTION_NAME} \
    --set-env-vars "POSTGRES_SERVER=/cloudsql/${CONNECTION_NAME}" \
    --set-env-vars "POSTGRES_USER=glass_user" \
    --set-env-vars "POSTGRES_DB=glass_db" \
    --set-secrets "POSTGRES_PASSWORD=db-password:latest" \
    --set-secrets "SECRET_KEY=jwt-secret:latest" \
    --set-env-vars "GOOGLE_CLOUD_PROJECT_ID=${PROJECT_ID}" \
    --memory 1Gi \
    --cpu 1 \
    --timeout 300 \
    --max-instances 10 \
    --min-instances 0
```

### Run Migrations
```bash
# Create migration job
gcloud run jobs create glass-migrate \
    --image gcr.io/${PROJECT_ID}/glass-api \
    --region us-central1 \
    --add-cloudsql-instances ${CONNECTION_NAME} \
    --set-env-vars "POSTGRES_SERVER=/cloudsql/${CONNECTION_NAME}" \
    --set-env-vars "POSTGRES_USER=glass_user" \
    --set-env-vars "POSTGRES_DB=glass_db" \
    --set-secrets "POSTGRES_PASSWORD=db-password:latest" \
    --command "alembic" \
    --args "upgrade,head" \
    --memory 512Mi

# Execute migration
gcloud run jobs execute glass-migrate --region us-central1
```

### Get Service URL
```bash
gcloud run services describe glass-api --region us-central1 --format="value(status.url)"
```

---

## 🔍 Verification Steps

After deployment, verify:

1. **Health Check**
   ```bash
   curl https://YOUR-SERVICE-URL/health
   ```

2. **API Documentation**
   - Visit: `https://YOUR-SERVICE-URL/docs/frame/swagger-ui/index.html`

3. **Check Logs**
   ```bash
   gcloud run services logs read glass-api --region us-central1 --limit 50
   ```

4. **Test Authentication**
   ```bash
   curl -X POST https://YOUR-SERVICE-URL/api/v1/user/signup \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"test123"}'
   ```

---

## 📊 Cost Monitoring

Monitor your costs:
```bash
# View current month costs
gcloud billing accounts list
gcloud billing projects describe glass-backend-api

# Set up billing alerts in Cloud Console
# https://console.cloud.google.com/billing
```

---

## 🆘 Troubleshooting

### View Logs
```bash
gcloud run services logs read glass-api --region us-central1 --follow
```

### Update Service
```bash
gcloud run services update glass-api --region us-central1 --memory 2Gi
```

### Delete and Redeploy
```bash
gcloud run services delete glass-api --region us-central1
# Then redeploy using deployment commands above
```

---

## ✅ Success Criteria

Your deployment is successful when:
- ✅ Health endpoint returns 200 OK
- ✅ Swagger documentation is accessible
- ✅ Database connections work
- ✅ Authentication endpoints work
- ✅ AI validation endpoints work
- ✅ No errors in Cloud Run logs
- ✅ Service scales automatically
- ✅ HTTPS is working (automatic)

---

**Next Steps**: See [GOOGLE_CLOUD_DEPLOYMENT_GUIDE.md](./GOOGLE_CLOUD_DEPLOYMENT_GUIDE.md) for detailed explanations.

