# Staging Environment Variables
app_name  = "mobilebank-api"
namespace = "mobilebank-staging"
environment = "staging"
replicas = 2
image    = "ferdev49/mobilebank-api:latest"
port     = 5000

# Staging: less resources (cost saving)
cpu_request    = "100m"
memory_request = "128Mi"
cpu_limit      = "250m"
memory_limit   = "256Mi"

# Health checks enabled
enable_health_checks = true
health_check_path    = "/health"

# Labels for staging
labels = {
  "tier"         = "staging"
  "cost-center"  = "development"
  "managed-by"   = "terraform"
  "environment"  = "staging"
}
