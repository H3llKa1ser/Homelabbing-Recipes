# Change Infrastructure

### 1) Create a new resource

In your main.tf file, add the resource block below to create a virtual network (VNet)

    # Create a virtual network
    resource "azurerm_virtual_network" "vnet" {
      name                = "myTFVnet"
      address_space       = ["10.0.0.0/16"]
      location            = "westus2"
      resource_group_name = azurerm_resource_group.rg.name
    }

To create a new Azure VNet, you have to specify the name of the resource group to contain the VNet. By referencing the resource group, you establish a dependency between the resources. Terraform ensures that resources are created in proper order by constructing a dependency graph for your configuration.

### 2) Apply changes

    terraform apply

### 3) Modify an existing resource

Open your main.tf file. Update the azurerm_resource_group resource in your configuration by adding the tags block as shown below:


      tags = {
        Environment = "Terraform Getting Started"
        Team = "DevOps"
        }

### 3) Apply changes

    terraform apply

### 4) Review updates to state

    terraform show

### 5) Get updated list of resources in your workspace

    terraform state list
