# Define Input Variables

### 1) Define variable

In your learn-terraform-azure directory, create a new file called variables.tf. Copy and paste the variable declaration below.

    variable "resource_group_name" {
      default = "myTFResourceGroup"
    }

This declaration includes a default value for the variable, so the resource_group_name variable will not be a required input.

### 2) Update Terraform configuration with variables

Update your azurerm_resource_group configuration to use the input variable for the resource group name. Modify the virtual machine block as follows:

    name     = var.resource_group_name

### 3) Apply configuration

    terraform apply

Now apply the configuration again, this time overriding the default resource group name by passing in a variable using the -var flag. Updating the resource group name is a destructive update that forces Terraform to recreate the resource, and in turn the virtual network that depends on it. Respond to the confirmation prompt with yes to rename the resource group and create the new resources.

    terraform apply -var "resource_group_name=myNewResourceGroupName"

