# Terraform Basics - Infrastructure as Code

## Overview

Terraform defines MobileBank infrastructure as code. Instead of clicking AWS console or kubectl manually, everything is version-controlled in Git.

## What is Terraform?

**Problem:** Manual infrastructure creation is error-prone and unreproducible.
**Solution:** Define infrastructure in HCL (Terraform language), version in Git, deploy consistently.

## Files Created

- **providers.tf** - Defines Kubernetes provider and Terraform version
- **variables.tf** - Defines configurable variables (replicas, image, resources)
- **main.tf** - Defines actual resources (namespace, deployment, service)
- **outputs.tf** - Exports useful values after apply

## Key Concepts

### Providers
`hcl
provider "kubernetes" {
  config_path = "~/.kube/config"
}
`
Tells Terraform which cloud/platform to use.

### Resources
`hcl
resource "kubernetes_deployment" "mobilebank_api" {
  # Configuration
}
`
Actual infrastructure objects to create.

### Variables
`hcl
variable "replicas" {
  type    = number
  default = 2
}
`
Configurable values, reusable across files.

### Outputs
`hcl
output "service_ip" {
  value = kubernetes_service.mobilebank_api.spec[0].cluster_ip
}
`
Values exported after creation.

## Terraform Commands

### Initialize
\\\ash
terraform init
\\\
Downloads providers and initializes working directory.

### Plan
\\\ash
terraform plan
\\\
Shows what WILL be created (dry-run).

### Apply
\\\ash
terraform apply
\\\
Actually creates/modifies resources.

### Import
\\\ash
terraform import kubernetes_deployment.name namespace/name
\\\
Adopts existing resources into Terraform state.

### Destroy
\\\ash
terraform destroy
\\\
Deletes all resources (careful!).

## Current State

✅ Terraform managing:
- Kubernetes namespace (mobilebank)
- Deployment (2 replicas)
- Service (LoadBalancer)
- Health checks (liveness + readiness)

## Resources Defined

| Resource | Name | Details |
|----------|------|---------|
| Namespace | mobilebank | Isolated K8s workspace |
| Deployment | mobilebank-api | 2 replicas with health checks |
| Service | mobilebank-api | LoadBalancer on port 80 |

## Variables (Configurable)

| Variable | Default | Purpose |
|----------|---------|---------|
| app_name | mobilebank-api | Application name |
| namespace | mobilebank | K8s namespace |
| replicas | 2 | Number of pods |
| image | ferdev49/mobilebank-api:latest | Docker image |
| port | 5000 | Container port |
| cpu_request | 100m | Min CPU |
| memory_request | 128Mi | Min memory |
| cpu_limit | 500m | Max CPU |
| memory_limit | 512Mi | Max memory |

## Why Terraform?

1. **Version Control** - Infrastructure in Git, reviewable
2. **Reproducibility** - Same code = same infrastructure everywhere
3. **Documentation** - Code documents itself
4. **Automation** - No manual clicks, no human error
5. **Scalability** - Change replicas from 2 to 10 in one variable

## Next Steps (Week 2)

- Create terraform/modules/ for reusable components
- Create terraform/environments/ for staging/production
- Integrate Terraform with CI/CD pipeline
- Add data sources for dynamic values

## Status

✅ Day 8: Terraform Basics - Complete
⏳ Day 9: Terraform Modules - Next
⏳ Day 10: Multi-environment - Next
