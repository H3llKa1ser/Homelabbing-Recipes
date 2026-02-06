Cloud Provider: Microsoft Azure

C2 Framework: Sliver

## Project Structure

    red-team-infra-azure/
    ├── terraform/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── providers.tf
    │   ├── network.tf
    │   ├── nsg.tf
    │   ├── vm-jumpbox.tf
    │   ├── vm-redirector.tf
    │   ├── vm-c2.tf
    │   ├── vm-phishing.tf
    │   ├── inventory.tf
    │   └── terraform.tfvars.example
    ├── ansible/
    │   ├── inventory.ini          (auto-generated)
    │   ├── ansible.cfg
    │   ├── site.yml
    │   ├── roles/
    │   │   ├── common/
    │   │   │   └── tasks/main.yml
    │   │   ├── redirector/
    │   │   │   ├── tasks/main.yml
    │   │   │   └── templates/
    │   │   │       ├── nginx-redirect.conf.j2
    │   │   │       └── iptables-dns.sh.j2
    │   │   ├── c2/
    │   │   │   └── tasks/main.yml
    │   │   ├── phishing/
    │   │   │   └── tasks/main.yml
    │   │   └── jumpbox/
    │   │       └── tasks/main.yml
    │   └── group_vars/
    │       └── all.yml
    └── README.md

## Deployment Steps

### 1) Install Azure CLI and Authenticate

    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    az login
    az account set --subscription "YOUR_SUBSCRIPTION_ID"

Verify

    az account show --query '{name:name, id:id}' -o table

### 2) Deploy with Terraform

    cd red-team-infra-azure/terraform

Configure your engagement

    cp terraform.tfvars.example terraform.tfvars
    vim terraform.tfvars

Deploy

    terraform init
    terraform plan -out=plan.out
    terraform apply plan.out

### 3) Configure with Ansible

    cd ../ansible

Verify all hosts are reachable

    ansible all -m ping

Full deployment

    ansible-playbook site.yml

### 4) Connect

SSH to jumpbox

    ssh -i ~/.ssh/id_rsa operatoradm@$(terraform -chdir=../terraform output -raw jumpbox_public_ip)

From jumpbox → C2

    ssh c2

Start Sliver interactive console on C2

    sudo /opt/c2/sliver-server

Generate operator config for multiplayer

    sliver > new-operator --name operator1 --lhost <c2_public_ip>

Access GoPhish admin

    https://<phishing_public_ip>:3333
    (default password printed in: journalctl -u gophish --no-pager | grep password)

### 5) Teardown

Destroy everything — single command

    cd terraform/
    terraform destroy -auto-approve

Or delete the entire resource group via CLI

    az group delete --name rg-acme-rt-2026 --yes --no-wait


## Azure Tips

| Topic            | Detail                                                                                                                     |
|------------------|-----------------------------------------------------------------------------------------------------------------------------|
| SMTP             | Azure **blocks outbound port 25** by default on new subscriptions. Submit a **support request** or use an external SMTP relay (SendGrid, Mailgun). |
| DNS Zones        | Consider using `azurerm_dns_zone` + `azurerm_dns_a_record` for managing domain records in Terraform.                       |
| Azure Bastion    | For even stronger OPSEC, replace the jumpbox public IP with **Azure Bastion** (no exposed SSH).                             |
| Managed Identity | Avoid storing credentials on VMs — use Azure Managed Identity for any Azure API calls.                                      |
| Cost Control     | Use `az vm deallocate` to stop billing when not testing. B-series VMs are burstable and cost-effective.                     |
| IP Rotation      | Deallocate + reallocate public IPs for fresh addresses if burned: `az network public-ip update`.                            |
| NSG Flow Logs    | Enable NSG Flow Logs → Storage Account for audit trail during the engagement.                                               |
| Disk Encryption  | Consider enabling Azure Disk Encryption (ADE) with Key Vault for at-rest encryption.                                       |
