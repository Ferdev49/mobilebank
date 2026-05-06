# ====================================================================
# Outputs del modulo kubernetes-app
# ====================================================================

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

output "service_type" {
  description = "Service type (ClusterIP/NodePort/LoadBalancer)"
  value       = kubernetes_service.app.spec[0].type
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
  description = "LoadBalancer external IP (solo si service_type=LoadBalancer)"
  value       = try(kubernetes_service.app.status[0].load_balancer[0].ingress[0].ip, "n/a")
}

output "replicas" {
  description = "Numero de replicas (base, sin contar HPA)"
  value       = var.replicas
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

# ---- Week 3 outputs ----
output "config_map_name" {
  description = "ConfigMap name (Week 3)"
  value       = kubernetes_config_map.app.metadata[0].name
}

output "secret_name" {
  description = "Secret name (Week 3)"
  value       = kubernetes_secret.app.metadata[0].name
}

output "ingress_host" {
  description = "Ingress hostname (Week 3)"
  value       = var.enable_ingress ? var.ingress_host : "ingress-disabled"
}

output "hpa_enabled" {
  description = "HPA habilitado (Week 3)"
  value       = var.enable_hpa
}

output "hpa_range" {
  description = "Rango min-max de replicas via HPA (Week 3)"
  value       = var.enable_hpa ? "${var.hpa_min_replicas}-${var.hpa_max_replicas}" : "n/a"
}

output "pvc_name" {
  description = "PVC name (Week 3)"
  value       = var.enable_persistence ? kubernetes_persistent_volume_claim.app[0].metadata[0].name : "no-pvc"
}

output "pvc_storage" {
  description = "PVC storage size (Week 3)"
  value       = var.enable_persistence ? var.storage_size : "n/a"
}

output "summary" {
  description = "Resumen de despliegue"
  value = {
    environment      = var.environment
    namespace        = kubernetes_namespace.app.metadata[0].name
    image            = var.image
    base_replicas    = var.replicas
    hpa              = var.enable_hpa ? "${var.hpa_min_replicas}-${var.hpa_max_replicas} pods" : "disabled"
    ingress          = var.enable_ingress ? var.ingress_host : "disabled"
    persistence      = var.enable_persistence ? var.storage_size : "disabled"
    config_map       = kubernetes_config_map.app.metadata[0].name
    secret           = kubernetes_secret.app.metadata[0].name
  }
}
