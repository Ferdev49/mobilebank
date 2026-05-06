#!/usr/bin/env bash
# Prueba endpoints via Ingress.
# Requiere /etc/hosts mapeado:
#   127.0.0.1 staging.mobilebank.local api.mobilebank.local
set -euo pipefail

HOSTS=("staging.mobilebank.local" "api.mobilebank.local")
PATHS=("/health" "/health/live" "/health/ready" "/api/accounts" "/metrics")

for host in "${HOSTS[@]}"; do
  echo ""
  echo "=== ${host} ==="
  for path in "${PATHS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: ${host}" "http://localhost${path}" || echo "000")
    echo "  ${path}  ->  HTTP ${code}"
  done
done
