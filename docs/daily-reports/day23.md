# Daily Report - Day 23 (Week 5)
**Fecha:** Dom 10 may (recuperado 13 may)
**Tema:** cert-manager + TLS en Ingress
**Status:** Completado

## Lo hecho
- `kubernetes/security/cert-manager/cluster-issuer.yaml`: selfsigned-issuer -> CA root `mobilebank-ca` -> `mobilebank-ca-issuer`.
- `kubernetes/security/cert-manager/certificate-mobilebank.yaml`: Certificates para staging y production con duracion 90d/renewBefore 15d.
- Actualizado `kubernetes/base/ingress.yaml`: ssl-redirect=true, TLS block, annotation cert-manager.
- Actualizados ambos overlays: patches ahora ajustan host + secretName del TLS.
- Actualizado `terraform/modules/kubernetes-app/ingress.tf`: dynamic tls block, ssl-redirect true.
- Agregadas variables: `enable_tls`, `tls_cluster_issuer`, `tls_secret_name`.
- `scripts/install-cert-manager.sh` (instala upstream v1.15.3 + aplica issuers).
- `docs/security-cert-manager.md`.

## Validacion
- YAML 3/3 OK
- HCL `ingress.tf` parses OK
- bash -n OK

## Tomorrow (Day 24)
Sealed Secrets para los Secret de mobilebank y grafana.
