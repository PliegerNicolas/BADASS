#! /bin/sh

echo "[i] Executing $0"

if [ -z "$(which ip)" ]; then
	echo "[!] ip command should be installed." >&2
	exit 1
fi

REQUIRED_ENV_VARS="ETH1_PREFIX VXLAN_TRAFFIC_DISTRIBUTION_METHOD VXLAN_NVI VTEP_LOCAL VTEP_REMOTE VXLAN_MULTICAST_GROUP"
echo "[i] Expected environment variables: $REQUIRED_ENV_VARS"

for VAR in $REQUIRED_ENV_VARS; do
	VALUE=$(printenv "$VAR")
	if [ -z "${VALUE:-}" ]; then
		echo "[!] Environment variable '$VAR' should be defined." >&2
		exit 1
	fi
done

# =================================================================== #
#                              frr.conf                               #
# =================================================================== #

# ...

# =================================================================== #
#                               Network                               #
# =================================================================== #


# Then, create a vxlan to allow connection thanks to layer3
ip link add vxlan0 type vxlan id 10 local 1.1.1.2 dstport 4789
ip link set dev vxlan0 up

# create a bridge to link eth0 to vxlan
ip link add br0 type bridge
ip link set dev eth0 master br0 #connect bridge to eth0
ip link set vxlan0 master br0  # connect bridge to vxlan
ip link set dev br0 up


# Configuration of interfaces (eth0, eth1, vxlan0...)
ip link set eth0 up # No IP address set as we only use Layer 2 communication here.
ip addr add ${ETH1_PREFIX} dev eth1
ip link set eth1 up
if [ "$VXLAN_TRAFFIC_DISTRIBUTION_METHOD" == "unicast" ]; then
	echo "[i] Configuring VXLAN with unicast."
	ip link add vxlan0 type vxlan \
		id $VXLAN_NVI \
		dev eth1 \
		remote $VTEP_REMOTE \
		dstport 4789
	ip link set vxlan0 up
elif [ "$VXLAN_TRAFFIC_DISTRIBUTION_METHOD" == "multicast" ]; then
	echo "[i] Configuring VXLAN with multicast."
	ip link add vxlan0 type vxlan \
		id $VXLAN_NVI \
		dev eth1 \
		group $VXLAN_MULTICAST_GROUP \
		dstport 4789
	ip link set vxlan0 up
else
	echo "[!] VXLAN_TRAFFIC_DISTRIBUTION_METHOD should be one of: [\"unicast\", \"multicast\"]." >&2
fi

# Configuration of the bridge between router1.eth0 and router1.vxlan0 to enable communication with the virtual VXLAN interface.
ip link add br0 type bridge
ip link set dev eth0 master br0
ip link set vxlan0 master br0
ip link set dev br0 up

# Execute all passed arguments of the script as a command (typically the Dockerfile's CMD entry).
exec "$@"
