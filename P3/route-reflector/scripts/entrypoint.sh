#! /bin/sh

echo "[i] Executing $0"

if [ -z "$(which ip)" ]; then
	echo "[!] ip command should be installed." >&2
	exit 1
fi

if [ -z "$(which envsubst)" ]; then
	echo "[!] envsubst should be installed." >&2
fi

# LO_PREFIX should be unique for each leaf and route-reflector.
# BGP_ASN should be a private value in the following range: [64512-65534]

OPTIONAL_ENV_VARS=""
REQUIRED_NETWORK_ENV_VARS="LO_IP ETH0_PREFIX ETH1_PREFIX ETH2_PREFIX LOCAL_BGP_ASN"
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
# Ensure that each prefix pairs (leaf.ethX <-> route-reflector.ethX) is on it's own subnet.
ip addr add $ETH0_PREFIX dev eth1
ip link set eth0 up
ip addr add $ETH1_PREFIX dev eth1
ip link set eth1 up
ip addr add $ETH2_PREFIX dev eth2
ip link set eth2 up
ip addr add ${LO_PREFIX}/32 dev lo
ip link set lo up

# Execute all passed arguments of the script as a command (typically the Dockerfile's CMD entry).
exec "$@"
