FROM frrouting/frr:latest

# Capabilities are set in the Makefile when starting up the container.

RUN	apk update && apk add --no-cache \
	iproute2 \
	tcpdump

RUN mv /etc/frr/daemons /etc/frr/daemons-backup
COPY ./config/vtysh.conf /etc/frr/vtysh.conf
COPY ./config/daemons /etc/frr/daemons
COPY ./config/frr.conf /etc/frr/frr.conf

COPY /scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]

CMD ["/usr/lib/frr/docker-start"]
