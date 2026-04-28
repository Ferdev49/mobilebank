# Production environment - uses production.tfvars for variables
module "mobilebank_production" {
  source = "./modules/kubernetes-app"

  # All variables come from production.tfvars
  app_name             = var.app_name
  namespace            = var.namespace
  environment          = var.environment
  replicas             = var.replicas
  image                = var.image
  port                 = var.port
  cpu_request          = var.cpu_request
  memory_request       = var.memory_request
  cpu_limit            = var.cpu_limit
  memory_limit         = var.memory_limit
  enable_health_checks = var.enable_health_checks
  health_check_path    = var.health_check_path
  labels               = var.labels
}
