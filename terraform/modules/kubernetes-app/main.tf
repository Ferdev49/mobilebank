# Crear namespace
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
    labels = merge(
      {
        "app"         = var.app_name
        "environment" = var.environment
        "managed-by"  = "terraform"
      },
      var.labels
    )
  }
}

# Crear Deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = merge(
      {
        "app"         = var.app_name
        "environment" = var.environment
        "managed-by"  = "terraform"
      },
      var.labels
    )
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        "app"         = var.app_name
        "environment" = var.environment
      }
    }

    template {
      metadata {
        labels = merge(
          {
            "app"         = var.app_name
            "environment" = var.environment
          },
          var.labels
        )
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

          dynamic "liveness_probe" {
            for_each = var.enable_health_checks ? [1] : []
            content {
              http_get {
                path = var.health_check_path
                port = var.port
              }
              initial_delay_seconds = 10
              period_seconds        = 10
            }
          }

          dynamic "readiness_probe" {
            for_each = var.enable_health_checks ? [1] : []
            content {
              http_get {
                path = var.health_check_path
                port = var.port
              }
              initial_delay_seconds = 5
              period_seconds        = 5
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.app]
}

# Crear Service (LoadBalancer)
resource "kubernetes_service" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = merge(
      {
        "app"         = var.app_name
        "environment" = var.environment
        "managed-by"  = "terraform"
      },
      var.labels
    )
  }

  spec {
    selector = {
      "app"         = var.app_name
      "environment" = var.environment
    }

    type = "LoadBalancer"

    port {
      port        = 80
      target_port = var.port
      protocol    = "TCP"
      name        = "http"
    }
  }

  depends_on = [kubernetes_deployment.app]
}
