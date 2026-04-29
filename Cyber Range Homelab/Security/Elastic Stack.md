# Elastic Stack

## Elasticsearch

### 1) Download

Link: https://www.elastic.co/downloads/elasticsearch

### 2) Install 

Unpack the .deb package

    sudo dpkg -i elasticsearch.deb

### 3) Configure

Set Elasticsearch resources (for VMs)

Create file:

    /etc/elasticsearch/jvm.options.d/heap.options

Add these

    -Xms1g
    -Xmx1g

### 4) Start 

Start

    sudo systemctl start elasticsearch

Enable

    sudo systemctl enable elasticsearch

Status

    sudo systemctl status elasticsearch

## Kibana

### 1) Download

Link: https://www.elastic.co/downloads/kibana

### 2) Install

Unpack the .deb package

    sudo dpkg -i kibana.deb

### 3) Configure

Add two small additions to the configuration file:

    /etc/kibana/kibana.yml

Append to the bottom of the file:

    xpack.encryptedSavedObjects.encryptionKey: "soc-lab-training-key-32chars-long!"
    xpack.fleet.registryUrl: "http://localhost:8081"

### 4) Start 

Start

    sudo systemctl start kibana

Enable 

    sudo systemctl enable kibana

Status

    sudo systemctl status kibana

### 5) Final steps

Browse to

    http://localhost:5601/

Create an enrollment token, then enter the generated codes in your browser

    /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana

Create a verification code

    /usr/share/kibana/bin/kibana-verification-code

Now head back to the browser, then follow the instructions so that it can set it up.

If you missed the password during the Elasticsearch installation or need to reset it, use the command below to generate a new password

    /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic

Login, then enjoy access!

## Fleet Server and Elastic Agent

### 1) Install

Follow these steps upon login:

1) Click the Kibana menu in the top left

2) Scroll down to Management

3) Select Fleet

4) From the Fleet home page, click Add Fleet Server

In the Add a Fleet Server flyout, let's fill in the details of our server:

1) Enter the name fleet-server

2) Enter your virtual machine IP as the URL https://10.113.148.175:8220

4) Click Generate Fleet Server policy

Elastic will generate a command for you to run in your terminal to install Fleet Server on your host(s).

### 2) Verifying Installation

Now go back to Kibana after successful installation, go to:

1) Exit the flyout menu

2) Refresh the page to see your newly installed Fleet Server and Elastic Agent

3) Click Fleet Server Policy

### 3) Agent Policies and Integrations

Agent policies allow you to define what data an Elastic Agent collects and how it behaves. Each policy is applied to enrolled agents and ensures consistent data collection across hosts. Policies are composed of integrations, which define what data is collected and how it is processed. 
