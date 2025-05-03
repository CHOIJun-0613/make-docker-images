#!/bin/bash

echo "======================================="
echo " Docker Compose 명령어 설명"
echo "======================================="
echo " (docker-compose.yml 파일이 있는 디렉토리에서 실행하세요)"
echo ""

echo "--- 서비스 시작 ---"
echo "docker-compose up           # 포그라운드에서 서비스 시작 (로그 표시)"
echo "docker-compose up -d        # 백그라운드에서 서비스 시작"
echo "docker-compose up --build   # 이미지를 다시 빌드하고 서비스 시작"
echo "docker-compose up -d <서비스_이름> # 특정 서비스만 백그라운드 시작"
echo ""

echo "--- 서비스 중지 ---"
echo "docker-compose down         # 컨테이너 중지 및 제거 (네트워크 포함)"
echo "docker-compose down -v      # 컨테이너, 네트워크, 볼륨 모두 제거"
echo "docker-compose stop         # 컨테이너 중지 (제거 안 함)"
echo "docker-compose stop <서비스_이름> # 특정 서비스만 중지"
echo ""

echo "--- 서비스 재시작 ---"
echo "docker-compose restart      # 모든 서비스 재시작"
echo "docker-compose restart <서비스_이름> # 특정 서비스만 재시작"
echo ""

echo "--- 이미지 빌드 ---"
echo "docker-compose build        # 서비스 이미지 빌드 또는 재빌드"
echo "docker-compose build --no-cache # 캐시 없이 빌드"
echo "docker-compose build <서비스_이름> # 특정 서비스 이미지만 빌드"
echo ""

echo "--- 상태 및 로그 확인 ---"
echo "docker-compose ps           # 실행 중인 컨테이너 목록 확인"
echo "docker-compose logs -f      # 모든 서비스 로그 실시간 확인"
echo "docker-compose logs -f <서비스_이름> # 특정 서비스 로그 실시간 확인"
echo ""

echo "--- 컨테이너 명령어 실행 ---"
echo "docker-compose exec <서비스_이름> /bin/bash # 컨테이너 내부 쉘 접속"
echo "docker-compose exec <서비스_이름> <명령어> # 컨테이너 내부에서 명령어 실행"
echo ""

echo "--- 중지된 컨테이너 제거 ---"
echo "docker-compose rm           # 중지된 컨테이너 제거"
echo ""
echo "======================================="