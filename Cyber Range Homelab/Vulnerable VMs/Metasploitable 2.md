# Metasploitable 2

Download link: https://download.vulnhub.com/metasploitable/metasploitable-linux-2.0.0.zip

Extract all files with any archive tool (WinRAR, for example)

Login Credentials:

    Username: msfadmin
    Password: msfadmin

#### 1) Create the VM

In VirtualBox Manager, select

    Machine -> New

### TIP: Ensure that the Folder is set to the location where all the VMs are going to be saved.

LEAVE ISO IMAGE OPTION EMPTY.

Enter these details upon VM creation:

    Base Memory: 1024MB
    Processors: 1

Next, select:

    Do Not Add a Virtual Hard Disk

Next, confirm that everything looks correct and click Finish. (Ignore the warning prompt by clicking "Continue")

Right-click on the Metasploitable VM. Select

    Move to Group -? [New]

Right-click on the newly created group, then select "Rename Group". Name the group "Cyber Range" or anything you want.

Right-click on the newly created group and select

    Move to Group -? Cybersecurity Homelab (or any name you gave your lab)

#### 2) Configure the VM

Find the Metasploitable VM folder location and move the downloaded .vmdk file into it.

Select the VM, then click "Settings".

Go to:

    Storage -> Controller: SATA

Then click on the small "Add Hard Disk" icon. (Sample image provided below)

<img width="746" height="508" alt="image" src="https://github.com/user-attachments/assets/ec4b3893-632f-453c-98c9-8b827d4151ca" />

This will open the Hard Disk Selector menu. Click on:

    Add -> Select the .vmdk file

Then click Choose to use the Hard Drive.

Go to:

    System -> Motherboard

In Boot Order, select the following details in this specific order:

<img width="579" height="211" alt="image" src="https://github.com/user-attachments/assets/5e84db08-633f-4a4a-bda8-99ecd5cfcac3" />

Go to:

    Network -> Adapter 1

Change "Attached to" field:

    Internal Network

Then in "Name", select:

    LAN 1 (or in our case, LabLAN 2)

Click OK to save changes.

#### 3) Testing Connectivity

Start your Metasploitable VM

Login with the following credentials:

    msfadmin:msfadmin

After login, use the following command to check if we have an IP address:

    ip a l eth0

The IP assigned should be inside the DHCP address range set for the CYBER_RANGE interface.

Ping Google to test internet connectivity:

    ping google.com -c 5

Ping our Attacker VM (Kali or any other pentesting distro you decided to install)

    ping ATTACKER_VM_IP -c 5

Ping Metasploitable VM from Attacker VM

    ping METASPLOITABLE_IP -c 5
