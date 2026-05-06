#!/usr/bin/env bash
# Despliega Week 3 con Kustomize (overlays staging/production)
# Uso: ./scripts/deploy-week3.sh [staging|production|both]
set -euo pipefail

ENV="${1:-both}"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

deploy() {
  local env="$1"
  echo ""
  echo "=== Desplegando overlay/${env} ==="
  kubectl apply -k "${BASE_DIR}/kubernetes/overlays/${env}/"
  echo ""
  echo "Esperando rollout en mobilebank-${env}..."
  kubectl -n "mobilebank-${env}" rollout status deployment/mobilebank-api --timeout=180s
  echo ""
  echo "Recursos en mobilebank-${env}:"
  kubectl -n "mobilebank-${env}" get all,ingress,configmap,secret,pvc,hpa
}

case "$ENV" in
  staging|production)
    deploy "$ENV"
    ;;
  both)
    deploy staging
    deploy production
    ;;
  *)
    echo "Uso: $0 [staging|production|both]"
    exit 1
    ;;
esac

echo ""
echo "OK Despliegue completado."
