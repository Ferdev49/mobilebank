output "namespace" {
  description = "Kubernetes namespace name"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "deployment_name" {
  description = "Deployment name"
  value       = kubernetes_deployment.app.metadata[0].name
}

output "service_name" {
  description = "Service name"
  value       = kubernetes_service.app.metadata[0].name
}

output "service_ip" {
  description = "Service cluster IP"
  value       = kubernetes_service.app.spec[0].cluster_ip
}

output "service_port" {
  description = "Service port"
  value       = kubernetes_service.app.spec[0].port[0].port
}

output "load_balancer_ip" {
  description = "LoadBalancer external IP"
  value       = try(kubernetes_service.app.status[0].load_balancer[0].ingress[0].ip, "pending")
}

output "replicas" {
  description = "Number of replicas"
  value       = var.replicas
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}
