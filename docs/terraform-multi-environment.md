# Terraform Multi-environment Configuration

## Overview

Multi-environment configuration allows managing different environments (staging, production) with a single codebase but different variables.

## Problem We're Solving

**Without tfvars (bad):**
`hcl
# staging.tf
module "staging" {
  replicas = 2
  cpu_limit = "250m"
}

# production.tf
module "production" {
  replicas = 3
  cpu_limit = "500m"
}
# Code duplicated, hard to maintain
`

**With tfvars (good):**
`ash
# Same code, different variables
terraform apply -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/production.tfvars"
`

## File Structure

\\\
terraform/
├── main.tf              # Root configuration
├── variables.tf         # Variable declarations
├── outputs.tf           # Output definitions
├── staging.tf           # Staging module call
├── production.tf        # Production module call
├── modules/
│   └── kubernetes-app/  # Reusable module
├── environments/
│   ├── staging.tfvars   # Staging variable values
│   └── production.tfvars # Production variable values
└── .terraform/          # Provider plugins
\\\

## Key Files

### variables.tf (Root Level)
Declares all variables that can be set via tfvars files.

**Important:** These are DECLARATIONS, not assignments.

\\\hcl
variable "replicas" {
  type = number  # What type of value
}
\\\

### staging.tfvars
Sets variable values FOR STAGING environment.

\\\hcl
replicas = 2  # Staging gets 2 replicas
cpu_limit = "250m"
\\\

### production.tfvars
Sets variable values FOR PRODUCTION environment.

\\\hcl
replicas = 3  # Production gets 3 replicas
cpu_limit = "500m"
\\\

### staging.tf and production.tf
Both use the SAME module but different variables via tfvars.

## How It Works

1. **Declare variables** in root variables.tf
2. **Set values** in environments/staging.tfvars and production.tfvars
3. **Apply with specific tfvars:**
   \\\ash
   terraform apply -var-file="environments/staging.tfvars"
   \\\
4. Terraform loads staging.tfvars and uses those variable values
5. Same code, different behavior based on variables

## Variable Types

| Type | Example |
|------|---------|
| string | "ferdev49/mobilebank-api:latest" |
| number | 3 |
| bool | true |
| map(string) | { "tier" = "production" } |
| list(string) | ["staging", "production"] |

## Environment Differences

### Staging (staging.tfvars)
- **replicas:** 2 (cost savings)
- **cpu_limit:** 250m (less powerful)
- **memory_limit:** 256Mi (less memory)
- **Purpose:** Testing before production
- **Cost:** Lower

### Production (production.tfvars)
- **replicas:** 3 (high availability)
- **cpu_limit:** 500m (more powerful)
- **memory_limit:** 512Mi (more memory)
- **Purpose:** Real users
- **Cost:** Higher but reliable

## Commands

### Plan for Staging
\\\ash
terraform plan -var-file="environments/staging.tfvars"
\\\

### Apply for Staging
\\\ash
terraform apply -var-file="environments/staging.tfvars"
\\\

### Plan for Production
\\\ash
terraform plan -var-file="environments/production.tfvars"
\\\

### Apply for Production
\\\ash
terraform apply -var-file="environments/production.tfvars"
\\\

### Destroy Staging
\\\ash
terraform destroy -var-file="environments/staging.tfvars"
\\\

## State Management

Each environment can have its own state file:

\\\ash
# Staging state
terraform apply -var-file="environments/staging.tfvars" -state="staging.tfstate"

# Production state
terraform apply -var-file="environments/production.tfvars" -state="production.tfstate"
\\\

This prevents accidental deletion of production when managing staging.

## Outputs

Terraform outputs show results of the deployment:

\\\hcl
output "staging_replicas" {
  value = module.mobilebank_staging.replicas
}

output "production_replicas" {
  value = module.mobilebank_production.replicas
}
\\\

View outputs:
\\\ash
terraform output
\\\

## Best Practices

1. **Use tfvars for environment-specific values** (replicas, resources)
2. **Keep code in staging.tf/production.tf minimal**
3. **All logic in modules** (reusable, testable)
4. **Different state files** for staging/production
5. **Version control tfvars** (commit to Git)
6. **Use sensitive() for secrets** (passwords, API keys)
7. **Separate backends** for different environments

## Example: Adding New Environment (QA)

To add a QA environment:

1. Create \environments/qa.tfvars\
2. Create \qa.tf\ that calls the same module
3. Deploy:
   \\\ash
   terraform apply -var-file="environments/qa.tfvars"
   \\\

Just 3 steps, no code duplication!

## Current Implementation

✅ variables.tf - Root level variables declared
✅ staging.tfvars - Staging configuration
✅ production.tfvars - Production configuration
✅ staging.tf - Staging module call
✅ production.tf - Production module call
✅ outputs.tf - Export deployment info

## Next Steps

- Implement separate state files (terraform.tf with backends)
- Add secrets management (Kubernetes Secrets)
- Integrate with CI/CD (automatic apply on push)
- Add testing (terratest for Terraform)

## Status

✅ Day 10: Multi-environment Configuration - In Progress
⏳ Day 11-12: CI/CD Integration + Demo - Next
