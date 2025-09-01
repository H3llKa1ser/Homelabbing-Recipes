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
