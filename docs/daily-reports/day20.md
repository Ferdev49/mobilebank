# Daily Report - Day 20 (Week 4)
**Fecha:** Jue 7 may (recuperado 13 may)
**Tema:** node-exporter + kube-state-metrics
**Status:** Completado

## Lo hecho
- `kubernetes/observability/node-exporter/` (DaemonSet, Service headless, kustomization). hostNetwork/hostPID + 3 mounts read-only para que vea /proc, /sys, /.
- `kubernetes/observability/kube-state-metrics/` (RBAC ClusterRole/Binding, Deployment v2.13.0, Service, kustomization).
- `scripts/install-exporters.sh`.
- `docs/observability-exporters.md`.

## Archivos
| Estado | Archivo |
|---|---|
| nuevo | kubernetes/observability/node-exporter/{daemonset,service,kustomization}.yaml |
| nuevo | kubernetes/observability/kube-state-metrics/{rbac,deployment,service,kustomization}.yaml |
| nuevo | scripts/install-exporters.sh |
| nuevo | docs/observability-exporters.md |
| nuevo | docs/daily-reports/day20.md |

## Validacion offline
7/7 YAML OK, bash -n OK.

## Tomorrow (Day 21)
Alertmanager + reglas sobre las metricas que ahora hay.
