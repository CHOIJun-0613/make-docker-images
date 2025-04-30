# Dockerfile for MySQL 8.0

# 베이스 이미지 설정
FROM mysql:8.0
 
# 환경 변수 설정 (필요에 따라 수정)
ENV MYSQL_ROOT_PASSWORD=#skcc06433
ENV MYSQL_DATABASE=mysql
ENV MYSQL_USER=mysqluser
ENV MYSQL_PASSWORD=#skcc06433 

# 포트 노출
EXPOSE 3306

# 컨테이너 시작 시 MySQL 실행 (기본 설정으로 실행)
# 필요한 경우 my.cnf 파일을 추가하여 MySQL 설정을 변경할 수 있습니다.
# COPY ./my.cnf /etc/mysql/my.cnf

# 볼륨 설정 (데이터 영구 저장을 위해)
VOLUME /var/lib/mysql

# 추가적인 설정이나 스크립트 실행 (선택 사항)
# COPY ./init.sql /docker-entrypoint-initdb.d/
# COPY ./my_custom_script.sh /docker-entrypoint-initdb.d/

# healthcheck 설정 (선택 사항)
HEALTHCHECK --timeout=5s --interval=5s --retries=5 \
  CMD mysqladmin ping -h localhost -u root -p"$MYSQL_ROOT_PASSWORD"

# 컨테이너 시작 시 실행될 명령어 (기본 MySQL 실행)
CMD ["mysqld"]