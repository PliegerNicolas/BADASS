#! /bin/sh

echo "[i] Executing $0"

if [ -z "$(which ip)" ]; then
	echo "[!] ip command should be installed." >&2
	exit 1
fi

OPTIONAL_ENV_VARS=""
REQUIRED_NETWORK_VARS="ETH1_PREFIX"
REQUIRED_VXLAN_ENV_VARS="VXLAN_NVI VTEP_REMOTE VXLAN_MULTICAST_GROUP VXLAN_TRAFFIC_DISTRIBUTION_METHOD"
echo "[i] Optional environment variables: $OPTIONAL_ENV_VARS"
echo "[i] Expected environment variables: $REQUIRED_ENV_VARS"
echo "[i] Expected environment variables: $REQUIRED_VXLAN_ENV_VARS"

for VAR in $REQUIRED_ENV_VARS; do
	VALUE=$(printenv "$VAR")
	if [ -z "${VALUE:-}" ]; then
		echo "[!] Environment variable '$VAR' should be defined." >&2
		exit 1
	fi
done

for VAR in $REQUIRED_VXLAN_ENV_VARS; do
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

# Configuration of interfaces (eth0, eth1, vxlan0...)
ip link set eth0 up # No IP address needed as we only use Layer 2 communication here.
ip addr add $ETH1_PREFIX dev eth1
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
