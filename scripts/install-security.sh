#!/usr/bin/env bash
# Aplica hardening de seguridad: NetworkPolicies + PodSecurityStandards labels.
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Etiquetando namespaces con Pod Security Standards..."
kubectl apply -f "${BASE_DIR}/kubernetes/security/pod-security/labels.yaml"

echo "==> Aplicando NetworkPolicies..."
kubectl apply -k "${BASE_DIR}/kubernetes/security/network-policies/"

echo ""
echo "Verificacion:"
kubectl get networkpolicies -A
echo ""
kubectl get ns mobilebank-staging mobilebank-production -o jsonpath='{range .items[*]}{.metadata.name}: {.metadata.labels.pod-security\.kubernetes\.io/enforce}{"\n"}{end}'

echo ""
echo "Probar isolation (debe FALLAR):"
echo "  kubectl run -n mobilebank-staging test --rm -it --image=busybox -- wget -T 3 http://google.com"
echo "Probar permitido (debe pasar):"
echo "  kubectl run -n mobilebank-staging test --rm -it --image=busybox -- nslookup kubernetes.default"
