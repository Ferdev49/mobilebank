#!/usr/bin/env bash
# Instala NGINX Ingress Controller en el cluster local (Docker Desktop / Minikube / Kind)
# Uso: ./scripts/install-ingress.sh
set -euo pipefail

echo "Instalando NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml

echo "Esperando a que el controller este listo..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo ""
echo "OK Ingress Controller listo."
echo "Verifica con: kubectl get pods -n ingress-nginx"
echo ""
echo "Para resolver hosts locales agrega a /etc/hosts (o C:\\Windows\\System32\\drivers\\etc\\hosts):"
echo "  127.0.0.1  staging.mobilebank.local"
echo "  127.0.0.1  api.mobilebank.local"
