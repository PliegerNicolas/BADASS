FROM frrouting/frr:latest
RUN mv /etc/frr/daemons /etc/frr/daemons-backup
COPY config/config-daemons /etc/frr/daemons
COPY test-install.sh /home/test-install.sh
RUN apk update && \
	apk add --no-cache busybox-static
CMD ["/bin/sh", "-l"]
