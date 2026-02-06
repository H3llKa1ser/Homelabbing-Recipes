# ══════════════════════════════════════════════
# Auto-generate Ansible Inventory
# ══════════════════════════════════════════════

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
    [jumpbox]
    ${azurerm_public_ip.jumpbox.ip_address} ansible_user=${var.admin_username}

    [redirectors]
    ${azurerm_public_ip.redirector.ip_address} ansible_user=${var.admin_username}

    [c2_servers]
    ${azurerm_public_ip.c2.ip_address} ansible_user=${var.admin_username}

    [phishing_servers]
    ${azurerm_public_ip.phishing.ip_address} ansible_user=${var.admin_username}

    [all:vars]
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
    c2_internal_ip=${azurerm_network_interface.c2.private_ip_address}
    redirector_internal_ip=${azurerm_network_interface.redirector.private_ip_address}
  EOT
}
