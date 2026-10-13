# Day 05 - Docker Compose

## What I built
The problem with Days 3 & 4: You ran 4-5 separate commands to get everything up — create network, create volume, run redis, run flask. In real projects with 5+ services, that’s unmaintainable.
Today’s goal: One file describes everything. One command brings it all up.


## Commands used
Copied Dockerfile for the Flask app from Day 03
Wrote docker compose file. 
docker compose up -d
docker compose down # stops and removes containers (volume stays)
docker compose up -d   # bring back up

## What worked
- docker compose down # stops and removes containers (volume stays)
  docker compose up -d   # bring back up
- Visited browser — count continue from where it left off, not reset to 0


## What I learned
Few thing to keep in mind while creating compose file: 
- No need to create network manually. Compose automatically creates a default network (named <project>_default) and puts all services on it, so web can reach redis by the service name 'redis' without doing anything extra. But if you want custom network names or to connect to an external network, you can define networks explicitly in docker-compose.yml. 
- The top-level volumes key registers it with Docker so it persists between compose down and compose up cycles. 
- yaml identation has to be correct. 
- depends_on: tells Compose to start redis before web. Without it, web might 
  start before redis is ready and crash on connection.

## Observation related to compose sequance 
- When ran compose up first time below was the sequence : 
 ✔ Image day05-web         Built                                                                                     2.1s
 ✔ Network day05_default   Created                                                                                   0.0s
 ✔ Volume day05_redis-data Created                                                                                   0.0s
 ✔ Container day05-redis-1 Started                                                                                   0.1s
 ✔ Container day05-web-1   Started                                                                                   0.2s
Then I did some code changes as I wanted to update the print statement. Compose up sequence was below : 
 ✔ Container day05-redis-1 Started                                                                                   0.1s
 ✔ Container day05-web-1   Started                                                                                   0.1s
As those images where already there it didnt built again. I removed those images and ran compose up again. Better way to force rebuild without deleting image manually:
docker compose up -d --build
This tells Compose to rebuild the image even if one already exists. You’ll use this every time you change app code — much faster than delete + up.

## Git Commands used 
cd ~/Desktop/Devops/Sep2026_Amiya
git add .
git commit -m "Day05 - Docker Compose"
git push
