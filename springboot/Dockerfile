# 빌드 환경 설정
# 베이스 이미지 설정 (특정 버전 명시 권장, 예: 22.04)
FROM ubuntu:22.04
 
# 환경 변수 설정
ENV DEV_USER=dev
ENV TZ=Asia/Seoul
ENV LANG=ko_KR.UTF-8
ENV LANGUAGE=ko_KR:ko
ENV LC_ALL=ko_KR.UTF-8
# SDKMAN 설치 경로 환경 변수 (선택 사항이지만 명시하면 좋음)
ENV SDKMAN_DIR="/home/${DEV_USER}/.sdkman"
# PATH에 SDKMAN bin 경로 추가 (Java, Gradle 등 실행 파일 경로 자동 설정)
ENV PATH="${SDKMAN_DIR}/candidates/java/current/bin:${SDKMAN_DIR}/candidates/gradle/current/bin:${PATH}"

# dev 그룹 및 사용자 생성
RUN groupadd $DEV_USER && \
    useradd -m -g $DEV_USER -s /bin/bash $DEV_USER

# 시스템 패키지 설치, 타임존/로케일 설정 및 정리 (단일 레이어)
# sudo, docker-compose, mysql-client는 필요한 경우에만 포함
# ca-certificates는 curl 등 HTTPS 통신에 필요할 수 있음
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        sudo \
        docker-compose \
        mysql-client \
        tzdata \
        locales \
        git \
        curl \
        bash \
	    ca-certificates \
        zip \
        unzip && \
    # 타임존 설정
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    # 로케일 설정
    locale-gen $LANG && \
    update-locale LANG=$LANG && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    # sudo 권한 부여 (필요한 경우)
    echo "${DEV_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # apt 캐시 정리
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# dev 사용자로 전환
USER $DEV_USER
WORKDIR /home/$DEV_USER

RUN bash -c '\
    set -e && \
    echo ">>> Installing SDKMAN..." && \
    curl -s "https://get.sdkman.io" | bash && \
    source "${SDKMAN_DIR}/bin/sdkman-init.sh" && \
    echo ">>> Configuring SDKMAN..." && \
    echo "sdkman_auto_answer=true" > "${SDKMAN_DIR}/etc/config" && \
    echo ">>> Installing Java 23-open..." && \
    sdk install java 23-open && \
    echo ">>> Installing Gradle 8.14..." && \
    sdk install gradle 8.14 && \
    echo ">>> Setting default versions..." && \
    sdk default java 23-open && \
    sdk default gradle 8.14 && \
    echo ">>> Cleaning SDKMAN caches..." && \
    sdk flush archives && \
    sdk flush temp && \
    echo ">>> Verifying installation..." && \
    sdk version \
'

# 필요한 파일 복사 (선택 사항)
# COPY --chown=$DEV_USER:$DEV_USER your_application /app/

