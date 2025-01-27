#! /bin/sh

CYAN="\033[0;36m"
LIGHT_GRAY="\0033[0;37m"
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

CURR_FILE_PATH="$(dirname "$(realpath "$0")")"

read -p "[i] Would you like to install optional packages ? (y/n) " OPTIONAL_PACKAGES_REPLY
if [ "$OPTIONAL_PACKAGES_REPLY" != "y" ] && [ "$OPTIONAL_PACKAGES_REPLY" != "n" ]; then
	echo "[!] Error: '$OPTIONAL_PACKAGES_REPLY' not recognized. Try using 'y' or 'n'." >&2
fi

set -e

echo "${CYAN}[i] Executing $0.${NC}"

echo "${CYAN}[i] Installing mandatory dependencies.${NC}"

sudo apt update && sudo apt upgrade -y

# Basic necessities (software installation, HTTP com. IDE, other...)
echo "${CYAN}[i] > Installing basic necessities and dependencies.${NC}"
sudo apt install -y -qq \
	ufw curl wget \
	vim \
	make cmake \
	net-tools \
	xterm \
	software-properties-common ca-certificates gnupg2

# Python
echo "${CYAN}[i] > Installing Python3 and related packages.${NC}"
sudo apt install -y -qq \
	python3 \
	python3-pip pipx \
	python3-pyqt5 python3-pyqt5.qtwebsockets python3-pyqt5.qtsvg

# Qemu
echo "${CYAN}[i] > Installing Qemu related packages.${NC}"
sudo apt install -y -qq \
	qemu-kvm qemu-utils

# libvirt
echo "${CYAN}[i] > Installing libvirt related packages.${NC}"
sudo apt install -y -qq \
	libvirt-clients libvirt-daemon-system virtinst

# dynamips (As it cannot be found in the apt sources, we install it manually).
echo "${CYAN}[i] > Installing dynamips.${NC}"
sudo apt update && sudo apt install -y -qq \
	libelf-dev libpcap0.8-dev

if [ -z "$(which dynamips)" ]; then
	git clone https://github.com/GNS3/dynamips.git ~/dynamips
	cd ~/dynamips && mkdir -p build && cd build
	cmake .. && sudo make install
	cd ~ && rm -rf ~/dynamips
else
	echo "${LIGHT_GRAY}[i] Dynamips already installed...${NC}"
fi

# uBridge (As it cannot be found in the apt sources, we install it manually).
echo "${CYAN}[i] > Installing uBridge.${NC}"
if [ -z "$(which ubridge)" ]; then
	git clone git@github.com:GNS3/ubridge.git ~/ubridge
	cd ~/ubridge
	make
	sudo make install
	cd ~&& rm -rf ~/ubridge
else
	echo "${LIGHT_GRAY}[i] uBridge already installed...${NC}"
fi

echo "${CYAN}[i] Configuring ufw (+ssh).${NC}"
sudo ufw allow ssh

if [ "$OPTIONAL_PACKAGES_REPLY" = "y" ]; then
	sudo apt update
	
	echo "${CYAN}[i] (Optional) Installing google chrome.${NC}"
	if [ -z "$(which google-chrome-stable)" ]; then
		sudo apt install fonts-liberation
		curl -o ~/gchrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo dpkg -i ~/gchrome.deb
		sudo rm -f ~/gchrome.deb
	else
		echo "${LIGHT_GRAY}[i] Google chrome already installed...${NC}"
	fi
	echo "${CYAN}[i] (Optional) Installing wireshark.${NC}"
	if [ -z "$(which wireshark)" ]; then
		sudo apt update && sudo apt install wireshark
		sudo usermod -aG wireshark $USER
	else
		echo "${LIGHT_GRAY}[i] Wireshark already installed...${NC}"
	fi
fi

echo "${CYAN}[i] Installing busybox.${NC}"
sudo apt update && sudo apt install -y busybox-static

echo "${CYAN}[i] Installing GNS3.${NC}"
sudo apt update
pipx install gns3-server
pipx install gns3-gui
pipx inject gns3-gui gns3-server PyQt5
pipx ensurepath

echo "${CYAN}[i] Installing docker.${NC}"
sh ${CURR_FILE_PATH}/install-docker.sh --rootful
sudo usermod -aG docker $USER

echo "$GREEN INSTALLATION SUCCEED ! $NC"
