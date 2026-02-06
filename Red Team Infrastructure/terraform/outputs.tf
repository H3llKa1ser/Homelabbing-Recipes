output "jumpbox_public_ip" {
  description = "Public IP of the jumpbox / bastion host"
  value       = aws_instance.jumpbox.public_ip
}

output "redirector_public_ip" {
  description = "Public IP of the redirector"
  value       = aws_instance.redirector.public_ip
}

output "c2_public_ip" {
  description = "Public IP of the C2 server"
  value       = aws_instance.c2.public_ip
}

output "phishing_public_ip" {
  description = "Public IP of the phishing server"
  value       = aws_instance.phishing.public_ip
}

output "c2_private_ip" {
  value = aws_instance.c2.private_ip
}

output "ssh_jumpbox" {
  value = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.jumpbox.public_ip}"
}

output "ansible_inventory_path" {
  value = local_file.ansible_inventory.filename
}
