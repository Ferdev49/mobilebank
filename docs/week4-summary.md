# Week 4: Observabilidad - Resumen

## Status: COMPLETO

5 dias, 5 piezas de observabilidad integradas con la infra de Week 1-3.

### Day 18 - Prometheus
Standalone deployment, RBAC, scrape jobs (apiservers, nodes, pods via annotations), retencion 7d.

### Day 19 - Grafana + OpenMetrics
Grafana 11.2.2 + dashboard MobileBank. Migrada `/metrics` de la app a `prometheus-client` (Counter, Histogram, Gauge).

### Day 20 - Exporters
node-exporter (DaemonSet hostNetwork) + kube-state-metrics (Deployment con RBAC).

### Day 21 - Alertmanager
Alertmanager + 8 reglas (errors, latency, crashloop, HPA maxed, CPU/disk, PVC). Webhook receiver demo.

### Day 22 - Loki + Promtail
Loki 3.1.1 single-binary + PVC 10Gi. Promtail DaemonSet shipping `/var/log/pods/*`. Datasource agregado en Grafana.

## Endpoints UI tras instalar todo

```
kubectl -n observability port-forward svc/prometheus 9090:9090
kubectl -n observability port-forward svc/grafana 3000:3000        # admin/admin
kubectl -n observability port-forward svc/alertmanager 9093:9093
kubectl -n observability port-forward svc/loki 3100:3100
```

O via Ingress:
```
prometheus.mobilebank.local
grafana.mobilebank.local
alertmanager.mobilebank.local
```
