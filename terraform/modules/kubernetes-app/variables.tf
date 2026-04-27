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
  description = "Number of pod replicas"
  type        = number
  default     = 2
  validation {
    condition     = var.replicas > 0 && var.replicas <= 10
    error_message = "Replicas must be between 1 and 10."
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
  description = "Enable liveness and readiness probes"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check endpoint"
  type        = string
  default     = "/health"
}

variable "labels" {
  description = "Additional labels"
  type        = map(string)
  default     = {}
}
