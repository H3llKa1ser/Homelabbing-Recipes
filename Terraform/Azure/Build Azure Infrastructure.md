# Build Azure Infrastructure

## Prerequisites

- An Azure Subscription

- Azure CLI

- Terraform 1.2.0 and later

## Install Azure CLI

### 1) Run the following command as an administrator

    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi

### 2) Authenticate with Azure CLI (Upon running this command, your browser will open and prompt you to enter your Azyre login credentials.)

    az login

Successful login printed on terminal

You have logged in. Now let us find all the subscriptions to which you have access...

    [
      {
        "cloudName": "AzureCloud",
        "homeTenantId": "0envbwi39-home-Tenant-Id",
        "id": "35akss-subscription-id",
        "isDefault": true,
        "managedByTenants": [],
        "name": "Subscription-Name",
        "state": "Enabled",
        "tenantId": "0envbwi39-TenantId",
        "user": {
          "name": "your-username@domain.com",
          "type": "user"
        }
      }
    ]

### 3) Choose account subscription ID and set it in Azure CLI

    az account set --subscription "35akss-subscription-id"

### 4) Create a Service Principal

    az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>"

### 5) Set your environment variables

    $Env:ARM_CLIENT_ID = "<APPID_VALUE>"
    $Env:ARM_CLIENT_SECRET = "<PASSWORD_VALUE>"
    $Env:ARM_SUBSCRIPTION_ID = "<SUBSCRIPTION_ID>"
    $Env:ARM_TENANT_ID = "<TENANT_VALUE>"

### 6) Create a directory for learning purposes

    New-Item -Path "c:\" -Name "learn-terraform-azure" -ItemType "directory"

### 7) Create a new file named main.tf (Configuration will be in the same folder as this one here.)
