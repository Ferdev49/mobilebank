# cert-manager + TLS (Day 23)

## Estrategia
En un lab local sin dominio publico real, Let's Encrypt no funciona (ACME requiere
challenge HTTP/DNS verificable desde internet). Usamos **CA interna self-signed**:

1. `selfsigned-issuer` (ClusterIssuer) genera certs auto-firmados sin trust externo.
2. `mobilebank-ca` (Certificate `isCA: true`) firma usando selfsigned-issuer, generando una CA root del lab.
3. `mobilebank-ca-issuer` (ClusterIssuer tipo `ca`) usa esa root para emitir certs reales para los Ingresses.

Cuando tengas dominio publico real, descomentas el `letsencrypt-staging` y luego pasas a `letsencrypt-prod`.

## Certificates creados
- `mobilebank-staging-tls` en namespace `mobilebank-staging` -> secret `mobilebank-staging-tls`.
- `mobilebank-production-tls` en namespace `mobilebank-production` -> secret `mobilebank-production-tls`.
- Duracion 90 dias, renewBefore 15 dias (cert-manager renueva automatico).

## Ingress
- `ssl-redirect: true` (antes era false).
- TLS block apuntando al secret correcto via overlay patch.
- Annotation `cert-manager.io/cluster-issuer: mobilebank-ca-issuer`.

## Confianza local
El navegador no confia en la CA del lab. Para no ver warnings:
```bash
kubectl -n cert-manager get secret mobilebank-ca-key-pair -o jsonpath='{.data.ca\.crt}' | base64 -d > mobilebank-ca.crt
# Importar en Keychain (Mac), certmgr.msc (Windows) o el trust store del navegador.
```
