# azure_zero_trust.tf — Zero Trust Network + Secrets Management
# Azure Zero Trust Network and Key Vault

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

data "azurerm_client_config" "current" {}

variable "trusted_ip_ranges" {
  type    = list(string)
  default = ["203.0.113.0/24"]
}

variable "environment" {
  type    = string
  default = "production"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# --- Resource Group ---
resource "azurerm_resource_group" "security" {
  name     = "rg-zerotrust-${var.environment}"
  location = "West Europe"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    SecurityTier = "critical"
  }
}

# --- Virtual Network & Subnets ---
resource "azurerm_virtual_network" "secure" {
  name                = "vnet-zerotrust"
  address_space       = ["10.50.0.0/16"]
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
}

resource "azurerm_subnet" "application" {
  name                 = "snet-application"
  resource_group_name  = azurerm_resource_group.security.name
  virtual_network_name = azurerm_virtual_network.secure.name
  address_prefixes     = ["10.50.1.0/24"]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

resource "azurerm_subnet" "database" {
  name                 = "snet-database"
  resource_group_name  = azurerm_resource_group.security.name
  virtual_network_name = azurerm_virtual_network.secure.name
  address_prefixes     = ["10.50.2.0/24"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "management" {
  name                 = "snet-management"
  resource_group_name  = azurerm_resource_group.security.name
  virtual_network_name = azurerm_virtual_network.secure.name
  address_prefixes     = ["10.50.3.0/24"]
  service_endpoints    = ["Microsoft.KeyVault"]
}

# --- NSG: Application Tier ---
resource "azurerm_network_security_group" "app_nsg" {
  name                = "nsg-application"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name

  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.trusted_ip_ranges
    destination_address_prefix = "10.50.1.0/24"
  }

  security_rule {
    name                       = "AllowAppToDb"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.50.1.0/24"
    destination_address_prefix = "10.50.2.0/24"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllOutbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.application.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

# --- NSG: Database Tier ---
resource "azurerm_network_security_group" "db_nsg" {
  name                = "nsg-database"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name

  security_rule {
    name                       = "AllowAppSubnetOnly"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.50.1.0/24"
    destination_address_prefix = "10.50.2.0/24"
  }

  security_rule {
    name                       = "DenyEverythingElse"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.database.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

# --- Azure Key Vault ---
resource "azurerm_key_vault" "secrets" {
  name                          = "kv-zt-${random_string.suffix.result}"
  location                      = azurerm_resource_group.security.location
  resource_group_name           = azurerm_resource_group.security.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "premium"
  enabled_for_disk_encryption   = true
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  enable_rbac_authorization     = true
  public_network_access_enabled = false

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.trusted_ip_ranges
    virtual_network_subnet_ids = [
      azurerm_subnet.application.id,
      azurerm_subnet.database.id,
      azurerm_subnet.management.id
    ]
  }

  tags = {
    Environment  = var.environment
    SecurityTier = "critical"
  }
}

# --- Private Endpoint for Key Vault ---
resource "azurerm_private_endpoint" "keyvault_pe" {
  name                = "pe-keyvault"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  subnet_id           = azurerm_subnet.management.id

  private_service_connection {
    name                           = "keyvault-connection"
    private_connection_resource_id = azurerm_key_vault.secrets.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

# --- Diagnostic Logging on Key Vault ---
resource "azurerm_log_analytics_workspace" "security" {
  name                = "law-security-${random_string.suffix.result}"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  sku                 = "PerGB2018"
  retention_in_days   = 365
}

resource "azurerm_monitor_diagnostic_setting" "keyvault_diag" {
  name                       = "keyvault-diagnostics"
  target_resource_id         = azurerm_key_vault.secrets.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.security.id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# --- Network Watcher Flow Logs ---
resource "azurerm_network_watcher" "main" {
  name                = "nw-security"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
}

resource "azurerm_storage_account" "flow_logs" {
  name                     = "stflowlogs${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.security.name
  location                 = azurerm_resource_group.security.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    delete_retention_policy { days = 365 }
  }
}

resource "azurerm_network_watcher_flow_log" "app_nsg_flow" {
  name                 = "fl-app-nsg"
  network_watcher_name = azurerm_network_watcher.main.name
  resource_group_name  = azurerm_resource_group.security.name
  network_security_group_id = azurerm_network_security_group.app_nsg.id
  storage_account_id   = azurerm_storage_account.flow_logs.id
  enabled              = true
  version              = 2

  retention_policy {
    enabled = true
    days    = 90
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.security.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.security.location
    workspace_resource_id = azurerm_log_analytics_workspace.security.id
    interval_in_minutes   = 10
  }
}

# --- Outputs ---
output "key_vault_uri" {
  value = azurerm_key_vault.secrets.vault_uri
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.security.id
}
