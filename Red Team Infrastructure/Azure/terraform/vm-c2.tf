# ══════════════════════════════════════════════
# C2 Server VM
# ══════════════════════════════════════════════

resource "azurerm_public_ip" "c2" {
  name                = "pip-${var.engagement_name}-c2"
  resource_group_name = azurerm_resource_group.redteam.name
  location            = azurerm_resource_group.redteam.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = { Role = "c2" }
}

resource "azurerm_network_interface" "c2" {
  name                = "nic-${var.engagement_name}-c2"
  resource_group_name = azurerm_resource_group.redteam.name
  location            = azurerm_resource_group.redteam.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.c2.id
  }
}

resource "azurerm_network_interface_security_group_association" "c2" {
  network_interface_id      = azurerm_network_interface.c2.id
  network_security_group_id = azurerm_network_security_group.c2.id
}

resource "azurerm_linux_virtual_machine" "c2" {
  name                            = "vm-${var.engagement_name}-c2"
  resource_group_name             = azurerm_resource_group.redteam.name
  location                        = azurerm_resource_group.redteam.location
  size                            = var.vm_size_c2
  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [azurerm_network_interface.c2.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    name                 = "osdisk-c2"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Role = "c2"
    Name = "${var.engagement_name}-c2"
  }
}
