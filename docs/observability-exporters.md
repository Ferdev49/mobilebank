# node-exporter + kube-state-metrics (Day 20)

## node-exporter
Daemon que expone metricas del host (CPU, memoria, disco, red, filesystem) por nodo.
Corre como DaemonSet con `hostNetwork: true` y `hostPID: true` para acceder al `/proc` real.
Lo monta read-only en `/host/proc`, `/host/sys`, `/host/root`.

Metricas clave que aporta:
- `node_cpu_seconds_total{mode}`
- `node_memory_MemAvailable_bytes`
- `node_filesystem_avail_bytes`
- `node_network_receive_bytes_total`
- `node_load1`, `node_load5`, `node_load15`

## kube-state-metrics
Expone el estado de los objetos K8s (no metricas de proceso). Util para HPA, replicas, restarts.

Metricas clave:
- `kube_deployment_status_replicas_available`
- `kube_hpa_status_current_replicas`
- `kube_pod_container_status_restarts_total`
- `kube_pod_status_phase`
- `kube_persistentvolumeclaim_status_phase`

## Como los descubre Prometheus
Ambos llevan las anotaciones `prometheus.io/scrape=true` + `prometheus.io/port`, asi que el job
`kubernetes-pods` del Day 18 los recoge sin cambios en la config.
