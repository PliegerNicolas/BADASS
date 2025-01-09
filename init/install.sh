#! /bin/sh


CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

CURR_FILE_PATH="$(dirname "$(realpath "$0")")"

read -p "[i] Would you like to install optional packages ? (y/n) " OPTIONAL_PACKAGES_REPLY
if [ "$OPTIONAL_PACKAGES_REPLY" != "y" ] && [ "$OPTIONAL_PACKAGES_REPLY" != "n" ]; then
	echo "[!] Error: '$OPTIONAL_PACKAGES_REPLY' not recognized. Try using 'y' or 'n'." >&2
fi

set -e

echo "${CYAN}[i] Executing $0.${NC}"

echo "${CYAN}[i] Installing mandatory dependencies.${NC}"

sudo apt update && sudo apt upgrade

# Basic necessities (software installation, HTTP com. IDE, other...)
echo "${CYAN}[i] > Installing basic necessities and dependencies.${NC}"
sudo apt install -y -qq \
	ufw curl wget \
	vim \
	make cmake \
	net-tools

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

git clone https://github.com/GNS3/dynamips.git ~/dynamips
cd ~/dynamips && mkdir -p build && cd build
cmake .. && sudo make install
rm -rf ~/dynamips

echo "${CYAN}[i] Configuring ufw (+ssh).${NC}"
sudo ufw allow ssh

if [ "$OPTIONAL_PACKAGES_REPLY" = "y" ]; then
	sudo apt update
	
	echo "${CYAN}[i] (Optional) Installing zsh.${NC}"
	sudo apt install -y zsh

	echo "${CYAN}[i] (Optional) Installing google chrome.${NC}"
	curl -o ~/gchrome.deb \
		https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo dpkg -i ~/gchrome.deb
	sudo rm -f ~/gchrome.deb
fi

# install docker
#sh ${CURR_FILE_PATH}/install-docker.sh

# install gns3
#sudo su -c "echo 'deb http://ftp.de.debian.org/debian buster main non-free' >>/etc/apt/sources.list"
#sudo su -c "echo 'deb http://deb.debian.org/debian/ buster-updates main contrib non-free' >>/etc/apt/sources.list"
#sudo su -c "echo 'deb http://security.debian.org/debian-security buster/updates main contrib non-free' >>/etc/apt/sources.list"
#sudo apt update
#sudo apt install python3 python3-pip pipx python3-pyqt5 python3-pyqt5.qtwebsockets python3-pyqt5.qtsvg qemu-system-x86 qemu-utils libvirt-clients libvirt-daemon-system virtinst dynamips software-properties-common ca-certificates curl gnupg2 
#pipx install -f gns3-server
#pipx install -f gns3-gui
#pipx ensurepath
#pipx inject gns3-gui gns3-server PyQt5


#echo "$GREEN INSTALLATION SUCCEED ! Please open a new terminal to update \$PATH $NC"
