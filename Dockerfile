FROM openjdk:8-jdk-slim
LABEL maintainer="Mirai Kim <me@euc-kr.net>"

ARG WORK_DIR="/srv/minecraft"
ARG VERSION="latest"
ENV DOCKER="TRUE"

RUN set -x \
	&& apt-get update \
	&& apt-get install --no-install-recommends -y bash curl openssl ca-certificates wget \
    && mkdir -p /srv/minecraft \
    && wget -O /tmp/waterfall.jar https://papermc.io/ci/job/Waterfall/lastSuccessfulBuild/artifact/Waterfall-Proxy/bootstrap/target/Waterfall.jar \
    && apt-get clean \
    && mv /tmp/waterfall.jar /srv/minecraft/proxy-server.jar

COPY scripts/start /srv/start
COPY scripts/initialize.sh /srv/initialize.sh
COPY scripts/run-minecraft-proxy.sh /srv/run-minecraft-proxy.sh

WORKDIR ${WORK_DIR}
EXPOSE 25565
EXPOSE 25577

CMD ["/srv/start"]
