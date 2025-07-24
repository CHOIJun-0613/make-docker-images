# Gemini CLI prompt

## 용도: Docker image 생성

### 1. Java 개발 환경 Docker
- 폴더 : .\\springboot
- Dockerfile: .\\springboot\\Dockerfile
- 베이스 이미지: 'ubuntu:22.04'

### 2. MySQL Database Docker
- 폴더 : .\\mysql
- Dockerfile: .\\mysql\\Dockerfile
- 베이스 이미지: 'mysql:8.0'

### 3. PostgreSQL Database Docker
- 폴더 : .\postgresql
- Dockerfile: .\\postgresql\\Dockerfile
- 베이스 이미지: 'postgres:16'

### 4. 전체 docker-compose
- 폴더 : .
- 파일 : docker-compose.yml

### 5. 환경변수
- 폴더 : .
- 파일 : .env