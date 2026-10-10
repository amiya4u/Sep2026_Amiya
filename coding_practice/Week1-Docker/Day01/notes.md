# Day 01 - Docker Basics

## What I built
Flask app containerized with Docker. Built image, ran container, verified in browser.

## Commands used
docker build -t day01-app:v1 .
docker run -d -p 8000:5000 --name day01-app day01-app:v1
docker ps
docker logs day01-app
docker exec -it day01-app bash -> to go inside the docker. 
ls /app
app.py	requirements.txt
docker stop day01-app
docker rm day01-app

## What worked
- Dockerfile written from reference, understood each line
- Container ran successfully on port 8000
- Browser showed "Day 01 - Docker Working!"
- Could go inside container and see files

## What I learned
- Dockerfile instructions: FROM, WORKDIR, COPY, RUN, EXPOSE, CMD
- Port mapping: host:container (-p 8000:5000)
- netstat -an | grep LISTEN - this is the command if I want to know which ports in use
- Container is isolated - has its own filesystem
- docker exec lets you go inside a running container

## Git Commands used 
cd ~/Desktop/Devops/Sep2026_Amiya
git add .
git commit -m "Day01 - Dockerfile build and run Flask app"
git push

