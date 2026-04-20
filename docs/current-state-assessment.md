Date: Monday, April 20, 2026
Assessor: Fer (DevOps Engineer)
## Application Overview
### Tech Stack
- Backend: Python (Flask)
- Database: PostgreSQL (not yet, but will add)
- Frontend: React (not yet, but will add)
- Current deployment: Local only
### Current Deployment Method
❌ No CI/CD
❌ Manual deployments
❌ Code in git, but deployment is manual command
❌ No testing in deployment pipeline
❌ No monitoring
❌ No logging infrastructure
## Infrastructure Baseline
### Current State
- Application: Runs in Docker locally ✅
- Deployment: Manual `docker run` ❌
mobilebank-onboarding.md 2026-04-18
5 / 10
- Testing: Developers run tests locally (not enforced) ❌
- Staging: Doesn't exist ❌
- Production: Doesn't exist ❌
- Monitoring: Doesn't exist ❌
- Logging: Console only ❌
- Database: SQLite or hardcoded data ❌
- Secrets: Hardcoded in .env files ❌
### Pain Points
1. **No automation** - Each deploy takes 30 min, manual steps
2. **No testing enforcement** - Code might break in production
3. **No visibility** - We discover bugs when customers complain (Twitter)
4. **No scaling** - If we get traffic spike, we're down
5. **No recovery** - If something breaks, we don't know what broke
6. **No standards** - Each team member deploys differently
7. **No audit trail** - "Who deployed this? When? What version?"
8. **No monitoring** - Is the app even up? We don't know
9. **No logging** - Where did the error occur? No idea
10. **No rollback** - If deployment breaks, we restart manually
## Desired State (Week 11, June 30)
✅ Automated CI/CD pipeline
✅ Tests run on every push
✅ Staging environment (production-like)
✅ Production environment on Kubernetes
✅ Automated deployments
✅ Rollback capability
✅ Monitoring & dashboards
✅ Centralized logging
✅ Incident response playbooks
✅ <5 min deployments
✅ 99.5% uptime SLO
## Gap Analysis
| Area | Current | Target | Gap | Priority |
|------|---------|--------|-----|----------|
| Deployments | Manual 30m | Automated 5m | Critical | 1 |
| Testing | Local/manual | Enforced in pipeline | High | 1 |
| Staging | None | K8s cluster | High | 2 |
| Production | None | K8s cluster | Critical | 3 |
| Monitoring | None | Full observability | High | 4 |
| Logging | Console | Centralized | Medium | 5 |
## Next Steps
Week 1: Understand and document current state ✅
Week 2-3: Implement CI/CD
Week 4-5: Kubernetes locally
Week 6-7: Staging + Monitoring
Week 8: Production migration
Week 9-11: Hardening
mobilebank-onboarding.md 2026-04-18
6 / 10
---
Status: STARTING POINT FOR TRANSFORMATION 🚀
