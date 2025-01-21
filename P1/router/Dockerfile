FROM frrouting/frr:latest

# Capabilities are set in the Makefile when starting up the container.

RUN mv /etc/frr/daemons /etc/frr/daemons-backup
COPY ./config/vtysh.conf /etc/frr/vtysh.conf
COPY ./config/daemons /etc/frr/daemons
COPY ./config/frr.conf /etc/frr/frr.conf

# Inherit ENTRYPOINT and CMD (+ the rest) from the base image.
