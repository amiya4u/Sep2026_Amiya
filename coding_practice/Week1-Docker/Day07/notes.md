## Day 07 -  Push image to ECR (AWS Elastic Container Registry)

## What I built: 
What you’ll do: Take your Flask app image, tag it, and push it to AWS’s private Docker registry — same concept as Docker Hub but on AWS

## Why we didnt push Day 06 image:

Day 06’s Flask app immediately tries to connect to PostgreSQL on startup. PostgreSQL is a separate container — it’s not bundled inside the image. So if you pull and run the Day 06 image alone, it crashes. The image is only half the picture.

## Why docker-compose.yaml won’t work in Kubernetes:

Compose is a local tool — it reads docker-compose.yaml and spins up multiple containers on your single machine. Kubernetes doesn’t understand docker-compose.yaml at all.

In Kubernetes, you define everything separately using Kubernetes-specific files (called manifests): one for the Flask deployment, one for the Postgres deployment, one for networking between them, one for environment variables. Kubernetes then orchestrates all of that across a cluster.
So what Compose did in one file automatically, Kubernetes makes you do explicitly — that’s actually the point of Phase 3, learning how to do it the Kubernetes way.

Day 07’s simple Flask app needs nothing external — pull and run anywhere. That’s why it’s the right image for Kubernetes practice.

## Commands
docker build --platform linux/amd64 -t day07-web .
aws ecr create-repository --repository-name flask-app_day07 -> This creates repo on ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 255093304980.dkr.ecr.us-east-1.amazonaws.com -> docker login
docker tag day07-web:latest 255093304980.dkr.ecr.us-east-1.amazonaws.com/flask-app_day07:day07-web
docker push 255093304980.dkr.ecr.us-east-1.amazonaws.com/flask-app_day07:day07-web

## Things I learned today: 
- docker tag — maps your local image name to the ECR repo URL
- ECR image URI format: <account-id>.dkr.ecr.<region>.amazonaws.com/<repo-name>:<tag>
- Local image name and ECR name are independent — you connect them via docker tag
- ECR auth token expires every 12 hours — the get-login-password command needs to be re-run each session before pushing
  --platform linux/amd64 — build for AWS even when your Mac is ARM
