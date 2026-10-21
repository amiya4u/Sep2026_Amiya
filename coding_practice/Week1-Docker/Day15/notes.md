## Day 15 — Kubernetes: Secrets
## What I built
Same pattern as ConfigMap, but for sensitive data. One Secret with a DB password, injected into the Deployment.
Secret data:
DB_PASSWORD: mydbpassword123

A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in a container image. Using a Secret means that you don't need to include confidential data in your application code.

## Way to inject Secrets into a pod:

## Per-key (what I used today):
yaml
env:
  - name: PASSWORD
      valueFrom:
        secretKeyRef: 
          name: password
          key: DB_PASSWORD

Control over which keys come in and what they’re named inside the container.
Secret values are base64 encoded in the YAML. We need to encode the value before putting it in the file.
bash
echo -n "mydbpassword123" | base64

## Commands used
bash
kubectl apply -f secrets.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl exec <pod> -- env | grep PASSWORD

## Verification output
PASSWORD=mydbpassword123

kubectl exec day15-deploy-85b775878f-djnkk -- env | grep PASSWORD

kubectl exec <pod> — run a command inside a running pod

-- — separator. Everything after this is the command to run inside the pod, not a kubectl flag. Without it, kubectl tries to parse env as its own flag (which is what broke it earlier).

env — the Linux command that prints all environment variables of the current process. Running it inside the pod means you see the pod’s environment, not your terminal’s.

| — pipe. Takes the output of env and sends it as input to the next command.

grep PASSWORD — filter lines containing “PASSWORD” from the env output

## Secret update behavior
Same as ConfigMap — changes after apply are not reflected in running pods.
Restart required:
kubectl rollout restart deployment <deployment-name>
