
## Day 21 - Persistent Volume + PVC**

## What I did:**
- Created a PersistentVolume (PV) of 1Gi using hostPath
- Created a PersistentVolumeClaim (PVC) requesting 500Mi
- Created a Pod that mounts the PVC at `/data`
- Proved data survives pod deletion

**Key concepts:**

## PV vs PVC:
- PV = actual storage (created by admin), lives on the node
- PVC = request for storage (created by developer)
- Pod always talks to PVC, never to PV directly
- PVC is the abstraction layer between app and storage

## How PVC finds a PV:
Kubernetes matches on 3 things:
1. `storageClassName` must match (manual in both our files)
2. `accessModes` must match (ReadWriteOnce in both)
3. PV capacity must be >= PVC request
One PVC binds to exactly one PV. Once bound, that PV is reserved — no other PVC can use it.

## hostPath vs production:**
- `hostPath` = stores data on the Kubernetes node (for local/lab use). 
/data in pv.yaml = /data on the Kubernetes node (the host machine)
- mountPath: /data in pod.yaml = /data inside the container
- In production: use AWS EBS, GCP PD, NFS etc — only PV changes, pod and PVC stay the same

## Data flow:**
```
Container /data → PVC → PV → Node's /data folder
```

When you write a file to /data inside the container, it actually gets stored in /data on the node. So if the pod dies and restarts, the data is still there on the node.

hostPath is used for local testing. In production you’d use AWS EBS or a network drive instead — but the pod and PVC files stay exactly the same. Only the PV changes.

## Commands:
```bash
kubectl get pv
kubectl get pvc
kubectl describe pvc <name>    # shows which PV it bound to
```

**Status to check:**
- PV STATUS = `Bound` means a PVC claimed it
- PVC STATUS = `Bound` means it found a matching PV

## Validation 
kubectl exec task-pv-pod -- sh -c "echo 'hello from pod' > /data/test.txt"
kubectl exec task-pv-pod -- cat /data/test.txt
kubectl delete pod task-pv-pod
kubectl apply -f pod.yaml
kubectl exec task-pv-pod -- cat /data/test.txt

Data survived the pod deletion. That's PersistentVolume working exactly as designed.

Pod died → data stayed on the node → new pod came up → data still there.

