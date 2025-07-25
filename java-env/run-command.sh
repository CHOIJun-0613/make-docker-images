# 도커 이미지를 빌드한 후 컨테이너를 실행하는 명령어 예시입니다.
docker build -t java-env:latest .
docker run --name java-env-container -it java-env:latest bash
