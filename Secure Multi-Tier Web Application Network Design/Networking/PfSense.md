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

 - Adapter 1: NAT (WAN)

 - Adapter 2: Internal Network (LAN) or Host-Only Network (in this case, we choose Internal Network and name it LabLAN, for example

 - Adapter 3: Internal Network (LAN) LabLAN 2

 - Adapter 4: Internal Network (LAN) LabLAN 3

 - Make sure that we have the option "wired connection" enabled in the advanced options of each NIC and all NICs use the Paravirtualized Network (virtio-net) Adapter Type.

<img width="736" height="486" alt="image" src="https://github.com/user-attachments/assets/e0061115-5b18-4ab8-815d-f4673b3d4223" />


#### 3) Boot the machine, and then follow the installation instructions, then make these changes:

 - Choose vtnet0 for the WAN interface

 - Choose vtnet1 for the LAN interface

 - Choose vtnet2 for the LAN 2 interface

 - Choose vtnet3 for the LAN 3 interface

 - Partitioning: UFS

#### 4) Once installed, DO NOT FORGET TO UNMOUNT THE ISO from our VM, then reboot the machine.

#### 5) When we land on the PfSense shell menu, press option 1 to assign the network interfaces. PfSense should detect them.
 
 - Enter vtnet0 (WAN)

 - Enter vtnet1 (LAN)

 - Enter vtnet2 (LAN)

 - Enter vtnet3 (LAN)

#### 6) Press option 2 to set interface(s) IP address (mostly to configure if we want DHCP enabled or assign static IP addresses.) In our case, we enable DHCP for all LANs except vtnet3 LAN.

##### vtnet1

 - Enter 2 to select “Set interface(s) IP address”. Enter 2 to select the LAN interface.

 - Configure IPv4 address LAN interface via DHCP?: n

 - Enter the new LAN IPv4 address: 10.0.0.1

 - Enter the new LAN IPv4 subnet bit count: 24

For the next question directly press Enter. Since this is a LAN interface we do not have to worry about configuring the upstream gateway.

 - Configure IPv6 address LAN interface via DHCP6: n

 - For the new LAN IPv6 address question press Enter

 - Do you want to enable the DHCP server on LAN?: y

 - Enter the start address of the IPv4 client address range: 10.0.0.11

 - Enter the end address of the IPv4 client address range: 10.0.0.243

 - Do you want to revert to HTTP as the webConfigurator protocol?: n

##### For all other LANs we choose the same options. Change only the corresponding IP addresses to assign

 - OPT1: 10.6.6.1 (Assigned IP), 10.6.6.11 (Start), 10.6.6.243 (End)

 - OPT2: 10.80.80.1 (Assigned IP) (Do not enable DHCP)

#### 7) Choose another VM to connect to our PfSense via LAN, and set these parameters on its network settings:

 - NIC: Internal Network (LAN)

 - Name: Same name as PfSense (LabLAN)

 - Wired Connection: Enabled

 - Adapter Type: Paravirtualized Network (virtio-net)

#### 8) Boot our machine, then check that an IP address was already assigned via DHCP with the command

    ip a

OR 

    ifconfig

Now we can access the PfSense web portal by browsing in

    https://10.0.0.1 
    
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

<img width="1920" height="962" alt="image" src="https://github.com/user-attachments/assets/ac792a80-0396-4b32-8500-804dcd3fdc13" />

#### 2) Enable HTTPS (if not already)

Go to:

    System -> Advanced -> Admin Access

Then press the radio button HTTPS (SSL/TLS)

<img width="1919" height="959" alt="image" src="https://github.com/user-attachments/assets/decc3379-a6af-4fb6-92c7-6263198296ed" />
