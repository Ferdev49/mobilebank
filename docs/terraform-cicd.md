# Terraform CI/CD Integration

## Overview

Automated deployment pipeline that runs Terraform whenever code is pushed to GitHub.

## How It Works

1. **Developer pushes code** to main branch
2. **GitHub Actions triggers automatically**
3. **Terraform plan** - Shows what will change
4. **Terraform apply** - Actually deploys changes
5. **Both staging and production updated**

## GitHub Actions Workflow

File: .github/workflows/terraform.yaml

### Triggers
- Push to main branch
- Pull requests to main branch
- Only if terraform/ or workflow files changed

### Jobs

**Job 1: terraform-plan**
- Runs on: ubuntu-latest
- Steps:
  1. Checkout code
  2. Setup Terraform
  3. Format check (terraform fmt)
  4. Init (terraform init)
  5. Validate (terraform validate)
  6. Plan staging (terraform plan -var-file="environments/staging.tfvars")
  7. Plan production (terraform plan -var-file="environments/production.tfvars")
  8. Comment on PR with results

**Job 2: terraform-apply**
- Runs on: ubuntu-latest
- Only on: push to main (not on PRs)
- Needs: terraform-plan (waits for it to finish)
- Steps:
  1. Checkout code
  2. Setup Terraform
  3. Init
  4. Apply staging (auto-approve)
  5. Apply production (auto-approve)
  6. Show outputs

## Workflow Commands

### terraform fmt -check -recursive terraform/
Checks if Terraform code is properly formatted. Fails if formatting issues found.

### terraform init
Initializes Terraform, downloads providers.

### terraform validate
Validates syntax - catches errors early.

### terraform plan
Shows what WILL change (dry-run, no actual changes).

### terraform apply -auto-approve
Actually makes the changes. -auto-approve skips confirmation prompt (safe in CI/CD).

## Pull Request Workflow

When you open a PR:
1. terraform-plan job runs
2. Shows what WOULD change if merged
3. GitHub comments on PR with results
4. You can review before merging
5. When merged to main, terraform-apply runs

## Push to Main Workflow

When you push directly to main:
1. terraform-plan runs (validation)
2. terraform-apply runs (deployment)
3. Both staging and production updated

## Environment Variables

\\\yaml
TERRAFORM_VERSION: 1.14.6
\\\

Sets the exact Terraform version to use in GitHub Actions.

## Error Handling

- \continue-on-error: true\ - If one environment fails, continue to next
- Jobs don't block each other with this setting
- Allows partial deployments if issues occur

## Security Considerations

**Current setup (learning):**
- Uses \-auto-approve\ (no manual review)
- Direct push to main triggers apply

**Production best practices:**
- Require PR reviews before merge
- Manual approval step before apply
- Separate secrets for AWS/cloud credentials
- Use terraform remote state (S3, Azure, etc)

## Monitoring Deployments

Go to GitHub Actions to see:
- ✅ Status (green = success, red = failed)
- ⏱️ Duration (how long it took)
- 📋 Logs (detailed output)
- 🔄 Commit info (what changed)

## Example Workflow Run

\\\
Commit: "Add 3 replicas to production"
↓
GitHub Actions triggers
↓
terraform-plan job
  - Terraform fmt check ✅
  - Terraform init ✅
  - Terraform validate ✅
  - Plan staging ✅
  - Plan production ✅
↓
terraform-apply job (only on push)
  - Apply staging ✅
  - Apply production ✅
↓
Both environments updated with new configuration
\\\

## Next Steps

- Monitor GitHub Actions for each deployment
- Review plan output before pushing to main
- Add manual approval step for production (advanced)
- Setup remote state backend (S3, Azure Blob, etc.)
- Add cost estimation to plan output

## Status

✅ Day 11: Terraform CI/CD Integration - Complete
⏳ Day 12: Final demo and Week 2 summary - Next
