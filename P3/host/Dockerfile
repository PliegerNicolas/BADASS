# Latest since 12/01/2025 (cf. https://hub.docker.com/_/alpine)
FROM alpine:3.21.2

COPY /scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]

CMD ["/bin/busybox", "sleep", "infinity"]
