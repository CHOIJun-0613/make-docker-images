#!/bin/bash

# ====================================
# Neo4j Docker 컨테이너 중지 스크립트
# ====================================

CONTAINER_NAME="neo4j-standalone"

echo "======================================"
echo "Neo4j 컨테이너 중지"
echo "======================================"

if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    echo "Stopping container: ${CONTAINER_NAME}..."
    docker stop ${CONTAINER_NAME}
    echo "Container stopped successfully!"
else
    echo "Container ${CONTAINER_NAME} is not running."
fi
