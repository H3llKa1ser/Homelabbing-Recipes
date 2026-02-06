# ──────────────────────────────────────────────
# Virtual Network & Subnets
# ──────────────────────────────────────────────
resource "azurerm_virtual_network" "redteam" {
  name                = "vnet-${var.engagement_name}"
  resource_group_name = azurerm_resource_group.redteam.name
  location            = azurerm_resource_group.redteam.location
  address_space       = ["10.0.0.0/16"]

  tags = { Name = "${var.engagement_name}-vnet" }
}

resource "azurerm_subnet" "public" {
  name                 = "snet-public"
  resource_group_name  = azurerm_resource_group.redteam.name
  virtual_network_name = azurerm_virtual_network.redteam.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "internal" {
  name                 = "snet-internal"
  resource_group_name  = azurerm_resource_group.redteam.name
  virtual_network_name = azurerm_virtual_network.redteam.name
  address_prefixes     = ["10.0.2.0/24"]
}
