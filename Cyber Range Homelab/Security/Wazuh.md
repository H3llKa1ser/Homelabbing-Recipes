# Wazuh SIEM

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
