# Wazuh SIEM/XDR

Installation guide: https://documentation.wazuh.com/current/quickstart.html

## VM Specs

OS: Ubuntu Linux

RAM: 8192MB (8GB)

CPU: 2

Disk Space: 50GB (You can choose a lot more if you actually want to simulate a SIEM lab. This is just a Proof-of-Concept about installing and configuring the tool only.)

Network Adapters: 2 (Internal Network LabLAN4 and Bridged)

## Wazuh Central Server 

### 1) Installation

Run this command:

    curl -sO https://packages.wazuh.com/4.12/wazuh-install.sh && sudo bash ./wazuh-install.sh -a

Once installed, browse to:

    https://<WAZUH_DASHBOARD_IP_ADDRESS>

and insert the credentials printed from the installer (DO NOT FORGET TO COPY-PASTE!)

Disable the Wazuh repository to prevent further updates that may break our environment

    sudo sed -i "s/^deb /#deb /" /etc/apt/sources.list.d/wazuh.list
    sudo apt update

Print all Wazuh user credentials

    sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt

## Wazuh Agent

### Windows

#### 1) Installation

You can install a Windows Wazuh Agent on your Windows endpoint with these commands run as an administrator in Powershell:

    Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.12.0-1.msi -OutFile $env:tmp\wazuh-agent; msiexec.exe /i $env:tmp\wazuh-agent /q WAZUH_MANAGER='10.10.10.11' WAZUH_AGENT_NAME='DC01-ADCYBER' 

The version might be different at the time of writing so beware!

Change the WAZUH_MANAGER and WAZUH_AGENT_NAME values to your corresponding values.

Then start the Wazuh service

    net start WazuhSvc

Then refresh your Wazuh dashboard after a few seconds to verify the connectivity of your agent.

Example:

<img width="1834" height="641" alt="image" src="https://github.com/user-attachments/assets/bb626826-8520-4fa0-818b-30e4204e044b" />

TIP: You can deploy a new agent via the Wazuh dashboard as well by Clicking "Deploy new agent", then follow the instructions to generate the necessary commands to run on the target endpoint.

### Linux

#### 1) Installation

Run this command as root:

    wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.12.0-1_amd64.deb && sudo WAZUH_MANAGER='10.10.10.11' WAZUH_AGENT_NAME='UBUNTU-TESTVM' dpkg -i ./wazuh-agent_4.12.0-1_amd64.deb

Again, replace any values as necessary. Also, check the version.

Then deploy your Wazuh agent

    systemctl daemon-reload
    systemctl enable wazuh-agent
    systemctl start wazuh-agent

Disable Wazuh updates

    sed -i "s/^deb/#deb/" /etc/apt/sources.list.d/wazuh.list
    apt-get update

Results

<img width="1841" height="716" alt="image" src="https://github.com/user-attachments/assets/2c171482-2e36-4371-a395-18ae4fc40cd7" />

TIP: If you agents do not connect to your central server for some reason, check your firewall rules in PfSense! You might have to add some allow rules for them to connect to other VLANS if you have them separately!

And just in case, you can enable traffic for the specific ports the agent uses on the host-based firewall on the central server!

Commands:

    sudo iptables -A INPUT -p tcp -s 192.168.10.0/24 --dport 1515 -j ACCEPT

    sudo iptables -A INPUT -p tcp -s 192.168.10.0/24 --dport 1514 -j ACCEPT

    sudo netfilter-persistent save



