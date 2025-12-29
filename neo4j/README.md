# Neo4j Docker 설정

Neo4j 5.x 그래프 데이터베이스 Docker 이미지 및 설정

## 주요 설정

### 버전
- **Neo4j 5.x** (최신 5.x 버전)

### 데이터베이스 설정
- **기본 데이터베이스**: `csadb01`
- **데이터베이스 자동 생성**: 초기화 스크립트를 통해 자동 생성

### 사용자 계정

#### 관리자 계정 (neo4j)
- **사용자명**: `neo4j`
- **비밀번호**: `neo4j123` (환경변수로 설정 가능)
- **권한**: 전체 관리자 권한

#### 애플리케이션 계정 (csauser)
- **사용자명**: `csauser`
- **비밀번호**: `csauser123`
- **권한**: csadb01 데이터베이스 전체 권한 (admin role)

### 포트 설정
- **7474**: Neo4j Browser (HTTP) - 웹 UI 접속용
- **7687**: Bolt Protocol - 애플리케이션 연결용

## 공통 설정

- `.env`: 저장소 루트에 위치하며 비밀번호, DB 이름과 같은 민감/환경별 값을 정의합니다. 존재하지 않으면 스크립트가 README에 명시된 기본값을 사용합니다.
- `neo4j/common.conf`: Neo4j 스크립트 공통 변수(`CONTAINER_NAME`, `IMAGE_NAME`, `VOLUME_DATA`, `VOLUME_LOGS`, `NETWORK_NAME`, `NEO4J_*` 등)를 선언하고 `.env`를 자동으로 로드합니다.
- `makerun.sh`, `dockerrun.sh`, `stop.sh`, `remove.sh`, `init-neo4j.sh` 등 모든 스크립트는 실행 시 `common.conf`를 자동으로 source 합니다. 동일한 변수를 재정의하려면 `.env` 또는 `common.conf`에서 값을 바꿔주세요.
- 수동으로 Docker 명령을 실행할 때도 `source neo4j/common.conf`를 먼저 수행하면 동일한 변수들을 재사용할 수 있습니다.

## 빌드 및 실행

### 방법 1: 독립 실행 스크립트 (권장)

Neo4j만 독립적으로 실행하려면 `neo4j/` 디렉토리에서 스크립트를 사용하세요:

```bash
# neo4j 디렉토리로 이동
cd neo4j

# 실행 권한 부여 (최초 1회)
chmod +x makerun.sh dockerrun.sh stop.sh remove.sh

# 처음 실행 (이미지 빌드 + 컨테이너 실행)
./makerun.sh

# 이후 실행 (이미 빌드된 이미지로 실행)
./dockerrun.sh

# 컨테이너 중지
./stop.sh

# 컨테이너, 이미지, 데이터 완전 삭제
./remove.sh
```

### 방법 2: Docker Compose로 실행

전체 서비스와 함께 실행:

```bash
# 프로젝트 루트 디렉토리에서
docker-compose up -d

# Neo4j만 실행
docker-compose up -d neo4j-db

# 로그 확인
docker-compose logs -f neo4j-db

# 중지
docker-compose stop neo4j-db

# 삭제
docker-compose down
```

### 방법 3: 수동 Docker 명령어

```bash
# 이미지 빌드
cd neo4j
docker build -t neo4j:5-community .

# 컨테이너 실행
docker run -d \
  --name neo4j-db \
  -p 7474:7474 \
  -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/${NEO4J_PASSWORD:-neo4j123} \
  -e NEO4J_initial_dbms_default__database=${NEO4J_DATABASE:-csadb01} \
  -e NEO4J_dbms_memory_heap_initial__size=1G \
  -e NEO4J_dbms_memory_heap_max__size=4G \
  -e NEO4J_dbms_memory_transaction_total_max=1.5G \
  -e NEO4J_dbms_memory_pagecache_size=1G \
  -v neo4j_data:/data \
  -v neo4j_logs:/logs \
  neo4j:5-community
```

## 접속 방법

### Neo4j Browser (웹 UI)
1. 브라우저에서 `http://localhost:7474` 접속
2. 로그인 정보 입력:
   - **URL**: `bolt://localhost:7687`
   - **사용자명**: `neo4j` 또는 `csauser`
   - **비밀번호**: `neo4j123` 또는 `csauser123`
   - **데이터베이스**: `csadb01`

### Cypher Shell (CLI)
```bash
# 컨테이너 내부에서 cypher-shell 실행
docker-compose exec neo4j-db cypher-shell -u csauser -p csauser123 -d csadb01

# 또는 관리자로 접속
docker-compose exec neo4j-db cypher-shell -u neo4j -p neo4j123
```

### Spring Boot 애플리케이션 연결

