# Bgp At Doors of Autonomous Systems is Simple (BADASS)

Emulation d'un reseau network 

## Installation

1. Install and access VirtualBox.
   
2. Create your VM using the latest Debian ISO file (cf. [Download URLs](#download-urls)).

3. Make yourself sudo.

```sh
# Copy/paste isn't permitted by default with VirtualBox from host to guest (VM).

su -lc "apt update && apt install -y sudo && usermod -aG sudo [user]"
exec su - [user]

# This replaces current shell with a new login shell.
# The second command can be skipped but then you'll have to restart your VM.
```

4. (Optional) Ensure VM is accessible via ssh.

```sh
sudo apt update && sudo apt install -y openssh-server
```

Apply this part if default SSH port (22) is reserved/blocked behind a firewall.

```sh
# We arbitrarily decide to use port 2222 and forward it to port 22 of our VM.
# You can choose whatever value you want for Host Port.

In VirtualBox go to your VM > Settings > Network > Advanced > PortForwarding and enter:

          Name           |  Protocol  |  Host IP  |  Host Port  |   Guest IP   |  Guest Port
 42-ssh-port-forwarding  |    TCP     |           |    2222     |              |      22

# You can then log via the host using...
ssh [user]@localhost -p 2222
```

*Small tip: use SSH to copy/paste commands from host to guest more easily.*

5. (Optional) Allow copy/paste from host to guest (VM).

```sh
# Go in your VM's view tabs and click: "Devices > Inert Guest Additions CD image...".
```

```
# In the Oracle VM VirtualBox Manager:
# step nº1: accès your VM's settings (right click your VM > settings.
# step nº2: General > advanced: set the options you'd like for Shared clipboard or Drag'n'Drop.
```

```sh
# Then in your VM. Open a terminal and run.
# /!\ This will reboot your VM.

sudo mkdir -p /mnt/cdrom && sudo mount /dev/cdrom /mnt/cdrom
sudo sh /mnt/cdrom/VBoxLinuxAdditions.run --nox11
sudo shutdown -r now
```

6. Install and prepare git.

```sh
sudo apt update && sudo apt install -y git openssh-client openssh-server
sudo git config --global user.email [your_email]
ssh-keygen -t rsa -b 4096 && cat ~/.ssh/id_rsa.pub # Assuming you used the default public key filename.
```

7. Go to [Github](https://github.com) in the [settings](https://github.com/settings/keys) and add your ssh key there to give permissions.

8. Download the repository and launch the installation script `install.sh`.

```sh
git clone git@github.com:maSorciereBienAimee/BADASS.git ~/BADASS && cd ~/BADASS
sh init/install.sh
```

9. Launch GNS3.

```sh
gns3

# GNS3 should launch it's server. But you can do it manually using:
# gns3server
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
    - https://hub.docker.com/u/gns3  
