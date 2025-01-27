# Latest since 12/01/2025 (cf. https://hub.docker.com/_/alpine)
FROM alpine:3.21.2

RUN apk update && apk add --no-cache iproute2

RUN mkdir -p /entrypoint
COPY /scripts/entrypoint.sh /entrypoint/
ENTRYPOINT ["sh", "/entrypoint/entrypoint.sh"]

CMD ["/bin/busybox", "sleep", "infinity"]
