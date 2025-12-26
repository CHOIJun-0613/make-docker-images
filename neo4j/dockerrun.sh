#!/bin/bash

# ====================================
# Neo4j Docker 간단 실행 스크립트
# ====================================
# 이 스크립트는 이미 빌드된 이미지를 사용하여 Neo4j를 실행합니다
# 사용법: ./dockerrun.sh

set -e

# 변수 설정
CONTAINER_NAME="neo4j-standalone"
IMAGE_NAME="neo4j-custom:5"
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
echo "Neo4j Docker 컨테이너 실행"
echo "======================================"

# 이미지 존재 확인
if [ ! "$(docker images -q ${IMAGE_NAME})" ]; then
    echo "Error: Image ${IMAGE_NAME} not found!"
    echo "Please run ./makerun.sh first to build the image."
    exit 1
fi

# 기존 컨테이너 확인
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo "Container ${CONTAINER_NAME} already exists."

    # 실행 중인지 확인
    if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
        echo "Container is already running."
        echo ""
        docker ps -f name=${CONTAINER_NAME}
        exit 0
    else
        echo "Starting existing container..."
        docker start ${CONTAINER_NAME}
        echo "Container started successfully!"
        exit 0
    fi
fi

# 새 컨테이너 실행
echo "Running new Docker container: ${CONTAINER_NAME}..."
docker run -d \
  --name ${CONTAINER_NAME} \
  -p 7474:7474 \
  -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/${NEO4J_PASSWORD} \
  -e NEO4J_initial_dbms_default__database=${NEO4J_DATABASE} \
  -e NEO4J_dbms_security_procedures_unrestricted=apoc.* \
  -e NEO4J_dbms_security_procedures_allowlist=apoc.* \
  -e NEO4J_dbms_memory_heap_initial__size=1G \
  -e NEO4J_dbms_memory_heap_max__size=4G \
  -e NEO4J_dbms_memory_transaction_total_max=1.5G \
  -e NEO4J_dbms_memory_pagecache_size=1G \
  -e NEO4J_dbms_connector_bolt_listen__address=0.0.0.0:7687 \
  -e NEO4J_dbms_connector_http_listen__address=0.0.0.0:7474 \
  -v ${VOLUME_DATA}:/data \
  -v ${VOLUME_LOGS}:/logs \
  ${IMAGE_NAME}

echo ""
echo "======================================"
echo "Neo4j 컨테이너 시작 완료!"
echo "======================================"
echo "Neo4j Browser: http://localhost:7474"
echo "Bolt: bolt://localhost:7687"
echo ""
echo "로그인 정보:"
echo "  관리자 - neo4j / ${NEO4J_PASSWORD}"
echo "  앱 사용자 - ${NEO4J_USER} / ${NEO4J_USER_PASSWORD}"
echo "  데이터베이스 - ${NEO4J_DATABASE}"
echo ""
echo "로그 확인: docker logs -f ${CONTAINER_NAME}"
echo "======================================"
