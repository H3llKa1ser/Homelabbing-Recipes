# Splunk SIEM

## VM Specs

    OS: Ubuntu Linux
    RAM: 4096 MB (4GB)
    CPU: 1
    Disk Space: 100GB
    Skip Unattended Installation: Yes
    Network Adapter: Internal Network (LabLAN4 AKA SECURITY INTERFACE)

### 1) Ubuntu Installation

After following the instructions for installing Ubuntu, install the VBox Guest Additions by inserting the disk by clicking on:

    Devices -> Insert Drive with Guest Additions

Click on the disk, right click anywhere within the file explorer and choose, Open in Terminal.

Run the command:

    sudo ./VBoxLinuxAdditions.run

Then

    sudo reboot

Install Updates

    sudo apt update && sudo apt full-upgrade

### 2) Splunk Installation

To install Splunk, you either have to create an account on https://www.splunk.com/en_us/download/splunk-enterprise.html to use the latest version,

OR

Download the .deb file from this link

    wget https://download.splunk.com/products/splunk/releases/9.1.2/linux/splunk-9.1.2-b6b9c8185839-linux-2.6-amd64.deb

Install cURL Splunk dependency

    sudo apt install curl

Install Splunk (If you have a different version, the filename might be different so use the filename you downloaded instead.)

    sudo dpkg -i splunk-9.1.2-b6b9c8185839-linux-2.6-amd64.deb

After the installation is completed use the following command to launch Splunk:

    sudo /opt/splunk/bin/splunk start --accept-license --answer-yes

Provide a name and password when prompted. These credentials need to be used to log into Splunk.

Once the setup is complete we see the Splunk is running on 

    http://127.0.0.1:8000

Run the following to allow Splunk to start automatically when the system is booted. (Optional)

    sudo /opt/splunk/bin/splunk enable boot-start

### 3) Splunk Configuration

Browse to 

    http://127.0.0.1:8000

and enter your admin credentials you used upon installing Splunk.

Then go to:

    Settings -> Forwarding and Receiving

<img width="1841" height="868" alt="image" src="https://github.com/user-attachments/assets/ed0bc376-e6cd-4f45-b1e4-9dd7d1bede37" />

In the "Receive data" section, click "Add new"

<img width="1831" height="467" alt="image" src="https://github.com/user-attachments/assets/c96116d0-fe67-49fd-a998-955b882d3847" />

In the text input, write 9997 for the Splunk server to listen on TCP port 9997 to receive data. then click Save

### 4) Universal Forwarder (Splunk Agent)

#### Windows

Download link: https://download.splunk.com/products/universalforwarder/releases/9.1.2/windows/splunkforwarder-9.1.2-b6b9c8185839-x64-release.msi
