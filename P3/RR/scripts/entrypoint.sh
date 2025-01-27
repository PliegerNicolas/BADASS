#! /bin/sh

echo "[i] Executing $0"

if [ -z "$(which ip)" ]; then
	echo "[i] ip command should be installed." >&2
	exit 1
fi

#setup all interfaces
ip addr add 10.1.1.1/30 dev eth0
ip link set eth0 up
ip addr add 10.1.1.5/30 dev eth1
ip link set eth1 up
ip addr add 10.1.1.9/30 dev eth2
ip link set eth2 up
ip addr add 1.1.1.1/32 dev lo
ip link set lo up

# Execute all passed arguments of the script as a command (typically the Dockerfile's CMD entry).
exec "$@"
