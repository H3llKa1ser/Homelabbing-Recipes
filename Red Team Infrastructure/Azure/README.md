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
