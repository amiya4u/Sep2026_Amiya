## Day 19 — Helm Basics

### What is Helm
Package manager for Kubernetes.
Instead of applying 5 separate YAML files, package everything into a chart
and deploy with one command.

### Key terms
Chart    — package of K8s YAML templates
Release  — one installed instance of a chart (name: my-nginx)
Revision — version number, increments on every install/upgrade/rollback
Repo     — collection of charts (like apt repository)

### Commands used
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-nginx bitnami/nginx         # install chart, creates revision 1
helm list                                   # show all installed releases
helm show values bitnami/nginx | head -50  # see configurable values
helm upgrade my-nginx bitnami/nginx --set replicaCount=3  # upgrade → revision 2
helm rollback my-nginx 1                   # rollback → creates revision 3
helm history my-nginx                      # show all revisions

### What helm install created automatically
- Deployment
- ReplicaSet
- Pod
- LoadBalancer Service
All from one command — no manual YAML files needed.

### Important — rollback behavior
helm rollback doesn't go back to revision 1.
It creates a NEW revision (3) that matches revision 1's config.
History is always preserved, never deleted.

### --set flag
Override chart values at install/upgrade time without editing files.
helm upgrade my-nginx bitnami/nginx --set replicaCount=3
Tomorrow: convert your own Flask deployment into a custom Helm chart.
