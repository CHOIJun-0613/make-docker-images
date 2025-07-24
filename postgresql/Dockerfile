# Dockerfile for PostgreSQL 16

# 베이스 이미지 설정
FROM postgres:16

# ARG for build-time variables with default values
# WARNING: Do not use default passwords in production environments.
# Pass the password at build time using --build-arg POSTGRES_PASSWORD_ARG=your_secure_password
ARG POSTGRES_DB_ARG=devdb
ARG POSTGRES_USER_ARG=devuser
ARG POSTGRES_PASSWORD_ARG=devpass

# 환경 변수 설정
# The password is set from a build-time argument.
# For production, it is strongly recommended to set the password via Docker secrets or at runtime.
ENV POSTGRES_DB=${POSTGRES_DB_ARG}
ENV POSTGRES_USER=${POSTGRES_USER_ARG}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD_ARG}

# 포트 노출
EXPOSE 5432

# 컨테이너 시작 시 PostgreSQL 실행 (기본 설정으로 실행)
# 필요한 경우 postgresql.conf 파일을 추가하여 PostgreSQL 설정을 변경할 수 있습니다.
# COPY ./postgresql.conf /etc/postgresql/postgresql.conf

# 볼륨 설정 (데이터 영구 저장을 위해)
VOLUME /var/lib/postgresql/data

# 추가적인 설정이나 스크립트 실행 (선택 사항)
# COPY ./init.sql /docker-entrypoint-initdb.d/
# COPY ./my_custom_script.sh /docker-entrypoint-initdb.d/

# HEALTHCHECK: 베이스 이미지에 포함된 기본 healthcheck 사용 권장
# CMD: 베이스 이미지의 기본 CMD ["postgres"] 사용