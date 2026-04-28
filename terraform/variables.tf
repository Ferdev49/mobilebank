# Root variables - used by staging.tf and production.tf
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
}

variable "replicas" {
  description = "Number of pod replicas"
  type        = number
}

variable "image" {
  description = "Docker image URI"
  type        = string
}

variable "port" {
  description = "Container port"
  type        = number
}

variable "cpu_request" {
  description = "CPU request per pod"
  type        = string
}

variable "memory_request" {
  description = "Memory request per pod"
  type        = string
}

variable "cpu_limit" {
  description = "CPU limit per pod"
  type        = string
}

variable "memory_limit" {
  description = "Memory limit per pod"
  type        = string
}

variable "enable_health_checks" {
  description = "Enable liveness and readiness probes"
  type        = bool
}

variable "health_check_path" {
  description = "Health check endpoint"
  type        = string
}

variable "labels" {
  description = "Additional labels"
  type        = map(string)
}
