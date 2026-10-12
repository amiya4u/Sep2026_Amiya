# Day 03 - Docker Networking

## What I built
Run Flask + Redis as two separate containers on a custom network. Flask reads/writes to Redis. Both containers talk to each other by container name.

## Commands used
docker build -t day03-app:v1 .
docker network create demo-network
docker run -d --name redis --network demo-network redis
docker run -d -p 8000:5000 --name day03-app --network demo-network day03-app:v1
docker ps
docker logs day03-app
docker stop day03-app
docker rm day03-app

## What worked
- Dockerfile written from reference, understood each line
- Container ran successfully on port 8000
- Browser showed "Day 03 - Docker Networking! Visit count: 8" and count increase everytime we refresh. 

## What I learned
- --network connects a container to a named network. Containers on the same network can reach each other by container name. Flask connected to Redis using hostname ‘redis’ — no IP needed.
- --network demo-network tells Docker to connect that container to a specific network when it starts
- When both containers are on the same network:
They can reach each other using the container name as hostname
Flask used host='redis' — Docker resolved that name to the Redis container’s IP automatically
Containers NOT on that network cannot reach them (isolation)

## Mistakes and fixes
- Ran: docker run -d --name redis redis --network demo-network
  Error: Redis treated '--network demo-network' as its own config option
  Fix: All Docker flags must come BEFORE the image name
  Correct: docker run -d --name redis --network demo-network redis

## Git Commands used 
cd ~/Desktop/Devops/Sep2026_Amiya
git add .
git commit -m "Day03 - Dockerfile networking with Flask and Redis container"
git push

## Questions I had 
By default 1 container can talk to another container right ? then why we have to create new network? 
- Default network (bridge)
 Yes, by default all containers are on a network called bridge. But there’s a catch — on the default bridge, containers can only talk to each other by IP address, not by name. When you create a custom network (demo-network), Docker gives you DNS resolution — containers find each other by name

- Host networking
--network host removes the network isolation entirely. The container shares your machine’s network stack directly — no port mapping needed, no virtual network
