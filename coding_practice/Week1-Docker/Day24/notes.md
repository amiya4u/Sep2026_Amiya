## Day 24 — Ingress

Concept:
Right now you access apps via NodePort (node-ip:31205). In production nobody uses that — you use a domain like myapp.com.

Ingress is a reverse proxy inside Kubernetes that routes traffic by domain or path to the right Service.

User → myapp.com → Ingress → Service → Pod

## What is ingress controller
Ingress controller is a piece of software that runs inside a Kubernetes cluster to manage external (Layer 7) HTTP and HTTPS traffic from outside the cluster to services running inside it. 
<Ingress-nginx> is the Ingress controller made by the nginx company. It’s the most popular Ingress controller. There are others — Traefik, HAProxy, AWS ALB — but ingress-nginx is what most people use.
The name is confusing but it routes traffic to ANY service (flask, node, whatever) — not just nginx apps.

## How to install ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/baremetal/deploy.yaml

## What you’ll build:

- Deploy 2 apps (flask + nginx)
  wrote nginx.yaml and flaskapp.yaml.  
- Create Services for both
  Both Deployment separate service to route traffic to each app.
- Create an Ingress that routes:
/ → nginx
/flask → flask
ingress.yaml — routes / to nginx, /flask to flask

So files are :
nginx.yaml — Deployment + Service (ClusterIP)
flask.yaml — Deployment + Service (ClusterIP)
ingress.yaml — routing rules

## Ports in Service 
In a Service, ports section has two fields:
port — the port the Service listens on (inside the cluster)
targetPort — the port the container is actually running on
For nginx, the container runs on port 80. So both are 80.
Request → Service port 80 → forwards to → container port 80

For your flask app — container runs on port 5000:
yaml
ports:
  - port: 80        # service listens on 80
    targetPort: 5000  # forwards to flask container on 5000

So from inside the cluster you call the Service on port 80, and it forwards to flask on 5000.

## Mistakes in code
`nginx.yaml` and `flaskapp.yaml` are correct. ✅

`ingress.yaml` has 5 issues:

1. **Two separate Ingress objects** — should be one Ingress with both paths
2. **`ingressClassName`** — should be `nginx` (not `nginx-example` or `flask-example`)
3. **Flask port `8000`** — should be `80` (that's what the Service listens on)
4. Ingress must point to the Service name, not the Deployment name
5. Kubernetes names must be all lowercase

Rewrite `ingress.yaml` as one single Ingress


## what is ingressClassName
It tells Kubernetes which Ingress controller to use.
We installed ingress-nginx controller. That controller registers itself with the class name nginx. So when your Ingress says ingressClassName: nginx — it means “use the nginx controller to handle this”.

If you had multiple controllers installed (nginx + traefik), this is how you’d pick which one handles your traffic.

User → Ingress :80 → nginx-Service → Pod

## The Full flow :
Exactly right! Full flow:

```
User → Ingress :80 → nginx-Service → Pod
```

Breaking down each hop:

**1. User → Ingress**
```
http://<cluster-ip>/   →  my-ingress  (routes based on path)
```

**2. Ingress → Service**
```
ingress.yaml says:
  backend:
    service:
      name: nginx-Service   ← finds Service by name
      port: 80
```

**3. Service → Pod** (this is what you're asking)
```yaml
# nginx-Service selector:
selector:
  app: nginx-deployment

# nginx Pod label:
labels:
  app: nginx-deployment     ← MATCHES → Service sends traffic here
```

Service finds pods by **matching labels**. Any pod with `app: nginx-deployment` gets traffic.

So the complete chain:

```
User
  ↓  path: /
Ingress (my-ingress)
  ↓  name: nginx-Service, port: 80
Service (nginx-Service)
  ↓  selector: app=nginx-deployment
Pod (nginx-deployment-xxxx)
  ↓  containerPort: 80
nginx running inside
```

Same for flask:
```
User
  ↓  path: /flask
Ingress → flask-Service → pod with app=flask-deployment → port 5000
```
The **label is the glue** everywhere in Kubernetes — Service finds Pods by label, Ingress finds Service by name.

## rewrite-target annotation

When Ingress forwards /flask to flask-service, it sends the full path /flask to the app.
But the flask app only has a route at / — it doesn't know /flask.

Fix: add rewrite annotation so Ingress strips the path before forwarding.

annotations:
  nginx.ingress.kubernetes.io/rewrite-target: /

What happens:
User requests: /flask
Ingress receives: /flask
After rewrite → sends: /    to flask-service
Flask app sees: /           ← has this route, returns response

## NodePort vs ClusterIP — how to find the port

ClusterIP — internal only. Pods talk to each other using this. Cannot access from browser or outside.

NodePort — exposes the service on a port on every node. External traffic enters here.

To find the NodePort of ingress controller:
kubectl get svc -n ingress-nginx

Output shows:
80:31674/TCP
 ↑   ↑
 │   └── NodePort (external port on every node)
 └────── port inside the cluster

So curl http://<any-node-ip>:31674/ goes through Ingress.
curl http://<cluster-ip>:80/ bypasses Ingress — goes directly to the service.



