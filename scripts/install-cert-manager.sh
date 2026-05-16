#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Instalando cert-manager v1.15.3..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.3/cert-manager.yaml

echo "==> Esperando rollout..."
kubectl -n cert-manager rollout status deployment/cert-manager --timeout=180s
kubectl -n cert-manager rollout status deployment/cert-manager-webhook --timeout=180s
kubectl -n cert-manager rollout status deployment/cert-manager-cainjector --timeout=180s

echo "==> Aplicando ClusterIssuers + CA root..."
kubectl apply -k "${BASE_DIR}/kubernetes/security/cert-manager/"

echo ""
echo "Verificacion:"
kubectl get clusterissuer
kubectl get certificate -A
