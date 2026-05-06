# PersistentVolumeClaim para datos persistentes (Week 3 - Day 16)
resource "kubernetes_persistent_volume_claim" "app" {
  count = var.enable_persistence ? 1 : 0

  metadata {
    name      = "${var.app_name}-data"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.storage_size
      }
    }

    storage_class_name = var.storage_class != "" ? var.storage_class : null
  }

  # Esperar a que el PVC se cree antes de crear el deployment
  wait_until_bound = false
}
