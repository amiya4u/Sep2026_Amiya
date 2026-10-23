## Day 17 — Deploy Flask App on Kubernetes

### What I built
Flask app from Docker Hub deployed on K8s with NodePort Service.
3 replicas running across 2 worker nodes.

### Image journey
Built in Docker phase → pushed to ECR (Day 07) →
pulled locally → tagged and pushed to Docker Hub →
KodeKloud lab pulled from Docker Hub automatically on kubectl apply

### Why Docker Hub instead of ECR
KodeKloud lab has no AWS CLI → can't authenticate to ECR.
Docker Hub is public → no credentials needed.

## Commands used for Image push

ECR login: 
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 255093304980.dkr.ecr.us-east-1.amazonaws.com
Pull Image: 
    docker pull 255093304980.dkr.ecr.us-east-1.amazonaws.com/flask-app_day07:day07-web
Login to docker: 
    docker login - this will be one time device confirmation code and need to login to docker hub via browser. Once login to browser is done then next step
Tag and Push image to docker hub : 
    docker tag 255093304980.dkr.ecr.us-east-1.amazonaws.com/flask-app_day07:day07-web amiya4u/flask-capstone:v2
    docker push amiya4u/flask-capstone:v2

### Key concept — Node vs Pod
Node = EC2 instance (the machine)
Pod = service running on that machine
Container = the process inside the pod
One node can run multiple pods.

### Port mapping — Docker vs Kubernetes
Docker: docker run -p 8080:5000 → host:container in one command
Kubernetes: split across two files
  deployment.yaml → containerPort: 5000 (what app listens on)
  service.yaml → targetPort: 5000 (must match containerPort)
               → nodePort: 31205 (external access)
nodePort is like host port when running docker.

### NodePort routing
Port 31205 opens on ALL nodes automatically.
Any node IP works — K8s routes traffic to the right pod.
curl 10.244.28.206:31205 → Day 07 - Pushed to ECR!

### Commands used
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get pods -o wide        # see which pod runs on which node
kubectl get nodes -o wide       # get node IPs

### Two ways to access
ClusterIP (internal only): curl 172.20.27.72:80
NodePort (external):       curl 10.244.28.206:31205
curl <node-ip>:31205
curl <ClusterIP>:80


