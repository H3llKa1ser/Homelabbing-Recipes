# Secure a Web App with ModSecurity WAF and Wazuh

## Machines

1) Attacker Machine -> Simulates Web Attacks against the Application.

2) Ubuntu Linux (Host Machine) -> Runs the docker engine, which hosts both the WAF and DVWA (example app) containers. Wazuh Agent is installed within the host.

3) Wazuh Central Server -> Collects and analyzes logs from ModSecurity for better visibility, alerting, and monitoring.

### 1) Install docker and docker-compose on Ubuntu Linux

    sudo apt install docker.io

and

    sudo apt install docker-compose

### 2) Preparing for deployment

Download the ModSecurity repository

    git clone https://github.com/enochgitgamefied/Modsecurity-Dashboard.git

Create a custom Docker network named waf-net (as mentioned in the docker-compose.yml file)

    sudo docker network create waf-net

### 3) Deploy DVWA

Deploy the DVWA web server on this network

    sudo docker run --rm --network waf-net -p 8088:80 vulnerables/web-dvwa

Browse on the DVWA server 

    http://<docker-server-ip>:8088

Test a vulnerability for further verification that the server has been deployed successfully.

### 4) Deploy ModSecurity WAF

Inside the cloned repository where the docker-compose.yml file is located run the following command:

    sudo docker-compose up --build

Once the WAF container is running, browse at the protected DVWA application

    http://<docker-server-ip>:8880

Test for a vulnerability (for example a SQL Injection) to see that he WAF actually blocks it now

<img width="1833" height="883" alt="image" src="https://github.com/user-attachments/assets/10c390e5-7ad6-4f03-97f5-6fbfce0be0a5" />

<img width="1843" height="863" alt="image" src="https://github.com/user-attachments/assets/aab4d12d-ff31-43f6-aaf8-78eb92711875" />

Check on the WAF dashboard by browsing at

    http://<docker-server-ip>:8000

<img width="1810" height="689" alt="image" src="https://github.com/user-attachments/assets/42a361d6-2605-479b-bfc5-3a7eeb767c80" />

### 5) Integration with Wazuh SIEM

To forward ModSecurity logs to Wazuh, add the following configuration to /var/ossec/etc/ossec.conf on the Wazuh agent:

    <localfile>
      <log_format>apache</log_format>
      <location>/home/*/Modsecurity-Dashboard/apache-modsec/logs/*.log</location>
    </localfile>

Once the configuration is updated, restart the Wazuh agent to apply the changes:

    sudo systemctl restart wazuh-agent

After the agent restarts, ModSecurity alerts will be visible in the Wazuh dashboard for monitoring and analysis. Filter rule.id 30411 to find them.

<img width="1839" height="864" alt="image" src="https://github.com/user-attachments/assets/2fb9d663-e3b7-42c2-a9b0-6b0b3b70b6b7" />
