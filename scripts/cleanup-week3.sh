#!/usr/bin/env bash
# Limpia recursos de la Week 3
set -euo pipefail

echo "Eliminando overlays..."
kubectl delete -k kubernetes/overlays/staging/ --ignore-not-found=true || true
kubectl delete -k kubernetes/overlays/production/ --ignore-not-found=true || true

echo "Borrando namespaces (catch-all)..."
kubectl delete namespace mobilebank-staging --ignore-not-found=true
kubectl delete namespace mobilebank-production --ignore-not-found=true
kubectl delete namespace mobilebank --ignore-not-found=true

echo "OK Cleanup completo."
