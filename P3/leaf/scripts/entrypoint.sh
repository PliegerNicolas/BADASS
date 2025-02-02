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
REQUIRED_NETWORK_ENV_VARS="LO_IP RR_LO_IP ETH1_IP BGP_ASN"
REQUIRED_VXLAN_ENV_VARS="VXLAN_NVI"
echo "[i] Optional environment variables: $OPTIONAL_ENV_VARS"
echo "[i] Expected environment variables: $REQUIRED_NETWORK_ENV_VARS"
echo "[i] Expected environment variables: $REQUIRED_VXLAN_ENV_VARS"

for VAR in $REQUIRED_NETWORK_ENV_VARS; do
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

# Mask CIDR examples /32
# Network address 192.168.1.0/32 | Usabe IP addresses: 192.168.1.0 | Broadcast address: X
# Usable IP and Network address are merged with CIDR /32.

# Enforce LO to start with 1.1.1.
# It's a less flexible strategy but easier to setup in frr.conf.template
if [[ $LO_IP == 1.1.1.* ]]; then
	ip addr add ${LO_IP}/32 dev lo
	ip link set lo up
else
	echo "[!] LO_IP should arbitrarily start with 1.1.1."
	exit 1
fi 

# Mask CIDR examples /30 
# Network address: 192.168.1.0/30 | Usable IP addresses: 192.168.1.1 => 192.168.1.2
# Network address: 192.168.1.4/30 | Usable IP addresses: 192.168.1.5 => 192.168.1.6
# Network address: 192.168.1.8/30 | Usable IP addresses: 192.168.1.9 => 192.168.1.10

ip link set eth0 up # No IP set: is bridged with vxlan0 and communicates via layer2.
ip addr add ${ETH1_IP}/30 dev eth1
ip link set eth1 up

# VTEP target is defined through BGP.
ip link add vxlan0 type vxlan \
	id ${VXLAN_NVI} \
	dev lo \
	dstport 4789
ip link set vxlan0 up

# Configuration of the bridge between leaf.eth0 and leaf.vxlan0 to enable communication with the virtual VXLAN interface.
ip link add br0 type bridge
ip link set dev eth0 master br0
ip link set vxlan0 master br0
ip link set dev br0 up

# Execute all passed arguments of the script as a command (typically the Dockerfile's CMD entry).
exec "$@"
