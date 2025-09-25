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

### 5) Update the HCP Terraform environment variables

Now that you have the authentication information for your account, navigate to the learn-terraform-azure workspace in the HCP Terraform UI.

Find the Variables tab and create the below environment variables using the values you put into and got back from the last command. Set the ARM_CLIENT_SECRET as a sensitive value.

| Environment Variable | AZ CLI Value                                             |
|-----------------------|----------------------------------------------------------|
| `ARM_SUBSCRIPTION_ID` | `SUBSCRIPTION_ID` from the last command's input.         |
| `ARM_CLIENT_ID`       | `appID` from the last command's output.                  |
| `ARM_CLIENT_SECRET`   | `password` from the last command's output. (**Sensitive**) |
| `ARM_TENANT_ID`       | `tenant` from the last command's output.                 |

Update and save these four environment variables. Set the ARM_CLIENT_SECRET as a sensitive value.

### 6) Apply configuration

    terraform apply

Terraform is now storing your state remotely in HCP Terraform. Remote state storage makes collaboration easier and keeps state and secret information off your local disk. Remote state is loaded only in memory when it is used.

### 7) Destroy Infrastructure

    terraform destroy
