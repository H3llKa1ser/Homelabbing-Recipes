# Init

Initialize prepares your workspace so Terraform can apply your configuration.

### 1) Initialize your workspace

    terraform init

### 2) Validate your configuration

    terraform validate

### 3) Upgrade the provider to the most recent version

Modify your main.tf provider version to a later version, then reinitialize your workspace by running

    terraform init -upgrade
