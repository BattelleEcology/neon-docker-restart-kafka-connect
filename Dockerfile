FROM alpine:3.17.0
RUN apk add --no-cache \
    jq \
    curl && \
    addgroup -g 1000 kcrestart && \
    adduser -u 1000 -D -h /usr/app kcrestart -G kcrestart

COPY connect-restart.sh /usr/app/connect-restart.sh
USER 1000
ENV CONNECT_URL="http://localhost:8083"
ENTRYPOINT [ "/usr/app/connect-restart.sh" ]
