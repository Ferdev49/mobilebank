# Persistent Volumes (Day 16)

## El problema

Los pods son efimeros. Cualquier archivo escrito al filesystem del contenedor desaparece cuando el
pod se reinicia (rolling update, OOM kill, drenado de nodo). Para datos que deben sobrevivir
necesitamos un volumen persistente.

## El modelo de K8s

```
PersistentVolume  (PV)   <-- recurso fisico (disco real, NFS, EBS, etc.)
       ^
       |  bind
       |
PersistentVolumeClaim (PVC)  <-- "yo necesito 1Gi RWO"
       ^
       |  mount
       |
Pod  --->  volumeMounts
```

En la mayoria de clusters modernos no creas PVs a mano; defines un `PVC` y un **StorageClass** crea
el PV dinamicamente. En Docker Desktop y Minikube la storageClass por defecto usa hostpath.

## En MobileBank

| Recurso | Archivo |
|---------|---------|
| `PersistentVolumeClaim mobilebank-data` | `kubernetes/base/pvc.yaml` |
| Mount en `/app/data` | `kubernetes/base/deployment.yaml` |
| Modulo Terraform | `terraform/modules/kubernetes-app/pvc.tf` |

Tamano por environment:
- staging: 1Gi
- production: 5Gi

## Que escribe la app en el PVC

`app.py` registra cada transferencia exitosa en `/app/data/transfers.log` y configura un
`FileHandler` adicional en `/app/data/app.log`. Si el PVC no esta montado (entorno local), la app cae
silenciosamente a stdout-only.

## Validacion

```bash
# Ver el PVC y su PV asociado
kubectl -n mobilebank-staging get pvc,pv

# Generar transferencias y verificar persistencia entre reinicios
curl -H "Host: staging.mobilebank.local" -X POST http://localhost/api/transfer \
  -H "Content-Type: application/json" \
  -d '{"from_account":1,"to_account":2,"amount":100}'

POD=$(kubectl -n mobilebank-staging get pod -l app=mobilebank-api -o name | head -1)
kubectl -n mobilebank-staging exec "$POD" -- cat /app/data/transfers.log

# Borrar el pod y comprobar que el log persiste
kubectl -n mobilebank-staging delete "$POD"
sleep 15
NEW_POD=$(kubectl -n mobilebank-staging get pod -l app=mobilebank-api -o name | head -1)
kubectl -n mobilebank-staging exec "$NEW_POD" -- cat /app/data/transfers.log
```

## Limitaciones de un PVC RWO

`ReadWriteOnce` significa que un solo nodo puede montarlo en modo lectura/escritura a la vez. Con
multiples replicas en distintos nodos, todas las replicas podrian no obtener acceso simultaneo al
volumen. Opciones para Week 7+:

- **RWX** con NFS, EFS o Azure Files.
- Sacar el log del filesystem y mandarlo a un sink central (Loki/Elasticsearch).
- Mover transferencias a una BD real (Postgres / CockroachDB).
