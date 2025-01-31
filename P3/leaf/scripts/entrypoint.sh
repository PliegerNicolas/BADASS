#! /bin/sh

echo "[i] Executing $0"

if [ -z "$(which ip)" ]; then
	echo "[!] ip command should be installed." >&2
	exit 1
fi

if [ -z "$(which envsubst)" ]; then
	echo "[!] envsubst should be installed." >&2
fi

OPTIONAL_ENV_VARS=""
REQUIRED_NETWORK_VARS="LO_PREFIX ETH1_PREFIX RR_LO_IP LOCAL_BGP_ASN RR_BGP_ASN"
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

# Substitute env variables in frr.conf file as it doesn't support that by default.
# We use the gettext apk package for this.
envsubst < /etc/frr/frr.conf.template > /etc/frr/frr.conf

# =================================================================== #
#                               Network                               #
# =================================================================== #

# Configuration of interfaces (eth0, eth1, vxlan0...)
# eth0: No IP address set because it is only used for layer 2 com. through br0-vxlan0.
# lo: is strictly virtual thus independent of physical underlaying changes and is always reachable.
ip link set eth0 up
ip addr add $ETH1_PREFIX dev eth1
ip link set eth1 up
ip addr add $LO_PREFIX dev lo
ip link set lo up
if [ "$VXLAN_TRAFFIC_DISTRIBUTION_METHOD" == "unicast" ]; then
	echo "[i] Configuring VXLAN with unicast."
	ip link add vxlan0 type vxlan \
		id $VXLAN_NVI \
		dev lo \
		remote $VTEP_REMOTE \
		dstport 4789
	ip link set vxlan0 up
elif [ "$VXLAN_TRAFFIC_DISTRIBUTION_METHOD" == "multicast" ]; then
	echo "[i] Configuring VXLAN with multicast."
	ip link add vxlan0 type vxlan \
		id $VXLAN_NVI \
		dev lo \
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
