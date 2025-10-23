#!/bin/bash
set -e

# Neo4j 초기화 스크립트
# 이 스크립트는 Neo4j가 처음 시작될 때 실행됩니다.

echo "======================================"
echo "Neo4j 초기화 스크립트 시작"
echo "======================================"

# Neo4j가 완전히 시작될 때까지 대기
echo "Neo4j 서버 시작 대기 중..."
until cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" "RETURN 1" > /dev/null 2>&1; do
    echo "Neo4j 연결 대기 중..."
    sleep 3
done

echo "Neo4j 서버 연결 성공!"

# 1. csadb01 데이터베이스 생성
echo "======================================"
echo "1. csadb01 데이터베이스 생성"
echo "======================================"
cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" "CREATE DATABASE csadb01 IF NOT EXISTS;" || true

# 데이터베이스가 온라인 상태가 될 때까지 대기
echo "csadb01 데이터베이스 온라인 대기 중..."
sleep 5

# 2. csauser 사용자 생성
echo "======================================"
echo "2. csauser 사용자 생성"
echo "======================================"
cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" \
"CREATE USER csauser IF NOT EXISTS
 SET PASSWORD 'csauser123'
 CHANGE NOT REQUIRED
 SET STATUS ACTIVE;" || echo "사용자가 이미 존재하거나 생성 중 오류 발생"

# 3. csauser에게 csadb01 데이터베이스 접근 권한 부여
echo "======================================"
echo "3. csauser 권한 설정"
echo "======================================"
cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" \
"GRANT ACCESS ON DATABASE csadb01 TO csauser;" || true

cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" \
"GRANT START ON DATABASE csadb01 TO csauser;" || true

cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" \
"GRANT ALL GRAPH PRIVILEGES ON GRAPH csadb01 TO csauser;" || true

# 4. csauser에게 관리 권한 부여 (선택사항)
echo "======================================"
echo "4. csauser 관리 권한 부여"
echo "======================================"
cypher-shell -u neo4j -p "${NEO4J_PASSWORD:-neo4j123}" \
"GRANT ROLE admin TO csauser;" || true

# 5. 설정 확인
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
echo "  - 비밀번호: neo4j123"
echo ""
echo "애플리케이션 계정:"
echo "  - 사용자: csauser"
echo "  - 비밀번호: csauser123"
echo "  - 데이터베이스: csadb01"
echo "======================================"
