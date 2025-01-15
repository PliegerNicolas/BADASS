# Latest since 12/01/2025 (cf. https://hub.docker.com/_/alpine)
FROM alpine:3.21.2

# Busybox is already installed on default alpine image
COPY test-busybox.sh /home/test-busybox.sh
RUN chmod 755 /home/test-busybox.sh

CMD ["/bin/sh", "-l"]
