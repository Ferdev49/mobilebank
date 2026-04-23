# Crear namespace
resource "kubernetes_namespace" "mobilebank" {
  metadata {
    name = var.namespace
  }
}

# Crear Deployment
resource "kubernetes_deployment" "mobilebank_api" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.mobilebank.metadata[0].name
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          image = var.image
          name  = var.app_name
          port {
            container_port = var.port
          }

          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = var.port
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = var.port
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.mobilebank]
}

# Crear Service (LoadBalancer)
resource "kubernetes_service" "mobilebank_api" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.mobilebank.metadata[0].name
    labels = {
      app = var.app_name
    }
  }

  spec {
    selector = {
      app = var.app_name
    }

    type = "LoadBalancer"

    port {
      port        = 80
      target_port = var.port
      protocol    = "TCP"
      name        = "http"
    }
  }

  depends_on = [kubernetes_deployment.mobilebank_api]
}
