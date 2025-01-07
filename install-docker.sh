#! /bin/sh

# By default, docker is installed in rootless mode.
# Options:
# - --rootful
# - --rootless
# - --uninstall

# Utils
usage_and_exit() {
	local error_msg="$1"
	echo "[!] Error: $1" >&2
	echo "[i] Execute as follows: sh $0 <OPTION>"
	echo " --rootful		Install docker in rootful mode."
	echo " --rootless		Install docker in rootless mode (default)."
	echo " --uninstall		Uninstall docker."
	echo " --uninstall-rootless	Uninstall rootless docker mode."
	exit 1
}

error_and_exit() {
	local error_msg="$1"
	echo "[!] Error: $1" >&2
	exit 1
}

check_distro() {
	if [ "$(uname -s)" != "Linux" ]; then
		error_and_exit "Script should be launched within a Linux distribution."
	fi

	if [ -f /etc/os-release ]; then
		# Extract the id from os-release. It's the most predictable value.
		DISTRIBUTION=$(awk -F= '/^ID=/{print $2}' /etc/os-release | tr -d '"')
		case "$DISTRIBUTION" in
			ubuntu)
				;;
			debian)
				;;
			centos)
				;;
			fedora)
				;;
			*)
				error_and_exit "$DISTRIBUTION not supported, try:
- debian
- buntu
- centOS
- fedora"
				;;
			esac
	else
		error_and_exit "Unknown Linux distribution. /etc/os-release file not found."
	fi
}

intro() {
	local DISTRO=$1

	echo "[i] ======================================="
	echo "[i] Current selected option: $DISTRO"
	echo "[i] ======================================="
}

# ##
# Functions.
# ##

install_docker_rootful() {
	if docker -v > /dev/null 2>&1; then
		echo "[i] Docker is already installed on this system."
		return 0
	fi

	echo "[i] Installing docker in rootful mode."

	case "$DISTRIBUTION" in
		ubuntu)
			if ! command apt-get -v > /dev/null 2>&1; then
				error_and_exit "Expecting apt-get to be installed."
			fi

			echo "[i] Uninstall old versions of docker engine."
			for pkg in \
				docker.io docker-doc docker-compose \
				docker-compose-v2 podman-docker containerd \
				runc; do
				sudo apt-get remove $pkg;
			done

			echo "[i] Setting up docker repository."
			sudo apt-get update
			sudo apt-get install ca-certificates curl
			sudo install -m 0755 -d /etc/apt/keyrings
			sudo curl -fsSL \
				https://download.docker.com/linux/${DISTRIBUTION}/gpg -o \
				/etc/apt/keyrings/docker.asc
			sudo chmod a+r /etc/apt/keyrings/docker.asc

			echo "[i] Adding docker to apt sources."
			echo \
				"deb [arch=$(dpkg --print-architecture) \
				signed-by=/etc/apt/keyrings/docker.asc] \
				https://download.docker.com/linux/${DISTRIBUTION} \
				$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
				sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
			sudo apt-get update -y

			echo "[i] Install docker and it's dependencies."
			sudo apt-get install -y \
				docker-ce \
				docker-ce-cli \
				containerd.io \
				docker-buildx-plugin \
				docker-compose-plugin

			;;
		debian)
			if ! command apt-get -v > /dev/null 2>&1; then
				error_and_exit "Expecting apt-get to be installed."
			fi

			echo "[i] Uninstall old versions of docker engine."
			for pkg in \
				docker.io docker-doc docker-compose \
				podman-docker containerd \
				runc; do
				sudo apt-get remove $pkg;
			done

			echo "[i] Setting up docker repository."
			sudo apt-get update
			sudo apt-get install ca-certificates curl
			sudo install -m 0755 -d /etc/apt/keyrings
			sudo curl -fsSL \
				https://download.docker.com/linux/${DISTRIBUTION}/gpg -o \
				/etc/apt/keyrings/docker.asc
			sudo chmod a+r /etc/apt/keyrings/docker.asc

			echo "[i] Adding docker to apt sources."
			echo \
				"deb [arch=$(dpkg --print-architecture) \
				signed-by=/etc/apt/keyrings/docker.asc] \
				https://download.docker.com/linux/${DISTRIBUTION} \
				$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
				sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
			sudo apt-get update -y

			echo "[i] Install docker and it's dependencies."
			sudo apt-get install -y \
				docker-ce \
				docker-ce-cli \
				containerd.io \
				docker-buildx-plugin \
				docker-compose-plugin
			#sudo chown $(whoami) /var/run/docker.sock
			#newgrp docker
			;;
		centos)

			# Not tested.

			if ! command yum -v > /dev/null 2>&1; then
				error_and_exit "Expecting yum to be installed."
			fi

			echo "[i] Uninstall previous version of Docker."
			sudo yum remove docker \
				docker-client \
				docker-client-latest \
				docker-common \
				docker-latest \
				docker-latest-logrotate \
				docker-logrotate \
				docker-engine

			echo "[i] Install yum-utils."
			sudo yum install -y yum-utils
			
			echo "[i] Add docker GPG to yum's config manager."
			sudo yum-config-manager -add-repo \
			https://download.docker.com/linux/${DISTRIBUTION}/docker-ce.repo
			
			echo "[i] Install docker and it's dependencies."
			sudo yum install -y
				docker-ce \
				docker-ce-cli \
				containerd.io \
				docker-buildx-plugin \
				docker-compose-plugin
			
			echo "[i] Start docker service."
			sudo systemctl start docker

			;;
		fedora)

			# Not tested.

			if ! command dnf -v > /dev/null 2>&1; then
				error_and_exit "Expecting dnf to be installed."
			fi

			echo "[i] Uninstall previous version of Docker."
			sudo dnf remove docker \
				docker-client \
				docker-client-latest \
				docker-common \
				docker-latest \
				docker-latest-logrotate \
				docker-logrotate \
				docker-selinux \
				docker-engine-selinux \
				docker-engine

			echo "[i] Add docker GPG to dnf's config manager."
			sudo dnf -y install dnf-plugins-core
			sudo dnf config-manager \
			--add-repo https://download.docker.com/linux/fedora/docker-ce.repo

			echo "[i] Install docker and it's dependencies."
			sudo dnf install -y \
				docker-ce \
				docker-ce-cli \
				containerd.io \
				docker-buildx-plugin \
				docker-compose-plugin
			
			echo "[i] Start docker service."
			sudo systemctl start docker

			;;
	esac
}

