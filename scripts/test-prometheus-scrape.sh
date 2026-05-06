#!/usr/bin/env bash
# Verifica que Prometheus este scrappeando correctamente la app MobileBank.
set -euo pipefail

NAMESPACE="${1:-mobilebank-staging}"

echo "==> Verificando que la app expone /metrics..."
POD=$(kubectl -n "${NAMESPACE}" get pod -l app=mobilebank-api -o jsonpath='{.items[0].metadata.name}')
if [[ -z "$POD" ]]; then
  echo "ERROR: no hay pods de mobilebank-api en ${NAMESPACE}"
  exit 1
fi
echo "  Pod: $POD"
kubectl -n "${NAMESPACE}" exec "$POD" -- wget -qO- http://localhost:5000/metrics | head -10

echo ""
echo "==> Verificando que las anotaciones de scrape esten presentes..."
kubectl -n "${NAMESPACE}" get pod "$POD" -o jsonpath='{.metadata.annotations}' | python3 -m json.tool || true

echo ""
echo "==> Consultando Prometheus por targets..."
echo "Hacer port-forward primero (en otra terminal):"
echo "  kubectl -n observability port-forward svc/prometheus 9090:9090"
echo ""
echo "Y luego revisar:"
echo "  http://localhost:9090/targets"
echo "  http://localhost:9090/graph?g0.expr=up{namespace=\"${NAMESPACE}\"}"
