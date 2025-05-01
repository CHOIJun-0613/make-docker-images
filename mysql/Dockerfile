# Dockerfile for MySQL 8.0

# 베이스 이미지 설정
FROM mysql:8.0
 
# 환경 변수 설정 (비밀번호는 컨테이너 실행 시 주입하는 것을 권장)
# ENV MYSQL_ROOT_PASSWORD=your_root_password_here # 실행 시 환경 변수로 전달 권장
ENV MYSQL_DATABASE=devdb 
ENV MYSQL_USER=devuser

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

# HEALTHCHECK: 베이스 이미지에 포함된 기본 healthcheck 사용 권장
# CMD: 베이스 이미지의 기본 CMD ["mysqld"] 사용