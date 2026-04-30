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

5) Give your Discover session the name VPN Logs and a description, then save as we will use this to create a dashboard

## Dashboards and Visualizations

### 1) Create dashboard

In the Kibana sidebar menu, go to:

1) Select Dashboards

2) Create dashboard

3) Select Add from library in the top right or at the bottom of the page

4) Search for and select the saved search, VPN Logs, from the previous task

### 2) Add visualizations

On the top right, click Add then Visualization. Let's focus on the event.action field for example

1) Enter the query event.module: "filestream"

2) Set the time to Last 24 hours

3) Change the chart type to Pie

4) Drag or select the event.action field for Slice by

5) Set the Metric to Count

#### Enhanced Visualizations

What if we want a more detailed look? Perhaps we want to see the connections as they occurred over time. Let's make some changes to our current visualization:

1) Change the graph type to Line

2) Horizontal axis to @timestamp

3) Keep the Vertical axis the same

4) Set the Breakdown to event.action

5) Now we can view the total for each event.action for a given 30-minute time period

6) Go ahead and click Save and return in the top right corner.

Kibana dashboards are fully modular, allowing analysts to drag and drop searches and visualizations into layouts that best support investigation and monitoring.

## Elastic Defend EDR

### 1) Configuration

Docs: https://www.elastic.co/docs/solutions/security/configure-elastic-defend/install-elastic-defend

Steps:

1) Select the Kibana menu in the top left

2) Scroll down to Management

3) Select Integrations

4) Click Installed integrations

5) Locate Elastic Defend

6) Click View 1 policies

Now we will get a closer look at the configurations available for Elastic Defend.

Click the integration policy defend-integration (already added with the button +Add Elastic Defend)

If you head to the Malware section, you can toggle the feature on or off and set the protection level. 

#### 1) Detect: 

Elastic monitors, an alert is generated if malicious activity is detected, but nothing is blocked

#### 2) Prevent: 

Elastic monitors, an alert is generated if malicious activity is detected, and Elastic Defend takes action by quarantining, blocking, or terminating processes

Lastly, head down to the Event Collection Linux and Session data sections. By default, Elastic Defend will collect file, network, and process data. Collecting session data allows us to track process trees and reconstruct full attack chains during investigations, which we will explore later. Select the two options below and save.

#### - Collect session data

#### - Capture terminal output

### 2) Build an Elastic Defend Data View

To focus only on the events monitored by Elastic Defend, we'll create a custom Data View in Kibana. Let's head to the Kibana menu to get started.

1) Scroll down to Stack Management

2) Select Data Views in the Kibana section

3) Choose Create data view

In the Create data view flyout panel.

1) Give your data view a name Defend Data

2) Enter the Index pattern logs-endpoint.events*, which covers file, network, and process events

3) Click Save data view to Kibana

After saving the data view, let's Set as default.

Lastly, using the Kibana menu in the top left.

1) Select Discover

2) Ensure your newly made Data view is active

3) Investigate the event.category field to verify we have data coming in from our three types of monitored activity: file, network, and process

## Alert Creation

Detection rules pre-built by Elastic: https://www.elastic.co/docs/reference/security/prebuilt-rules#endpoint

### 1) Alerts in Discover

Let's head back to Discover, but this time we will use the Security solution alerts data view to investigate the alert.

1) Select the Security solution alerts data view

2) Build a table with the following fields:

        kibana.alert.rule.name
        kibana.alert.severity
        event.action
        file.path
        file.name
        user.name

3) Investigate the alert

### 2) Alerts Dashboard

Using the Kibana menu, head to the Security section and select Alerts. We can now view a summary of our alert, including: 

1) The severity level

2) The name of the alert

3) The host on which it triggered

4) A table containing an overview of alerts

Let's expand the malware alert by clicking the View details button.

From the flyout panel, we have a wealth of information available, including descriptions of the triggered rule, relevant fields, and even suggested response actions.

1) The Overview section

2) Rule description and Alert reason

3) Highlighted important fields

4) The Table section, which includes all fields associated with the alert. In the table section, you can pin important fields for your investigation

### 3) Event Analysis

Select the Analyze event option from the malware alert in the Alerts dashboard.

When you open the Analyzer graph, Elastic automatically centers the view on the event that triggered the alert, making it your anchor point for investigation. From there, Elastic reconstructs the surrounding activity into a visual process tree, helping you understand how the behavior unfolded. Depending on what commands you have executed in your session, your process tree may look slightly different, but in the example below, you can see:

1) The parent process

2) The process that triggered the alert

3) The child process

4) Further child processes

## Detection Rules

### 1) Manage detection rules

1) Using the Kibana menu, head to Security

2) Select Rules

3) Click Detection rules (SIEM)

From here, we can see a list of our installed rules, including Elastic Defend's native rule list and two pre-added rules.

- Click + Add Elastic rules to view Elastic's extensive rule list.

On the next screen, you can search and enable any rules you like based on your specific needs.

