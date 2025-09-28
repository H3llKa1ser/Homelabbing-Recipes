# Microsoft Cloud Adoption Framework enterprise-scale module

Tutorial Link: https://developer.hashicorp.com/terraform/tutorials/azure/microsoft-caf-enterprise-scale

## Prerequisites

 - The Terraform 1.0.4+ CLI installed locally.

 - An Azure account with one or more Subscriptions.

 - A configured Azure CLI.

### 1) Clone example repo

    git clone https://github.com/hashicorp-education/learn-terraform-microsoft-caf-enterprise-scale

### 2) Deploy enterprise-scale resources

Deploy the core and demo enterprise scale landing zones.

First, rename the terraform.tfvars.example to terraform.tfvars.

    mv terraform.tfvars.example terraform.tfvars

Then, in terraform.tfvars, replace the security contact email address with your email address.

    security_contact_email_address = "security.contact@replace_me"

Initialize

    terraform init

Apply

    terraform apply

