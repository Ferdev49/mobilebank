# Daily Report - Day 21 (Week 4)
**Fecha:** Vie 8 may (recuperado 13 may)
**Tema:** Alertmanager + 8 reglas
**Status:** Completado

## Lo hecho
- 7 manifiestos en `kubernetes/observability/alertmanager/`:
  - rules.yaml (8 reglas en 2 groups)
  - configmap.yaml (alertmanager.yml con routing + inhibit)
  - pvc.yaml, deployment.yaml v0.27.0, service.yaml, ingress.yaml
  - webhook-receiver.yaml (echo-server para probar)
  - kustomization.yaml
- Actualizada config de Prometheus: agregadas `rule_files` y `alerting.alertmanagers`.
- Actualizado deployment de Prometheus: nuevo volume mount `/etc/prometheus/rules`.
- scripts/install-alertmanager.sh (instala + restartea Prometheus)
- docs/observability-alerting.md

## Reglas implementadas
| Alerta | Severity | Trigger |
|---|---|---|
| MobileBankHighErrorRate | critical | rate(5xx)/rate(total) > 5% por 2min |
| MobileBankHighLatency | warning | p95 > 1s por 5min |
| MobileBankPodCrashLooping | critical | restart rate > 0 por 5min |
| HPAMaxedOut | warning | current == max por 10min |
| NodeHighCPU | warning | CPU > 85% por 10min |
| NodeLowDisk | critical | / < 10% por 5min |
| PVCAlmostFull | warning | PVC < 10% por 5min |

## Validacion offline
- 7 archivos YAML del modulo alertmanager: OK
- Prometheus configmap/deployment regenerados: OK
- Script bash -n: OK

## Tomorrow (Day 22)
Loki + Promtail para shipping de logs.
