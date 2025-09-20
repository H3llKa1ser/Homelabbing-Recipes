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
