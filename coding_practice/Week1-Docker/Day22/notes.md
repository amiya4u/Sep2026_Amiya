
## Day 22 - StatefulSet

## Concept first:
A regular Deployment gives pods random names (pod-abc123, pod-xyz456) and no guaranteed order. That’s fine for stateless apps like nginx.

But databases need:
Stable names — mysql-0, mysql-1, mysql-2 always
Stable storage — each pod gets its own PVC, not shared
Ordered startup — pod-0 starts first, then pod-1, then pod-2

## What I did:
- Created 3 PVs manually (no storage class in lab)
- Created a headless Service
- Created a StatefulSet with 3 replicas
- Watched PVCs and pods get created one by one in order

**Key concepts:**

**StatefulSet vs Deployment:**

| | Deployment | StatefulSet |
|---|---|---|
| Pod names | random | stable (web-0, web-1, web-2) |
| Storage | shared/none | one PVC per pod |
| Startup | all at once | ordered (0 first) |
| Use case | stateless apps | databases |

**volumeClaimTemplates:**
- StatefulSet creates PVCs automatically — one per pod
- Names follow pattern: `<claim-name>-<pod-name>` → `www-web-0`, `www-web-1`

**Headless Service (`clusterIP: None`):**
- Gives each pod a unique DNS name inside cluster
- `web-0.nginx`, `web-1.nginx` etc.
- Used so pods can talk to a specific pod by name (e.g. replicas connecting to primary DB)

**Commands:**
```bash
kubectl get statefulset
kubectl get pvc
kubectl get pods
```

## Notes relaetd to this task 

## Stateless vs Stateful:
Nginx is stateless — every request is independent. You can kill any pod and the next request goes to another pod and it doesn’t matter. No pod remembers anything.

A database is stateful — it has data. If you kill mysql-0 randomly and bring up a replacement, it won’t have the same data as the original. Order and identity matter.
That’s why databases need StatefulSet and nginx is fine with Deployment.

## Ingress — what is it:
Right now to access your app you use NodePort — a port on the node like 31205.
In real life you want myapp.com to route to your app. Ingress does that — it’s a reverse proxy inside Kubernetes.
User → myapp.com → Ingress → Service → Pod
One Ingress can route multiple domains:

myapp.com → flask service
myapp.com/admin → admin service
api.myapp.com → api service

Instead of exposing 10 NodePorts, you expose one Ingress.

## What Stateful creates: 
Pods — but with stable names: web-0, web-1, web-2 (not random)
One PVC per pod — www-web-0, www-web-1, www-web-2 (from volumeClaimTemplates)
No ReplicaSet — StatefulSet manages pods directly

Compare:

Deployment	 | StatefulSet
Pod names |	random (pod-abc123) | stable (web-0, web-1)
Storage	 |  shared or none	|  one PVC per pod
Startup order |	all at once |  one by one (0 first)
Use case |	stateless apps	|  databases

The StatefulSet itself is the controller — like a smarter Deployment that remembers identity.

## Why we need Headless Service in StatefulSet
Now add this:

StatefulSet = like Deployment, but for apps that need identity (databases). Pods get stable names and their own storage.
Headless Service = not for outside world access. It’s for pods to talk to each other by name inside the cluster.

So your summary becomes:

Pod → one container
Deployment → multiple pods, stateless
StatefulSet → multiple pods, stateful (each pod has identity + own storage)
Service (normal) → pods talk to outside world, or random pod inside cluster
Service (headless) → pods talk to a specific pod inside cluster by name

with StatefulSet, volumeClaimTemplates creates PVCs automatically — one per pod. So you need to pre-create 3 PVs manually.

## What is storageClassName
It’s just a label that connects PV and PVC together.

Think of it like a category name:

PV says: “I belong to category manual”
PVC says: “I want storage from category manual”
Kubernetes matches them

That’s it. It’s not a real thing that exists — just a string both sides agree on so Kubernetes knows which PVs are available for which PVCs.

In production, storage classes are real — they tell Kubernetes to automatically create storage on AWS EBS or GCP disk. But in our lab there’s no cloud, so we create PVs manually and use a made-up class name.

# How mountPath is mentioned in container:
each pod gets its OWN /data/ inside its own container. They don’t share it.

web-0 container → /data/ → www-web-0 PVC → pv-0 → node /data/pv-0
web-1 container → /data/ → www-web-1 PVC → pv-1 → node /data/pv-1
web-2 container → /data/ → www-web-2 PVC → pv-2 → node /data/pv-2

Same mountPath: /data/ in the spec, but each pod gets its own separate storage. That’s the whole point of StatefulSet — isolated storage per pod.

## Questions I got during this task 

## Q: Your database pods keep losing data on restart. How do you fix it?**

**A:** The issue is that the app is deployed as a Deployment without persistent storage. Container filesystem is ephemeral — when pod restarts, data is gone.

Fix:
1. Switch from Deployment to StatefulSet — gives each pod stable identity and its own storage
2. Create PersistentVolumes (or use a StorageClass in production)
3. Add `volumeClaimTemplates` in StatefulSet — automatically creates one PVC per pod
4. Mount the PVC inside the container at the data directory

After fix — each pod (`mysql-0`, `mysql-1`) has its own PVC bound to its own PV. Pod restarts, PVC stays, data stays.

---

## Q: What's the difference between a Deployment and StatefulSet?**

**A:** Deployment is for stateless apps — pods are identical, names are random, can be killed and replaced in any order. StatefulSet is for stateful apps like databases — pods have stable names (`web-0`, `web-1`), each has its own PVC, and they start and stop in order. You'd use StatefulSet for MySQL, MongoDB, Kafka — anything where identity and data persistence matter.

---

## Q: Why does a StatefulSet need a headless Service?**

**A:** A normal Service load balances — you can't control which pod you hit. For a database cluster, replicas need to connect specifically to the primary. A headless Service (`clusterIP: None`) gives each pod a unique DNS name like `mysql-0.mysql` so pods can address each other directly by name.
