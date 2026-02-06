output "resource_group_name" {
  value = azurerm_resource_group.redteam.name
}

output "jumpbox_public_ip" {
  description = "Public IP of the jumpbox / bastion host"
  value       = azurerm_public_ip.jumpbox.ip_address
}

output "redirector_public_ip" {
  description = "Public IP of the redirector"
  value       = azurerm_public_ip.redirector.ip_address
}

output "c2_public_ip" {
  description = "Public IP of the C2 server"
  value       = azurerm_public_ip.c2.ip_address
}

output "c2_private_ip" {
  description = "Private IP of the C2 server (used by redirector)"
  value       = azurerm_network_interface.c2.private_ip_address
}

output "phishing_public_ip" {
  description = "Public IP of the phishing server"
  value       = azurerm_public_ip.phishing.ip_address
}

output "ssh_jumpbox" {
  value = "ssh -i ~/.ssh/id_rsa ${var.admin_username}@${azurerm_public_ip.jumpbox.ip_address}"
}

output "gophish_admin_url" {
  value = "https://${azurerm_public_ip.phishing.ip_address}:3333"
}

output "ansible_inventory_path" {
  value = local_file.ansible_inventory.filename
}