upgrade_docker_to_rootless() {
	if [ "$(id -u)" -eq 0 ]; then
		error_and_exit "Cannot upgrade docker to rootless mode as $(whoami)."
	fi


	if [ -f ${HOME}/.docker/config.json ]; then
		if cat ${HOME}/.docker/config.json | grep -i rootless > /dev/null 2>&1; then
			echo "[i] Docker is already set in rootless mode for $(whoami)."
			return 0
		fi
	fi

	echo "[i] Upgrading docker to rootless mode for $(whoami)."

	case "$DISTRIBUTION" in
		ubuntu)
			if ! command apt-get -v > /dev/null 2>&1; then
				error_and_exit "Expecting apt-get to be installed."
			fi

			echo "[i] Install docker rootless dependencies."
			sudo apt-get update -y && sudo apt-get install -y \
				dbus-user-session \
				uidmap \
				docker-ce-rootless-extra

			echo "[i] Setup rootless mode via provided setup tool."
			dockerd-rootless-setuptool.sh install --force

			;;
		debian)
			if ! command apt-get -v > /dev/null 2>&1; then
				error_and_exit "Expecting apt-get to be installed."
			fi

			echo "[i] Install docker rootless dependencies."
			sudo apt-get update -y && sudo apt-get install -y \
				dbus-user-session \
				fuse-overlayfs \
				slirp4netns \
				uidmap \
				docker-ce-rootless-extras

			echo "[i] Setup rootless mode via provided setup tool."
			dockerd-rootless-setuptool.sh install --force

			;;
		centos)

			# Not tested.

			if ! command yum -v > /dev/null 2>&1; then
				error_and_exit "Expecting yum to be installed."
			fi

			echo "[i] Install docker rootless dependencies."
			sudo yum update -y && sudo yum install -y \
				fuse-overlayfs \
				iptables \
				docker-ce-rootless-extras

			echo "[i] Setup rootless mode via provided setup tool."
			dockerd-rootless-setuptool.sh install --force

			;;
		fedora)

			# Not tested.

			if ! command dnf -v > /dev/null 2>&1; then
				error_and_exit "Expecting dnf to be installed."
			fi

			echo "[i] Install docker rootless dependencies."
			sudo dnf update -y && sudo dnf install -y \
				fuse-overlayfs \
				iptables \
				docker-ce-rootless-extras

			echo "[i] Setup rootless mode via provided setup tool."
			dockerd-rootless-setuptool.sh install --force

			;;
	esac
}

