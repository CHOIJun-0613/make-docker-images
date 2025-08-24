# 베이스 이미지로 eclipse-temurin 21-jdk-alpine 사용
FROM eclipse-temurin:21-jdk-alpine


# 환경 변수 설정
ENV DEV_USER=dev
ENV TZ=Asia/Seoul

# 로케일을 한글로 설정 (locales 패키지 없이 간단히 설정)
ENV LANG=ko_KR.UTF-8
ENV LANGUAGE=ko_KR:ko
ENV LC_ALL=ko_KR.UTF-8

# dev 사용자 생성 (Alpine은 adduser 사용)
RUN adduser -D $DEV_USER

# 시스템 패키지 설치, 타임존/로케일 설정 및 정리 (단일 레이어)
# sudo, docker-compose, mysql-client는 필요한 경우에만 포함
# ca-certificates는 curl 등 HTTPS 통신에 필요할 수 있음
RUN apk update && apk add --no-cache  \
        sudo \
        docker-compose \
        mysql-client \
        tzdata \
        git \
        curl \
        bash \
	    ca-certificates \
        zip \
        unzip && \
    # 타임존 설정
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    # sudo 권한 부여 (필요한 경우)
    echo "${DEV_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 

# Gradle 8.14 설치 (root 권한에서 실행)
ARG GRADLE_VERSION=8.14
ARG GRADLE_SHA256=61ad310d3c7d3e5da131b76bbf22b5a4c0786e9d892dae8c1658d4b484de3caa

RUN set -eux; \
    wget -O gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"; \
    echo "${GRADLE_SHA256}  gradle.zip" | sha256sum -c -; \
    unzip gradle.zip; \
    mv "gradle-${GRADLE_VERSION}" /opt/gradle; \
    rm gradle.zip; \
    ln -s /opt/gradle/bin/gradle /usr/bin/gradle

# Gradle 경로 환경변수 추가
ENV PATH="/opt/gradle/bin:${PATH}"

WORKDIR /home/workspace




