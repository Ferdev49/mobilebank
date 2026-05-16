# Network Policies + Pod Security Standards (Day 25)

## Modelo de NetworkPolicy: default-deny + whitelist
1. **default-deny-all** en cada namespace de mobilebank: bloquea TODO ingress y egress.
2. **allow-app-ingress**: permite trafico al puerto 5000 desde namespaces `ingress-nginx` y `observability` (este ultimo para que Prometheus scrape `/metrics`).
3. **allow-app-egress**: permite DNS a kube-dns, trafico al mismo namespace, y trafico a observability.
4. **observability-egress-all** + **promtail-egress**: el observability namespace tiene reglas relajadas porque necesita scrape global.

## Pod Security Standards
Niveles K8s estandar (mas estricto cada uno):
| Nivel | Permite |
|---|---|
| privileged | Todo |
| baseline | Bloquea hostNetwork, privileged, hostPath inseguros |
| restricted | + runAsNonRoot, drop ALL caps, no seccomp Unconfined, readOnlyRootFilesystem recomendado |

Configuracion:
- `mobilebank-staging`: `enforce=baseline`, `audit/warn=restricted`. Permite warnings sin bloquear.
- `mobilebank-production`: `enforce=restricted`. Bloquea pods no-conformes.

## Hardening del deployment
Para que el pod cumpla `restricted`:
- `runAsNonRoot: true` + `runAsUser: 1000`
- `allowPrivilegeEscalation: false`
- `readOnlyRootFilesystem: true`
- `capabilities.drop: ["ALL"]`
- `seccompProfile.type: RuntimeDefault`
- Volume `tmp` (emptyDir) montado en `/tmp` (Flask/gunicorn necesita escribir ahi)

## Dockerfile
Cambios:
- Crear `app` user uid 1000.
- `chown -R app:app /app` antes del USER switch.
- `USER 1000` al final.

## Terraform module
`main.tf` ahora tiene:
- `pod.spec.security_context` (run_as_non_root, fs_group 1000, seccomp).
- `container.security_context` (drop ALL caps, read_only_root_filesystem, no priv escalation).

## Validar isolation
```bash
# DEBE fallar (sin egress salvo DNS y same-ns)
kubectl run -n mobilebank-staging test --rm -it --image=busybox -- wget -T 3 http://example.com

# DEBE pasar (DNS a kube-dns)
kubectl run -n mobilebank-staging test --rm -it --image=busybox -- nslookup kubernetes.default
```
