# Chronos

Download link: https://download.vulnhub.com/chronos/Chronos.ova

#### 1) Create VM

On the VirtualBox Manager, select:

    File -> Import Device

Select your downloaded .ova file

In Settings, select the following:

    RAM: 1024
    CPU: 1
    MAC Address Policy: Generate new MAC addresses for all network adapters

  Then add the VM to the Cyber Range Group.

#### 2) Configure VM

Select the Chronos VM, then click "Settings"

Go to:

    System -> Motherboard

In Boot Order, put Hard Disk on the top, followed by Optical. Disable Floppy.

Go to:

    Network -> Adapter 1

For the "Attached to" field, select "Internal Network"

Adapter Type: Paravirtualized Network (virtio-net)

#### 3) Testing Connectivity

Start your Chronos VM.

On the Kali VM, go to the PfSense portal. Select:

    Status -> DHCP Leases

You should see the assigned IP address under the Leases section.

Ping for verification:

    ping CHRONOS_IP -c 5
