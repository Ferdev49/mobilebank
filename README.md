# DevOps Lab - MobileBank Platform

A comprehensive DevOps learning project: CI/CD, Kubernetes, Infrastructure as Code

## Status
🚀 In progress (11 weeks, started April 14, 2026)

## What's here?
- `.github/workflows/` - CI/CD pipelines
- `kubernetes/` - K8s manifests for all environments
- `terraform/` - Infrastructure as Code
- `docker/` - Containerization
- `docs/` - All documentation
- `scripts/` - Automation scripts

## Quick Start

### Local Development
```bash
cd mobilebank-app
pip install -r requirements.txt
python app.py
```

### Docker
```bash
cd mobilebank-app
docker build -t mobilebank-api:latest .
docker run -p 5000:5000 mobilebank-api:latest
```

### CI/CD
The pipeline automatically runs on every push to `main`:
- Builds Docker image
- Runs tests
- (Soon: pushes to registry)

See [CI Pipeline Documentation](docs/ci-pipeline.md) for details.

## Roadmap
Week 1-2: CI/CD Foundation
Week 3-4: Containerization & K8s
Week 5-6: Staging Production-like
Week 7-8: Production Migration
Week 9-11: Hardening & Optimization

---
Created for real-world DevOps learning
