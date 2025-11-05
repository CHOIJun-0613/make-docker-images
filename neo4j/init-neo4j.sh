#!/bin/bash
set -e

# Neo4j 초기화 스크립트
# 컨테이너 최초 기동 시 Neo4j 엔트리포인트가 자동 실행한다.

echo "======================================"
echo "Neo4j 초기화 스크립트 시작"
echo "======================================"

echo "Neo4j 서버 기동 확인 중..."
until cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" "RETURN 1" >/dev/null 2>&1; do
    echo "Neo4j 연결 대기 중..."
    sleep 3
done

echo "Neo4j 서버 연결 성공!"

echo "======================================"
echo "1. csadb01 데이터베이스 생성"
echo "======================================"
cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" \
    "CREATE DATABASE csadb01 IF NOT EXISTS;" || true

echo "csadb01 데이터베이스가 ONLINE 될 때까지 대기..."
sleep 5

echo "======================================"
echo "2. csauser 계정 생성"
echo "======================================"
cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" \
"CREATE USER csauser IF NOT EXISTS
 SET PASSWORD 'csauser123'
 CHANGE NOT REQUIRED
 SET STATUS ACTIVE;" || echo "csauser가 이미 존재하여 생략되었습니다."

echo "======================================"
echo "3. csauser 데이터베이스 권한 부여"
echo "======================================"
cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" \
    "GRANT ACCESS ON DATABASE csadb01 TO csauser;" || true
cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" \
    "GRANT START ON DATABASE csadb01 TO csauser;" || true
cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" \
    "GRANT ALL GRAPH PRIVILEGES ON GRAPH csadb01 TO csauser;" || true

# echo "======================================"
# echo "4. csauser 관리 권한 부여"
# echo "======================================"
# cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" \
#     "GRANT ROLE admin TO csauser;" || true

echo "======================================"
echo "5. 설정 확인"
echo "======================================"
echo "데이터베이스 목록:"
cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" "SHOW DATABASES;" || true

echo ""
echo "사용자 목록:"
cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" "SHOW USERS;" || true

echo ""
echo "======================================"
echo "Neo4j 초기화 완료!"
echo "======================================"
echo "접속 정보:"
echo "  - Neo4j Browser: http://localhost:7474"
echo "  - Bolt: bolt://localhost:7687"
echo ""
echo "관리자 계정:"
echo "  - 사용자: neo4j"
echo "  - 비밀번호: ${NEO4J_PASSWORD:-neo4j123}"
echo ""
echo "애플리케이션 계정:"
echo "  - 사용자: csauser"
echo "  - 비밀번호: ${NEO4J_USER_PASSWORD:-csauser123}"
echo "  - 데이터베이스: ${NEO4J_DATABASE:-csadb01}"
echo "======================================"
