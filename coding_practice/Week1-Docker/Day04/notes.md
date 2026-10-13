# Day 04 - Docker Volume

## What I built
The problem with Day 3: Stop and remove your Redis container. Start it again. Visit count resets to 0. All data is gone. In production, that’s a disaster.
Today’s goal: Visit count survives container stop, remove, and restart.

## Commands used
docker build -t day04-app:v1 .
docker volume create redis-data
docker run -d --name redis --network demo-network -v redis-data:/data redis
docker run -d -p 8000:5000 --name day04-app --network demo-network day04-app:v1
docker ps
docker logs day04-app
docker stop day04-app
docker rm day04-app

## What worked
- Dockerfile written from reference, understood each line
- Container ran successfully on port 8000
- Stopped and removed redis container at count 8 and started with same volume. Count count starts at 9 on next request. 
- Browser showed "Day 04 - Docker Volumes! Retained Visit count: 9" 

## What I learned
- volume lives independently of the container. I deleted the container, the data stayed in redis-data, new container picked it up and continued from last count.
- when we create volume , docker creates a local volume on host and while running the container we map this path to the path where that particular stores data by default. In this case /data. Redis stores its persistence files in /data by default. That's why we map the volume to /data — so Redis writes to our named volume instead of the container's temporary filesystem.
- --mount (verbose, new way) and -v (short, old way) both does same thing, The difference is syntax and readability. 
docker run -v redis-data:/data redis 
docker run --mount type=volume,source=redis-data,target=/data redis

## Observation related to volume
- docker volume ls - this listed lots of volumes. Those are anonymous volumes — Docker created them automatically with random IDs, which means you (or some image) didn’t give them a name. To see what each one was used for:
docker volume inspect 2c488eb56c71ef84f57152fb614396c80e6ccaca08bcf74f8f5c00eb5a0b2584
Look at the Labels field — it sometimes shows which container created it. But often it’s empty and you can’t tell anymore, especially if the container that created it is already deleted. 
Clean up those anonymous volumes (safe to delete if no container is using them):
docker volume prune
This removes all volumes not attached to any container. Since those random-ID ones are from old experiments, they’re almost certainly safe to prune

## Git Commands used 
cd ~/Desktop/Devops/Sep2026_Amiya
git add .
git commit -m "Day04 - Docker Volume"
git push


