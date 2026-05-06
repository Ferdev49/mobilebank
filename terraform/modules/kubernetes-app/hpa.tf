# Horizontal Pod Autoscaler (Week 3 - Day 15)
# Requiere metrics-server en el cluster.
resource "kubernetes_horizontal_pod_autoscaler_v2" "app" {
  count = var.enable_hpa ? 1 : 0

  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.app.metadata[0].name
    }

    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.hpa_cpu_target
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = var.hpa_memory_target
        }
      }
    }

    behavior {
      scale_up {
        stabilization_window_seconds = 30
        select_policy                = "Max"
        policy {
          type           = "Percent"
          value          = 100
          period_seconds = 30
        }
        policy {
          type           = "Pods"
          value          = 2
          period_seconds = 30
        }
      }
      scale_down {
        stabilization_window_seconds = 300
        select_policy                = "Min"
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 60
        }
      }
    }
  }
}
