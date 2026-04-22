# Kubernetes Deployment

## Overview
MobileBank API deployed to Kubernetes with:
- 2 replicas for redundancy
- Load balancer for traffic distribution
- Health checks for auto-recovery
- Resource limits for efficiency

## Deployment Architecture

                LoadBalancer Service
                        |
            ____________|____________
           |                        |
    Pod 1: mobilebank-api    Pod 2: mobilebank-api
    (Replica 1)             (Replica 2)
           |                        |
           └────────┬───────────────┘
                    |
              kubernetes namespace

## Files
- \kubernetes/base/namespace.yaml\ - Creates isolated namespace
- \kubernetes/base/deployment.yaml\ - Defines 2 replicas, health checks
- \kubernetes/base/service.yaml\ - Creates load balancer
- \kubernetes/base/kustomization.yaml\ - Groups files together

## Deployment

### Create namespace
\\\ash
kubectl apply -f kubernetes/base/namespace.yaml
\\\

### Deploy app
\\\ash
kubectl apply -k kubernetes/base/
\\\

### Verify
\\\ash
kubectl get all -n mobilebank
\\\

### Test
\\\ash
kubectl port-forward -n mobilebank svc/mobilebank-api 8080:80
curl http://localhost:8080/health
\\\

## Features
✅ **2 Replicas** - If one pod dies, another serves traffic
✅ **Load Balancer** - Distributes traffic between pods
✅ **Liveness Probe** - Restarts unhealthy pods
✅ **Readiness Probe** - Only sends traffic to ready pods
✅ **Resource Limits** - Prevents app from consuming all resources

## Cleanup
\\\ash
kubectl delete namespace mobilebank
\\\

## Status
✅ Deployed and working
