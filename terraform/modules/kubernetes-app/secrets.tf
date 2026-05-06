# Secret con credenciales (Week 3 - Day 14)
# IMPORTANTE: en produccion usar SealedSecrets / External Secrets Operator / Vault.
# Aqui se inyectan los valores via variable sensible (no se commitean).
resource "kubernetes_secret" "app" {
  metadata {
    name      = "${var.app_name}-secrets"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = local.common_labels
  }

  type = "Opaque"

  data = {
    API_KEY     = var.api_key
    JWT_SECRET  = var.jwt_secret
    DB_PASSWORD = var.db_password
  }
}
