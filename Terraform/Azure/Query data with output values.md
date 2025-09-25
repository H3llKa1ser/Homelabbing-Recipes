# Query data with output values

### 1) Define an output

Create a file called outputs.tf in your learn-terraform-azure directory. Add the following output definition to outputs.tf.

    output "resource_group_id" {
      value = azurerm_resource_group.rg.id
    }

This defines an output variable named resource_group_id. The name of the variable must conform to Terraform variable naming conventions if it is to be used as an input to other modules. The value field specifies the value, the id attribute of your resource group.

You can define multiple output blocks to specify multiple output variables.

### 2) Observe your resource outputs

Apply your configuration

    terraform apply

Query the output

    terraform output resource_group_id
