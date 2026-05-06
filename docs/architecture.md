# MobileBank Architecture

## Estado actual al cierre de Week 3

```text
                     +-------------------------+
                     |  Developer Laptop       |
                     |  git push origin main   |
                     +-----------+-------------+
                                 |
                                 v
                  +-----------------------------+
                  |  GitHub Actions (Week 1+2)  |
                  |  - Lint / Build Docker      |
                  |  - Push a Docker Hub        |
                  |  - terraform plan/apply     |
                  +--------------+--------------+
                                 |
                                 v
                  +-----------------------------+
                  |  Terraform IaC (Week 2)     |
                  |  modules/kubernetes-app     |
                  +--------------+--------------+
                                 |
                                 v
   +-----------------------------+-----------------------------+
   |                                                           |
   v                                                           v
+-----------------------+                          +-----------------------+
|  staging.mobilebank.local                       |  api.mobilebank.local
|  Namespace: mobilebank-staging                  |  Namespace: mobilebank-production
+-----------------------+                          +-----------------------+
        ^                                                   ^
        |  Ingress (NGINX, rps=20)        Ingress (NGINX, rps=100)
        |
+-----------------------------------------------------------+
|                NGINX Ingress Controller (Week 3)          |
+-------------------------+---------------------------------+
                          |
                          v
                +---------------------+
                |  Service ClusterIP  |   <-- Week 3 (antes era LoadBalancer)
                +---------+-----------+
                          |
                          v
                +---------------------+
                |  Deployment         |   <-- HPA controla replicas (2..10)
                |  + envFrom CM/Secret|
                |  + volumeMounts PVC |
                +----+------+---------+
                     |      |
             +-------+      +-------+
             v                      v
        +----------+            +-----+
        |ConfigMap | mobilebank-config (Day 14)
        |Secret    | mobilebank-secrets (Day 14)
        |PVC       | mobilebank-data 1-5Gi (Day 16)
        +----------+
                     |
                     v
                +---------+
                |  HPA    |  <-- usa metrics-server (Day 15)
                +---------+
```

## Flujo end-to-end (Week 3)

1. Push a `main` -> GitHub Actions construye imagen y la sube a Docker Hub.
2. (Local en este lab) `terraform apply -var-file=environments/<env>.tfvars` o
   `kubectl apply -k kubernetes/overlays/<env>/` materializa los recursos.
3. NGINX Ingress recibe el trafico HTTP en `staging.mobilebank.local` o `api.mobilebank.local` y lo
   enruta al `Service` ClusterIP del namespace correspondiente.
4. El `Deployment` corre 2-10 replicas (controladas por el `HorizontalPodAutoscaler`).
5. Cada pod arranca con la configuracion del `ConfigMap` y los `Secrets` inyectados como variables
   de entorno (`envFrom`).
6. El pod monta el `PVC` en `/app/data`. `app.py` escribe `app.log` y `transfers.log` ahi.
7. Probes:
   - `startup` y `liveness` apuntan a `/health/live` (rapido, no toca BD).
   - `readiness` apunta a `/health/ready` (valida estado de la BD simulada).

## Rangos por environment

| Aspecto | staging | production |
|---------|---------|------------|
| Replicas (HPA min-max) | 2-5 | 3-10 |
| CPU target HPA | 70% | 60% |
| CPU request | 100m | 200m |
| Memory request | 128Mi | 256Mi |
| Storage PVC | 1Gi | 5Gi |
| Ingress rate limit | 20 rps | 100 rps |
| Log level | DEBUG | INFO |
| Max transfer amount | 5,000 | 50,000 |

## Roadmap restante

- **Week 4-5** - Cert-manager + TLS, secret management externo (Sealed Secrets / ESO).
- **Week 6** - Observabilidad: Prometheus, Grafana, Loki, alertas.
- **Week 7-8** - BD real (Postgres / CockroachDB), backup/restore del PVC.
- **Week 9-11** - Network Policies, Pod Security Standards, image scanning, performance tuning.
