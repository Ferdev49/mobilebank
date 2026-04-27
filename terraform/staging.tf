# Staging environment configuration
module "mobilebank_staging" {
  source = "./modules/kubernetes-app"

  app_name  = "mobilebank-api"
  namespace = "mobilebank-staging"
  environment = "staging"
  
  # Staging: fewer replicas (cost saving)
  replicas = 2
  image    = "ferdev49/mobilebank-api:latest"
  port     = 5000

  # Staging: less resources needed
  cpu_request    = "100m"
  memory_request = "128Mi"
  cpu_limit      = "250m"
  memory_limit   = "256Mi"

  enable_health_checks = true
  health_check_path    = "/health"

  labels = {
    "tier" = "staging"
    "cost-center" = "development"
  }
}
