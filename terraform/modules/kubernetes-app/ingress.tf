# Ingress NGINX (Week 3 - Day 13)
# Requiere NGINX Ingress Controller instalado en el cluster.
resource "kubernetes_ingress_v1" "app" {
  count = var.enable_ingress ? 1 : 0

  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = local.common_labels
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target"     = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "false"
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "1m"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "30"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "30"
      "nginx.ingress.kubernetes.io/limit-rps"          = tostring(var.ingress_rate_limit_rps)
      "nginx.ingress.kubernetes.io/limit-connections"  = "10"
    }
  }

  spec {
    ingress_class_name = "nginx"

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
