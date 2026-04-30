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

    nano /etc/elasticsearch/jvm.options.d/heap.options

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

2) Enter your virtual machine IP as the URL https://ELASTIC_SEARCH_IP:8220

4) Click Generate Fleet Server policy

Elastic will generate a command for you to run in your terminal to install Fleet Server on your host(s).

### 2) Verifying Installation

Now go back to Kibana after successful installation, go to:

1) Exit the flyout menu

2) Refresh the page to see your newly installed Fleet Server and Elastic Agent

3) Click Fleet Server Policy

### 3) Agent Policies and Integrations

Agent policies allow you to define what data an Elastic Agent collects and how it behaves. Each policy is applied to enrolled agents and ensures consistent data collection across hosts. Policies are composed of integrations, which define what data is collected and how it is processed. 

### 4) Confirm Log Ingestion

1) From the Kibana menu in the top-left corner, select Discover

2) Select the logs-* Data view in the top left to view incoming logs from your VM

3) From here, we can investigate interesting fields associated with our logs

4) View our incoming logs

## Elastic Integrations

### 1) Example: Apache HTTP Server logs

Integrate logs from various sources in the example steps below:

1) Click the Kibana menu in the top left

2) Scroll down to Management

3) Select Integrations

4) Access the Integrations home page

Then, do the following:

1) Search Apache HTTP Server

2) Select the integration

3) Click Add Apache HTTP Server

Next, we will ensure that the integration is being applied to the correct Agent policy:

1) Keep the default name

2) Select Existing hosts

3) Ensure the Fleet Server Policy is selected

4) Click Save and Continue

5) Click Save and deploy changes

## Custom Log Types

### 1) Build an Ingest Pipeline

Ingest pipelines allow us to process incoming events before they are indexed, enabling us to extract structured fields from raw log data. 

Steps:

From the Kibana menu:

1) Scroll down to Management

2) Select Stack Management

3) Select Ingest Pipelines

4) Click Create pipeline → New pipeline

In the Create pipeline flyout menu:

1) Name your pipeline vpn.logs.pipeline

2) Give a short description

3) Click Add a processor

### 2) Add processors

Processors define the actions Elasticsearch takes on an event as it is ingested. The Grok processor extracts multiple fields from the raw message field by matching specific parts of each log entry. The Date processor converts our event.time_string field into the native @timestamp field. Now add these processors:

#### 1. Grok

    Field: message
    Pattern: %{TIMESTAMP_ISO8601:event.time_string} %{WORD:event.action} %{USER:user.name} %{IP:source.ip} %{IP:vpn.client.ip} %{NOTSPACE:vpn.server.region}

#### 2. Date

    Field: event.time_string
    Formats: ISO8601
    Target field: @timestamp

After adding both processors, we should see them in the Create pipeline home screen:

Click Create pipeline

### 3) Filestream Integration

1) Click the Kibana menu in the top left

2) Scroll down to Management

3) Select Integrations

4) Search Custom Logs (Filestream)

5) Select the integration

6) Click Add Custom Logs (Filestream)

Next, we will apply the integration to the correct Agent policy, use our ingest pipeline, and ensure it points to the correct log files.

1) Keep the default name

2) Select the Change defaults dropdown

3) Enter the /var/log/vpnlog path

4) Enter vpn.logs.pipeline to match the ingest pipeline we created

5) Select Existing hosts

6) Ensure the Fleet Server Policy is selected

7) Click Save and Continue

8) Click Save and deploy changes

### 4) Confirm Log Ingestion and Parsing

To confirm that we have correctly configured the integration and our ingest pipeline, let's pivot back to Discover:

1) Enter the query event.module: "filestream"

2) Set the time to Last 24 hours

3) Build a table with our new fields by clicking the + next to the following fields

        event.action
        user.name
        source.ip
        vpn.client.ip
        vpn.server.region

4) Click Save 

5) Give your Discover session the name VPN Logs and a description, then save, as we will use it in the next task

