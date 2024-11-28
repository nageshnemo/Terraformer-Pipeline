# Terraformer-Pipeline

name: Test Authentication with GCP

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  auth-test:
    runs-on: ubuntu-latest
    permissions:
      contents: 'read'
      id-token: 'write'

    steps:
      # Step 1: Checkout the repository
      - name: Checkout code
        uses: actions/checkout@v3

      # Step 2: Authenticate with GCP using Workload Identity Federation
      - name: Authenticate with GCP
        uses: google-github-actions/auth@v2
        with:
          service_account: 'gitops-cicd@fast-ability-439911-u1.iam.gserviceaccount.com'
          workload_identity_provider: 'projects/784674387874/locations/global/workloadIdentityPools/github/providers/my-repo'
