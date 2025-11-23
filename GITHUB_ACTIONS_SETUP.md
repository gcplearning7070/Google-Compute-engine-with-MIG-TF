# GitHub Actions Setup Guide

## Prerequisites

1. **GCP Service Account** with the following permissions:
   - Compute Instance Admin (v1)
   - Compute Network Admin
   - Service Account User

2. **Service Account Key** in JSON format

## Setup Instructions

### 1. Create GCP Service Account

```bash
# Set your project ID
export PROJECT_ID="your-gcp-project-id"

# Create service account
gcloud iam service-accounts create terraform-sa \
    --display-name="Terraform Service Account" \
    --project=${PROJECT_ID}

# Grant necessary permissions
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/compute.instanceAdmin.v1"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

# Create and download key
gcloud iam service-accounts keys create terraform-sa-key.json \
    --iam-account=terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com
```

### 2. Add GitHub Secret

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret**
4. Name: `GCP_SA_KEY`
5. Value: Paste the entire content of `terraform-sa-key.json`
6. Click **Add secret**

### 3. Update terraform.tfvars

Edit `terraform.tfvars` and update the project ID:

```hcl
project_id = "your-actual-gcp-project-id"
```

### 4. Configure GitHub Environments (Optional but Recommended)

For approval gates on deployments:

1. Go to **Settings** > **Environments**
2. Create environment: `dev`
3. Add protection rules:
   - Required reviewers (optional)
   - Wait timer (optional)
4. Create environment: `dev-destroy` (for destroy operations)
   - Add required reviewers for safety

## Workflow Overview

There are two separate GitHub Actions workflows:

### Workflow 1: Terraform Apply (`terraform-apply.yml`)

**Jobs:**

1. **Terraform Validate**
   - **Triggers**: On push to main, pull requests, manual dispatch
   - **Actions**:
     - Checks Terraform formatting
     - Validates Terraform configuration
     - No GCP authentication needed

2. **Terraform Plan**
   - **Triggers**: On pull requests only
   - **Actions**:
     - Authenticates to GCP using service account
     - Runs `terraform plan`
     - Uploads plan artifact for review
  
3. **Terraform Apply**
   - **Triggers**: On push to main branch
   - **Actions**:
     - Authenticates to GCP using service account
     - Runs `terraform plan` and `terraform apply`
     - Uploads and displays outputs
     - Uses `dev` environment for approval gate

### Workflow 2: Terraform Destroy (`terraform-destroy.yml`)

**Jobs:**

1. **Terraform Destroy**
   - **Triggers**: Manual workflow dispatch only with confirmation input
   - **Actions**:
     - Requires typing "destroy" to confirm
     - Authenticates to GCP using service account
     - Shows destroy plan
     - Destroys all infrastructure
     - Uses `dev-destroy` environment for approval gate

## Usage

### Deploy Infrastructure

1. Make changes to Terraform files
2. Commit and push to a feature branch
3. Create a pull request to main
4. Review the Terraform plan in the PR
5. Merge to main to trigger deployment

### Destroy Infrastructure

1. Go to **Actions** tab in GitHub
2. Select **Terraform Destroy** workflow
3. Click **Run workflow**
4. Select branch: `main`
5. Type `destroy` in the confirmation input field
6. Click **Run workflow** button
7. Approve in the `dev-destroy` environment if configured

## Workflow File Structure

```
.github/
└── workflows/
    ├── terraform-apply.yml
    └── terraform-destroy.yml
```

## Security Best Practices

1. **Never commit service account keys** to the repository
2. **Use environment protection rules** for production deployments
3. **Enable branch protection** on main branch
4. **Review Terraform plans** before applying
5. **Rotate service account keys** regularly
6. **Use least privilege** for service account permissions

## Troubleshooting

### Authentication Errors

If you see authentication errors:
- Verify `GCP_SA_KEY` secret is set correctly
- Check service account has required permissions
- Ensure service account key is valid

### Plan/Apply Failures

- Check Terraform logs in GitHub Actions
- Verify GCP quotas are sufficient
- Ensure project ID is correct in `terraform.tfvars`

### State Lock Issues

If using remote state (GCS backend):
- Check if state is locked by another process
- Manually unlock if needed: `terraform force-unlock <lock-id>`

## Next Steps

1. **Set up remote state**: Configure GCS backend for state storage
2. **Add notifications**: Configure Slack/email notifications for workflow status
3. **Implement testing**: Add terraform-compliance or similar tools
4. **Multi-environment**: Extend workflow for staging/production environments
