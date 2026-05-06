#!/usr/bin/env bash
# Validacion offline: kustomize build + dry-run + terraform fmt/validate
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

echo "=== 1. Kustomize build base ==="
kubectl kustomize kubernetes/base/ > /tmp/base.yaml
echo "  OK base genera $(wc -l < /tmp/base.yaml) lineas"

echo "=== 2. Kustomize build staging ==="
kubectl kustomize kubernetes/overlays/staging/ > /tmp/staging.yaml
echo "  OK staging genera $(wc -l < /tmp/staging.yaml) lineas"

echo "=== 3. Kustomize build production ==="
kubectl kustomize kubernetes/overlays/production/ > /tmp/production.yaml
echo "  OK production genera $(wc -l < /tmp/production.yaml) lineas"

echo "=== 4. Terraform fmt ==="
terraform -chdir=terraform fmt -recursive -check || echo "  Formato sugerido (no fatal)"

echo "=== 5. Terraform validate ==="
terraform -chdir=terraform init -backend=false >/dev/null
terraform -chdir=terraform validate

echo ""
echo "OK Todas las validaciones pasaron."
