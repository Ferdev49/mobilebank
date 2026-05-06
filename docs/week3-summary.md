# Week 3: Advanced Kubernetes - Resumen

## Estado: COMPLETO

5 dias, 5 primitivas avanzadas de Kubernetes integradas tanto en manifiestos K8s como en el modulo
Terraform existente, con paridad funcional entre ambos.

## Dias completados

### Day 13 - NGINX Ingress Controller
- Manifiesto `kubernetes/base/ingress.yaml` con rate limit, proxy timeouts, body-size.
- Recurso Terraform `kubernetes_ingress_v1` en `terraform/modules/kubernetes-app/ingress.tf`.
- Variables del modulo: `enable_ingress`, `ingress_host`, `ingress_rate_limit_rps`.
- Service paso de `LoadBalancer` a `ClusterIP` (toggle via `service_type`).
- Script `scripts/install-ingress.sh` para deploy del controller.
- Hostnames: `staging.mobilebank.local` (rps=20), `api.mobilebank.local` (rps=100).

### Day 14 - ConfigMaps y Secrets
- `mobilebank-config`: 8 variables (env, log level, port, debug, feature flags, max transfer).
- `mobilebank-secrets`: API_KEY, JWT_SECRET, DB_PASSWORD (demo en base64).
- Terraform `configmap.tf` y `secrets.tf` con variables sensibles para los secrets.
- `envFrom` en el deployment para inyectar todo como variables de entorno.
- Annotations `checksum/config` y `checksum/secret` en el pod template para forzar rolling update
  cuando cambia la configuracion.
- `app.py` refactorizada para leer toda la config con `os.getenv(...)` y respetar feature flags.

### Day 15 - HPA + Metrics Server
- `kubernetes/base/hpa.yaml` con metricas de CPU y memoria, behavior policies de scaleUp/scaleDown.
- Terraform `kubernetes_horizontal_pod_autoscaler_v2` en `hpa.tf`.
- Script `scripts/install-metrics-server.sh` con `--kubelet-insecure-tls` para clusters locales.
- Script `scripts/test-hpa.sh` (50 workers en paralelo, duracion configurable) para validar
  escalado.
- Deployment Terraform con `replicas = enable_hpa ? null : var.replicas` y `lifecycle.ignore_changes
  = [spec[0].replicas]` para no chocar con el HPA.
- Rangos: staging 2-5, production 3-10. Targets CPU: 70% / 60%.

### Day 16 - Persistent Volumes
- `kubernetes/base/pvc.yaml` con `ReadWriteOnce` y storageClass por defecto del cluster.
- Terraform `kubernetes_persistent_volume_claim` en `pvc.tf` con tamano configurable.
- `volumeMount` en `/app/data` y `volume` con `persistent_volume_claim` en el deployment.
- `app.py` escribe `app.log` y `transfers.log` en el PVC; cae a stdout si no esta montado.
- Tamanos: staging 1Gi, production 5Gi.

### Day 17 - Documentacion + diagrama
- `docs/week3-roadmap.md` - plan de la semana.
- `docs/kubernetes-ingress.md`, `docs/kubernetes-configmaps-secrets.md`, `docs/kubernetes-hpa.md`,
  `docs/kubernetes-persistent-volumes.md` - guia tecnica de cada primitiva.
- `docs/architecture.md` - diagrama actualizado.
- `docs/week3-summary.md` - este archivo.

## Estructura final tras Week 3

