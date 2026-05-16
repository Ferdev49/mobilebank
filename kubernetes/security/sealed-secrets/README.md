# SealedSecrets workflow

## Que es un SealedSecret
Un `SealedSecret` es la version cifrada de un `Secret` que SI se puede commitear al repo. El
controller `sealed-secrets-controller` corre en el cluster y solo el tiene la clave privada para
descifrarlo en runtime (genera el Secret de Kubernetes equivalente).

## Flujo
1. Crear el Secret normal (no commitear).
2. `kubeseal -f secret.yaml -w sealed-secret.yaml` cifra usando la pubkey del controller.
3. Commitear el `sealed-secret.yaml`.
4. `kubectl apply -f sealed-secret.yaml` -> el controller lo descifra y crea el Secret real.

## Rotacion de clave del controller
Por defecto el controller rota su clave cada 30 dias. Los SealedSecrets viejos siguen funcionando
porque el controller guarda historial. Si pierdes la clave privada del controller, **TODOS los
SealedSecrets se vuelven irrecuperables** - de ahi la importancia de hacer backup del Secret
`sealed-secrets-key*` en `kube-system`.

```bash
# Backup
kubectl -n kube-system get secret -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > backup.yaml
# Restore en cluster nuevo
kubectl apply -f backup.yaml
kubectl -n kube-system rollout restart deployment sealed-secrets-controller
```

## Archivos generados (cuando corras seal-secrets.sh)
- `kubernetes/base/sealed-secret.yaml` (reemplaza a `secret.yaml`)
- `kubernetes/observability/grafana/sealed-secret.yaml` (reemplaza al de grafana)
