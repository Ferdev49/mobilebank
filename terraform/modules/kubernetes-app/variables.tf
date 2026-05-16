# ====================================================================
# Variables del modulo kubernetes-app
# Week 1-2: app, namespace, replicas, recursos, health checks
# Week 3:   ConfigMap, Secret, Ingress, HPA, PVC
# ====================================================================

# ---- App basics (Week 1-2) ----
variable "app_name" {
  description = "Application name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "environment" {
  description = "Environment name (staging, production)"
  type        = string
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be staging or production."
  }
}

variable "replicas" {
  description = "Number of pod replicas (ignorado si enable_hpa = true)"
  type        = number
  default     = 2
  validation {
    condition     = var.replicas > 0 && var.replicas <= 20
    error_message = "Replicas must be between 1 and 20."
  }
}

variable "image" {
  description = "Docker image URI"
  type        = string
}

variable "port" {
  description = "Container port"
  type        = number
  default     = 5000
}

variable "cpu_request" {
  description = "CPU request per pod"
  type        = string
  default     = "100m"
}

variable "memory_request" {
  description = "Memory request per pod"
  type        = string
  default     = "128Mi"
}

variable "cpu_limit" {
  description = "CPU limit per pod"
  type        = string
  default     = "500m"
}

variable "memory_limit" {
  description = "Memory limit per pod"
  type        = string
  default     = "512Mi"
}

variable "enable_health_checks" {
  description = "Enable liveness/readiness/startup probes"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check base path (se sufijaran /live y /ready)"
  type        = string
  default     = "/health"
}

variable "labels" {
  description = "Additional labels"
  type        = map(string)
  default     = {}
}

variable "service_type" {
  description = "Tipo de Service (ClusterIP cuando hay Ingress, LoadBalancer si no)"
  type        = string
  default     = "ClusterIP"
  validation {
    condition     = contains(["ClusterIP", "NodePort", "LoadBalancer"], var.service_type)
    error_message = "service_type debe ser ClusterIP, NodePort o LoadBalancer."
  }
}

# ---- ConfigMap (Week 3 - Day 14) ----
variable "log_level" {
  description = "Nivel de logging"
  type        = string
  default     = "INFO"
  validation {
    condition     = contains(["DEBUG", "INFO", "WARNING", "ERROR"], var.log_level)
    error_message = "log_level debe ser DEBUG, INFO, WARNING o ERROR."
  }
}

variable "debug" {
  description = "Modo debug de Flask"
  type        = bool
  default     = false
}

variable "feature_transfer_enabled" {
  description = "Feature flag: endpoint /api/transfer activo"
  type        = bool
  default     = true
}

variable "feature_metrics_enabled" {
  description = "Feature flag: endpoint /metrics activo"
  type        = bool
  default     = true
}

variable "max_transfer_amount" {
  description = "Monto maximo permitido en una transferencia"
  type        = number
  default     = 10000
}

variable "extra_config" {
  description = "Pares clave/valor extra a agregar al ConfigMap"
  type        = map(string)
  default     = {}
}

# ---- Secrets (Week 3 - Day 14) ----
variable "api_key" {
  description = "API key (sensitive). En produccion usar SealedSecrets/ESO."
  type        = string
  default     = "demo-api-key-change-me"
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT signing secret"
  type        = string
  default     = "demo-jwt-secret-change-me"
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "demo-db-password"
  sensitive   = true
}

# ---- HPA (Week 3 - Day 15) ----
variable "enable_hpa" {
  description = "Crear HorizontalPodAutoscaler (requiere metrics-server)"
  type        = bool
  default     = true
}

variable "hpa_min_replicas" {
  description = "Minimo de replicas para el HPA"
  type        = number
  default     = 2
}

variable "hpa_max_replicas" {
  description = "Maximo de replicas para el HPA"
  type        = number
  default     = 10
}

variable "hpa_cpu_target" {
  description = "Porcentaje objetivo de utilizacion de CPU"
  type        = number
  default     = 70
}

variable "hpa_memory_target" {
  description = "Porcentaje objetivo de utilizacion de memoria"
  type        = number
  default     = 80
}

# ---- PVC (Week 3 - Day 16) ----
variable "enable_persistence" {
  description = "Crear PVC y montarlo en /app/data"
  type        = bool
  default     = true
}

variable "storage_size" {
  description = "Tamano del PVC"
  type        = string
  default     = "1Gi"
}

variable "storage_class" {
  description = "StorageClass a usar (vacio = default del cluster)"
  type        = string
  default     = ""
}

# ---- Ingress (Week 3 - Day 13) ----
variable "enable_ingress" {
  description = "Crear Ingress (requiere NGINX Ingress Controller)"
  type        = bool
  default     = true
}

variable "ingress_host" {
  description = "Hostname del Ingress (ej. api.mobilebank.local)"
  type        = string
  default     = "mobilebank.local"
}

variable "ingress_rate_limit_rps" {
  description = "Rate limit (requests por segundo por IP) en Ingress"
  type        = number
  default     = 20
}

# ---- TLS (Week 5 - Day 23) ----
variable "enable_tls" {
  description = "Habilitar TLS en el Ingress via cert-manager"
  type        = bool
  default     = true
}

variable "tls_cluster_issuer" {
  description = "Nombre del ClusterIssuer de cert-manager"
  type        = string
  default     = "mobilebank-ca-issuer"
}

variable "tls_secret_name" {
  description = "Nombre del Secret donde cert-manager guarda el cert (vacio = autogenerado)"
  type        = string
  default     = ""
}
