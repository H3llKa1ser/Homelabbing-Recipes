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




