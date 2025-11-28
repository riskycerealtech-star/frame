# Setup Workload Identity Federation (Alternative to Service Account Keys)

Since your organization has disabled service account key creation (for security), we'll use **Workload Identity Federation**, which is the recommended approach by Google.

## Option 1: Use Workload Identity Federation (Recommended)

This is more secure and doesn't require service account keys.

### Steps:

1. **Enable Workload Identity:**
   ```bash
   gcloud services enable iamcredentials.googleapis.com sts.googleapis.com
   ```

2. **Create Workload Identity Pool:**
   ```bash
   gcloud iam workload-identity-pools create github-pool \
     --project="test-deploy-project-479618" \
     --location="global" \
     --display-name="GitHub Actions Pool"
   ```

3. **Create Workload Identity Provider:**
   ```bash
   gcloud iam workload-identity-pools providers create-oidc github-provider \
     --project="test-deploy-project-479618" \
     --location="global" \
     --workload-identity-pool="github-pool" \
     --display-name="GitHub Provider" \
     --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
     --issuer-uri="https://token.actions.githubusercontent.com"
   ```

4. **Allow GitHub to impersonate the service account:**
   ```bash
   gcloud iam service-accounts add-iam-policy-binding \
     github-actions-sa@test-deploy-project-479618.iam.gserviceaccount.com \
     --project="test-deploy-project-479618" \
     --role="roles/iam.workloadIdentityUser" \
     --member="principalSet://iam.googleapis.com/projects/746287435076/locations/global/workloadIdentityPools/github-pool/attribute.repository/riskycerealtech-star/frame"
   ```

5. **Update GitHub Actions workflow** to use Workload Identity (I'll update the workflow file)

## Option 2: Request Policy Exception

Contact your Google Cloud administrator to:
- Temporarily allow service account key creation for this project
- Or grant you permission to create keys

## Option 3: Use Existing Service Account

If you have another service account with keys already created, you can use that instead.

---

**I recommend Option 1 (Workload Identity Federation)** as it's more secure and doesn't require keys.

Would you like me to set up Workload Identity Federation?

