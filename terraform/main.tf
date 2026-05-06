# ====================================================================
# Despliegue multi-environment (Week 2-3)
# Week 3 agrega: ConfigMap, Secret, Ingress, HPA, PVC
# ====================================================================

module "mobilebank_staging" {
  source = "./modules/kubernetes-app"

  # Basics
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
  service_type         = "ClusterIP"

  # ConfigMap (Day 14)
  log_level                = "DEBUG"
  debug                    = false
  feature_transfer_enabled = true
  feature_metrics_enabled  = true
  max_transfer_amount      = 5000

  # HPA (Day 15)
  enable_hpa        = true
  hpa_min_replicas  = 2
  hpa_max_replicas  = 5
  hpa_cpu_target    = 70
  hpa_memory_target = 80

  # PVC (Day 16)
  enable_persistence = true
  storage_size       = "1Gi"

  # Ingress (Day 13)
  enable_ingress         = true
  ingress_host           = "staging.mobilebank.local"
  ingress_rate_limit_rps = 20

  labels = {
    "tier"        = "staging"
    "cost-center" = "development"
  }
}

module "mobilebank_production" {
  source = "./modules/kubernetes-app"

  # Basics
  app_name             = "mobilebank-api"
  namespace            = "mobilebank-production"
  environment          = "production"
  replicas             = 3
  image                = "ferdev49/mobilebank-api:latest"
  port                 = 5000
  cpu_request          = "200m"
  memory_request       = "256Mi"
  cpu_limit            = "1000m"
  memory_limit         = "1Gi"
  enable_health_checks = true
  health_check_path    = "/health"
  service_type         = "ClusterIP"

  # ConfigMap (Day 14)
  log_level                = "INFO"
  debug                    = false
  feature_transfer_enabled = true
  feature_metrics_enabled  = true
  max_transfer_amount      = 50000

  # HPA (Day 15) - production mas agresivo
  enable_hpa        = true
  hpa_min_replicas  = 3
  hpa_max_replicas  = 10
  hpa_cpu_target    = 60
  hpa_memory_target = 75

  # PVC (Day 16) - production mas storage
  enable_persistence = true
  storage_size       = "5Gi"

  # Ingress (Day 13)
  enable_ingress         = true
  ingress_host           = "api.mobilebank.local"
  ingress_rate_limit_rps = 100

  labels = {
    "tier"        = "production"
    "cost-center" = "operations"
  }
}

# ---- Outputs consolidados ----
output "staging" {
  description = "Resumen del environment de staging"
  value       = module.mobilebank_staging.summary
}

output "production" {
  description = "Resumen del environment de production"
  value       = module.mobilebank_production.summary
}
