#!/usr/bin/env bash
# Convierte cada Secret existente en un SealedSecret cifrado y commiteable.
# Pre-requisito: kubeseal instalado y sealed-secrets controller corriendo.
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

seal() {
  local in="$1"
  local out="$2"
  echo "  Sellando $in -> $out"
  kubeseal --controller-namespace=kube-system \
           --controller-name=sealed-secrets-controller \
           -f "$in" -w "$out" -o yaml
}

echo "==> Sellando Secrets..."
seal "${BASE_DIR}/kubernetes/base/secret.yaml" \
     "${BASE_DIR}/kubernetes/base/sealed-secret.yaml"

seal "${BASE_DIR}/kubernetes/observability/grafana/secret.yaml" \
     "${BASE_DIR}/kubernetes/observability/grafana/sealed-secret.yaml"

echo ""
echo "Listo. Ahora puedes:"
echo "  1) Cambiar kustomization.yaml para usar sealed-secret.yaml en lugar de secret.yaml"
echo "  2) Commitear el sealed-secret.yaml al repo (esta cifrado, no expone valores)"
echo "  3) Borrar el secret.yaml original o moverlo fuera del repo"
