# Horizontal Pod Autoscaler (Day 15)

## Que problema resuelve

En Week 1-2 el numero de replicas era estatico (2 en staging, 3 en production). El HPA lo convierte
en dinamico: arriba bajo carga, abajo cuando esta tranquilo, dentro de un rango definido.

## Pre-requisito: metrics-server

Sin `metrics-server`, el HPA no puede leer CPU/memoria de los pods y se queda en `unknown`. Instalar:

```bash
./scripts/install-metrics-server.sh
```

(En clusters locales se le pasa `--kubelet-insecure-tls` porque el certificado del kubelet no esta
firmado por una CA reconocida.)

## Configuracion por environment

| | Staging | Production |
|---|---------|------------|
| min replicas | 2 | 3 |
| max replicas | 5 | 10 |
| target CPU | 70% | 60% |
| target memoria | 80% | 75% |

Production escala antes (target mas bajo) y mas alto (max 10) porque el coste de degradar UX es mayor.

## Politicas de escalado

`scaleUp`:
- ventana de estabilizacion 30s
- maximo entre +100% o +2 pods cada 30s

`scaleDown`:
- ventana de estabilizacion 5 minutos (evita "flapping")
- maximo -50% cada 60s

## Convivencia con Terraform

El deployment Terraform tiene:

```hcl
spec {
  replicas = var.enable_hpa ? null : var.replicas
}

lifecycle {
  ignore_changes = [ spec[0].replicas ]
}
```

De esta forma Terraform no pelea con el HPA por modificar el numero de replicas.

## Prueba de carga

```bash
./scripts/test-hpa.sh staging 180   # 50 workers, 180 segundos
```

En otra terminal:

```bash
kubectl -n mobilebank-staging get hpa -w
kubectl -n mobilebank-staging get pods -w
kubectl top pods -n mobilebank-staging
```

Vas a ver el numero de replicas crecer progresivamente y bajar despues del periodo de estabilizacion.
