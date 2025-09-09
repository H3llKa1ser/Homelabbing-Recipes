# Kali Linux Installation

### 1) VM Creation

Go to -> https://www.kali.org/get-kali/#kali-installer-images

And download the .iso file

    https://cdimage.kali.org/kali-2025.2/kali-linux-2025.2-installer-amd64.iso

Then, in VirtualBox, create a new VM (Highlighted in pic)

<img width="864" height="192" alt="image" src="https://github.com/user-attachments/assets/59efb25c-7fc3-442a-b303-4f74c1c5ce96" />

Choose your downloaded Kali .iso, then as you proceed with the VM creation, set these specs:

 - 2048 or 4096 MB RAM

 - 1 CPU (2 if you have issues with performance)

 - 80 GB Virtual Hard Disk (VHD) Space

### 2) VM Configuration

Select our newly created Kali VM and then select "Settings".

Go to the "Storage" tab.

Select the Empty disk (Controller: IDE), then click on the small disk icon on the right side of the Optical Drive option.

Then select:

    Choose a disk file -> Downloaded .iso Kali

### 3) Network Configuration

#### Adapter 1

Go to:

    Network -> Adapter 1

Select 

    Attached to: Internal Network

    Name: LAN 0

Expand the Advanced section, then select:

    Adapter Type: Paravirtualized Network (virtiio-net)

    Cable Connected: Yes (Box ticked)

#### Adapter 2 (You can access the internet without PfSense being online)

Go to:

    Network -> Adapter 2

    Attached to: NAT

Expand the Advanced section, then select

    Adapter Type: Interl PRO/1000 MT Desktop (Might be different on your PC)

    Cable Connected: Yes (Box ticked)

### 4) Kali Boot and Installation

The installation is straightforward. Select Graphical Install, then by following the recommended options that the installer tells you, you should successfully install Kali in your VM with no issues.

### 5) Post-Installation

Run the command

    ip a

To check the assigned IP address from the LAN network range. The VM should be able to access the internet as well.

Update the system (Enter password when prompted)

    sudo apt update && sudo apt full-upgrade

After the update, remove the unused packages

    sudo apt autoremove
