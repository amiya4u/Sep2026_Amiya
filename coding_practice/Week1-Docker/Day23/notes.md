
## Day 23 - Namespace

## What I did:
- Created `dev` and `prod` namespaces
- Deployed a single pod in `dev`
- Deployed 3 replicas in `prod`
- Verified isolation — `kubectl get pods` shows nothing without `-n` flag

## Key concepts:**

## What is a Namespace:**
- A way to divide one cluster into virtual clusters
- Resources in different namespaces are isolated from each other
- Default namespace is used when none is specified

## Real world use:**
- `dev` — developers test here
- `staging` — pre-production testing
- `prod` — live traffic
- `monitoring` — Prometheus, Grafana

## How to assign namespace:**
```yaml
metadata:
  name: my-app
  namespace: dev    # this line puts it in dev namespace
```

## Commands:**
```bash
kubectl get pods                  # default namespace only
kubectl get pods -n dev           # dev namespace
kubectl get pods -n prod          # prod namespace
kubectl get pods --all-namespaces # everything
kubectl get namespaces            # list all namespaces
```
