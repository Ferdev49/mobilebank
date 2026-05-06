# Prometheus (Week 4 - Day 18)

## Que se instalo

Prometheus standalone (no Operator) corriendo en su propio namespace `observability`. Lo basico:
un Deployment, un PVC para retencion de 7 dias, RBAC para autodiscovery de pods/nodos, ConfigMap
con `prometheus.yml`, Service ClusterIP y un Ingress opcional para abrir el UI.

No usamos kube-prometheus-stack (chart de Helm) en este Day 18 a proposito: queremos ver los
manifiestos crudos para entender la pieza. Day 19 (Grafana) lo dejaremos en la misma linea.

## Recursos creados

| Recurso | Archivo |
|---------|---------|
| Namespace `observability` | `kubernetes/observability/prometheus/namespace.yaml` |
| ServiceAccount + ClusterRole + Binding | `rbac.yaml` |
| ConfigMap `prometheus-config` con scrape jobs | `configmap.yaml` |
| PVC `prometheus-data` (5Gi RWO) | `pvc.yaml` |
| Deployment `prometheus` (1 replica, 200m/256Mi req) | `deployment.yaml` |
| Service `prometheus` (ClusterIP, port 9090) | `service.yaml` |
| Ingress `prometheus.mobilebank.local` | `ingress.yaml` |

## Scrape jobs activos

1. **prometheus** - scrape interno (localhost:9090).
2. **kubernetes-apiservers** - metricas del API server.
3. **kubernetes-nodes** - metricas del kubelet por nodo.
4. **kubernetes-pods** - **autodiscovery por anotaciones**. Cualquier pod con
   `prometheus.io/scrape: "true"` se scrapea automaticamente.

## Como se conecta MobileBank API

Las anotaciones se agregaron en dos lugares para mantener paridad:

- `kubernetes/base/deployment.yaml` (Kustomize):
  ```yaml
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/path: "/metrics"
        prometheus.io/port: "5000"
  ```
- `terraform/modules/kubernetes-app/main.tf` (Terraform): mismo bloque dentro de
  `template.metadata.annotations`.

La app expone `/metrics` desde Week 3 (devuelve cpu/memory/disk/uptime en JSON). En Day 19 vamos a
cambiar ese endpoint a formato **OpenMetrics** real con `prometheus-client` para que las series sean
graficables en Grafana sin parsing custom.

## Como instalar

```bash
./scripts/install-prometheus.sh
```

## Como verificar el scrape

```bash
./scripts/test-prometheus-scrape.sh mobilebank-staging
```

Despues, port-forward al UI:
```bash
kubectl -n observability port-forward svc/prometheus 9090:9090
```

Y revisar `http://localhost:9090/targets`. Deberias ver el job `kubernetes-pods` con un endpoint
por cada pod de mobilebank-api en estado `UP`.

## Limitaciones de este Day 18

- **No hay alerting:** vamos a sumar Alertmanager despues (probablemente Day 21).
- **No hay node-exporter:** los kubelets dan algo de metricas de nodo pero faltan disk/network
  detallados. Day 20.
- **El endpoint /metrics es JSON propietario:** no Prometheus exposition format. Day 19 lo arregla.
- **Sin TLS para el scraper:** `insecure_skip_verify: true` en el TLS config. Aceptable en lab,
  fix viene cuando metamos cert-manager (Week 5).
- **Retencion de 7 dias y 5Gi:** suficiente para lab, no para produccion real.

## Pendiente para Days 19-22

| Day | Tema |
|-----|------|
| 19 | Grafana + datasource Prometheus + dashboard MobileBank + cambiar /metrics a OpenMetrics |
| 20 | node-exporter + kube-state-metrics |
| 21 | Alertmanager + reglas (HPA al 100%, error rate, latencia) |
| 22 | Loki para logs + integracion Grafana |
