#! /bin/sh

echo "[i] Executing $0"

if [ -z "$(which ip)" ]; then
	echo "[i] ip command should be installed." >&2
	exit 1
fi

# ===================================================================== #
# ===================================================================== #
# P3: first of all, create eth0 that physically link to the host1, with layer 2:
ip link set eth0 up

# configure eth1 (link to RR)
#ip addr add 10.1.1.2/24 dev eth1
#ip link set eth1 up
# configure addr loopback
#ip addr add 1.1.1.2/32 dev lo
#ip link set lo up

# Then, create a vxlan to allow connection thanks to layer3
ip link add vxlan0 type vxlan id 10 local 1.1.1.2 dstport 4789
ip link set dev vxlan0 up

# create a bridge to link eth0 to vxlan
ip link add br0 type bridge
ip link set dev eth0 master br0 #connect bridge to eth0
ip link set vxlan0 master br0  # connect bridge to vxlan
ip link set dev br0 up

# Execute all passed arguments of the script as a command (typically the Dockerfile's CMD entry).
exec "$@"
