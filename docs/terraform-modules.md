# Terraform Modules - Reusable Infrastructure Code

## Overview

Terraform modules are reusable, self-contained packages of infrastructure. Instead of duplicating code for staging and production, we define once and reuse with different variables.

## Module Structure

```
modules/
└── kubernetes-app/
    ├── main.tf        # Resource definitions
    ├── variables.tf   # Input variables
    └── outputs.tf     # Output values
```

## The kubernetes-app Module

### Purpose
Deploys a containerized application to Kubernetes with:
- Namespace (isolated workspace)
- Deployment (with replicas, health checks, resource limits)
- Service (LoadBalancer for traffic distribution)

### Key Variables
- **app_name** - Application name (e.g., mobilebank-api)
- **namespace** - K8s namespace (e.g., mobilebank-staging)
- **environment** - Environment name (staging or production)
- **replicas** - Number of pod copies (2 for staging, 3 for production)
- **image** - Docker image URI
- **cpu_request/limit** - CPU allocation
- **memory_request/limit** - Memory allocation
- **enable_health_checks** - Enable liveness/readiness probes

### Why Modules?

**Without modules:**
`hcl
# Staging
resource "kubernetes_namespace" "staging" { ... }
resource "kubernetes_deployment" "staging" { ... }
resource "kubernetes_service" "staging" { ... }

# Production
resource "kubernetes_namespace" "production" { ... }
resource "kubernetes_deployment" "production" { ... }
resource "kubernetes_service" "production" { ... }
# Code duplicated, hard to maintain
`

**With modules:**
`hcl
module "staging" {
  source = "./modules/kubernetes-app"
  environment = "staging"
  replicas = 2
}

module "production" {
  source = "./modules/kubernetes-app"
  environment = "production"
  replicas = 3
}
# Clean, DRY, maintainable
`

## Environment Differences

### Staging Environment
- **Replicas:** 2 (cost saving, development testing)
- **CPU Request:** 100m (minimal)
- **Memory Request:** 128Mi (minimal)
- **CPU Limit:** 250m (light constraint)
- **Memory Limit:** 256Mi (light constraint)
- **Purpose:** Testing before production
- **Users:** Internal team only
- **SLA:** Best effort (no guaranteed uptime)

### Production Environment
- **Replicas:** 3 (high availability, redundancy)
- **CPU Request:** 200m (moderate)
- **Memory Request:** 256Mi (moderate)
- **CPU Limit:** 500m (higher capacity)
- **Memory Limit:** 512Mi (higher capacity)
- **Purpose:** Real users, real money
- **Users:** Public/customers
- **SLA:** 99.9% uptime target

## How Modules Work

1. **Define once:** kubernetes-app module defines the structure
2. **Use many times:** staging.tf and production.tf use the same module
3. **Different variables:** Each instance gets its own configuration
4. **Same resources:** Both get namespace, deployment, service
5. **Consistent structure:** Guaranteed same patterns everywhere

## Terraform Files

### staging.tf
Calls kubernetes-app module for staging environment (2 replicas, less resources)

### production.tf
Calls kubernetes-app module for production environment (3 replicas, more resources)

## Current State

✅ Module created and validated
✅ Staging environment deployed (2 pods running)
✅ Production environment deployed (3 pods running)
✅ Each environment completely isolated
✅ Easy to add more environments (dev, qa, etc.)

## Scaling with Modules

To add a new environment (e.g., dev):

\\\hcl
module "mobilebank_dev" {
  source = "./modules/kubernetes-app"
  
  app_name  = "mobilebank-api"
  namespace = "mobilebank-dev"
  environment = "dev"
  replicas = 1  # Single replica for development
  image    = "ferdev49/mobilebank-api:latest"
}
\\\

Just create dev.tf and done!

## Best Practices

1. **One module = one reusable concept** (not a massive kitchen sink)
2. **Variables for differences** (staging vs prod)
3. **Outputs for dependencies** (other modules might need service IP)
4. **Documentation** (README for each module)
5. **Versioning** (tag modules like 1.0.0, 1.1.0, etc.)

## Next Steps

- Create more modules (databases, networking, etc.)
- Use module versions/registries
- Integrate modules with CI/CD
- Test modules before using in production

## Status

✅ Day 9: Terraform Modules - Complete
⏳ Day 10: Multi-environment advanced configuration - Next
⏳ Day 11-12: CI/CD integration + Demo - Next
