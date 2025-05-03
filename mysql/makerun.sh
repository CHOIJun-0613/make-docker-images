# 1. 사용자 정의 네트워크 생성
docker network create my-dev-network

docker build --no-cache -t dev-mysql-db:latest .


docker run -d --name dev-mysql-db -e MYSQL_ROOT_PASSWORD=#skcc06433 -e MYSQL_USER=devuser -e MYSQL_PASSWORD=#skcc06433 -e MYSQL_DATABASE=devdb -p 3306:3306  -v mysql_data:/var/lib/mysql  dev-mysql-db
