#!/bin/bash

read -p "Enter the GitHub repo URL: " repo_url

## Extract repo name from URL
repo_name=$(basename -s .git "$repo_url")

## Check if directory exists
if [ -d "$repo_name" ]; then
  echo "Directory $repo_name already exists. Pulling latest changes..."
  else
    echo "Cloning repository $repo_name..."
      git clone "$repo_url"

      if [ $? -ne 0 ]; then
        echo "Failed to clone repository. Please check the URL and try again."
        exit 1
        fi
      fi

   cd $repo_name

   echo "the repo name is __________ $repo_name"

cat <<EOL > docker-compose.yml
version: "3.9"
services:
  myapp:
    build: .
    ports:
      - "80:80"
EOL
#start cont
docker ps
echo " container is starting.............................."
docker-compose up -d --build
echo "  check   >>"
docker ps

echo ""
echo ""
res=$(curl -s -o /dev/null -w "%{http_code}" https://hub.docker.com/v2/repositories/deepaktaliyan123/${repo_name}_myapp/tags/latest/) 
 
 if [ "$res" == 200 ]; then
    echo ""
    echo "docker image is available in dockerhub"
 else
    echo "docker image is not available in dockerhub"
 fi
read -p " Do you want to push the image to Docker Hub? (y/n): " push_choice

if [ "$push_choice" == "y" ]; then
    echo "Pushing image to Docker Hub..."
    read -p " enter docker username: " docker_username

    
    docker login -u "$docker_username" 




    echo ""
    docker image tag ${repo_name}_myapp:latest ${docker_username}/${repo_name}_myapp:latest
    docker push ${docker_username}/${repo_name}_myapp:latest
    echo "Image pushed to Docker Hub successfully."


    (sleep 120 && docker-compose down && echo " conainer is stopped after 2 min") &
else
    echo "Skipping image push to Docker Hub."
    (sleep 120 && docker-compose down && echo " conainer is stopped after 2 min") &

fi
