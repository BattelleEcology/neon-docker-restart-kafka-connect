FROM alpine:3.19.1
RUN apk upgrade --no-cache && \
    apk add --no-cache \
        jq \
        curl && \
    addgroup -g 1000 kcrestart && \
    adduser -u 1000 -D -h /usr/app kcrestart -G kcrestart

COPY connect-restart.sh /usr/app/connect-restart.sh
USER 1000
ENV CONNECT_URL="http://localhost:8083" \
    RESTART_SLEEP_SECONDS="900"
ENTRYPOINT [ "/usr/app/connect-restart.sh" ]
