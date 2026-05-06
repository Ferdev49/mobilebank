# Ingress (Day 13)

## Que es

Un objeto **Ingress** define reglas L7 (HTTP/HTTPS) para enrutar trafico externo a Services internos
del cluster. Por si solo no hace nada: necesita un **Ingress Controller** corriendo (nosotros usamos
NGINX). El controller observa los recursos `Ingress` y configura un proxy reverso real.

## Por que en Week 3

En Week 1-2 cada Service estaba expuesto como `LoadBalancer`, lo que en clouds reales crea un LB
(con su factura) por cada servicio. Con un Ingress concentramos N servicios detras de un solo punto
de entrada y obtenemos:

- Hostnames y path-based routing.
- Rate limiting / proxy timeouts via annotations.
- Lugar natural para enchufar TLS (cert-manager en Week 4).

## Componentes creados

| Recurso | Archivo K8s | Archivo Terraform |
|---------|-------------|-------------------|
| Ingress object | `kubernetes/base/ingress.yaml` | `terraform/modules/kubernetes-app/ingress.tf` |

`Service` paso de `LoadBalancer` a `ClusterIP` en Week 3 (el Ingress es el unico que recibe trafico
externo). Si quieres revertirlo, cambia `service_type = "LoadBalancer"` o `enable_ingress = false`.

## Instalacion del Ingress Controller

```bash
./scripts/install-ingress.sh
```

Despues mapea los hostnames en tu archivo de hosts:

```text
127.0.0.1  staging.mobilebank.local
127.0.0.1  api.mobilebank.local
```

(En Linux/Mac: `/etc/hosts`. En Windows: `C:\Windows\System32\drivers\etc\hosts`.)

## Pruebas

```bash
./scripts/test-ingress.sh
```

Hace `curl -H "Host: staging.mobilebank.local" http://localhost/health` y similares.

## Annotations clave

| Annotation | Para que sirve |
|------------|----------------|
| `nginx.ingress.kubernetes.io/rewrite-target` | Reescribe la ruta antes de pasarla al backend |
| `nginx.ingress.kubernetes.io/ssl-redirect` | Forzar redirect a HTTPS (off mientras no hay TLS) |
| `nginx.ingress.kubernetes.io/limit-rps` | Rate limit por IP cliente |
| `nginx.ingress.kubernetes.io/proxy-body-size` | Tamano max del request body |

## Diferencias staging vs production

| | Staging | Production |
|---|---------|------------|
| Host | `staging.mobilebank.local` | `api.mobilebank.local` |
| Rate limit | 20 rps | 100 rps |
