# Create new interfaces in VMs using VBox CLI

## VirtualBox CLI Setup

With this method, we can create up to 8 interfaces for each virtual machine. In GUI, we are restricted up to 4 interfaces per virtual machine.

Add the location of VirtualBox CLI as an environmental variable to execute it from any location in cmd or Powershell.

VirtualBox is by default installed at 

    C:\Program Files\Oracle\VirtualBox

Go to:

    Search bar -> Type Environment -> Edit environment variables for your account -> Environment Variables

In the top window, select the variable named “Path” and then click on Edit.

<img width="611" height="578" alt="image" src="https://github.com/user-attachments/assets/3d7f683c-8c29-4967-8afe-472bb7188f31" />

Click on New and then paste the path to the VirtualBox CLI. Then click on OK.

<img width="564" height="496" alt="image" src="https://github.com/user-attachments/assets/32cd8f69-ad3d-4bb5-bde3-f140fd32393a" />

## Creating new Interface

### Commands:

#### 1) List VMs (we need the name of our PfSense VM)

    VBoxManage list vms

#### 2) Create an Internal Network

    VBoxManage modifyvm "PfSense" --nic5 intnet

#### 3) Use the paravirtualized Adapter

    VBoxManage modifyvm "PfSense" --nictype5 virtio

#### 4) Give it any name you like (LAN 3, or in my case, LabLAN 4

    VBoxManage modifyvm "PfSense" --intnet "LabLAN 4"

#### 5) Network interface is connected by Cable

    VBoxManage modifyvm "PfSense" --cableconnected5 on

Image example:

<img width="884" height="548" alt="image" src="https://github.com/user-attachments/assets/8d33b50b-0430-43d8-8e5b-1f1e97f543b4" />

## Enabling the Interface

Start the PfSense VM

Enter 1 (Assign Interfaces)

Then follow the below:

    Should VLANs be set up now? n
    Enter the WAN interface name: vtnet0
    Enter the LAN interface name: vtnet1
    Enter the Optional 1 interface name: vtnet2   
    Enter the Optional 2 interface name: vtnet3
    Enter the Optional 3 interface name: vtnet4
    Do you want to proceed?: y

The new interface has been added. Now we need to assign the interface an IP address.

Enter 2 (Set interface(s) IP address)

Enter 5 to select the OPT3 interface

Then follow the below:

    Configure IPv4 address OPT3 interface via DHCP?: n
    Enter the new OPT3 IPv4 address: 10.99.99.1
    Enter the new OPT3 IPv4 subnet bit count: 24
    Press Enter
    Configure IPv6 address OPT3 interface via DHCP6: n
    For the new OPT3 IPv6 address question press Enter.
    Do you want to enable the DHCP server on OPT3?: y
    Enter the start address of the IPv4 client address range: 10.99.99.11
    Enter the end address of the IPv4 client address range: 10.99.99.243
    Do you want to revert to HTTP as the webConfigurator protocol?: n

Now interface OPT3 will have an IP address.

Interface IP Address

    10.99.99.1

Subnet Mask (bit)

    24

Start-End of the IPv4 client address range

    10.99.99.11 - 10.99.99.243

DHCP Server enabled

    yes

## Renaming the Interface

Start the Kali VM and browse to the PfSense administrative dashboard.

Then select

    Interfaces -> OPT3

In the description field, enter

    SECURITY

Then click

    Save -> Apply Changes

## Interface Firewall Configuration

Click on

    Firewall -> Rules

Select the SECURITY tab, then add these rules below:

#### Rule 1

    Action: Block
    Address Family: IPv4+IPv6   
    Protocol: Any
    Source: SECURITY subnets
    Destination: WAN subnets
    Description: Block access to services on WAN interface

#### Rule 2

    Action: Block
    Address Family: IPv4+IPv6
    Protocol: Any
    Source: SECURITY subnets
    Destination: LAN subnets
    Description: Block access to services on LAN

#### Rule 3

    Address Family: IPv4+IPv6
    Protocol: Any
    Source: SECURITY subnets
    Description: Allow traffic to all subnets and Internet

Final results

<img width="1911" height="866" alt="image" src="https://github.com/user-attachments/assets/c10d1219-766d-46cb-a7d0-29e03831f8ea" />

Apply Changes, then reboot pfSense

Go to

    Diagnostics -> Reboot -> Submit

Once pfSense boots up you will be redirected to the login page.
