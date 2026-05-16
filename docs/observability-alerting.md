# Alertmanager + reglas (Day 21)

## Componentes
- Alertmanager v0.27.0 con PVC 1Gi.
- Prometheus rules ConfigMap montado en `/etc/prometheus/rules/` (Prometheus relee).
- Webhook receiver de prueba (echo-server) en `webhook-receiver.observability.svc:5001`.

## Reglas (8 alertas)
- **mobilebank-api:** MobileBankHighErrorRate (5xx > 5%), MobileBankHighLatency (p95 > 1s), MobileBankPodCrashLooping.
- **cluster:** HPAMaxedOut (10min al max), NodeHighCPU (> 85%), NodeLowDisk (< 10%), PVCAlmostFull (< 10%).

## Routing
- Default receiver para todo.
- Routes adicional `severity=critical` -> path `/critical` del webhook (mismo servicio, distinto endpoint).
- Inhibit rule: si hay critical activa con mismo alertname+namespace, suprime warnings duplicados.

## En produccion
Cambiar el webhook por:
- Slack (`slack_configs`)
- PagerDuty (`pagerduty_configs`)
- Opsgenie (`opsgenie_configs`)
- Email (`email_configs`)
