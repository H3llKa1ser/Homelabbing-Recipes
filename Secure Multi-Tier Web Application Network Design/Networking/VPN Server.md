# VPN Server

### Specs

 - OS: Debian

 - RAM: 1024MB 

 - Storage Space: 15GB

#### 1) Installation

Download Debian .iso file from:

    https://www.debian.org/download

Then, create a new VM in VirtualBox Manager and set the specs mentioned above.

#### 2) Configuration

Login as root (enter your password) OR run everything with sudo. If sudo is not installed, run as root:

    su root

Then

    apt install sudo
   
Update apt repository

    sudo apt update && sudo apt full-upgrade

Add our created user to the sudo group to allow him to execute commands with elevated privileges (sudo)

    sudo usermod -aG sudo USER

Install GUI environment

    sudo apt install task-mate-desktop -y

Then 

    sudo apt install lightdm -y

 Reboot the system with this command

    sudo systemctl reboot
