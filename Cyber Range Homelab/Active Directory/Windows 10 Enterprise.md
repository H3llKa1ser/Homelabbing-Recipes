# Windows 10 Enterprise

Download link: https://www.microsoft.com/en-us/evalcenter/download-windows-10-enterprise (English United States 64-bit)

### 1) VM Creation

In VirtuaklBox Manager, create VM by clicking:

    Machine -> New

Give the VM a name. Ensure that the Folder option is pointing to the location where all the Home Lab VMs are saved. For the ISO Image option select the Windows 10 Enterprise image. Tick the Skip Unattended Installation option. Click on Next to continue.

Leave Memory and CPU on its default value. Click on Next.

Increase the Hard Disk size to 100GB and then click on Next.

Verify that all the options are correct and then click on Finish.

Right-click on the VM and then choose Move to 

    Group -> Home Lab/Active Directory.

Do this one more time for another Windows 10 VM with the EXACT steps.

### 2) VM Configuration

Select your Windows 10 VM, then select Settings

Go to:

    System -> Motherboard

For Boot Order ensure Hard Disk is on the top followed by Optical. Disable Floppy.

Go to:

    Network -> Adapter 1

For the "attached to" field select "Internal Network", then name LAN 2 (LabLAN 3)

Follow the EXACT same steps for the other VM.

### 3) VM Setup

Select your Windows 10 Enterprise VM, then click Start

#### OS Installation

Click Next, then Install now

Accept the agreement and then click on Next.

Select “Custom: Install Windows only (advanced)”.

Select Disk 0 and then click on Next.

The VM will reboot multiple times during the installation.

Select your Region and Keyboard Layout.

Click Skip

Select “Domain join instead”. This will allow us to configure a local account.

Enter a username and click on Next.

Enter a password and click on Next. (This password can be different from the password that was configured in Active Directory.)

Configure the “Security Questions” for the user. Remember to note down these details in a secure location.

Disable all the features that are shown. Then click on Accept.

Select Not now.

Once on the desktop a prompt to allow internet access should show up click on Yes.

#### Guest Additions Installation

Similar to the Windows 2019 Server VM we need to install Guest Additions to enable Fullscreen mode. From the VM toolbar select 

    Devices -> Remove disk for virtual drive. 
    
This will remove the Windows 10 image.

Click on 

    Devices -> Insert Guest Additions CD image.

Open File Explorer. Once the disk has loaded from the sidebar select the disk drive. Double-click VBoxWindowsAdditions to start the installer.

Click Next, Next, then Install.

Select “Reboot now” and then click on Finish. The VM will reboot.

Login into the system.

From the toolbar select Optical Devices -> Remove disk from virtual drive to remove the Guest Additions image.

#### Add VM to Domain

Now we can add this device to the AD domain and log in as an AD user.

Click on the Search Bar and search for “This PC”. Right-click on it and select Properties.

Click on Advanced system settings.

Select the “Computer Name” tab and click on Change.

In the Computer name field enter a name that can be used to easily identify this VM. In the Member of section select Domain and enter the name of the AD domain. Then click on More.

In the “Primary DNS suffix of this computer” field enter the domain name. Click on OK.

Click OK.

Now a popup should appear. Enter the login name and password of the Domain Admin and click on OK.

The device will be added to the AD environment. Click on OK.

The device needs to be rebooted to apply the domain-specific settings. Click on OK to continue.

Click on “Restart Now”.

Once on the login screen. Click on “Other user”. Enter the login name and password of the AD user that will use this device and press Enter.

Now we are logged into the system as the AD user. To confirm this we can open PowerShell and run whoami.

Follow SIMILAR steps for setting up the other Windows 10 VM.