uninstall_docker() {
	if ! docker -v > /dev/null 2>&1; then
		echo "[i] Docker isn't installed on this system."
		return 0
	fi

	echo "[i] Uninstalling docker."
	case "$DISTRIBUTION" in
		ubuntu)
			if ! command apt-get -v > /dev/null 2>&1; then
				error_and_exit "Expecting apt-get to be installed."
			fi

			echo "[i] Removing docker related packages."
			sudo apt-get purge -y \
				docker-ce \
				docker-ce-cli \
				containerd.io \
				docker-buildx-plugin \
				docker-compose-plugin \
				docker-ce-rootless-extras

			echo "[i] Removing docker related folders."
			sudo rm -rf /var/lib/docker # Root directory
			sudo rm -rf /etc/docker # Daemon configuration files.
			sudo rm -rf /var/run/docker # Runtime directory

			echo "[i] Some configuration files should be removed manually."

			;;
		debian)
			if ! command apt-get -v > /dev/null 2>&1; then
				error_and_exit "Expecting apt-get to be installed."
			fi

			echo "[i] Removing docker related packages."
			sudo apt-get purge -y \
				docker-ce \
				docker-ce-cli \
				containerd.io \
				docker-buildx-plugin \
				docker-compose-plugin \
				docker-ce-rootless-extras

			echo "[i] Removing docker related folders."
			sudo rm -rf /var/lib/docker # Root directory
			sudo rm -rf /etc/docker # Daemon configuration files.
			sudo rm -rf /var/run/docker # Runtime directory

			#sudo rm -rf /var/lib/containerd
			#sudo rm /etc/apparmor.d/docker
			#sudo groupdel docker

			echo "[i] Some configuration files should be removed manually."

			;;
		centos)
			if ! command yum -v > /dev/null 2>&1; then
				error_and_exit "Expecting yum to be installed."
			fi

			echo "[i] Removing docker related packages."
			sudo yum remove -y \
				docker-ce \
				docker-ce-cli \
				containerd.io \
				docker-buildx-plugin \
				docker-compose-plugin \
				docker-ce-rootless-extras

			echo "[i] Removing docker related folders."
			sudo rm -rf /var/lib/docker # Root directory
			sudo rm -rf /etc/docker # Daemon configuration files.
			sudo rm -rf /var/run/docker # Runtime directory

			sudo rm -rf /var/lib/containerd

			echo "[i] Some configuration files should be removed manually."

			;;
		fedora)
			if ! command dnf -v > /dev/null 2>&1; then
				error_and_exit "Expecting dnf to be installed."
			fi

			echo "[i] Removing docker related packages."
			sudo dnf remove -y \
				docker-ce \
				docker-ce-cli \
				containerd.io \
				docker-buildx-plugin \
				docker-compose-plugin \
				docker-ce-rootless-extras

			echo "[i] Removing docker related folders."
			sudo rm -rf /var/lib/docker # Root directory
			sudo rm -rf /etc/docker # Daemon configuration files.
			sudo rm -rf /var/run/docker # Runtime directory

			sudo rm -rf /var/lib/containerd

			;;
	esac
}

