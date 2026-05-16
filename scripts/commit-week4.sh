#!/usr/bin/env bash
# Commit Week 4 (Days 19-22) - ejecutar desde Git Bash en la raiz del repo.
# Crea 4 commits atomicos con mensajes descriptivos.
# NO toca Day 18 (ya esta en main desde tu commit "Week 3").
# NO toca .github/workflows ni archivos no relacionados.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> Limpiando lock si existe..."
rm -f .git/index.lock || true

echo "==> Configurando identidad..."
git config user.name "Ferdev49"
git config user.email "fercho00.fb@gmail.com"

# Si el index esta corrupto de sesiones pasadas, lo reseteamos al HEAD
echo "==> Reseteando index al HEAD por seguridad..."
git reset HEAD >/dev/null

# ---------- DAY 19 ----------
echo ""
echo "==> Day 19: Grafana + OpenMetrics"
git add kubernetes/observability/grafana/secret.yaml \
        kubernetes/observability/grafana/datasources.yaml \
        kubernetes/observability/grafana/dashboard-providers.yaml \
        kubernetes/observability/grafana/dashboard-mobilebank.yaml \
        kubernetes/observability/grafana/pvc.yaml \
        kubernetes/observability/grafana/deployment.yaml \
        kubernetes/observability/grafana/service.yaml \
        kubernetes/observability/grafana/ingress.yaml \
        kubernetes/observability/grafana/kustomization.yaml \
        mobilebank-app/app.py \
        mobilebank-app/requirements.txt \
        scripts/install-grafana.sh \
        docs/observability-grafana.md \
        docs/daily-reports/day19.md
git commit -m "feat(week4-day19): Grafana + migracion /metrics a OpenMetrics

- Grafana 11.2.2 deployment en namespace observability
- Datasource Prometheus auto-provisionado
- Dashboard MobileBank con 5 paneles (request rate, p95 latency, transfers, etc.)
- PVC 2Gi, Service ClusterIP, Ingress grafana.mobilebank.local
- app.py v1.3.0: migrado /metrics a formato OpenMetrics nativo
  - Counter mobilebank_http_requests_total{method,endpoint,status}
  - Histogram mobilebank_http_request_duration_seconds
  - Counter mobilebank_transfers_total{status}
  - Gauge mobilebank_total_balance, mobilebank_app_info
  - Middleware before_request/after_request
- requirements.txt: agregado prometheus-client==0.20.0
- scripts/install-grafana.sh
"

# ---------- DAY 20 ----------
echo ""
echo "==> Day 20: node-exporter + kube-state-metrics"
git add kubernetes/observability/node-exporter/ \
        kubernetes/observability/kube-state-metrics/ \
        scripts/install-exporters.sh \
        docs/observability-exporters.md \
        docs/daily-reports/day20.md
git commit -m "feat(week4-day20): node-exporter + kube-state-metrics

- node-exporter v1.8.2 como DaemonSet con hostNetwork/hostPID
  - 3 mounts hostPath read-only: /proc, /sys, /
- kube-state-metrics v2.13.0 deployment con RBAC ClusterRole
- Ambos descubiertos por Prometheus via anotaciones prometheus.io/scrape
- scripts/install-exporters.sh
"

# ---------- DAY 21 ----------
echo ""
echo "==> Day 21: Alertmanager + 8 reglas"
git add kubernetes/observability/alertmanager/ \
        kubernetes/observability/prometheus/configmap.yaml \
        kubernetes/observability/prometheus/deployment.yaml \
        scripts/install-alertmanager.sh \
        docs/observability-alerting.md \
        docs/daily-reports/day21.md
git commit -m "feat(week4-day21): Alertmanager + reglas de Prometheus

- Alertmanager v0.27.0 con PVC 1Gi, routing critical/default
- 8 reglas en 2 groups (mobilebank-api + cluster):
  - HighErrorRate, HighLatency, PodCrashLooping
  - HPAMaxedOut, NodeHighCPU, NodeLowDisk, PVCAlmostFull
- Inhibit rule: critical suprime warnings duplicados
- webhook-receiver de prueba (echo-server) en svc:5001
- Prometheus actualizado: rule_files + alerting.alertmanagers
- scripts/install-alertmanager.sh (instala + restartea Prometheus)
"

# ---------- DAY 22 ----------
echo ""
echo "==> Day 22: Loki + Promtail"
git add kubernetes/observability/loki/ \
        kubernetes/observability/promtail/ \
        kubernetes/observability/grafana/datasources.yaml \
        scripts/install-logging.sh \
        docs/observability-logging.md \
        docs/daily-reports/day22.md
git commit -m "feat(week4-day22): Loki + Promtail + datasource Grafana

- Loki 3.1.1 StatefulSet single-binary, schema v13 + tsdb
- PVC 10Gi, retencion 168h
- Promtail 3.1.1 DaemonSet con RBAC
  - hostPath mounts: /run/promtail, /var/lib/docker/containers, /var/log/pods
  - Pipeline cri parser + relabel (namespace, pod, container, app)
- Grafana datasources actualizado: agregado Loki url http://loki:3100
- scripts/install-logging.sh
"

echo ""
echo "==> Commits creados (Week 4):"
git log --oneline -4
echo ""
echo "Para subir a GitHub:"
echo "  git push origin main"
