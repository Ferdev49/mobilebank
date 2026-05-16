# Ingress NGINX con TLS via cert-manager (Week 5 - Day 23)
resource "kubernetes_ingress_v1" "app" {
  count = var.enable_ingress ? 1 : 0

  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = local.common_labels
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target"     = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "1m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "30"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "30"
      "nginx.ingress.kubernetes.io/limit-rps"          = tostring(var.ingress_rate_limit_rps)
      "nginx.ingress.kubernetes.io/limit-connections"  = "10"
      "cert-manager.io/cluster-issuer"                 = var.tls_cluster_issuer
    }
  }

  spec {
    ingress_class_name = "nginx"

    dynamic "tls" {
      for_each = var.enable_tls ? [1] : []
      content {
        hosts       = [var.ingress_host]
        secret_name = var.tls_secret_name != "" ? var.tls_secret_name : "${var.app_name}-tls"
      }
    }

    rule {
      host = var.ingress_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.app.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
