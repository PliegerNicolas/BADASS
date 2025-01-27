#! /bin/sh

echo "[i] Executing $0"

if [ -z "$(which ip)" ]; then
	echo "[i] ip command should be installed." >&2
	exit 1
fi

# P2: we want host2 to be able to communicate with host1 via OSI layer 2.
# Here, we only need to ensure host2.eth0 is setup and is in the same subnet as host1.eth0.
# We act just as if host2.eth0 and host1.eth0 where directly connected by cable.
# Router2 will ensure that the received data packets will get transmitted to destination using VXLAN encapsulation.

# Configuration of interfaces (eth0, eth1, vxlan0...)
ip addr add 192.168.1.3/24 dev eth0
ip link set eth0 up

exec "$@"
