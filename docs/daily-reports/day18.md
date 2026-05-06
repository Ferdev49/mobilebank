# Daily Report - Day 18 (Week 4)

**Fecha:** 2026-05-05
**Tema:** Observabilidad - Prometheus standalone
**Status:** Completado

## Objetivos

1. Levantar Prometheus en su propio namespace, manifiestos crudos (no Helm).
2. Conectar autodiscovery con la app MobileBank via anotaciones.
3. Persistencia con PVC para no perder series cuando el pod reinicie.
4. Dejar el path para sumar Grafana, node-exporter, alerting en Days 19-22.

## Lo hecho

### Stack Prometheus en namespace `observability`

7 manifiestos en `kubernetes/observability/prometheus/`:
- `namespace.yaml` - aislamiento de monitoring del resto del cluster.
- `rbac.yaml` - ServiceAccount + ClusterRole con permisos de `get/list/watch` sobre
  pods/nodes/services/endpoints, mas acceso al endpoint `/metrics` no-resource del API server.
- `configmap.yaml` - `prometheus.yml` con 4 scrape jobs (prometheus, apiservers, nodes, pods).
- `pvc.yaml` - 5Gi para retencion de 7 dias.
- `deployment.yaml` - Prometheus v2.54.1, requests 200m/256Mi, `--web.enable-lifecycle` para reload
  via API.
- `service.yaml` - ClusterIP en puerto 9090.
- `ingress.yaml` - host `prometheus.mobilebank.local` (NGINX Ingress de Week 3).

### Autodiscovery de MobileBank

Agregue las anotaciones de scrape al pod template en dos lugares para mantener paridad:
- `kubernetes/base/deployment.yaml` (camino Kustomize).
- `terraform/modules/kubernetes-app/main.tf` (camino Terraform).

Anotaciones:
```yaml
prometheus.io/scrape: "true"
prometheus.io/path:   "/metrics"
prometheus.io/port:   "5000"
```

El job `kubernetes-pods` en `prometheus.yml` usa `keep` sobre la anotacion `scrape=true` y reemplaza
el path/port con las otras dos via relabeling.

### Scripts agregados

- `scripts/install-prometheus.sh` - aplica el kustomize y espera el rollout.
- `scripts/test-prometheus-scrape.sh` - verifica que el pod responda en `/metrics`, lista las
  anotaciones, e imprime las URLs del UI a chequear.

### Documentacion

- `docs/observability-prometheus.md` - guia tecnica completa de la pieza.
- Este reporte.

## Archivos creados / modificados

| Estado | Archivo |
|--------|---------|
| nuevo | kubernetes/observability/prometheus/namespace.yaml |
| nuevo | kubernetes/observability/prometheus/rbac.yaml |
| nuevo | kubernetes/observability/prometheus/configmap.yaml |
| nuevo | kubernetes/observability/prometheus/pvc.yaml |
| nuevo | kubernetes/observability/prometheus/deployment.yaml |
| nuevo | kubernetes/observability/prometheus/service.yaml |
| nuevo | kubernetes/observability/prometheus/ingress.yaml |
| nuevo | kubernetes/observability/prometheus/kustomization.yaml |
| modificado | kubernetes/base/deployment.yaml (anotaciones prometheus.io/*) |
| modificado | terraform/modules/kubernetes-app/main.tf (mismas anotaciones) |
| nuevo | scripts/install-prometheus.sh |
| nuevo | scripts/test-prometheus-scrape.sh |
| nuevo | docs/observability-prometheus.md |
| nuevo | docs/daily-reports/day18.md |

## Validacion ejecutada (sandbox, sin cluster)

- `python3 yaml.safe_load_all` sobre los 8 manifiestos nuevos: 8/8 OK.
- `bash -n` sobre los 2 scripts nuevos: 2/2 OK.
- Sintaxis HCL del modulo Terraform tras la edicion: OK (parseable).

## Lo que NO se ejecuto (requiere cluster + ya pasados a ti)

- `kubectl apply -k kubernetes/observability/prometheus/` (instalar).
- `kubectl -n observability port-forward svc/prometheus 9090:9090` y abrir el UI.
- Verificar que `up{job="kubernetes-pods"}` tenga targets de mobilebank.
- Re-deployar mobilebank-api con las nuevas anotaciones para que Prometheus lo descubra.

## Comandos para correr en tu maquina (cuando empieces el dia)

```bash
# 1. Instalar Prometheus
./scripts/install-prometheus.sh

# 2. Re-aplicar mobilebank para que tome las nuevas anotaciones
./scripts/deploy-week3.sh both
# (o terraform apply)

# 3. Verificar
./scripts/test-prometheus-scrape.sh mobilebank-staging

# 4. Abrir UI
kubectl -n observability port-forward svc/prometheus 9090:9090
# -> http://localhost:9090/targets
```

## Blockers / observaciones

- El push de Week 3 no se pudo hacer desde el sandbox: `.git/index.lock` esta bloqueado a nivel
  filesystem por Windows (probablemente VS Code o GitHub Desktop con el repo abierto). Te deje
  `scripts/commit-week3.sh` para que lo corras tu desde Git Bash.
- El endpoint `/metrics` actual de la app devuelve **JSON propietario**, no formato OpenMetrics.
  Prometheus puede consumirlo pero no genera series limpias. Day 19 lo migra a `prometheus-client`.

## Tomorrow (Day 19)

Grafana + dashboard de MobileBank + cambiar `/metrics` a OpenMetrics real con `prometheus-client`
en `requirements.txt`.

## Metricas del dia

- Archivos nuevos: 12
- Archivos modificados: 2
- Lineas YAML nuevas: ~190
- Tiempo estimado de ejecucion en cluster: ~3 min (pull image + rollout)