```text
mobilebank/
|-- mobilebank-app/
|   |-- app.py                       # MODIFICADO: lee env vars del ConfigMap/Secret
|   |-- requirements.txt             # MODIFICADO: gunicorn agregado
|   `-- Dockerfile
|-- kubernetes/
|   |-- base/
|   |   |-- namespace.yaml
|   |   |-- configmap.yaml           # NUEVO Day 14
|   |   |-- secret.yaml              # NUEVO Day 14
|   |   |-- pvc.yaml                 # NUEVO Day 16
|   |   |-- deployment.yaml          # MODIFICADO: envFrom, volumeMounts, probes /live /ready
|   |   |-- service.yaml             # MODIFICADO: ClusterIP
|   |   |-- ingress.yaml             # NUEVO Day 13
|   |   |-- hpa.yaml                 # NUEVO Day 15
|   |   `-- kustomization.yaml       # MODIFICADO: incluye nuevos recursos
|   `-- overlays/                    # NUEVO Week 3
|       |-- staging/
|       |   |-- kustomization.yaml
|       |   `-- patches/{replicas,configmap,ingress-host,hpa}.yaml
|       `-- production/
|           |-- kustomization.yaml
|           `-- patches/{replicas,configmap,ingress-host,hpa,pvc}.yaml
|-- terraform/
|   |-- main.tf                      # MODIFICADO: nuevas variables del modulo
|   |-- variables.tf                 # MODIFICADO: bloques Week 3
|   |-- environments/
|   |   |-- staging.tfvars           # MODIFICADO
|   |   `-- production.tfvars        # MODIFICADO
|   `-- modules/kubernetes-app/
|       |-- main.tf                  # MODIFICADO: envFrom, volumeMounts, ignore replicas
|       |-- variables.tf             # MODIFICADO: variables Week 3
|       |-- outputs.tf               # MODIFICADO: nuevos outputs
|       |-- configmap.tf             # NUEVO Day 14
|       |-- secrets.tf               # NUEVO Day 14
|       |-- pvc.tf                   # NUEVO Day 16
|       |-- hpa.tf                   # NUEVO Day 15
|       `-- ingress.tf               # NUEVO Day 13
|-- scripts/                         # NUEVO Week 3
|   |-- install-ingress.sh
|   |-- install-metrics-server.sh
|   |-- deploy-week3.sh
|   |-- test-ingress.sh
|   |-- test-hpa.sh
|   |-- validate-week3.sh
|   `-- cleanup-week3.sh
`-- docs/
    |-- architecture.md              # MODIFICADO
    |-- kubernetes-ingress.md        # NUEVO
    |-- kubernetes-configmaps-secrets.md  # NUEVO
    |-- kubernetes-hpa.md            # NUEVO
    |-- kubernetes-persistent-volumes.md  # NUEVO
    |-- week3-roadmap.md             # NUEVO
    `-- week3-summary.md             # NUEVO
```

## Como probar la Week 3 end-to-end

```bash
# 1. Pre-requisitos (una sola vez)
./scripts/install-ingress.sh
./scripts/install-metrics-server.sh

# Mapear hostnames en /etc/hosts:
#   127.0.0.1  staging.mobilebank.local api.mobilebank.local

# 2. Validacion offline (sin tocar el cluster)
./scripts/validate-week3.sh

# 3. Deploy via Kustomize
./scripts/deploy-week3.sh both

#    o via Terraform
terraform -chdir=terraform init
terraform -chdir=terraform apply

# 4. Pruebas funcionales
./scripts/test-ingress.sh

# 5. Prueba de autoscaling
./scripts/test-hpa.sh staging 180

# 6. Cleanup
./scripts/cleanup-week3.sh
```

## Metricas

- Archivos nuevos: 25 (5 K8s base + 11 overlays + 5 Terraform + 7 scripts + 6 docs)
- Archivos modificados: 8 (app.py, requirements.txt, deployment, service, kustomization base,
  main.tf raiz, variables.tf raiz, modulo main/variables/outputs, ambos tfvars, architecture.md,
  README.md)
- Lineas de IaC nuevas: ~600 (Terraform + YAML)
- Recursos K8s nuevos por environment: ConfigMap, Secret, PVC, Ingress, HPA = +5
- Replicas dinamicas: 2-5 staging, 3-10 production

## Pain points que cierra Week 3

| Antes | Despues |
|-------|---------|
| 1 LoadBalancer por servicio | 1 Ingress concentrador con hostnames y rate limit |
| Config quemada en la imagen | ConfigMap externo, mismo tag a varios environments |
| Secrets hardcodeados | Secret de K8s + variables sensibles en Terraform |
| Replicas estaticas, no escala | HPA basado en CPU/memoria con behavior policies |
| Logs y datos efimeros | PVC montado en /app/data |
| Probes basicos `/health` | Endpoints dedicados `/health/live` y `/health/ready` + `startupProbe` |
| Cambiar config = rebuild | Cambiar ConfigMap = rolling update automatico (checksum) |

## Pendiente para Week 4+

- TLS via cert-manager + Let's Encrypt.
- Secret management profesional (Sealed Secrets / External Secrets Operator).
- Network Policies para aislar namespaces.
- Pod Security Standards (restricted).
- Observabilidad (Prometheus / Grafana / Loki).
- BD real (Postgres / CockroachDB) y backup/restore del PVC.

## Status

**Week 3: Advanced Kubernetes - COMPLETE**
