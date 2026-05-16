#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "==> Loki..."
kubectl apply -k "${BASE_DIR}/kubernetes/observability/loki/"
kubectl -n observability rollout status statefulset/loki --timeout=180s
echo ""
echo "==> Promtail..."
kubectl apply -k "${BASE_DIR}/kubernetes/observability/promtail/"
echo ""
echo "==> Re-aplicar Grafana datasources..."
kubectl apply -k "${BASE_DIR}/kubernetes/observability/grafana/"
kubectl -n observability rollout restart deployment/grafana
echo ""
echo "OK. En Grafana, datasource 'Loki' apuntara a http://loki:3100"
echo "Probar con LogQL: { namespace=\"mobilebank-staging\" }"
