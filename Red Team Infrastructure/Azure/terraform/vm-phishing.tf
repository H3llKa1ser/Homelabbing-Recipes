# ══════════════════════════════════════════════
# Phishing Server VM
# ══════════════════════════════════════════════

resource "azurerm_public_ip" "phishing" {
  name                = "pip-${var.engagement_name}-phishing"
  resource_group_name = azurerm_resource_group.redteam.name
  location            = azurerm_resource_group.redteam.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = { Role = "phishing" }
}

resource "azurerm_network_interface" "phishing" {
  name                = "nic-${var.engagement_name}-phishing"
  resource_group_name = azurerm_resource_group.redteam.name
  location            = azurerm_resource_group.redteam.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.phishing.id
  }
}

resource "azurerm_network_interface_security_group_association" "phishing" {
  network_interface_id      = azurerm_network_interface.phishing.id
  network_security_group_id = azurerm_network_security_group.phishing.id
}

resource "azurerm_linux_virtual_machine" "phishing" {
  name                            = "vm-${var.engagement_name}-phishing"
  resource_group_name             = azurerm_resource_group.redteam.name
  location                        = azurerm_resource_group.redteam.location
  size                            = var.vm_size_phishing
  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [azurerm_network_interface.phishing.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    name                 = "osdisk-phishing"
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
    Role = "phishing"
    Name = "${var.engagement_name}-phishing"
  }
}
