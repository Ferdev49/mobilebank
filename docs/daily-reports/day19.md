# Daily Report - Day 19 (Week 4)

**Fecha:** Mie 6 may 2026 (recuperado el 13 may)
**Tema:** Grafana + migracion /metrics a OpenMetrics
**Status:** Completado

## Lo hecho

### Grafana en namespace observability
9 manifiestos en `kubernetes/observability/grafana/`:
- secret.yaml con admin/admin (DEMO, migrar a SealedSecret en Day 24)
- datasources.yaml auto-provisionando Prometheus
- dashboard-providers.yaml + dashboard-mobilebank.yaml (5 paneles)
- pvc.yaml 2Gi RWO
- deployment.yaml Grafana 11.2.2, securityContext fsGroup=472
- service.yaml ClusterIP
- ingress.yaml host grafana.mobilebank.local
- kustomization.yaml

### Migracion de /metrics a OpenMetrics nativo
- `requirements.txt`: agregado `prometheus-client==0.20.0`.
- `app.py` v1.3.0:
  - Counter `mobilebank_http_requests_total{method,endpoint,status}`
  - Histogram `mobilebank_http_request_duration_seconds`
  - Counter `mobilebank_transfers_total{status}` (success/insufficient_funds/invalid/blocked)
  - Gauge `mobilebank_total_balance` actualizado tras cada transferencia
  - Gauge `mobilebank_app_info{version,environment}`
  - Middleware `before_request`/`after_request` para medir todo automaticamente
  - `/metrics` retorna `Content-Type: text/plain; version=0.0.4` (formato exposition)

### Script
- `scripts/install-grafana.sh`

### Docs
- `docs/observability-grafana.md`
- `docs/daily-reports/day19.md`

## Archivos creados/modificados

| Estado | Archivo |
|--------|---------|
| nuevo | kubernetes/observability/grafana/* (9) |
| modificado | mobilebank-app/app.py (v1.3.0, +middleware +5 metrics) |
| modificado | mobilebank-app/requirements.txt (+prometheus-client) |
| nuevo | scripts/install-grafana.sh |
| nuevo | docs/observability-grafana.md |
| nuevo | docs/daily-reports/day19.md |

## Validacion offline
- YAML: 9/9 OK
- app.py compila OK
- bash -n install-grafana.sh OK

## Pendiente runtime (en tu cluster)
- Rebuild Docker image de la app (`docker build` y push) porque `app.py` cambio.
- `./scripts/install-grafana.sh`
- `kubectl -n observability port-forward svc/grafana 3000:3000`
- Importar dashboard y verificar paneles llenandose con datos.

## Tomorrow (Day 20)
node-exporter (DaemonSet) + kube-state-metrics (Deployment) y ampliar scrape de Prometheus.
