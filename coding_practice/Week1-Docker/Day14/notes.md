## Day 14 — Kubernetes: ConfigMap
## What I built
ConfigMap with 3 env variables
Injected into nginx Deployment using env + configMapKeyRef
Key concepts

ConfigMap — stores non-sensitive config as key-value pairs, decoupled from the container image

## Two ways to inject ConfigMap into a pod:

## Per-key (what I used today):
yaml
env:
  - name: APP_ENV
    valueFrom:
      configMapKeyRef:
        name: day14-config
        key: APP_ENV

Control over which keys come in and what they’re named inside the container.

## All-at-once (envFrom):
yaml
envFrom:
  - configMapRef:
      name: day14-config
All keys injected as-is. Shorter, less control.

## Bug fixed
kubectl exec <pod> --env → unknown flag error
Correct syntax: kubectl exec <pod> -- env (two dashes + space before the command)

## Commands used
bash
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl exec <pod> -- env | grep -E "APP_ENV|APP_VERSION|LOG_LEVEL"

## Verification output
LOG_LEVEL=info
APP_ENV=production
APP_VERSION=1.0.0

kubectl exec day14-deploy-7578f66d75-4cnrp -- env | grep -E "APP_ENV|APP_VERSION|LOG_LEVEL"

kubectl exec <pod> — run a command inside a running pod

-- — separator. Everything after this is the command to run inside the pod, not a kubectl flag. Without it, kubectl tries to parse env as its own flag (which is what broke it earlier).

env — the Linux command that prints all environment variables of the current process. Running it inside the pod means you see the pod’s environment, not your terminal’s.

| — pipe. Takes the output of env and sends it as input to the next command.

grep -E "APP_ENV|APP_VERSION|LOG_LEVEL" — filter lines matching any of those three names. -E enables extended regex so | means OR.

## ConfigMap update behavior
If you change a value in the ConfigMap and re-apply, the running pods
do NOT pick up the change automatically. Values are baked in at pod startup.

To apply the new values, restart the deployment:
kubectl rollout restart deployment <deployment-name>

Exception: if ConfigMap is mounted as a file (volume mount), Kubernetes
updates it automatically without restart.

Rule:
- Env var injection → restart required
- Volume mount → auto-updated
