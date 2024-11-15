#!/bin/bash

export ORGANIZATION_ID=$(gcloud organizations list --format="value(ID)")
export PROJECT_ID=
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
export REGION=
export SERVICE_ACCOUNT_NAME=terraform-test
export BUCKET_NAME=

# Create Bucket to store terraform state backend files.
gcloud storage buckets create gs://$BUCKET_NAME --location=$REGION

# Commands to create Service Account and grant permissions at Org level for WIF
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
  --description="This is for test pipeline" \
  --display-name="test-terraform"


gcloud iam workload-identity-pools create "test-terraform" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="GitHub Actions Pool"

gcloud iam workload-identity-pools providers create-oidc "test-terraform" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="test-terraform" \
  --display-name="My GitHub repo Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --issuer-uri="https://token.actions.githubusercontent.com"

gcloud iam service-accounts add-iam-policy-binding "$SERVICE_ACCOUNT_NAME@${PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/test-terraform/attribute.repository/nagesh-nemo/Terraformer-Pipeline"
