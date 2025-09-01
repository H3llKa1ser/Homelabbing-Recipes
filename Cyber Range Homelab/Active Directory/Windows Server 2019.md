# Windows Server 2019

Download Link: https://www.microsoft.com/en-us/evalcenter/download-windows-server-2019 (English (US) 64-bit edition)

### TIP: Rename the downloaded .iso file OR create a separate folder with the name of the server to avoid confusion.

#### 1) VM Creation

On the VirtualBox Manager, select:

    Machine -> New

Ensure that the Folder option points to the location where all of your Home Lab VMs are stored.

Select the downloaded .iso image file in the "ISO Image".

Select the "Skip Unattended Installation" option, then click Next.

Next, set the specs for the VM listed below:

    Base Memory (RAM): 4096
    Processors: 1
    Hard Drive Size: 100GB

Confirm all values are correct, then click Finish.

Add the VM to a new group, then rename the group "Active Directory". After that, nest the "Active Directory" group under "Home Lab".

Go to:

    Settings -> System -> Motherboard

In Boot Order, set Hard Disk on top, second Optical. Disable Floppy.

Now go to:

    Settings -> Network -> Adapter 1

In the "Attached to" field, select:

    Internal Network -> LAN 2 (or in our case, LabLAN 3)

#### 2) Server Setup

Start the VM.

Click next, then Install now.

Select

    Windows Server 2019 Standalone Evaluation (Desktop Experience)

and then click Next.

Accept the license terms, then Next.

Select

    Custom: Install Windows only (Advanced)

Select

    Disk 0

and then Click Next

Wait for the installation (the VM will restart twice during installation)

#### 3) Server Configuration

Once the installation is complete, we will be asked to set the password for the Administrator account. Set any password you like (remember this is a Cyber Range Home Lab).

Click Finish.

We won’t be able to log in by using the Ctrl+Alt+Delete shortcut. This will open the system settings menu of the host system.

VirtualBox has a shortcut configured to perform this action. Use the shortcut Right Ctrl+Delete to access the login screen. Login as the Administrator in the VM.

- Guest Additions Installation

We need to install the VBOX Guest Additions to adjust the size of the VM screen.

From the VM toolbar, click:

    Devices -> Optical Drives -> Remove disk from virtual drive.

Then select:

    Devices -> Insert Guest Additions CD Image

Now open the File Explorer. Once the disk is loaded, it will show up in the sidebar.

Click on it, then Double-click on VBOXWindowsAdditions to start the installer.

Click Next, Next, Install. Once installed, choose Reboot now, then Finish. The VM will restart.

After restart, login again. Then click on

    Devices -> Optical Drivers -> Remove disk from virtual drive

to remove the Guest Additions image.

From the VM toolbar, click:

    View -> (Choose any view mode you wish)

 - Network Configuration

The AD_LAB interface has disabled DHCP, and because of this, we have to manually assign an IP address.

From the taskbar, right-click on the network icon, and select

    Open Network & Internet Settings

Click on 

    Change Adapter Options

On the Network Connections page, we should see the Ethernet Adapter. Right-click on the adapter and select "Properties".


