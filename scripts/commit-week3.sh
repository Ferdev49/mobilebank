#!/usr/bin/env bash
# Commit Week 3 - ejecutar desde Git Bash o WSL en la raiz del repo.
# Solo agrega los archivos que Claude modifico/creo para Week 3.
# NO toca .github/workflows ni archivos no relacionados.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Limpiando lock si existe..."
rm -f .git/index.lock || true

echo "==> Configurando identidad para este commit..."
git config user.name "Ferdev49"
git config user.email "fercho00.fb@gmail.com"

echo "==> Staging archivos de Week 3..."

# K8s base
git add kubernetes/base/deployment.yaml \
        kubernetes/base/service.yaml \
        kubernetes/base/kustomization.yaml \
        kubernetes/base/configmap.yaml \
        kubernetes/base/secret.yaml \
        kubernetes/base/pvc.yaml \
        kubernetes/base/ingress.yaml \
        kubernetes/base/hpa.yaml

# K8s overlays
git add kubernetes/overlays/

# Terraform modulo
git add terraform/modules/kubernetes-app/main.tf \
        terraform/modules/kubernetes-app/variables.tf \
        terraform/modules/kubernetes-app/outputs.tf \
        terraform/modules/kubernetes-app/configmap.tf \
        terraform/modules/kubernetes-app/secrets.tf \
        terraform/modules/kubernetes-app/pvc.tf \
        terraform/modules/kubernetes-app/hpa.tf \
        terraform/modules/kubernetes-app/ingress.tf

# Terraform raiz
git add terraform/main.tf \
        terraform/variables.tf \
        terraform/providers.tf \
        terraform/environments/staging.tfvars \
        terraform/environments/production.tfvars

# App
git add mobilebank-app/app.py \
        mobilebank-app/requirements.txt

# Scripts
git add scripts/install-ingress.sh \
        scripts/install-metrics-server.sh \
        scripts/deploy-week3.sh \
        scripts/test-ingress.sh \
        scripts/test-hpa.sh \
        scripts/validate-week3.sh \
        scripts/cleanup-week3.sh \
        scripts/commit-week3.sh

# Docs Week 3
git add docs/week3-roadmap.md \
        docs/week3-summary.md \
        docs/kubernetes-ingress.md \
        docs/kubernetes-configmaps-secrets.md \
        docs/kubernetes-hpa.md \
        docs/kubernetes-persistent-volumes.md \
        docs/architecture.md \
        README.md

echo ""
echo "==> Resumen de lo que se va a commitear:"
git diff --cached --stat
echo ""
echo "Total archivos staged: $(git diff --cached --name-only | wc -l)"
echo ""

read -rp "Proceder con el commit? [y/N] " yn
case "$yn" in
  [Yy]*) ;;
  *) echo "Cancelado. Revisa con 'git status' o 'git diff --cached'."; exit 0 ;;
esac

git commit -m "feat(week3): Advanced Kubernetes - Ingress, ConfigMap/Secret, HPA, PVC

Day 13: NGINX Ingress Controller con rate limiting y hostname routing
  - kubernetes/base/ingress.yaml (host-based routing, rate limit 20rps)
  - terraform module ingress.tf con variables enable_ingress/host/rps
  - Service base cambiado de LoadBalancer a ClusterIP
  - scripts/install-ingress.sh

Day 14: ConfigMap + Secret externalizados
  - mobilebank-config: ENVIRONMENT, LOG_LEVEL, feature flags, MAX_TRANSFER_AMOUNT
  - mobilebank-secrets: API_KEY, JWT_SECRET, DB_PASSWORD (demo en base64)
  - app.py refactor para leer todo via os.getenv()
  - terraform module: configmap.tf, secrets.tf, checksum annotations en pod template

Day 15: HPA + Metrics Server
  - kubernetes/base/hpa.yaml con CPU/memory targets y behavior policies
  - terraform module hpa.tf
  - Deployment con replicas=null cuando HPA esta activo + ignore_changes
  - scripts/install-metrics-server.sh, test-hpa.sh

Day 16: PersistentVolumeClaim
  - kubernetes/base/pvc.yaml con storageClass por defecto
  - terraform module pvc.tf
  - Mount en /app/data, app.py escribe transfers.log y app.log persistentes

Day 17: Documentacion + diagrama
  - docs/week3-roadmap.md, docs/week3-summary.md
  - docs/kubernetes-{ingress,configmaps-secrets,hpa,persistent-volumes}.md
  - docs/architecture.md actualizado con Week 3
  - README.md status Week 3 complete

Adicional:
  - Kustomize overlays/ para staging y production con patches por env
  - 7 scripts de automatizacion (install, deploy, test, validate, cleanup)
  - Fix: gunicorn agregado a requirements.txt (lo usaba el Dockerfile)
"

echo ""
echo "==> Commit creado:"
git log -1 --oneline
echo ""
echo "==> Para hacer push:"
echo "    git push origin main"
