# Windows Server 2019

Download Link: https://www.microsoft.com/en-us/evalcenter/download-windows-server-2019 (English (US) 64-bit edition)

### TIP: Rename the downloaded .iso file OR create a separate folder with the name of the server to avoid confusion.

### 1) VM Creation

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

### 2) Server Setup

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

### 3) Server Configuration

Once the installation is complete, we will be asked to set the password for the Administrator account. Set any password you like (remember this is a Cyber Range Home Lab).

Click Finish.

We won’t be able to log in by using the Ctrl+Alt+Delete shortcut. This will open the system settings menu of the host system.

VirtualBox has a shortcut configured to perform this action. Use the shortcut Right Ctrl+Delete to access the login screen. Login as the Administrator in the VM.

#### Guest Additions Installation

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

#### Network Configuration

The AD_LAB interface has disabled DHCP, and because of this, we have to manually assign an IP address.

From the taskbar, right-click on the network icon, and select

    Open Network & Internet Settings

Click on 

    Change Adapter Options

On the Network Connections page, we should see the Ethernet Adapter. Right-click on the adapter and select "Properties".

Select:

    Internet Protocol Version 4 (TCP/IPv4) -> Properties

Enter the details below, click OK, then OK again.

    IP Address: 10.80.80.2
    Subnet Mask: 255.255.255.0
    Default Gateway: 10.80.80.1
    Preferred DNS Server: 10.80.80.2

Windows will display a banner to allow internet access click on Yes.

Close the Network Connections page.

#### Renaming the System

In the Settings app click on the Home button (above search bar).

Select "System".

Click on "About" on the sidebar and then click on the “Rename this PC” button. Give the PC an easy-to-remember name and then click on Next.

Click on “Restart now” for the changes to take effect.

### 4) Active Directory and DNS Installation

On the Server Manager, click on the "Manage" tab from the top right corner and select "Add Roles and Features".

Click on Next until "Server Roles".

Enable "Active Directory Domain Services" and "DNS Server".

Click "Add Features" to confirm selection (This tab opens every time you enable a feature)

Click Next until "Confirmation"

Install. Once the installation is complete, exit the wizard.

#### Active Directory Configuration

Click on the Flag icon, then click on "Promote this server to a domain controller".

The AD Domain Servers Configuration Wizard will open. For deployment operation select Add a new Forest. Give the domain a name.

You can name your domain anything you like (the domain in this example shall be named adcyber.lab)

Enter a password to use for using Directory Services Restore Mode (DSRM)

Click Next

The NetBIOS name should automatically be filled. It will be the first part of the domain name. Click on Next to continue.

Next, Next, then Install to start the Domain Services setup.

Once the install is complete the machine will reboot. CLick close to reboot.

#### DNS Configuration

Open Start Menu, then:

    Windows Administrative Tools -> DNS

Select the Domain Controller (The machine name you just gave a few steps back). Double-click on "Forwarders" to the right.

Go to:

    Forwarders -> Edit

Enter the IP address of the AD_LAB interface (10.80.80.1), then Enter.

Click OK, Apply then OK.

### 5) DHCP Installation

Click on Manage from the toolbar in Server Manager. Then choose “Add Roles and Features”.

Keep clicking Next till you reach the “Server Roles” page. Enable “DHCP Server” then click on “Add Features”.

Keep clicking Next till you reach the Confirmation page. Click Install to enable DHCP.

#### DHCP Configuration

After the installation is complete click on the Flag present in the toolbar of Server Manager and click on “Complete DHCP configuration”.

Click on "Commit"

Click "Close"

Then from the Start Menu, go to:

    Windows Administrative Tools -> DHCP

Expand the DHCP server (dc1.adcyber.lab in our example)

Right-click on "IPv4", then select "New Scope"

Enter a Name and Description for the new scope.

Enter the details below, then Next:

    Start IP address: 10.80.80.11 (You can start with 10.80.80.3, but you may need some IPs for static assignment)
    End IP address: 10.80.80.253
    Length: 24
    Subnet mask: 255.255.255.0

Click Next

Increase the lease time to 365 days, then Next

Select “Yes, I want to configure these options now” and click on Next.

In the IP address field enter the default gateway for the AD_LAB interface (10.80.80.1) and then click on Add. Once added click on Next.

Next, Next, then "Yes, I want to activate this scope now", then Next.


