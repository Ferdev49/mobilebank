# Sealed Secrets (Day 24)

## Por que
Hasta ahora `kubernetes/base/secret.yaml` y `grafana/secret.yaml` tienen valores en base64. base64
no es cifrado, cualquiera con acceso al repo los puede leer. SealedSecrets cifra con la pubkey del
controller, y solo el controller en el cluster puede descifrarlos.

## Componentes
- `sealed-secrets-controller` (instalado por `scripts/install-sealed-secrets.sh` desde release upstream).
- CLI `kubeseal` (instala manual: brew, choco, o tarball).
- `scripts/seal-secrets.sh` que convierte los Secrets actuales a SealedSecrets.
- `kubernetes/security/sealed-secrets/README.md` con workflow y backup/restore.

## Workflow operativo
```bash
# Una vez por cluster
./scripts/install-sealed-secrets.sh

# Cada vez que cambies un Secret
./scripts/seal-secrets.sh
git add kubernetes/**/sealed-secret.yaml
git commit -m "rotate sealed secrets"
```

## .gitignore (opcional)
En esta entrega NO modificamos `.gitignore` porque los `secret.yaml` actuales contienen valores DEMO
(base64 de "demo-api-key-change-me" etc.) y los necesitamos en el repo para reproducibilidad del lab.
Cuando migres a SealedSecret en un cluster real, puedes:
1. Generar el `sealed-secret.yaml` con `kubeseal`.
2. Borrar el `secret.yaml` con valores reales.
3. Agregar `secret.yaml` al `.gitignore` y dejar SOLO `sealed-secret.yaml`.

## Backup CRITICO
La clave privada del controller en `kube-system/sealed-secrets-key*` es la unica forma de descifrar
todos los SealedSecrets. Backup obligatorio:
```bash
kubectl -n kube-system get secret -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml \
  > backup-sealed-secrets-key.yaml
# Guardar en lugar seguro fuera del repo.
```
