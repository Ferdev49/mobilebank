# Docker Push to Docker Hub

## Overview
GitHub Actions automatically builds and pushes Docker images to Docker Hub on every push to main.

## Pipeline Steps
1. **Checkout code**
2. **Setup Docker Buildx**
3. **Login to Docker Hub** (using secrets)
4. **Build and push image** with tags:
   - \erdev49/mobilebank-api:latest\
   - \erdev49/mobilebank-api:<commit-sha>\
5. **Confirmation message**

## Docker Hub Repository
https://hub.docker.com/r/ferdev49/mobilebank-api

## Usage
\\\ash
docker pull ferdev49/mobilebank-api:latest
docker run -p 5000:5000 ferdev49/mobilebank-api:latest
\\\

## Status
✅ Pipeline working and pushing to Docker Hub successfully

## Next Steps
- Deploy to Kubernetes cluster
- Add image scanning for vulnerabilities
- Implement image signing
