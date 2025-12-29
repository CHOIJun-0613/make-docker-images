#!/bin/bash

# ====================================
# Neo4j Docker 컨테이너 완전 삭제 스크립트
# ====================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.conf"

echo "======================================"
echo "Neo4j 컨테이너 완전 삭제"
echo "======================================"
echo "WARNING: This will remove the container, image, and all data!"
echo ""
read -p "Are you sure? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

# 컨테이너 중지 및 제거
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo "Removing container: ${CONTAINER_NAME}..."
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
    echo "Container removed."
fi

# 이미지 제거
if [ "$(docker images -q ${IMAGE_NAME})" ]; then
    echo "Removing image: ${IMAGE_NAME}..."
    docker rmi ${IMAGE_NAME}
    echo "Image removed."
fi

# 볼륨 제거 (선택사항)
read -p "Do you want to remove data volumes? (yes/no): " REMOVE_VOLUMES

if [ "$REMOVE_VOLUMES" = "yes" ]; then
    echo "Removing volumes..."
    docker volume rm ${VOLUME_DATA} 2>/dev/null || echo "Volume ${VOLUME_DATA} not found."
    docker volume rm ${VOLUME_LOGS} 2>/dev/null || echo "Volume ${VOLUME_LOGS} not found."
    echo "Volumes removed."
fi

echo ""
echo "======================================"
echo "Cleanup completed!"
echo "======================================"
