# ====================================================================
# Variables raiz - usadas cuando se aplica con un .tfvars especifico
# por environment (terraform apply -var-file=environments/staging.tfvars)
# ====================================================================

# ---- Basics ----
variable "app_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "environment" {
  type = string
}

variable "replicas" {
  type = number
}

variable "image" {
  type = string
}

variable "port" {
  type = number
}

variable "cpu_request" {
  type = string
}

variable "memory_request" {
  type = string
}

variable "cpu_limit" {
  type = string
}

variable "memory_limit" {
  type = string
}

variable "enable_health_checks" {
  type = bool
}

variable "health_check_path" {
  type = string
}

variable "labels" {
  type = map(string)
}

# ---- ConfigMap (Week 3) ----
variable "log_level" {
  type    = string
  default = "INFO"
}

variable "debug" {
  type    = bool
  default = false
}

variable "feature_transfer_enabled" {
  type    = bool
  default = true
}

variable "feature_metrics_enabled" {
  type    = bool
  default = true
}

variable "max_transfer_amount" {
  type    = number
  default = 10000
}

# ---- Secrets (Week 3) ----
variable "api_key" {
  type      = string
  sensitive = true
  default   = "demo-api-key-change-me"
}

variable "jwt_secret" {
  type      = string
  sensitive = true
  default   = "demo-jwt-secret-change-me"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "demo-db-password"
}

# ---- HPA (Week 3) ----
variable "enable_hpa" {
  type    = bool
  default = true
}

variable "hpa_min_replicas" {
  type    = number
  default = 2
}

variable "hpa_max_replicas" {
  type    = number
  default = 10
}

variable "hpa_cpu_target" {
  type    = number
  default = 70
}

variable "hpa_memory_target" {
  type    = number
  default = 80
}

# ---- PVC (Week 3) ----
variable "enable_persistence" {
  type    = bool
  default = true
}

variable "storage_size" {
  type    = string
  default = "1Gi"
}

variable "storage_class" {
  type    = string
  default = ""
}

# ---- Ingress (Week 3) ----
variable "enable_ingress" {
  type    = bool
  default = true
}

variable "ingress_host" {
  type    = string
  default = "mobilebank.local"
}

variable "ingress_rate_limit_rps" {
  type    = number
  default = 20
}

# ---- Service ----
variable "service_type" {
  type    = string
  default = "ClusterIP"
}

# ---- TLS (Week 5 - Day 23) ----
variable "enable_tls" {
  type    = bool
  default = true
}

variable "tls_cluster_issuer" {
  type    = string
  default = "mobilebank-ca-issuer"
}

variable "tls_secret_name" {
  type    = string
  default = ""
}
