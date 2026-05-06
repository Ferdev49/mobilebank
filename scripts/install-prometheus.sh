#!/usr/bin/env bash
# Instala Prometheus standalone (sin operator) en el namespace observability.
# Para Docker Desktop / Minikube / Kind.
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Aplicando manifiestos de Prometheus..."
kubectl apply -k "${BASE_DIR}/kubernetes/observability/prometheus/"

echo ""
echo "==> Esperando rollout..."
kubectl -n observability rollout status deployment/prometheus --timeout=180s

echo ""
echo "==> Recursos en observability:"
kubectl -n observability get all,pvc,ingress

echo ""
echo "OK Prometheus instalado."
echo ""
echo "Acceso al UI:"
echo "  Opcion 1 - port-forward (rapido, sin tocar /etc/hosts):"
echo "    kubectl -n observability port-forward svc/prometheus 9090:9090"
echo "    Luego abre: http://localhost:9090"
echo ""
echo "  Opcion 2 - via Ingress (necesitas el host en /etc/hosts):"
echo "    127.0.0.1  prometheus.mobilebank.local"
echo "    Luego abre: http://prometheus.mobilebank.local"
