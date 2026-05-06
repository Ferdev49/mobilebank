# ConfigMap con configuracion no-sensible (Week 3 - Day 14)
resource "kubernetes_config_map" "app" {
  metadata {
    name      = "${var.app_name}-config"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = local.common_labels
  }

  data = merge(
    {
      ENVIRONMENT              = var.environment
      LOG_LEVEL                = var.log_level
      PORT                     = tostring(var.port)
      DEBUG                    = tostring(var.debug)
      FEATURE_TRANSFER_ENABLED = tostring(var.feature_transfer_enabled)
      FEATURE_METRICS_ENABLED  = tostring(var.feature_metrics_enabled)
      MAX_TRANSFER_AMOUNT      = tostring(var.max_transfer_amount)
      HEALTH_CHECK_PATH        = var.health_check_path
    },
    var.extra_config
  )
}
