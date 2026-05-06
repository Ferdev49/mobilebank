# ConfigMaps y Secrets (Day 14)

## Por que existen

Hardcodear configuracion en el codigo o en la imagen Docker rompe los principios 12-factor:
- Misma imagen no puede ir a staging y production sin recompilarla.
- Las credenciales viajan en el repo (mal).
- Cambiar el `LOG_LEVEL` exige rebuild.

`ConfigMap` (no sensible) y `Secret` (sensible) resuelven esto inyectando variables en runtime.

## ConfigMap - mobilebank-config

| Variable | Default base | Staging | Production |
|----------|--------------|---------|------------|
| `ENVIRONMENT` | `base` | `staging` | `production` |
| `LOG_LEVEL` | `INFO` | `DEBUG` | `INFO` |
| `MAX_TRANSFER_AMOUNT` | `10000` | `5000` | `50000` |
| `FEATURE_TRANSFER_ENABLED` | `true` | `true` | `true` |
| `FEATURE_METRICS_ENABLED` | `true` | `true` | `true` |
| `DEBUG` | `False` | `False` | `False` |
| `PORT` | `5000` | `5000` | `5000` |
| `HEALTH_CHECK_PATH` | `/health` | `/health` | `/health` |

Implementaciones:
- K8s: `kubernetes/base/configmap.yaml` + overlays `patches/configmap.yaml`.
- Terraform: `terraform/modules/kubernetes-app/configmap.tf` (variables `log_level`, `max_transfer_amount`, etc.).

## Secret - mobilebank-secrets

Contiene `API_KEY`, `JWT_SECRET`, `DB_PASSWORD`. Los valores en `secret.yaml` son **demo en base64**;
en un entorno real usar uno de:

- **Sealed Secrets** (Bitnami) para commitear cifrado al repo.
- **External Secrets Operator** + AWS Secrets Manager / GCP Secret Manager / Vault.
- `kubectl create secret generic ... --from-literal=...` operado fuera del repo.

## Como llegan a la app

El deployment usa `envFrom` para inyectar **todo** el ConfigMap y Secret como variables de entorno.
La app (`app.py`) las lee con `os.getenv(...)`:

```python
ENVIRONMENT = os.getenv("ENVIRONMENT", "local")
MAX_TRANSFER_AMOUNT = float(os.getenv("MAX_TRANSFER_AMOUNT", "10000"))
API_KEY = os.getenv("API_KEY", "")
```

## Rollouts automaticos al cambiar config

El deployment Terraform incluye dos annotations en el pod template:

```hcl
"checksum/config" = sha256(jsonencode(kubernetes_config_map.app.data))
"checksum/secret" = sha256(jsonencode(kubernetes_secret.app.data))
```

Con esto, cualquier cambio al ConfigMap o Secret modifica el hash, lo que dispara un rolling update
automatico la siguiente vez que `terraform apply` se ejecuta. Sin esto, los pods seguirian con la
config vieja hasta el siguiente reinicio manual.

## Validacion

```bash
kubectl -n mobilebank-staging get configmap mobilebank-config -o yaml
kubectl -n mobilebank-staging get secret mobilebank-secrets -o yaml   # base64
kubectl -n mobilebank-staging exec deploy/mobilebank-api -- env | grep -E "LOG_LEVEL|ENVIRONMENT|MAX_TRANSFER"
```
