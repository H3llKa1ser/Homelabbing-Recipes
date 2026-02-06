# ──────────────────────────────────────────────
# General
# ──────────────────────────────────────────────
variable "azure_location" {
  description = "Azure region to deploy into"
  type        = string
  default     = "West Europe"
}

variable "engagement_name" {
  description = "Short name for this engagement (used in resource naming)"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key for VM access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "operator_ip" {
  description = "Operator's public IP (CIDR) for SSH/admin access, e.g. 203.0.113.10/32"
  type        = string
}

variable "admin_username" {
  description = "Admin username for all VMs"
  type        = string
  default     = "operatoradm"
}

# ──────────────────────────────────────────────
# VM Sizing
# ──────────────────────────────────────────────
variable "vm_size_jumpbox" {
  type    = string
  default = "Standard_B1s"
}

variable "vm_size_redirector" {
  type    = string
  default = "Standard_B1s"
}

variable "vm_size_c2" {
  type    = string
  default = "Standard_B2s"
}

variable "vm_size_phishing" {
  type    = string
  default = "Standard_B1ms"
}

# ──────────────────────────────────────────────
# Domain
# ──────────────────────────────────────────────
variable "redirect_domain" {
  description = "Domain name pointed at the redirector (for HTTPS certs)"
  type        = string
  default     = ""
}
