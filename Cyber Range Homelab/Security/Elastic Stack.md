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
