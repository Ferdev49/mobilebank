# ===== Staging Environment Variables (Week 3) =====
app_name    = "mobilebank-api"
namespace   = "mobilebank-staging"
environment = "staging"
replicas    = 2
image       = "ferdev49/mobilebank-api:latest"
port        = 5000

# Resources (cost saving)
cpu_request    = "100m"
memory_request = "128Mi"
cpu_limit      = "250m"
memory_limit   = "256Mi"

# Health
enable_health_checks = true
health_check_path    = "/health"
service_type         = "ClusterIP"

# ConfigMap
log_level                = "DEBUG"
debug                    = false
feature_transfer_enabled = true
feature_metrics_enabled  = true
max_transfer_amount      = 5000

# HPA
enable_hpa        = true
hpa_min_replicas  = 2
hpa_max_replicas  = 5
hpa_cpu_target    = 70
hpa_memory_target = 80

# PVC
enable_persistence = true
storage_size       = "1Gi"

# Ingress
enable_ingress         = true
ingress_host           = "staging.mobilebank.local"
ingress_rate_limit_rps = 20

# Labels
labels = {
  "tier"         = "staging"
  "cost-center"  = "development"
  "managed-by"   = "terraform"
  "environment"  = "staging"
}
