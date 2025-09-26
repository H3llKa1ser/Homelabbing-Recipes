# Build Docker Infrastructure

### 1) Create workspace directory and main.tf file

    mkdir learn-terraform-docker-container
    cd learn-terraform-docker-container
    touch main.tf

### 2) Initialize the directory

    terraform init

### 3) Format and validate the configuration

    terraform fmt

Then

    terraform validate

### 4) Create infrastructure

    terraform apply

### 5) Inspect state

    terraform show

### 6) Manually Manage State

Example:

    terraform state list 
