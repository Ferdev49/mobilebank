# Grafana (Week 4 - Day 19)

## Que se hizo

1. **Grafana 11.2.2 deployment** en namespace `observability` con PVC 2Gi.
2. **Datasource Prometheus** auto-provisionado apuntando a `http://prometheus:9090`.
3. **Dashboard MobileBank** auto-provisionado con 5 paneles: pods UP, request rate, p95 latency, transferencias por status, CPU por pod.
4. **Migracion de `/metrics`** de la app: ahora es **OpenMetrics nativo** via `prometheus-client`, no JSON propietario.

## Metricas que expone la app ahora

| Metrica | Tipo | Labels |
|---------|------|--------|
| `mobilebank_http_requests_total` | Counter | method, endpoint, status |
| `mobilebank_http_request_duration_seconds` | Histogram | method, endpoint |
| `mobilebank_transfers_total` | Counter | status (success/insufficient_funds/invalid/blocked) |
| `mobilebank_total_balance` | Gauge | (sin labels) |
| `mobilebank_app_info` | Gauge | version, environment |

El middleware `before_request`/`after_request` mide automaticamente todas las rutas excepto `/metrics`.

## Acceso

```bash
./scripts/install-grafana.sh
kubectl -n observability port-forward svc/grafana 3000:3000
# admin / admin
```

## Pendiente

- Day 20: node-exporter + kube-state-metrics para metricas de cluster.
- Day 21: Alertmanager con reglas sobre las metricas que ahora produce la app.
