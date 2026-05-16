# Loki + Promtail (Day 22)

## Arquitectura
- **Loki 3.1.1** como StatefulSet 1 replica, single-binary mode (filesystem storage, sin S3).
- PVC 10Gi, retencion 168h (7 dias).
- **Promtail 3.1.1** como DaemonSet, lee `/var/log/pods/*` y envia a `http://loki:3100`.
- Labels enriquecidos via Kubernetes SD: namespace, pod, container, app, host.

## Datasource en Grafana
Se actualizo `grafana-datasources` para incluir Loki ademas de Prometheus.

## Queries de ejemplo (LogQL)
```
{ namespace="mobilebank-staging" }
{ app="mobilebank-api" } |= "Transferencia"
{ app="mobilebank-api" } |~ "ERROR|WARNING"
rate({ app="mobilebank-api" } |= "Transferencia" [1m])
```
