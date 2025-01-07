#!/bin/sh
EMAIL=""
USERNAME=""
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
# checks
if (whoami != root); then
	echo "$RED Please run as root! ($ su;) $NC"
	exit 1
fi
if [ $USERNAME = "" ]; then
	echo "$RED Please fill the USERNAME var in script to add root privilege !$NC"
	exit 1;
fi
if [ $EMAIL = "" ]; then
	echo "$RED Please fill the EMAIL var in script to set up github!$NC"
	exit 1
fi

#passe en sudoers
echo "$USERNAME ALL=(ALL:ALL) ALL" >> /etc/sudoers
sudo usermod -aG sudo $USERNAME

#config git
sudo apt install git
sudo git config --global user.email $EMAIL

# update and install essentials
sudo apt update
sudo apt install build-essential -y
sudo apt install net-tools -y
sudo apt install vim -y
sudo apt install make -y
sudo apt install openssh-server -y
sudo apt install openssh-client -y
sudo apt install ufw -y
sudo apt install htop -y
sudo apt install curl -y
sudo apt install wget -y
sudo apt install zsh -y

#allow ssh on firewall
sudo ufw allow ssh

#install chrome
sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install fonts-liberation libu2f-udev -y #utile pour chrome
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get install -f -y

echo "$RED Warning ! You are about to create new ssh key! $NC"
ssh-keygen

#install
./install-docker.sh

echo "$GREEN INSTALLATION SUCCEED! If you want to install guest additions, please insert guestAdditions CD image in 'Devices' and then run"

# you can install guestAddition : 
# insert guestAddition
# then 
# sudo mkdir -p /mnt/cdrom
# sudo mount /dev/cdrom /mnt/cdrom
# cd /mnt/cdrom
# sudo sh ./VBoxLinuxAdditions.run --nox11
# And relaunch :
# sudo shutdown -r now
