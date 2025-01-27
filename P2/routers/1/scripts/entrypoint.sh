#! /bin/sh

echo "[i] Executing $0"

if [ -z "$(which ip)" ]; then
	echo "[i] ip command should be installed." >&2
	exit 1
fi

ARGS="${ENTRYPOINT_ARGS:-unicast}"

# ===================================================================== #
# ===================================================================== #

#P2: our router should use a vxlan interface that would encapsulate received OSI layer 2 data packets into OSI layer 3 IP packets and send them to router2 where those will get decapsulated by another vxlan interface identified by their common VNI (IDs).
# This simulates effective OSI layer 2 communicate over OSI layer 3.

# As VXLAN interfaces aren't physical, we cannot connect ethernet cables to them. This would make OSI layer 2 communicate difficult.
# We use a bridge to link on OSI layer 2 a physical interface (eth0) and our VXLAN interface (vxlan0) so that our data packets comming from host1 can communicate over layer two with that VXLAN interface (vxlan0).

# Our VXLAN interface (vxlan0) can be configured with the following fields:
# - id: the VNI (VXLAN Network Identifier). It identifies the VXLAN tunnel endpoints.
# - dev ethX: the physical interface used to start the OSI layer 3 traffic (our VXLAN tunnel endpoint).
# - local: the IP address of the local VXLAN tunnel endpoint (VTEP). By default the IP address of dev ethX.
# - remote: the IP address of the target VXLAN tunnel endpoint (VTEP).

# ===================================================================== #
# ===================================================================== #

# Configuration of interfaces (eth0, eth1, vxlan0...)
ip link set eth0 up # No IP address set as we only use Layer 2 communication here.
ip addr add 10.1.1.1/24 dev eth1
ip link set eth1 up
if [ "$ARGS" == "unicast" ]; then
	ip link add vxlan0 type vxlan id 10 dev eth1 local 10.1.1.1 remote 10.1.1.2
else
	ip link add vxlan0 type vxlan id 10 dev eth1 group 239.0.0.1
fi
ip link set vxlan0 up

# Configuration of the bridge between router1.eth0 and router1.vxlan0 to enable communication with the virtual VXLAN interface.
ip link add br0 type bridge
ip link set dev eth0 master br0
ip link set vxlan0 master br0
ip link set dev br0 up

# Execute all passed arguments of the script as a command (typically the Dockerfile's CMD entry).
exec "$@"
