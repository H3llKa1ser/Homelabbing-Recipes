# This is an example starting point. You can customize the files with your preferred C2 framework and web server URI paths to match your C2 malleable profile as you see fit!

## Project Structure

    red-team-infra/
    ├── terraform/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── providers.tf
    │   └── terraform.tfvars.example
    ├── ansible/
    │   ├── inventory.tmpl
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

## Instructions

### 1) Initialize and deploy Terraform

    cd red-team-infra/terraform

##### Copy and fill in your variables

    cp terraform.tfvars.example terraform.tfvars
    vim terraform.tfvars

##### Deploy

    terraform init
    terraform plan -out=plan.out
    terraform apply plan.out

### 2) Run Ansible

    cd ../ansible

##### Verify connectivity

    ansible all -m ping

##### Deploy full infrastructure

    ansible-playbook site.yml

### 3) Connect

##### SSH into jumpbox

    ssh -i ~/.ssh/id_rsa ubuntu@<jumpbox_ip>

##### From jumpbox, access C2

    ssh c2

##### Access GoPhish admin panel

    https://<phishing_ip>:3333  (default creds in stdout on first run)

##### Start Sliver C2 client

    /opt/c2/sliver-client

### 4) Teardown (After the assessment)

    cd terraform/
    terraform destroy -auto-approve

## OPSEC

| Area         | Recommendation                                                                    |
|--------------|------------------------------------------------------------------------------------|
| DNS          | Use categorized aged domains, not freshly registered ones                          |
| TLS          | Use valid certificates; match C2 profiles to HTTPS redirector                      |
| User-Agents  | Filter and block scanner UAs at the redirector                                     |
| Logging      | Centralize and encrypt all logs; wipe on engagement end                            |
| SSH Keys     | Generate engagement-specific keys; destroy after                                   |
| IP Rotation  | Use Elastic IPs and rotate if burned                                               |
| Cleanup      | Run `terraform destroy` at engagement end                                          |
