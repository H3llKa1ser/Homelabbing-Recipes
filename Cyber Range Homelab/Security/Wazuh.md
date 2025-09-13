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

Disable Wazuh repository to prevent further updates that may break our environment

    sudo sed -i "s/^deb /#deb /" /etc/apt/sources.list.d/wazuh.list
    sudo apt update

Print all Wazuh user credentials

    sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt

## Wazuh Agent

### Windows

