# Production Environment Variables
app_name  = "mobilebank-api"
namespace = "mobilebank-production"
environment = "production"
replicas = 3
image    = "ferdev49/mobilebank-api:latest"
port     = 5000

# Production: more resources (reliability)
cpu_request    = "200m"
memory_request = "256Mi"
cpu_limit      = "500m"
memory_limit   = "512Mi"

# Health checks enabled
enable_health_checks = true
health_check_path    = "/health"

# Labels for production
labels = {
  "tier"         = "production"
  "cost-center"  = "operations"
  "managed-by"   = "terraform"
  "environment"  = "production"
}
