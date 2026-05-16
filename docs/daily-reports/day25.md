# Daily Report - Day 25 (Week 5)
**Fecha:** Mar 12 may (recuperado 13 may)
**Tema:** Network Policies + Pod Security Standards
**Status:** Completado

## Lo hecho
### Network Policies (4 archivos en `kubernetes/security/network-policies/`)
- default-deny.yaml: deny ALL ingress+egress en mobilebank-staging y mobilebank-production.
- allow-ingress.yaml: permite scrape desde observability + trafico desde ingress-nginx al puerto 5000.
- allow-egress.yaml: permite DNS, mismo-ns y observability como destinos.
- observability.yaml: prometheus egress libre, promtail solo a loki+DNS.
- kustomization.yaml.

### Pod Security Standards
- `kubernetes/security/pod-security/labels.yaml`:
  - staging: enforce=baseline, warn/audit=restricted.
  - production: enforce=restricted.

### Hardening de la app
- `kubernetes/base/deployment.yaml`:
  - pod-level securityContext: runAsNonRoot, uid 1000, fsGroup, seccomp RuntimeDefault.
  - container-level: drop ALL caps, no priv escalation, readOnlyRootFilesystem.
  - emptyDir tmp en /tmp para gunicorn.
- `mobilebank-app/Dockerfile`: crea user 1000, chown /app, USER 1000.
- `terraform/modules/kubernetes-app/main.tf`: security_context pod y container.

### Script + docs
- scripts/install-security.sh
- docs/security-network-policies-pss.md
- docs/daily-reports/day25.md

## Validacion offline
- 5 NetworkPolicy YAMLs OK
- 1 PSS labels YAML OK
- deployment.yaml YAML OK + readonly-root + non-root
- Dockerfile sintactico OK
- Terraform module: braces balanceadas, security_context insertado

## Estado al cierre del catch-up (13 may, 7 dias en una sesion)
- Week 4 completa: Days 18-22
- Week 5 completa: Days 23-25

## Pendiente para tu cluster
1. Rebuild image con el nuevo Dockerfile (cambia user a 1000): `docker build -t ferdev49/mobilebank-api:latest mobilebank-app/`
2. Push: `docker push ferdev49/mobilebank-api:latest`
3. Aplicar todo: `./scripts/install-security.sh`
4. Probar isolation con los curl/nslookup del doc.