uninstall_docker_rootless_mode() {
	if [ "$(id -u)" -eq 0 ]; then
		error_and_exit "Cannot remove docker's rootless mode for $(whoami)."
	fi

	if [ ! -f ${HOME}/.docker/config.json ]; then
		echo "[i] Docker isn't installed in rootless mode for $(whoami)."
		return 0
	fi

	if ! (cat ${HOME}/.docker/config.json | grep -i rootless > /dev/null 2>&1); then
		rm -rf ${HOME}/.docker
		echo "[i] Docker isn't set in rootless mode for $(whoami)."
		return 0
	fi

	echo "[i] Uninstalling docker's rootless configuration."
	case "$DISTRIBUTION" in
		ubuntu)
			if ! command apt-get -v > /dev/null 2>&1; then
				error_and_exit "Expecting apt-get to be installed."
			fi

			echo "[i] You should remove env. variables from ~/.bashrc if set."

			echo "[i] Uninstall dockerd rootless via it's setup tool."
			dockerd-rootless-setuptool.sh uninstall

			echo "[i] Remove config directory using rootlesskit tool."
			rootlesskit rm -rf ~/.local/share/docker

			echo "[i] Clean package manager."
			sudo apt-get purge -y docker-ce-rootless-extras
			sudo apt-get autoremove -y

			echo "[i] Remove user specific configuration data."
			sudo rm -rf ${HOME}/.docker
			sudo rm -rf ${HOME}/.config/docker
			sudo rm -rf ${HOME}/.config/systemd/user/docker.service


			echo "[i] Remove env variables."
			unset DOCKER_HOST DOCKER_CONTEXT

			echo "[i] Some configuration files should be removed manually."

			;;
		debian)
			if ! command apt-get -v > /dev/null 2>&1; then
				error_and_exit "Expecting apt-get to be installed."
			fi

			echo "[i] You should remove env. variables from ~/.bashrc if set."

			echo "[i] Uninstall dockerd rootless via it's setup tool."
			dockerd-rootless-setuptool.sh uninstall

			echo "[i] Remove config directory using rootlesskit tool."
			rootlesskit rm -rf ~/.local/share/docker

			echo "[i] Clean package manager."
			sudo apt-get purge -y docker-ce-rootless-extras
			sudo apt-get autoremove -y

			echo "[i] Remove user specific configuration data."
			sudo rm -rf ${HOME}/.docker
			sudo rm -rf ${HOME}/.config/docker
			sudo rm -rf ${HOME}/.config/systemd/user/docker.service

			echo "[i] Remove env variables."
			unset DOCKER_HOST DOCKER_CONTEXT

			echo "[i] Some configuration files should be removed manually."

			;;
		centos)
			if ! command yum -v > /dev/null 2>&1; then
				error_and_exit "Expecting yum to be installed."
			fi

			echo "[i] You should remove env. variables from ~/.bashrc if set."

			echo "[i] Uninstall dockerd rootless via it's setup tool."
			dockerd-rootless-setuptool.sh uninstall

			echo "[i] Remove config directory using rootlesskit tool."
			rootlesskit rm -rf ~/.local/share/docker

			echo "[i] Clean package manager."
			sudo yum remove -y docker-ce-rootless-extras
			sudo yum autoremove -y

			echo "[i] Remove user specific configuration data."
			sudo rm -rf ${HOME}/.docker
			sudo rm -rf ${HOME}/.config/docker
			sudo rm -rf ${HOME}/.config/systemd/user/docker.service

			echo "[i] Remove env variables."
			unset DOCKER_HOST DOCKER_CONTEXT

			echo "[i] Some configuration files should be removed manually."

			;;
		fedora)
			if ! command dnf -v > /dev/null 2>&1; then
				error_and_exit "Expecting dnf to be installed."
			fi

			echo "[i] You should remove env. variables from ~/.bashrc if set."

			echo "[i] Uninstall dockerd rootless via it's setup tool."
			dockerd-rootless-setuptool.sh uninstall

			echo "[i] Remove config directory using rootlesskit tool."
			rootlesskit rm -rf ~/.local/share/docker

			echo "[i] Clean package manager."
			sudo dnf remove -y docker-ce-rootless-extras
			sudo dnf autoremove -y

			echo "[i] Remove user specific configuration data."
			sudo rm -rf ${HOME}/.docker
			sudo rm -rf ${HOME}/.config/docker
			sudo rm -rf ${HOME}/.config/systemd/user/docker.service

			echo "[i] Remove env variables."
			unset DOCKER_HOST DOCKER_CONTEXT
			
			echo "[i] Some configuration files should be removed manually."

			;;
	esac
}

# ##
# Script
# ##

if [ "$(uname -s)" != "Linux" ]; then
	error_and_exit "Script should be launched within a Linux distribution."
fi

if [ -f /etc/os-release ]; then
	# Extract the id from os-release. It's the most predictable value.
	DISTRIBUTION=$(awk -F= '/^ID=/{print $2}' /etc/os-release | tr -d '"')
fi

DISTRIBUTION=${DISTRIBUTION}

# Check current distribution.
case "$DISTRIBUTION" in
	ubuntu) ;;
	debian) ;;
	centos) ;;
	fedora) ;;
	*)
		error_and_exit "$DISTRIBUTION is not a supported distribution."
		;;
esac

# Check options and launch according functions.
if [ $# -ge 1 ]; then
	case "$1" in
		--rootful)
			intro "rootful"
			uninstall_docker_rootless_mode
			install_docker_rootful
			;;
		--rootless)
			intro "rootless"
			install_docker_rootful
			upgrade_docker_to_rootless
			;;
		--uninstall)
			intro "uninstall"
			uninstall_docker
			uninstall_docker_rootless_mode
			;;
		--uninstall-rootless)
			intro "uninstall-rootless"
			uninstall_docker_rootless_mode
			;;
		*)
			usage_and_exit "Unrecognized option."
			;;
	esac
else
	intro "rootless"
	install_docker_rootful
	upgrade_docker_to_rootless
fi
