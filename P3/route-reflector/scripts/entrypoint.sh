#! /bin/sh

echo "[i] Executing $0"

if [ -z "$(which ip)" ]; then
	echo "[!] ip command should be installed." >&2
	exit 1
fi

if [ -z "$(which envsubst)" ]; then
	echo "[!] envsubst should be installed." >&2
fi

# BGP_ASN should be a private value in the following range: [64512-65534]

OPTIONAL_ENV_VARS=""
REQUIRED_NETWORK_ENV_VARS="LO_IP ETH0_IP ETH1_IP ETH2_IP BGP_ASN"
echo "[i] Optional environment variables: $OPTIONAL_ENV_VARS"
echo "[i] Expected environment variables: $REQUIRED_NETWORK_ENV_VARS"

for VAR in $REQUIRED_NETWORK_ENV_VARS; do
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
if [ "$LO_IP" = 1.1.1.* ]; then
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

ip addr add ${ETH0_IP}/30 dev eth0
ip link set eth0 up
ip addr add ${ETH1_IP}/30 dev eth1
ip link set eth1 up
ip addr add ${ETH2_IP}/30 dev eth2
ip link set eth2 up

# Execute all passed arguments of the script as a command (typically the Dockerfile's CMD entry).
exec "$@"
