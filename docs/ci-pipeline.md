# GitHub Actions CI/CD Pipeline

## Overview
Automated pipeline that runs on every push to main and pull requests.

## Pipeline Stages

### 1. Checkout
- Clones the repository code

### 2. Setup Docker
- Installs Docker Buildx for efficient builds

### 3. Build Docker Image
- Builds the mobilebank-api Docker image
- Tags with commit SHA and 'latest'

### 4. Test Image
- Runs basic tests (placeholder for pytest)
- Currently skips if no tests exist

### 5. Image Info
- Displays built Docker images

## Trigger Events
- ✅ Push to main branch
- ✅ Pull requests to main branch

## Status
- ✅ Pipeline working and passing all jobs

## Next Steps
- Add Docker push to registry
- Add code quality checks
- Add security scanning
