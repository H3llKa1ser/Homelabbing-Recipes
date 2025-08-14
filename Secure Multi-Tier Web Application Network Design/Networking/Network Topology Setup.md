# Network Topology Setup - PfSense

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

#### 1) Setup Wizard

Go to: 

    System -> Setup Wizard -> pfSense Setup

On step 2, you can give the firewall host a name. It can be anything. Then you can also give it a domain name \. It can be whichever you like if you identify the pfSense device within your network.

In our example, the firewall host has the domain:

    edgefw.homelab.lan

Uncheck the "Override DNS" option, then next

<img width="1917" height="940" alt="image" src="https://github.com/user-attachments/assets/3c175059-fa0a-4c75-b696-473d77487d1b" />

On step 3, choose your timezone, then next

On step 4, uncheck the "Block private networks from entering via WAN", then next

<img width="1144" height="255" alt="image" src="https://github.com/user-attachments/assets/1b50876e-b045-4f53-8d5e-0aca1de2b46f" />

On step 5, do not change anything, then next

On step 6, change the admin password to something strong, then next.

Click finish.

#### 2) Rename interfaces

We will 

Go to:

    Interfaces -> LAN/OPT1/OPT2

In the description name, enter the appropriate name for the interface for identification

 - LAN: UserNetwork

 - OPT1: DMZ

 - OPT2: Security

For each option, after clicking save, go to the top of the screen and click "Apply Changes"

#### 3) DNS Resolver 

Go to:

    Services -> DNS Resolver

Then, in General Settings, check these 3 options:

<img width="1138" height="310" alt="image" src="https://github.com/user-attachments/assets/9381a797-1749-4d49-94a4-cf269f481ebe" />

Go to Advanced Settings and check these 2 options:

<img width="1137" height="185" alt="image" src="https://github.com/user-attachments/assets/15a42347-d0df-493b-be16-2087ce7bce61" />

Then click "Save", then "Apply Changes" to take effect.

#### 4) Disable DHCPv6

Go to:

    Interfaces -> WAN

Then in IPv6 Configuration type, select None.

After that, click "Save", then "Apply Changes" and proceed to reboot the PfSense VM

#### 5) Advanced Configuration

Go to 

    System -> Advanced -> Networking

Check this option

<img width="1141" height="131" alt="image" src="https://github.com/user-attachments/assets/4422675a-da3b-4385-b445-7df5a6e7739a" />

Then, click "Save", "Apply Changes", and click OK in the prompt for rebooting PfSense.

After reboot, login again.

