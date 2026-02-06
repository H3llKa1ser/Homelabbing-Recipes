# ══════════════════════════════════════════════
# Jumpbox VM
# ══════════════════════════════════════════════

resource "azurerm_public_ip" "jumpbox" {
  name                = "pip-${var.engagement_name}-jumpbox"
  resource_group_name = azurerm_resource_group.redteam.name
  location            = azurerm_resource_group.redteam.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = { Role = "jumpbox" }
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "nic-${var.engagement_name}-jumpbox"
  resource_group_name = azurerm_resource_group.redteam.name
  location            = azurerm_resource_group.redteam.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }
}

resource "azurerm_network_interface_security_group_association" "jumpbox" {
  network_interface_id      = azurerm_network_interface.jumpbox.id
  network_security_group_id = azurerm_network_security_group.jumpbox.id
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                            = "vm-${var.engagement_name}-jumpbox"
  resource_group_name             = azurerm_resource_group.redteam.name
  location                        = azurerm_resource_group.redteam.location
  size                            = var.vm_size_jumpbox
  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [azurerm_network_interface.jumpbox.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    name                 = "osdisk-jumpbox"
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
    Role = "jumpbox"
    Name = "${var.engagement_name}-jumpbox"
  }
}
