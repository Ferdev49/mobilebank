#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "==> Aplicando Grafana..."
kubectl apply -k "${BASE_DIR}/kubernetes/observability/grafana/"
kubectl -n observability rollout status deployment/grafana --timeout=180s
echo ""
echo "OK. Acceso:"
echo "  kubectl -n observability port-forward svc/grafana 3000:3000"
echo "  -> http://localhost:3000  (admin / admin)"
echo ""
echo "O via Ingress (mapear en /etc/hosts):"
echo "  127.0.0.1  grafana.mobilebank.local"
