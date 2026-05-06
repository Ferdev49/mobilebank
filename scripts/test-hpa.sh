#!/usr/bin/env bash
# Genera carga sintetica para validar autoscaling.
# Uso: ./scripts/test-hpa.sh [staging|production] [duracion_segundos]
set -euo pipefail

ENV="${1:-staging}"
DURATION="${2:-180}"
NAMESPACE="mobilebank-${ENV}"

if [[ "$ENV" == "staging" ]]; then
  HOST="staging.mobilebank.local"
else
  HOST="api.mobilebank.local"
fi

echo "Lanzando carga contra ${HOST} por ${DURATION}s..."
echo "En otra terminal monitorea con:"
echo "  kubectl -n ${NAMESPACE} get hpa -w"
echo "  kubectl -n ${NAMESPACE} get pods -w"
echo ""

# Lanza 50 workers en paralelo haciendo curl
END=$((SECONDS + DURATION))
PIDS=()
for i in $(seq 1 50); do
  ( while [[ $SECONDS -lt $END ]]; do
      curl -s -o /dev/null -H "Host: ${HOST}" "http://localhost/api/accounts" || true
    done ) &
  PIDS+=($!)
done

# Esperar que terminen
for pid in "${PIDS[@]}"; do
  wait "$pid" 2>/dev/null || true
done

echo ""
echo "OK Carga finalizada. Revisa el HPA:"
kubectl -n "${NAMESPACE}" get hpa
echo ""
kubectl -n "${NAMESPACE}" get pods