application.properties:
```properties
spring.neo4j.uri=bolt://neo4j-db:7687
spring.neo4j.authentication.username=csauser
spring.neo4j.authentication.password=csauser123
spring.neo4j.database=csadb01
```

application.yml:
```yaml
spring:
  neo4j:
    uri: bolt://neo4j-db:7687
    authentication:
      username: csauser
      password: csauser123
    database: csadb01
```

## 초기화 스크립트

`init-neo4j.sh` 스크립트가 컨테이너 시작 시 자동으로 실행되어 다음 작업을 수행합니다:

1. ✅ Neo4j 서버 시작 대기
2. ✅ `csadb01` 데이터베이스 생성
3. ✅ `csauser` 사용자 생성 (비밀번호: csauser123)
4. ✅ csauser에게 csadb01 접근 권한 부여
5. ✅ csauser에게 admin 권한 부여
6. ✅ 설정 확인 (데이터베이스 목록, 사용자 목록)

**참고**: 초기화 스크립트는 볼륨이 처음 생성될 때만 실행됩니다. 재실행하려면 볼륨을 삭제해야 합니다.

## 주요 기능

### APOC 플러그인
- APOC (Awesome Procedures On Cypher) 플러그인이 활성화되어 있습니다
- 다양한 유틸리티 함수 및 프로시저 사용 가능

### 메모리 설정 (개발 환경 권장치)
- Heap 초기 크기: 1G (`NEO4J_dbms_memory_heap_initial__size`)
- Heap 최대 크기: 4G (`NEO4J_dbms_memory_heap_max__size`)
- 트랜잭션 메모리 한도: 1.5G (`NEO4J_dbms_memory_transaction_total_max`)
- Page Cache: 1G (`NEO4J_dbms_memory_pagecache_size`)

프로덕션 환경에서는 서버 사양에 맞게 조정하세요.

## 환경 변수

`.env` 또는 `neo4j/common.conf`에서 다음 환경 변수를 설정할 수 있습니다. `.env`에 값을 지정하면 `common.conf`에서 기본값보다 우선적으로 적용됩니다.

```env
# Neo4j 관리자 비밀번호
NEO4J_PASSWORD=neo4j123

# 기본 데이터베이스명
NEO4J_DATABASE=csadb01

# 애플리케이션 사용자
NEO4J_USER=csauser
NEO4J_USER_PASSWORD=csauser123

# Docker 리소스 이름 (필요 시)
CONTAINER_NAME=neo4j-db
IMAGE_NAME=neo4j:5-community
VOLUME_DATA=neo4j_data
VOLUME_LOGS=neo4j_logs
NETWORK_NAME=neo4j-network
```

## 데이터 영구 저장

Docker 볼륨을 사용하여 데이터를 영구 저장합니다:

- `neo4j_data`: Neo4j 데이터베이스 파일
- `neo4j_logs`: Neo4j 로그 파일

### 데이터 초기화 (주의!)

```bash
# 모든 데이터 삭제 (볼륨 포함)
docker-compose down -v

# Neo4j 데이터만 삭제
docker volume rm make-docker-images_neo4j_data
docker volume rm make-docker-images_neo4j_logs
```

## 문제 해결

### 컨테이너가 시작되지 않는 경우
```bash
# 로그 확인
docker-compose logs neo4j-db

# 컨테이너 상태 확인
docker-compose ps
```

### 초기화 스크립트 재실행
초기화 스크립트는 컨테이너가 처음 시작될 때만 실행됩니다. 재실행하려면:

```bash
# 컨테이너 및 볼륨 삭제
docker-compose down -v

# 다시 시작
docker-compose up -d neo4j-db
```

### 데이터베이스 목록 확인
```bash
docker-compose exec neo4j-db cypher-shell -u neo4j -p neo4j123 "SHOW DATABASES;"
```

### 사용자 목록 확인
```bash
docker-compose exec neo4j-db cypher-shell -u neo4j -p neo4j123 "SHOW USERS;"
```

## Cypher 쿼리 예제

### 데이터베이스 전환
```cypher
:use csadb01
```

### 간단한 노드 생성
```cypher
CREATE (p:Person {name: 'Alice', age: 30})
RETURN p;
```

### 관계 생성
```cypher
MATCH (a:Person {name: 'Alice'})
MATCH (b:Person {name: 'Bob'})
CREATE (a)-[r:KNOWS]->(b)
RETURN a, r, b;
```

### 데이터 조회
```cypher
MATCH (p:Person)
RETURN p;
```

## 참고 자료

- [Neo4j 공식 문서](https://neo4j.com/docs/)
- [Neo4j Docker Hub](https://hub.docker.com/_/neo4j)
- [Cypher 쿼리 언어](https://neo4j.com/docs/cypher-manual/current/)
- [APOC 문서](https://neo4j.com/labs/apoc/)
