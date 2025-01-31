FROM frrouting/frr:latest

ARG	ENTRYPOINT_ARGS="unicast"
ENV	ENTRYPOINT_ARGS=$ENTRYPOINT_ARGS
# Capabilities and ARGS are set/passed in the Makefile when starting up the container.

RUN	apk update && apk add --no-cache \
	iproute2 \
	tcpdump

RUN	mv /etc/frr/daemons /etc/frr/daemons-backup
COPY	./config/daemons /etc/frr/daemons
COPY	./config/frr.conf /etc/frr/frr.conf
COPY	./config/vtysh.conf /etc/frr/vtysh.conf

RUN	mkdir -p /entrypoint
COPY	./scripts/entrypoint.sh /entrypoint/

ENTRYPOINT ["sh", "/entrypoint/entrypoint.sh"]
CMD ["/usr/lib/frr/docker-start"]
# Inherit ENTRYPOINT and/or CMD (+ the rest) from the base image.
