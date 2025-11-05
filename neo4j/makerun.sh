#!/bin/bash

# ====================================
# Neo4j Docker 독립 실행 스크립트
# ====================================
# 이 스크립트는 neo4j/ 디렉토리에서 실행하세요
# 사용법: ./makerun.sh

set -e

# 변수 설정
CONTAINER_NAME="neo4j-db"
IMAGE_NAME="neo4j:5-community"
NETWORK_NAME="neo4j-network"
VOLUME_DATA="neo4j_data"
VOLUME_LOGS="neo4j_logs"

# .env 파일에서 환경 변수 로드 (프로젝트 루트에서)
if [ -f ../.env ]; then
  echo "Loading environment variables from ../.env"
  export $(cat ../.env | grep -v '^#' | grep -v '^$' | xargs)
else
  echo "Warning: ../.env file not found. Using default values."
fi

# 환경 변수 기본값 설정
NEO4J_PASSWORD=${NEO4J_PASSWORD:-neo4j123}
NEO4J_DATABASE=${NEO4J_DATABASE:-csadb01}
NEO4J_USER=${NEO4J_USER:-csauser}
NEO4J_USER_PASSWORD=${NEO4J_USER_PASSWORD:-csauser123}

echo "======================================"
echo "Neo4j Docker 컨테이너 설정"
echo "======================================"
echo "Container Name: ${CONTAINER_NAME}"
echo "Image Name: ${IMAGE_NAME}"
echo "Neo4j Admin User: neo4j"
echo "Neo4j App User: ${NEO4J_USER}"
echo "Default Database: ${NEO4J_DATABASE}"
echo "======================================"

# 1. 기존 컨테이너 중지 및 제거
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo "Stopping and removing existing container: ${CONTAINER_NAME}..."
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
fi

# 2. 기존 이미지 제거 (선택사항 - 캐시를 사용하려면 주석 처리)
if [ "$(docker images -q ${IMAGE_NAME})" ]; then
    echo "Removing existing image: ${IMAGE_NAME}..."
    docker rmi ${IMAGE_NAME}
fi

# 3. 네트워크 생성 (존재하지 않으면)
if ! docker network inspect ${NETWORK_NAME} >/dev/null 2>&1; then
    echo "Creating network: ${NETWORK_NAME}..."
    docker network create ${NETWORK_NAME}
else
    echo "Network ${NETWORK_NAME} already exists."
fi

# 4. Docker 이미지 빌드
echo "Building Docker image: ${IMAGE_NAME}..."
docker build -t ${IMAGE_NAME} .

# 5. Docker 컨테이너 실행
echo "Running Docker container: ${CONTAINER_NAME}..."
docker run -d \
  --name ${CONTAINER_NAME} \
  --network ${NETWORK_NAME} \
  -p 7474:7474 \
  -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/${NEO4J_PASSWORD} \
  -e NEO4J_initial_dbms_default__database=${NEO4J_DATABASE} \
  -e NEO4J_dbms_security_procedures_unrestricted=apoc.* \
  -e NEO4J_dbms_security_procedures_allowlist=apoc.* \
  -e NEO4J_dbms_memory_heap_initial__size=512m \
  -e NEO4J_dbms_memory_heap_max__size=2G \
  -e NEO4J_dbms_memory_pagecache_size=512m \
  -e NEO4J_dbms_connector_bolt_listen__address=0.0.0.0:7687 \
  -e NEO4J_dbms_connector_http_listen__address=0.0.0.0:7474 \
  -v ${VOLUME_DATA}:/data \
  -v ${VOLUME_LOGS}:/logs \
  ${IMAGE_NAME}

echo ""
echo "======================================"
echo "Neo4j 컨테이너 시작 완료!"
echo "======================================"
echo "컨테이너가 시작되는 중입니다. 초기화에 약 30초 정도 소요됩니다."
echo ""
echo "로그 확인:"
echo "  docker logs -f ${CONTAINER_NAME}"
echo ""
echo "컨테이너 상태 확인:"
echo "  docker ps -f name=${CONTAINER_NAME}"
echo ""
echo "Neo4j Browser 접속:"
echo "  http://localhost:7474"
echo ""
echo "초기 로그인 정보:"
echo "  사용자: neo4j"
echo "  비밀번호: ${NEO4J_PASSWORD}"
echo ""
echo "초기화 완료 후 사용 가능한 계정:"
echo "  사용자: ${NEO4J_USER}"
echo "  비밀번호: ${NEO4J_USER_PASSWORD}"
echo "  데이터베이스: ${NEO4J_DATABASE}"
echo "======================================"
