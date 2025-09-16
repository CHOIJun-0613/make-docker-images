#!/bin/bash

# Variables
CONTAINER_NAME="dev-neo4j-db"
IMAGE_NAME="dev-neo4j-db:latest"
NETWORK_NAME="my-dev-network"
VOLUME_NAME="neo4j_data"

# Load .env file (assuming it's in the project root)
if [ -f ../.env ]; then
  export $(cat ../.env | sed 's/#.*//g' | xargs)
fi

# Check if NEO4J_PASSWORD is set
if [ -z "${NEO4J_PASSWORD}" ]; then
    echo "Error: NEO4J_PASSWORD is not set. Please set it in your .env file."
    exit 1
fi

# 1. Stop and remove existing container
if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    echo "Stopping and removing existing container..."
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
fi

# 2. Remove existing image
if [ "$(docker images -q ${IMAGE_NAME})" ]; then
    echo "Removing existing image..."
    docker rmi ${IMAGE_NAME}
fi

# 3. Create custom network (if it doesn't exist)
docker network inspect ${NETWORK_NAME} >/dev/null 2>&1 || \
    echo "Creating network ${NETWORK_NAME}..." && docker network create ${NETWORK_NAME}

# 4. Build Docker image (using build-arg)
echo "Building new image..."
docker build --no-cache \
  --build-arg NEO4J_PASSWORD_ARG=${NEO4J_PASSWORD} \
  -t ${IMAGE_NAME} .

# 5. Run Docker container
echo "Running new container..."
docker run -d \
  --name ${CONTAINER_NAME} \
  -e NEO4J_AUTH=neo4j/${NEO4J_PASSWORD} \
  -p 7474:7474 -p 7687:7687 \
  -v ${VOLUME_NAME}:/data \
  --network ${NETWORK_NAME} \
  ${IMAGE_NAME}

echo "Script finished."
