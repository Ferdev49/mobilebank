#!/usr/bin/env bash
# Commit Week 5 (Days 23-25) - ejecutar desde Git Bash en la raiz del repo.
set -euo pipefail
cd "$(dirname "$0")/.."

rm -f .git/index.lock || true
git config user.name "Ferdev49"
git config user.email "fercho00.fb@gmail.com"

# ---------- DAY 23 ----------
echo "==> Day 23: cert-manager + TLS"
git add kubernetes/security/cert-manager/ \
        kubernetes/base/ingress.yaml \
        kubernetes/overlays/staging/patches/ingress-host.yaml \
        kubernetes/overlays/production/patches/ingress-host.yaml \
        terraform/modules/kubernetes-app/ingress.tf \
        terraform/modules/kubernetes-app/variables.tf \
        scripts/install-cert-manager.sh \
        docs/security-cert-manager.md \
        docs/daily-reports/day23.md
git commit -m "feat(week5-day23): cert-manager + TLS en Ingress

- Self-signed CA root para lab (no Let's Encrypt sin dominio publico)
- selfsigned-issuer -> mobilebank-ca (Certificate isCA) -> mobilebank-ca-issuer
- Certificates para staging y production: 90d, renew 15d antes
- Ingress base: ssl-redirect=true, TLS block, annotation cert-manager.io/cluster-issuer
- Overlays: patches actualizados con TLS hosts y secret names
- Terraform module: dynamic tls block, variables enable_tls/tls_cluster_issuer/tls_secret_name
- scripts/install-cert-manager.sh (v1.15.3 upstream)
"

# ---------- DAY 24 ----------
echo ""
echo "==> Day 24: Sealed Secrets"
git add scripts/install-sealed-secrets.sh \
        scripts/seal-secrets.sh \
        kubernetes/security/sealed-secrets/ \
        kubernetes/base/sealed-secret.yaml.example \
        kubernetes/observability/grafana/sealed-secret.yaml.example \
        docs/security-sealed-secrets.md \
        docs/daily-reports/day24.md
git commit -m "feat(week5-day24): Sealed Secrets workflow

- scripts/install-sealed-secrets.sh: bitnami-labs controller v0.27.1
- scripts/seal-secrets.sh: kubeseal sobre secret.yaml -> sealed-secret.yaml
- Templates *.yaml.example mostrando estructura SealedSecret
- README + docs con workflow, backup y rotacion de la clave del controller
"

# ---------- DAY 25 ----------
echo ""
echo "==> Day 25: Network Policies + Pod Security Standards"
git add kubernetes/security/network-policies/ \
        kubernetes/security/pod-security/ \
        kubernetes/base/deployment.yaml \
        mobilebank-app/Dockerfile \
        terraform/modules/kubernetes-app/main.tf \
        scripts/install-security.sh \
        docs/security-network-policies-pss.md \
        docs/daily-reports/day25.md
git commit -m "feat(week5-day25): NetworkPolicies + PodSecurityStandards

NetworkPolicies (default-deny + whitelist):
- default-deny-all en mobilebank-staging y production
- allow-app-ingress: solo desde ingress-nginx y observability al puerto 5000
- allow-app-egress: DNS + same-ns + observability
- observability: prometheus egress libre, promtail solo a loki+DNS

Pod Security Standards via labels en namespace:
- staging: enforce=baseline, warn/audit=restricted
- production: enforce=restricted

Hardening del deployment para cumplir restricted:
- runAsNonRoot, uid 1000, fsGroup, seccompProfile RuntimeDefault
- Container: drop ALL caps, no priv escalation, readOnlyRootFilesystem
- emptyDir tmp en /tmp (gunicorn lo necesita)

Dockerfile: crear user 1000, chown /app, USER 1000.
Terraform module: security_context pod + container.
"

echo ""
echo "==> Commits creados (Week 5):"
git log --oneline -3
echo ""
echo "Para subir a GitHub (incluye Week 4 y Week 5):"
echo "  git push origin main"
