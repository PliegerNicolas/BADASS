#! /bin/sh

echo "[i] Executing $0."
set -e

EMAIL=""
USERNAME=""
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# echo "[i] Would you like to install optional packages ? (y/n)"
read -p "[i] Would you like to install optional packages ? (y/n) " OPTIONAL_PACKAGES_REPLY
if [ "$OPTIONAL_PACKAGES_REPLY" != "y" ] && [ "$OPTIONAL_PACKAGES_REPLY" != "n" ]; then
	echo "[!] Error: '$OPTIONAL_PACKAGES_REPLY' not recognized. Try using 'y' or 'n'." >&2
fi

# update and install essentials
sudo apt update && sudo apt install -y \
	make vim curl wget ufw net-tools

if [ "$OPTIONAL_PACKAGES_REPLY" = 'y' ]; then
	sudo apt update && sudo apt install -y \
		zsh build-essential htop
fi

#allow ssh on firewall
sudo ufw allow ssh

#install chrome
sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install fonts-liberation libu2f-udev -y #utile pour chrome
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get install -f -y
sudo rm -f google-chrome-stable_current_amd64.deb

# install docker
sh ./install-docker.sh

# install gns3
sudo su -c "echo 'deb http://ftp.de.debian.org/debian buster main non-free' >>/etc/apt/sources.list"
sudo su -c "echo 'deb http://deb.debian.org/debian/ buster-updates main contrib non-free' >>/etc/apt/sources.list"
sudo su -c "echo 'deb http://security.debian.org/debian-security buster/updates main contrib non-free' >>/etc/apt/sources.list"
sudo apt update
sudo apt install python3 python3-pip pipx python3-pyqt5 python3-pyqt5.qtwebsockets python3-pyqt5.qtsvg qemu-system-x86 qemu-utils libvirt-clients libvirt-daemon-system virtinst dynamips software-properties-common ca-certificates curl gnupg2 
pipx install -f gns3-server
pipx install -f gns3-gui
pipx inject gns3-gui gns3-server PyQt5


echo "$GREEN INSTALLATION SUCCEED! If you want to install guest additions, please insert guestAdditions CD image in 'Devices' and then run :$NC"
echo "sudo mkdir -p /mnt/cdrom & sudo mount /dev/cdrom /mnt/cdrom & sudo cd /mnt/cdrom & sudo sh ./VBoxLinuxAdditions.run --nox11 & sudo shutdown -r now"
