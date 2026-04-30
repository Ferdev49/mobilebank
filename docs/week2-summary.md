# Week 2: Infrastructure as Code - Complete Summary

## Overview

Week 2 focused on Infrastructure as Code using Terraform, transforming manual deployments into automated, version-controlled infrastructure.

## Days Completed

### Day 8: Terraform Basics ✅
- Installed Terraform (v1.14.6)
- Created terraform/main.tf with Kubernetes resources
- Kubernetes provider configuration
- Manual apply/destroy workflow
- First deployment to Kubernetes
- Status: Staging namespace, deployment, service created

### Day 9: Terraform Modules ✅
- Created reusable modules/kubernetes-app/
- Module structure: main.tf, variables.tf, outputs.tf
- Separated staging and production configurations
- staging.tf and production.tf call the same module
- DRY principle implemented
- Status: Both staging (2 replicas) and production (3 replicas) deployable

### Day 10: Multi-environment Configuration ✅
- Created root-level variables.tf
- Created environments/staging.tfvars
- Created environments/production.tfvars
- Separated variable declarations from values
- Outputs for deployment info
- Multi-env deployment: terraform apply -var-file="environments/staging.tfvars"
- Status: Different configs for staging and production

### Day 11: CI/CD Integration ✅
- Created .github/workflows/terraform.yaml
- GitHub Actions auto-runs terraform plan on push
- GitHub Actions auto-runs terraform apply on main branch
- Workflow triggers only on terraform/ changes
- Separate jobs for plan and apply
- Created .gitignore for Terraform files
- Status: Fully automated deployment pipeline

### Day 12: Final Demo & Summary (Today) ✅
- Verified all components running
- Staging: 2 pods, LoadBalancer IP: 172.25.0.5
- Production: 3 pods, LoadBalancer pending
- Multi-environment working perfectly
- Terraform state managed
- GitHub Actions passing

## Architecture Achieved

\\\
Code Push
    ↓
GitHub (main branch)
    ↓
GitHub Actions (terraform.yaml)
    ↓
Terraform Plan (validate changes)
    ↓
Terraform Apply (deploy changes)
    ↓
Kubernetes
    ↓
Staging (2 replicas)
Production (3 replicas)
\\\

## Key Technologies

- **Terraform:** Infrastructure as Code
- **Kubernetes:** Container orchestration (Docker Desktop)
- **GitHub Actions:** CI/CD automation
- **Docker:** Containerization
- **Git:** Version control

## Files Created (Week 2)

**Terraform Structure:**
- terraform/main.tf
- terraform/variables.tf
- terraform/outputs.tf
- terraform/providers.tf
- terraform/modules/kubernetes-app/
  - main.tf (namespace, deployment, service)
  - variables.tf (input variables)
  - outputs.tf (output values)
- terraform/environments/
  - staging.tfvars
  - production.tfvars

**GitHub Workflows:**
- .github/workflows/ci.yaml (from Week 1)
- .github/workflows/terraform.yaml (new Week 2)

**Documentation:**
- docs/terraform-basics.md
- docs/terraform-modules.md
- docs/terraform-multi-environment.md
- docs/terraform-cicd.md
- docs/week2-summary.md (this file)

**Configuration:**
- .gitignore (Terraform exclusions)

## Current Deployment Status

### Staging Environment
- **Namespace:** mobilebank-staging
- **Replicas:** 2
- **Image:** ferdev49/mobilebank-api:latest
- **Resources:** 100m CPU request, 128Mi memory request
- **Service IP:** 172.25.0.5
- **Port:** 80 → 5000
- **Status:** ✅ Running

### Production Environment
- **Namespace:** mobilebank-production
- **Replicas:** 3
- **Image:** ferdev49/mobilebank-api:latest
- **Resources:** 200m CPU request, 256Mi memory request
- **Service IP:** Pending (LoadBalancer)
- **Port:** 80 → 5000
- **Status:** ✅ Running

## Best Practices Implemented

1. **Modularity:** Reusable module for both environments
2. **DRY Principle:** One module, multiple environments
3. **Separation of Concerns:** Modules, environments, variables separate
4. **Version Control:** All infrastructure in Git
5. **Automation:** GitHub Actions handles deployment
6. **Documentation:** Each component documented
7. **State Management:** Terraform state tracked
8. **Validation:** terraform validate, terraform plan before apply

## Workflow in Action

1. Developer makes code change
2. Commit and push to GitHub
3. GitHub Actions triggers automatically
4. terraform validate - syntax check
5. terraform plan - preview changes
6. terraform apply - deploy changes
7. Kubernetes updates both staging and production
8. New replicas start, old ones terminate
9. Zero-downtime rolling updates

## Metrics

- **Infrastructure as Code:** 100% complete
- **Automation:** Fully automated pipeline
- **Environments:** 2 (staging, production)
- **Replicas Staging:** 2
- **Replicas Production:** 3
- **Total Pods Running:** 5
- **GitHub Actions Workflows:** 2
- **Terraform Modules:** 1 reusable
- **Lines of Terraform Code:** ~300+
- **Days to Build:** 5 days (Days 8-12)

## Key Learnings

1. Terraform manages infrastructure as code
2. Modules enable code reuse
3. Variables separate configuration from code
4. GitHub Actions automates deployments
5. Multi-environment configuration is crucial
6. Kubernetes manifests can be generated by Terraform
7. Version control for infrastructure = safer deployments

## Challenges Overcome

1. Kubernetes provider state conflicts → Resolved with clean state
2. Resource already exists errors → Fixed with proper module structure
3. LoadBalancer IP pending → Expected in Minikube/Docker Desktop
4. Multiple environments in single apply → Consolidated in main.tf

## Ready for Week 3

✅ Infrastructure fully automated
✅ Multi-environment working
✅ CI/CD pipeline active
✅ Code versioned in Git
✅ Deployments reproducible

## Status

✅ **Week 2: Infrastructure as Code - COMPLETE**
- All objectives met
- All days completed (8-12)
- Production-ready infrastructure setup
- Automated deployment pipeline active

## Next Steps (Week 3)

- Advanced Terraform (backends, modules registry)
- Monitoring and logging
- Security hardening
- Production deployments
- High availability setup
- Disaster recovery procedures

---

**Week 2 Summary:**
From manual deployments to fully automated infrastructure. Terraform + GitHub Actions = reliable, reproducible infrastructure.

**Status:** ✅ READY FOR PRODUCTION
