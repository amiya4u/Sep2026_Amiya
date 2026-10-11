# Day 02 - Multistage Docker

## What I built
Flask app containerized with Multistage Dockerfile. Built image, ran container, verified in browser.

## Commands used
docker build -t day02-app:v2 .
docker run -d -p 8000:5000 --name day02-app day02-app:v1
docker ps
docker logs day02-app
docker exec -it day02-app bash -> to go inside the docker. 
ls /app
app.py	-> requirements.txt stays in the builder
docker stop day02-app
docker rm day02-app

## What worked
- Dockerfile written from reference, understood each line
- Container ran successfully on port 8000
- Browser showed "Day 02 - Multi-stage Build!"
- Could go inside container and see files

## What I learned
- Dockerfile instructions: FROM, WORKDIR, COPY, RUN, EXPOSE, CMD
- A multi-stage Dockerfile uses more than one FROM statement in a single Dockerfile. Each FROM starts a new stage. 
- By default pip packages go: /usr/local/lib/python3.11/site-packages/
With --user flag: /root/.local/lib/python3.11/site-packages/
Here Dockerfile copies /root/.local — that only works if we add --user to pip install in the builder stage.
- Rule of thumb:
Copy from builder (--from=builder) → only for things the builder produced (installed packages, compiled code)
Copy from build context → for your source files (app.py, config files, etc.)
In our example we dont copy app.py in the build image. We copy it from source to 2nd image. 

## Git Commands used 
cd ~/Desktop/Devops/Sep2026_Amiya
git add .
git commit -m "Day02 - Multi-stage Dockerfile"
git push
git remote -v -> to know where I am pushing 
