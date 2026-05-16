#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VERSION="v0.27.1"
echo "==> Instalando sealed-secrets controller ${VERSION}..."
kubectl apply -f "https://github.com/bitnami-labs/sealed-secrets/releases/download/${VERSION}/controller.yaml"

echo "==> Esperando rollout..."
kubectl -n kube-system rollout status deployment/sealed-secrets-controller --timeout=180s

echo ""
echo "==> Descargando kubeseal CLI..."
if ! command -v kubeseal >/dev/null 2>&1; then
  echo "  kubeseal no instalado. Instala con:"
  echo "    Linux:   wget https://github.com/bitnami-labs/sealed-secrets/releases/download/${VERSION}/kubeseal-${VERSION#v}-linux-amd64.tar.gz"
  echo "    Mac:     brew install kubeseal"
  echo "    Windows: choco install kubeseal"
fi

echo ""
echo "==> Exportando clave publica del controller..."
kubeseal --fetch-cert > "${BASE_DIR}/kubernetes/security/sealed-secrets/pub-cert.pem" 2>/dev/null \
  && echo "  Guardado en kubernetes/security/sealed-secrets/pub-cert.pem" \
  || echo "  (Instala kubeseal primero y vuelve a correr)"

echo ""
echo "Para sellar un Secret existente:"
echo "  kubeseal -f kubernetes/base/secret.yaml -w kubernetes/base/sealed-secret.yaml"
echo ""
echo "Para sellar inline:"
echo "  kubectl create secret generic mysec --from-literal=k=v --dry-run=client -o yaml | kubeseal -o yaml"
