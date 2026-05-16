# Labels comunes (Week 3 - reutilizadas por todos los recursos)
locals {
  common_labels = merge(
    {
      "app"         = var.app_name
      "environment" = var.environment
      "managed-by"  = "terraform"
      "week"        = "3"
    },
    var.labels
  )

  selector_labels = {
    "app"         = var.app_name
    "environment" = var.environment
  }
}

# Crear namespace
resource "kubernetes_namespace" "app" {
  metadata {
    name   = var.namespace
    labels = local.common_labels
  }
}

# Crear Deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    # Si HPA esta habilitado, ignoramos cambios en replicas (HPA las gestiona)
    replicas = var.enable_hpa ? null : var.replicas

    selector {
      match_labels = local.selector_labels
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "25%"
        max_unavailable = "25%"
      }
    }

    template {
      metadata {
        labels = merge(local.selector_labels, var.labels)
        annotations = {
          # Forzar rollout cuando cambien configmap o secret (Week 3 - Day 14)
          "checksum/config" = sha256(jsonencode(kubernetes_config_map.app.data))
          "checksum/secret" = sha256(jsonencode(kubernetes_secret.app.data))
          # Autodiscovery de Prometheus (Week 4 - Day 18)
          "prometheus.io/scrape" = "true"
          "prometheus.io/path"   = "/metrics"
          "prometheus.io/port"   = tostring(var.port)
        }
      }

      spec {
        # Pod Security restricted (Week 5 - Day 25)
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          run_as_group    = 1000
          fs_group        = 1000
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        container {
          image             = var.image
          name              = var.app_name
          image_pull_policy = "IfNotPresent"

          # Container-level security context (Week 5 - Day 25)
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 1000
            capabilities {
              drop = ["ALL"]
            }
          }

          port {
            container_port = var.port
            name           = "http"
          }

          # Inyectar todo el ConfigMap y Secret como variables de entorno (Week 3 - Day 14)
          env_from {
            config_map_ref {
              name = kubernetes_config_map.app.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.app.metadata[0].name
            }
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
                path = "${var.health_check_path}/live"
                port = var.port
              }
              initial_delay_seconds = 10
              period_seconds        = 10
              failure_threshold     = 3
            }
          }

          dynamic "readiness_probe" {
            for_each = var.enable_health_checks ? [1] : []
            content {
              http_get {
                path = "${var.health_check_path}/ready"
                port = var.port
              }
              initial_delay_seconds = 5
              period_seconds        = 5
              failure_threshold     = 2
            }
          }

          dynamic "startup_probe" {
            for_each = var.enable_health_checks ? [1] : []
            content {
              http_get {
                path = "${var.health_check_path}/live"
                port = var.port
              }
              initial_delay_seconds = 0
              period_seconds        = 3
              failure_threshold     = 30
            }
          }

          # Volumen persistente (Week 3 - Day 16)
          dynamic "volume_mount" {
            for_each = var.enable_persistence ? [1] : []
            content {
              name       = "data"
              mount_path = "/app/data"
            }
          }
        }

        # Volumes (Week 3 - Day 16)
        dynamic "volume" {
          for_each = var.enable_persistence ? [1] : []
          content {
            name = "data"
            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.app[0].metadata[0].name
            }
          }
        }
      }
    }
  }

  # Si HPA gestiona replicas, evitar que terraform reescriba en cada apply
  lifecycle {
    ignore_changes = [
      spec[0].replicas,
    ]
  }

  depends_on = [
    kubernetes_namespace.app,
    kubernetes_config_map.app,
    kubernetes_secret.app,
  ]
}

# Service - ClusterIP (el trafico externo entra via Ingress en Week 3)
resource "kubernetes_service" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    selector = local.selector_labels
    type     = var.service_type

    port {
      port        = 80
      target_port = var.port
      protocol    = "TCP"
      name        = "http"
    }
  }

  depends_on = [kubernetes_deployment.app]
}
