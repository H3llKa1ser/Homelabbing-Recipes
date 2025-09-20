# Deploying a Dockerized Nginx server using Terraform

## Commands

### 1) Initialize the project, which downloads a plugin that allows Terraform to interact with Docker

    terraform init

### 2) Provision the NGINX server container with apply. When Terraform asks you to confirm, type yes and press ENTER.

    terraform apply

### 3) Verify NGINX instance

    docker ps

### 4) Stop the container and destroy the resources (decommission)

    terraform destroy
