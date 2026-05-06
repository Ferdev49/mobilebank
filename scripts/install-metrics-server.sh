#!/usr/bin/env bash
# Instala metrics-server (necesario para HPA) en clusters locales.
# En Docker Desktop / Minikube TLS no esta listo: usamos --kubelet-insecure-tls.
set -euo pipefail

echo "Instalando metrics-server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.1/components.yaml

echo "Parchando deployment con --kubelet-insecure-tls (entornos locales)..."
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' \
  || echo "patch ya aplicado (o falla esperada en un cluster gestionado)."

echo "Esperando a que metrics-server este listo..."
kubectl wait --namespace kube-system \
  --for=condition=ready pod \
  --selector=k8s-app=metrics-server \
  --timeout=180s

echo "OK metrics-server listo. Prueba con: kubectl top pods -A"
