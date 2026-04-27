# Production environment configuration
module "mobilebank_production" {
  source = "./modules/kubernetes-app"

  app_name  = "mobilebank-api"
  namespace = "mobilebank-production"
  environment = "production"
  
  # Production: more replicas (high availability)
  replicas = 3
  image    = "ferdev49/mobilebank-api:latest"
  port     = 5000

  # Production: more resources (reliability)
  cpu_request    = "200m"
  memory_request = "256Mi"
  cpu_limit      = "500m"
  memory_limit   = "512Mi"

  enable_health_checks = true
  health_check_path    = "/health"

  labels = {
    "tier" = "production"
    "cost-center" = "operations"
    "sla" = "99-9-percent"
  }
}
