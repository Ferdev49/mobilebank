variable "app_name" {
  description = "Application name"
  type        = string
  default     = "mobilebank-api"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "mobilebank"
}

variable "replicas" {
  description = "Number of pod replicas"
  type        = number
  default     = 2
}

variable "image" {
  description = "Docker image URI"
  type        = string
  default     = "ferdev49/mobilebank-api:latest"
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
