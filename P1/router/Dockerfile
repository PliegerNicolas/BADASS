FROM frrouting/frr:latest

# Busybox is already installed on frrouting default image
RUN mv /etc/frr/daemons /etc/frr/daemons-backup
COPY config/config-daemons /etc/frr/daemons

COPY test-install.sh /home/test-install.sh
RUN chmod 755 /home/test-install.sh

CMD ["/bin/sh", "-l"]
