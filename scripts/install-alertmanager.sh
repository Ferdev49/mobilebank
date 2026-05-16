#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "==> Aplicando reglas y Alertmanager..."
kubectl apply -k "${BASE_DIR}/kubernetes/observability/alertmanager/"
kubectl -n observability rollout status deployment/alertmanager --timeout=120s
kubectl -n observability rollout status deployment/webhook-receiver --timeout=120s

echo "==> Refrescando Prometheus (re-aplicar config y reload)..."
kubectl apply -k "${BASE_DIR}/kubernetes/observability/prometheus/"
kubectl -n observability rollout restart deployment/prometheus

echo ""
echo "UIs:"
echo "  kubectl -n observability port-forward svc/alertmanager 9093:9093"
echo "  kubectl -n observability port-forward svc/prometheus 9090:9090"
