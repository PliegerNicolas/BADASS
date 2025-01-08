# Bgp At Doors of Autonomous Systems is Simple (BADASS)

Emulation d'un reseau network 

## Installation

1. Install and access VirtualBox.
2. Create your VM using the latest Debian ISO file (cf. [Download URLs](#download-urls)).
3. Make yourself sudo.
```sh
su -lc "apt update && apt install -y sudo && usermod -aG sudo [user] && su - [user]"
```
3. You can optionnaly set the GuestAdditions to allow copy/paste for the rest of installation.
For that, in options tab click on  Devices > Insert Guest Additions CD image... then :
```sh
sudo mkdir -p /mnt/cdrom
sudo mount /dev/cdrom /mnt/cdrom
sudo cd /mnt/cdrom
sudo sh ./VBoxLinuxAdditions.run --nox11
sudo shutdown -r now
```
4. Install and prepare git.
```sh
sudo apt update && sudo apt install -y git openssh-client openssh-server
sudo git config --global user.email [your_email]
ssh-keygen -t rsa -b 4096 && cat ~/.ssh/id_rsa.pub # Assuming you used the default public key filename.
```
5. Ensure VM is accessible via ssh.
```sh
# Skip this part if not at School. 42 already uses port 22.
# We arbitrarily decide to use port 2222 and forward it to port 22 of our VM.

In VirtualBox go to your VM > Settings > Network > Advanced > PortForwarding and enter:

          Name           |  Protocol  |  Host IP  |  Host Port  |   Guest IP   |  Guest Port
 42-ssh-port-forwarding  |    TCP     |           |    2222     |  127.0.0.1   |      22
```
5. Go to [Github](https://github.com) in the [settings](https://github.com/settings/keys) and add your ssh key there to allow contact.
6. Download the repository.
```sh
git clone git@github.com:maSorciereBienAimee/BADASS.git ~/BADASS
```
7. To continue installation launch the dedicated script `install.sh`.
```sh
cd ~/BADASS && sh init/install.sh
```

## Notions

**Border Gateway Protocol (BGP)**:  
    - https://fr.wikipedia.org/wiki/Border_Gateway_Protocol  
    - https://datatracker.ietf.org/doc/rfc4271  

**Multiprotocol Border Gateway Protocol (MP_BGP)**:  
    - https://en.wikipedia.org/wiki/Multiprotocol_BGP  
    - https://datatracker.ietf.org/doc/html/rfc4760  

**Ethernet VPN (EVPN)**  
    - https://fr.wikipedia.org/wiki/Ethernet_VPN

## Download URLs

**Debian ISO** ᭜ https://www.debian.org/download.fr.html  
**GNS3** ᭜ https://www.gns3.com/software/download  

## Documentation

**GNS3**:  
    - https://docs.gns3.com/docs
