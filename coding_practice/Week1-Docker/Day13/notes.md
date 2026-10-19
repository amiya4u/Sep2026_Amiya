## Day 13 — Kubernetes: Deployment + NodePort Service
What I built
nginx Deployment with 3 replicas
NodePort Service to expose it

## Key concepts

# Deployment

apiVersion: apps/v1 (not v1 — that was my bug today)
replicas: 3 — K8s maintains exactly 3 pods always
selector.matchLabels must match template.metadata.labels — this is how Deployment finds its pods

# Service — NodePort

selector: app: nginx — finds pods with this label and routes traffic to them
Three ports:
port: 80 — Service’s port inside the cluster
targetPort: 80 — port on the pod/container
nodePort: 31205 — port opened on the node for external access (range: 30000-32767)

# Traffic flow:
External → Node:31205 → Service:80 → Pod:80

# Two ways to verify:

ClusterIP (internal): curl 172.20.89.124:80  - kubectl get all - Get the cluster IP where app is running
NodePort (external):
kubectl get nodes -o wide
curl <node-ip>:31205 -     10.244.51.129 is the actual node’s IP. Port 31205 is the nodePort field — opened on every node in the cluster. This is how external traffic reaches your service

selector — how the Service finds which pods to send traffic to.

In your service:

yaml
selector:
  app: nginx

This means: “send traffic to any pod that has the label app: nginx”. Your deployment creates pods with exactly that label, so the service automatically finds them. Change the label in one place and they disconnect.

ports — three different port numbers, each with a job:

yaml
ports:
  - port: 80        # port on the Service itself (inside cluster)
    targetPort: 80  # port on the pod/container
    nodePort: 31205 # port on the actual node (external access)

Think of it as a chain:

External traffic
      ↓
  Node:31205        ← nodePort  (you curl this)
      ↓
  Service:80        ← port      (internal cluster address)
      ↓
  Pod:80            ← targetPort (where nginx actually listens)

So when you curl <node-ip>:31205, traffic flows through that chain and hits nginx inside the pod.

port and targetPort are often the same (both 80) but don’t have to be — if your app runs on port 5000 you’d set targetPort: 5000
nodePort must be between 30000-32767 — that’s the Kubernetes reserved range for external access

# Bug fixed
Wrote apiVersion: v1 for Deployment → should be apps/v1
Deployments, ReplicaSets, DaemonSets all use apps/v1
Only Pod, Service, ConfigMap, Secret use v1

# Commands used
bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get all
kubectl get nodes -o wide
curl 10.244.51.129:31205 - > 10.244.51.129 is a private IP inside the KodeKloud lab environment. It’s not reachable from your laptop’s browser. To access from browser you’d need a public IP — which only happens when the node is an actual cloud VM (like an EC2) with a public IP, or when you use a LoadBalancer service type (which provisions an external load balancer on AWS/GCP).
