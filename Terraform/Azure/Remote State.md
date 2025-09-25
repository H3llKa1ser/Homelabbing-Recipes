# Store Remote State

### 1) Set up HCP Terraform (HashiCorp Cloud Platform)

Sign up for a new account and create an organization

Link: https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up

Next, configure the cloud block in your configuration with the organization name, and a new workspace name of your choice:

    cloud {
        organization = "<ORG_NAME>"
        workspaces {
          name = "learn-terraform-azure"
        }
      }

### 2) Authenticate with HCP Terraform

    terraform login

### 3) Migrate the state file

Migrate your local state file to HCP Terraform

    terraform init

Now that Terraform has migrated the state file to HCP Terraform, delete the local state file.

    rm terraform.tfstate

### 4) Configure a Service Principal

Log in to Azure

    az login

List the Subscriptions associated with your Azure account to copy the Subscription's ID

    az account list

Paste the value into the command below and save it

    az account set --subscription="SUBSCRIPTION_ID"

Create a Service Principal with the same Subscription ID

    az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"

Copy this output somewhere else
