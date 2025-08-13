# PfSense

We set up a PfSense appliance as our gateway to the outside world (WAN) for our internal LAN, which also works as a Layer 4 firewall.

## Installation Steps

#### 1) Download the PfSense iso image for free from:

    https://www.pfsense.org/download/

#### 2) Create a VM in VirtualBox with these specs:

 - FreeBSD x64bit

 - 2048MB RAM

 - VDI Disk Type

 - 10GB Storage

 - Check "Pre-allocate full size"

#### 3) Create 2 Network Interface Cards (NICs) for the VM

 - Adapter 1: Bridged Mode (WAN)

 - Adapter 2: Internal Network (LAN) or Host-Only Network (in this case, we choose Internal Network and name it LabLAN, for example

 - Make sure that we have the option "wired connection" enabled in the advanced options of each NIC.

#### 3) Boot the machine, and then follow the installation instructions, then make these changes:

 - Choose em0 for the WAN interface

 - Choose em1 for the LAN interface

 - Partitioning: UFS

#### 4) Once installed, DO NOT FORGET TO UNMOUNT THE ISO from our VM, then reboot the machine.

#### 5) When we land on the PfSense shell menu, press option 1 to assign the network interfaces. PfSense should detect them.
 
 - Enter em0 (WAN)

 - Enter em1 (LAN)

#### 6) Press option 2 to set interface(s) IP address (mostly to configure if we want DHCP enabled or assign static IP addresses.) In our case, we assign static IP addresses for our LAN.

#### 7) Choose another VM to connect to our PfSense via LAN, and set these parameters on its network settings:

 - NIC: Internal Network (LAN)

 - Name: Same name as PfSense (LabLAN)

 - Wired Connection: Enabled

#### 8) Boot our machine, then on the command line type these commands to assign it an IP address in the LAN network

    sudo ip addr add 192.168.10.2/24 dev eth1

Then

    sudo ip route add default via 192.168.10.1

Now we can access the PfSense web portal by browsing in

    https://192.168.10.1 
    
OR if https is disabled 
    
    http://192.168.10.1

with default credentials (Change password upon login to something strong!):

    admin:pfsense

## PfSense Web Administration Panel

You can instead use the GUI to make changes on the PfSense device.

#### 1) Make any changes on setup

You can go to: 

    System -> Setup Wizard -> pfSense Setup

if you want to make any additional changes.

On step 2, you can give the firewall host a name. It can be anything. Then you can give it a domain name as well (we will configure DNS later).

In our example, the firewall host has the domain:

    edgefw.homelab.lan

#### 2) Enable HTTPS (if not already)

Go to:

        System -> Advanced -> Admin Access

Then press the radio button HTTPS (SSL/TLS)

<img width="1919" height="959" alt="image" src="https://github.com/user-attachments/assets/decc3379-a6af-4fb6-92c7-6263198296ed" />
