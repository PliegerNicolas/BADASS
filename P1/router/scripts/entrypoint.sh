#! /bin/sh

echo "[i] Executing $0"

if [ -z "$(which ip)" ]; then
	echo "[i] ip command should be installed." >&2
	exit 1
fi

OPTIONAL_ENV_VARS="ETH0_PREFIX"
REQUIRED_ENV_VARS=""
echo "[i] Optional environment variables: $OPTIONAL_ENV_VARS"
echo "[i] Expected environment variables: $REQUIRED_ENV_VARS"

for VAR in $REQUIRED_ENV_VARS; do
	VALUE=$(printenv "$VAR")
	if [ -z "${VALUE:-}" ]; then
		echo "[i] Environment variable '$VAR' should be defined." >&2
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

[ -n "$ETH0_PREFIX" ] && ip addr add $ETH0_PREFIX dev eth0
ip link set eth0 up
[ -n "$ETH1_PREFIX" ] && ip addr add $ETH1_PREFIX dev eth0
ip link set eth1 up

# Execute all passed arguments of the script as a command (typically the Dockerfile's CMD entry).
exec "$@"
