# Week 5: Production Hardening - Resumen

## Status: COMPLETO (Days 23-25)

### Day 23 - cert-manager + TLS
Self-signed CA del lab (no Let's Encrypt sin dominio publico). 3 ClusterIssuers + 2 Certificates (staging, production). Ingress base con TLS y `ssl-redirect: true`.

### Day 24 - Sealed Secrets
Bitnami controller v0.27.1 + kubeseal CLI workflow. Scripts para sellar secrets. Templates `.yaml.example`. `.gitignore` actualizado para no commitear secrets en claro.

### Day 25 - NetworkPolicies + PSS
- 4 archivos de NetworkPolicies: default-deny + 3 sets de allow.
- PSS labels en namespaces: staging baseline+warn-restricted, production enforce-restricted.
- Deployment hardenizado: runAsNonRoot uid 1000, drop ALL caps, readOnlyRootFilesystem, seccomp RuntimeDefault.
- Dockerfile actualizado: user 1000, chown.
- Terraform module con security_context.

## Pendiente para Days 26-27 (esta semana)
- Day 26 (Mie 13 hoy): ya consumido en este catch-up.
- Day 27+: ver roadmap Week 6 (BD real Postgres? mTLS service mesh? Trivy scan?).

## CRITICAL: rebuild de la imagen
El Dockerfile cambio (user 1000 + chown). Tienes que:
```
cd mobilebank-app
docker build -t ferdev49/mobilebank-api:latest .
docker push ferdev49/mobilebank-api:latest
```
Sin esto, el pod nuevo va a fallar con `permission denied` al escribir `/app/data` o tmp.
