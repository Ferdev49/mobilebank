# Week 3 Roadmap - Advanced Kubernetes

> Periodo: Apr 28 - May 2, 2026
> Pre-requisitos: Week 1 (CI/CD + Docker + K8s base) y Week 2 (Terraform IaC) completas

## Objetivos de la semana

Promover el deployment de "Hello World en K8s" a una infra **production-grade** introduciendo cinco
primitivas de Kubernetes que faltaban en Week 1-2:

1. **Ingress** - punto unico de entrada HTTP, hostnames y rate limiting.
2. **ConfigMaps** - configuracion no sensible inyectada como env vars.
3. **Secrets** - credenciales separadas del codigo y de la imagen.
4. **HPA** - autoscaling horizontal segun CPU/memoria.
5. **PVC** - almacenamiento persistente entre reinicios de pod.

Cada primitiva se implementa en dos formatos paralelos:
- Manifiestos K8s + overlays de Kustomize (`kubernetes/`).
- Modulo Terraform parametrizado (`terraform/modules/kubernetes-app/`).

## Plan dia por dia

| Dia | Tema | Entregables |
|-----|------|-------------|
| **Day 13** | NGINX Ingress Controller | `ingress.yaml`, `ingress.tf`, `install-ingress.sh`, `kubernetes-ingress.md` |
| **Day 14** | ConfigMaps & Secrets | `configmap.yaml`, `secret.yaml`, `configmap.tf`, `secrets.tf`, `app.py` refactor para leer env, `kubernetes-configmaps-secrets.md` |
| **Day 15** | HPA + Metrics Server | `hpa.yaml`, `hpa.tf`, `install-metrics-server.sh`, `test-hpa.sh`, `kubernetes-hpa.md` |
| **Day 16** | Persistent Volumes | `pvc.yaml`, `pvc.tf`, mount en deployment, log persistente de transferencias, `kubernetes-persistent-volumes.md` |
| **Day 17** | Demo final + docs | `architecture.md` actualizado, `week3-summary.md`, README actualizado |

## Definicion de hecho

- `kubectl kustomize kubernetes/overlays/{staging,production}/` genera YAML valido.
- `terraform validate` pasa sin errores en el modulo y en la raiz.
- Los scripts `validate-week3.sh`, `deploy-week3.sh`, `test-ingress.sh`, `test-hpa.sh` corren
  end-to-end en un cluster local (Docker Desktop / Minikube / Kind).
- Documentacion publicada en `/docs/`.

## Out of scope (queda para semanas 4+)

- TLS / cert-manager (Week 4).
- Network Policies y Pod Security Standards (Week 9).
- Observabilidad: Prometheus, Grafana, Loki (Week 6).
- Backup/restore del PVC (Week 7).
