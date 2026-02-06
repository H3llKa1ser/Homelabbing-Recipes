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
