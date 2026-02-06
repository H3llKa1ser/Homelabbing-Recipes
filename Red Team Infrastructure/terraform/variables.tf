# ──────────────────────────────────────────────
# General
# ──────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "engagement_name" {
  description = "Short name for this engagement (used in naming)"
  type        = string
}

variable "ssh_public_key" {
  description = "Path to the SSH public key for instance access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "operator_ip" {
  description = "Operator's public IP (CIDR) for SSH access, e.g. 203.0.113.10/32"
  type        = string
}

# ──────────────────────────────────────────────
# Instance sizing
# ──────────────────────────────────────────────
variable "instance_type_redirector" {
  type    = string
  default = "t3.micro"
}

variable "instance_type_c2" {
  type    = string
  default = "t3.medium"
}

variable "instance_type_phishing" {
  type    = string
  default = "t3.small"
}

variable "instance_type_jumpbox" {
  type    = string
  default = "t3.micro"
}

# ──────────────────────────────────────────────
# Domain
# ──────────────────────────────────────────────
variable "redirect_domain" {
  description = "Domain name pointed at the redirector (for HTTPS certs)"
  type        = string
  default     = ""
}
