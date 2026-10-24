## Day 18 — HPA (Horizontal Pod Autoscaler).

## What it does: 
Automatically scales the number of pods up or down based on CPU usage.

## What you’re building:

Deploy nginx with a resource limit set
Create an HPA that scales between 1-5 pods when CPU hits 50%
Generate load to trigger the scaling
Watch pods increase automatically

## Key concepts
HPA needs two things to work:
1. resources.requests.cpu set in the deployment (so it can calculate percentage)
2. metrics-server running in the cluster (so it can read actual usage)

Scale up: fast (within seconds of threshold breach)
Scale down: slow (5 minute cooldown to avoid flapping)

## Files to write:

Day18/deployment.yaml — nginx with CPU resource requests and limits
Day18/hpa.yaml — HPA targeting that deployment

Key thing to figure out from docs: HPA needs resources.requests.cpu set in the deployment, otherwise it can’t measure CPU percentage.

### Commands used
1.  kubectl apply -f deployment.yaml
2.  kubectl apply -f hpa.yaml
3.  kubectl get hpa
4.  Load Generator
    kubectl run load-generator --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://day18-deploy-849b7756d8-xsdwc.default.svc.cluster.local; done"
5. kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
6. kubectl get pods -n kube-system | grep metrics
7. kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
8. kubectl run load-generator --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://$(kubectl get pod -l app=nginx -o jsonpath='{.items[0].status.podIP}'); done"
9. kubectl delete pod load-generator

## Issues faced 
- In hpa.yaml apiVersion to scaleTargetRef was missing. Added that. 
- When ran command <kubectl get hpa> cpu: unknown/50%, and it was unknown. Than command <kubectl top pods> and got error error: Metrics API not available —  this means metrics server is missing and HPA can’t read CPU. We had to run command 5. Command 5 installs the metrics server — a component that collects CPU/memory usage from all pods in the cluster. Without it, HPA has no data to work with.
- Then metrics server started running but it was not ready (0/1).This is a common issue — metrics-server needs a flag to work in lab environments. Ran command 7 to fix that. After this cpu: 0%/50%, which means HPA is getting metrics. 
- Next ran command 8 to generate load. Command 8 and 4 is same but in 8 we are getting the ip of the pod via command not hard coded. 

## Full HPA cycle
cpu: 0% → load generator starts → cpu: 55% → exceeds 50% threshold
REPLICAS: 1 → 2 (HPA scaled up to handle the load)
CPU drops to 32-31% (2 pods sharing the load now)

## Explanation of each command
1. kubectl run load-generator --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://<pod-ip>; done"

kubectl run load-generator — create a pod named load-generator
--image=busybox — use busybox image (tiny Linux with basic tools)
--restart=Never — run once, don’t restart (makes it a Pod, not a Deployment)
-- — separator, everything after is the command to run inside the pod
/bin/sh -c "..." — run a shell with this command
while true; do wget ...; done — infinite loop hitting the nginx pod URL to generate CPU load. 

2. kubectl get hpa
Shows all HorizontalPodAutoscalers — current CPU%, min/max replicas, current replicas.

3. kubectl top pods
Shows live CPU and memory usage of all pods. Like top command in Linux but for pods. Needs metrics-server to work.

4. kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml  
Same as kubectl apply -f file.yaml but the file is a URL. Downloads and applies the metrics-server manifest directly from GitHub.

5. kubectl get pods -n kube-system | grep metrics
-n kube-system — look in the kube-system namespace (where K8s system components live, not your apps)
| grep metrics — filter only lines containing “metrics”

6. kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl patch — modify a specific field in a running resource without rewriting the whole YAML
--type='json' — use JSON patch format
--kubelet-insecure-tls — skip TLS certificate verification when talking to kubelets (needed in lab environments where certs aren’t properly set up)
You won’t use patch often — it’s for quick fixes without editing the full YAML.

7. kubectl run load-generator --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://$(kubectl get pod -l app=nginx -o jsonpath='{.items[0].status.podIP}'); done"
The $(...) part runs a command inside the command:

kubectl get pod -l app=nginx — find pods with label app=nginx
-o jsonpath='{.items[0].status.podIP}' — extract just the IP address of the first pod
The result gets inserted into the wget URL automatically
So instead of you manually finding the pod IP and typing it, the command finds it itself.

8. kubectl get hpa -w
-w = watch. Keeps running and prints a new line every time something changes. Same as kubectl get pods -w you used on Day 16.
