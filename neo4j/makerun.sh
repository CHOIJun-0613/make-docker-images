#!/bin/bash

# ====================================
# Neo4j Docker 독립 실행 스크립트
# ====================================
# 이 스크립트는 neo4j/ 디렉토리에서 실행하세요
# 사용법: ./makerun.sh

set -e

# 변수 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.conf"

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
echo "Waiting for Neo4j to accept cypher-shell connections..."
until docker exec ${CONTAINER_NAME} cypher-shell -u neo4j -p "${NEO4J_PASSWORD}" "RETURN 1" >/dev/null 2>&1; do
  echo "Neo4j is still starting up. Retrying in 3 seconds..."
  sleep 3
done

echo "Checking Neo4j edition to determine admin capabilities..."
NEO4J_EDITION=$(docker exec ${CONTAINER_NAME} \
  cypher-shell -u neo4j -p "${NEO4J_PASSWORD}" -d system --format plain \
  "CALL dbms.info() YIELD edition RETURN edition" | tail -n +2 | tr -d '\r')

if echo "${NEO4J_EDITION}" | grep -iq "enterprise"; then
  echo "Detected Neo4j edition: ${NEO4J_EDITION}. Proceeding with database/user setup."

  echo "Creating default database: ${NEO4J_DATABASE}"
  docker exec ${CONTAINER_NAME} \
    cypher-shell -u neo4j -p "${NEO4J_PASSWORD}" -d system \
    "CREATE DATABASE ${NEO4J_DATABASE} IF NOT EXISTS;"

  echo "Creating application user: ${NEO4J_USER}"
  docker exec ${CONTAINER_NAME} \
    cypher-shell -u neo4j -p "${NEO4J_PASSWORD}" -d system \
    "CREATE USER ${NEO4J_USER} IF NOT EXISTS
     SET PASSWORD '${NEO4J_USER_PASSWORD}'
     CHANGE NOT REQUIRED
     SET STATUS ACTIVE;"

  echo "Granting privileges on ${NEO4J_DATABASE} to ${NEO4J_USER}"
  docker exec ${CONTAINER_NAME} \
    cypher-shell -u neo4j -p "${NEO4J_PASSWORD}" -d system \
    "GRANT ACCESS ON DATABASE ${NEO4J_DATABASE} TO ${NEO4J_USER};"
  docker exec ${CONTAINER_NAME} \
    cypher-shell -u neo4j -p "${NEO4J_PASSWORD}" -d system \
    "GRANT START ON DATABASE ${NEO4J_DATABASE} TO ${NEO4J_USER};"
  docker exec ${CONTAINER_NAME} \
    cypher-shell -u neo4j -p "${NEO4J_PASSWORD}" -d system \
    "GRANT ALL GRAPH PRIVILEGES ON GRAPH ${NEO4J_DATABASE} TO ${NEO4J_USER};"

  echo "Database and user initialization completed."
else
  echo "Detected Neo4j edition: ${NEO4J_EDITION}. Community 에디션에서는 추가 데이터베이스/사용자 생성이 지원되지 않습니다."
  echo "컨테이너는 환경 변수에 설정된 기본 데이터베이스(${NEO4J_DATABASE})와 기본 관리자 계정(neo4j)만 사용할 수 있습니다."
  echo "Enterprise 에디션을 사용하거나 Neo4j Aura 등에서 멀티 DB/사용자 기능을 활성화해야 CREATE DATABASE / CREATE USER 명령이 동작합니다."
fi

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
