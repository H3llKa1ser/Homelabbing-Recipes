# ══════════════════════════════════════════════
# Redirector VM
# ══════════════════════════════════════════════

resource "azurerm_public_ip" "redirector" {
  name                = "pip-${var.engagement_name}-redirector"
  resource_group_name = azurerm_resource_group.redteam.name
  location            = azurerm_resource_group.redteam.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = { Role = "redirector" }
}

resource "azurerm_network_interface" "redirector" {
  name                 = "nic-${var.engagement_name}-redirector"
  resource_group_name  = azurerm_resource_group.redteam.name
  location             = azurerm_resource_group.redteam.location
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.redirector.id
  }
}

resource "azurerm_network_interface_security_group_association" "redirector" {
  network_interface_id      = azurerm_network_interface.redirector.id
  network_security_group_id = azurerm_network_security_group.redirector.id
}

resource "azurerm_linux_virtual_machine" "redirector" {
  name                            = "vm-${var.engagement_name}-redirector"
  resource_group_name             = azurerm_resource_group.redteam.name
  location                        = azurerm_resource_group.redteam.location
  size                            = var.vm_size_redirector
  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [azurerm_network_interface.redirector.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    name                 = "osdisk-redirector"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Role = "redirector"
    Name = "${var.engagement_name}-redirector"
  }
}
