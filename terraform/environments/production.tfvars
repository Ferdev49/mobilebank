# ===== Production Environment Variables (Week 3) =====
app_name    = "mobilebank-api"
namespace   = "mobilebank-production"
environment = "production"
replicas    = 3
image       = "ferdev49/mobilebank-api:latest"
port        = 5000

# Resources (reliability)
cpu_request    = "200m"
memory_request = "256Mi"
cpu_limit      = "1000m"
memory_limit   = "1Gi"

# Health
enable_health_checks = true
health_check_path    = "/health"
service_type         = "ClusterIP"

# ConfigMap
log_level                = "INFO"
debug                    = false
feature_transfer_enabled = true
feature_metrics_enabled  = true
max_transfer_amount      = 50000

# HPA - mas agresivo
enable_hpa        = true
hpa_min_replicas  = 3
hpa_max_replicas  = 10
hpa_cpu_target    = 60
hpa_memory_target = 75

# PVC - mas storage
enable_persistence = true
storage_size       = "5Gi"

# Ingress
enable_ingress         = true
ingress_host           = "api.mobilebank.local"
ingress_rate_limit_rps = 100

# Labels
labels = {
  "tier"         = "production"
  "cost-center"  = "operations"
  "managed-by"   = "terraform"
  "environment"  = "production"
}
