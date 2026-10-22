## Day 16 — Kubernetes: Liveness + Readiness Probes

### What I built
nginx Deployment with livenessProbe and readinessProbe.
Deliberately broke liveness probe to observe CrashLoopBackOff behavior.

---

### Three probe types

| Probe | Purpose | On failure |
|---|---|---|
| startupProbe | App is slow to boot — disables liveness/readiness until app starts | Pod killed if never succeeds |
| livenessProbe | App is running but frozen/deadlocked | Container restarted |
| readinessProbe | App is running but not ready for traffic | Removed from load balancer, NOT restarted |

### How probes are different from ReplicaSet

ReplicaSet answers: "how many pods exist?"
- If a pod is deleted or crashes → creates a new one
- Only checks if pod is running, not if the app inside is healthy
- A frozen/deadlocked app still counts as running to ReplicaSet

Liveness probe answers: "is the app inside the pod actually working?"
- K8s calls your endpoint every N seconds
- If it fails → restarts the container inside the pod
- ReplicaSet still sees the pod as existing

Real scenario: Flask app has memory leak, stops responding after 2 hours.
Process is still running so ReplicaSet does nothing.
Liveness probe gets no response → restarts container automatically.
Without probe → app is silently dead until someone notices.
With probe → K8s self-heals.

---

### Probe config used today

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /
    port: 80
  periodSeconds: 5
```

K8s added defaults automatically:
- successThreshold: 1 — 1 success to mark healthy
- failureThreshold: 3 — 3 failures before acting

---

### Important: /health and /ready paths

For nginx — / exists by default, probes work out of the box.
For a real app (Flask) — you must add the endpoints yourself:

```python
@app.route('/health')
def health():
    return 'ok', 200

@app.route('/ready')
def ready():
    return 'ok', 200
```

K8s just calls the URL — the app is responsible for responding.

---

### CrashLoopBackOff — how it works

Changed liveness path to /broken → nginx returns 404 → probe fails.

Restart cycle:
1. Container starts → nginx boots → pod shows 1/1 Running
2. Probe hits /broken every 10s
3. Fails 3 times (3 × 10s = 30s)
4. K8s restarts container → RESTARTS count +1
5. Repeat forever

Why pod shows Running even when broken:
Probe needs to fail 3 times before acting.
During those 30s pod looks healthy. Problem only visible by watching
RESTARTS climb — went 0 → 1 → 2 → 3 → 4 every 30 seconds.

Exponential backoff:
Restart 1 → wait 10s
Restart 2 → wait 20s
Restart 3 → wait 40s
Restart 4 → wait 80s
Restart 5 → wait 160s
...caps at 5 minutes

K8s never gives up. Retries every 5 minutes indefinitely.

To confirm probe failure:
kubectl describe pod <pod-name>
→ Events section shows: "Liveness probe failed: HTTP probe failed with statuscode: 404"

---

### Commands used
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get pods -w
kubectl describe pod <pod-name>
```
