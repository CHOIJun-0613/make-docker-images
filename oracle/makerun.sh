#!/bin/bash

# 변수 설정
CONTAINER_NAME="dev-oracle-db"
IMAGE_NAME="dev-oracle-db:latest"
NETWORK_NAME="my-dev-network"
VOLUME_NAME="oracle_data"

# .env 파일 로드 (프로젝트 루트에 있다고 가정)
if [ -f ../.env ]; then
  export $(cat ../.env | sed 's/#.*//g' | xargs)
fi

# 1. 기존 컨테이너 중지 및 삭제
if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    echo "Stopping and removing existing container..."
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
fi

# 2. 기존 이미지 삭제
if [ "$(docker images -q ${IMAGE_NAME})" ]; then
    echo "Removing existing image..."
    docker rmi ${IMAGE_NAME}
fi

# 3. 사용자 정의 네트워크 생성 (없으면)
docker network inspect ${NETWORK_NAME} >/dev/null 2>&1 || \
    echo "Creating network ${NETWORK_NAME}..." && docker network create ${NETWORK_NAME}

# 4. Docker 이미지 빌드
echo "Building new image..."
docker build --no-cache -t ${IMAGE_NAME} .

# 5. Docker 컨테이너 실행
echo "Running new container..."
docker run -d \
  --name ${CONTAINER_NAME} \
  -e ORACLE_PASSWORD=${ORACLE_ROOT_PASSWORD} \
  -e APP_USER=${ORACLE_USER} \
  -e APP_USER_PASSWORD=${ORACLE_PASSWORD} \
  -p 1521:1521 \
  -v ${VOLUME_NAME}:/opt/oracle/oradata \
  --network ${NETWORK_NAME} \
  ${IMAGE_NAME}

echo "Script finished."
