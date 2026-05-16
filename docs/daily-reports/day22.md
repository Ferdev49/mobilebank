# Daily Report - Day 22 (Week 4)
**Fecha:** Sab 9 may (recuperado 13 may)
**Tema:** Loki + Promtail + datasource Grafana
**Status:** Completado

## Lo hecho
### Loki
- StatefulSet single-binary v3.1.1, fsGroup 10001, PVC 10Gi.
- Config con schema v13 + tsdb + filesystem storage + retencion 168h.
- Service ClusterIP 3100/9096.

### Promtail
- ServiceAccount + ClusterRole (list pods/nodes/services).
- ConfigMap con pipeline cri parser + relabel para namespace/pod/container/app.
- DaemonSet con 3 hostPath mounts: /run/promtail, /var/lib/docker/containers (RO), /var/log/pods (RO).

### Integracion Grafana
- Actualizado `grafana-datasources` configmap: agregado datasource `Loki` apuntando a `http://loki:3100`.
- `install-logging.sh` re-aplica Grafana y hace rollout restart.

## Archivos
| Estado | Archivo |
|---|---|
| nuevo | kubernetes/observability/loki/{configmap,pvc,deployment,service,kustomization}.yaml |
| nuevo | kubernetes/observability/promtail/{rbac,configmap,daemonset,kustomization}.yaml |
| modificado | kubernetes/observability/grafana/datasources.yaml |
| nuevo | scripts/install-logging.sh |
| nuevo | docs/observability-logging.md |
| nuevo | docs/daily-reports/day22.md |

## Validacion offline
9 YAML OK, bash -n OK.

## Estado Week 4 al cierre
| Day | Tema | Status |
|---|---|---|
| 18 | Prometheus | hecho + pusheado |
| 19 | Grafana + OpenMetrics | hecho local |
| 20 | exporters | hecho local |
| 21 | Alertmanager | hecho local |
| 22 | Loki + Promtail | hecho local |

## Tomorrow (Day 23 - Week 5)
cert-manager + TLS para ingress.
