#!/bin/bash

# ====================================
# Neo4j Docker 컨테이너 중지 스크립트
# ====================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.conf"

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
