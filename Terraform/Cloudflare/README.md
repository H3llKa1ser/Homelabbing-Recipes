# Cloudflare IaC Template Code Example

This is an example IaC code to deploy Cloudflare rules via Terraform

## How To Use

### 1. Initialize Terraform

    terraform init
    
### 2. Review the plan

    terraform plan -var-file="terraform.tfvars"
    
### 3. Apply the configuration
  
    terraform apply -var-file="terraform.tfvars"
