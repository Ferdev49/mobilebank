# MobileBank Architecture
## Current State (Week 1)
┌─────────────────┐ │ Developer's │ │ Laptop │ │ ├─ Code (git) │ │ ├─ Docker │ │ └─ App
running │ └────────┬────────┘ │ ├─ Manual push to "production" │ (which is also local or a VM) │
└─ No monitoring, no logging
## Target State (Week 11)
┌──────────────────┐ │ GitHub │ │ ├─ Code push │ │ └─ Webhook │
└────────┬─────────┘ │ ▼ ┌──────────────────┐ │ GitHub Actions │ │ ├─ Lint │ │ ├─
Test │ │ ├─ Build Docker │ │ └─ Deploy │ └────────┬─────────┘ │ ┌────┴─────┐ │ │ ▼ ▼
┌────────┐ ┌──────────┐ │ Staging│ │Production│ │ K8s │ │ K8s │ │Cluster │ │ Cluster │
└────┬───┘ └────┬─────┘ │ │ ▼ ▼ ┌────────────────────────┐ │ Monitoring │ ├─
Prometheus/Grafana │ ├─ Logs (ELK/Loki) │ ├─ Alerts (PagerDuty) │
└────────────────────────┘
## Deployment Flow
1. Developer: `git push` to main branch
2. GitHub: Webhook triggers GitHub Actions
3. CI Pipeline:
 - Checkout code
 - Run linting
 - Run tests
 - Build Docker image
 - Push to registry
4. Deploy to staging:
 - Kubernetes applies new image
 - Health checks pass? Continue
 - Health checks fail? Rollback automatically
5. If all good:
 - Awaiting approval to production
mobilebank-onboarding.md 2026-04-18
7 / 10
 - Approver clicks "Deploy" in Slack
6. Deploy to production:
 - Same process as staging
 - More careful monitoring
7. Monitoring:
 - Metrics dashboard shows real-time status
 - Logs searchable and correlated
 - Alerts notify on anomalies
---
More details to come week-by-week...
