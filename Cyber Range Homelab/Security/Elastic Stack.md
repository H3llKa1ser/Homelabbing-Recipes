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

