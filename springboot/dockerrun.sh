# 1. 사용자 정의 네트워크 생성
docker network create my-app-network

# 2. MySQL 컨테이너 실행 (네트워크 지정 및 이름 부여)
docker run --name mysql-db --network my-app-network \
  -e MYSQL_ROOT_PASSWORD=your_root_password \
  -e MYSQL_DATABASE=your_database_name \
  -e MYSQL_USER=your_mysql_user \
  -e MYSQL_PASSWORD=your_mysql_password \
  -v mysql-data:/var/lib/mysql \
  -d mysql:8.0

# 3. Spring Boot 컨테이너 실행 (네트워크 지정)
docker run --name spring-app --network my-app-network \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://mysql-db:3306/your_database_name?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC \
  -e SPRING_DATASOURCE_USERNAME=your_mysql_user \
  -e SPRING_DATASOURCE_PASSWORD=your_mysql_password \
  -d your-springboot-app-image:latest