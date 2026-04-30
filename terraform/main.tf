# Consolidate both environments in main.tf
module "mobilebank_staging" {
  source = "./modules/kubernetes-app"

  app_name             = "mobilebank-api"
  namespace            = "mobilebank-staging"
  environment          = "staging"
  replicas             = 2
  image                = "ferdev49/mobilebank-api:latest"
  port                 = 5000
  cpu_request          = "100m"
  memory_request       = "128Mi"
  cpu_limit            = "250m"
  memory_limit         = "256Mi"
  enable_health_checks = true
  health_check_path    = "/health"
  labels = {
    "tier"         = "staging"
    "cost-center"  = "development"
  }
}

module "mobilebank_production" {
  source = "./modules/kubernetes-app"

  app_name             = "mobilebank-api"
  namespace            = "mobilebank-production"
  environment          = "production"
  replicas             = 3
  image                = "ferdev49/mobilebank-api:latest"
  port                 = 5000
  cpu_request          = "200m"
  memory_request       = "256Mi"
  cpu_limit            = "500m"
  memory_limit         = "512Mi"
  enable_health_checks = true
  health_check_path    = "/health"
  labels = {
    "tier"         = "production"
    "cost-center"  = "operations"
  }
}
