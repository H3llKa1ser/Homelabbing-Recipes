terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

provider "azurerm" {
  features {}

  # Authenticate via:
  #   az login                          (interactive)
  #   ARM_SUBSCRIPTION_ID env var       (service principal)
  #   ARM_CLIENT_ID / ARM_CLIENT_SECRET (service principal)
}
