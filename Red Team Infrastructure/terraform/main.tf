# ──────────────────────────────────────────────
# Data Sources
# ──────────────────────────────────────────────
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ──────────────────────────────────────────────
# SSH Key
# ──────────────────────────────────────────────
resource "aws_key_pair" "operator" {
  key_name   = "${var.engagement_name}-operator-key"
  public_key = file(var.ssh_public_key)
}

# ──────────────────────────────────────────────
# VPC & Networking
# ──────────────────────────────────────────────
resource "aws_vpc" "redteam" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.engagement_name}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.redteam.id
  tags   = { Name = "${var.engagement_name}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.redteam.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = { Name = "${var.engagement_name}-public-subnet" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.redteam.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${var.engagement_name}-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ──────────────────────────────────────────────
# Security Groups
# ──────────────────────────────────────────────

# --- Jumpbox SG ---
resource "aws_security_group" "jumpbox" {
  name        = "${var.engagement_name}-jumpbox-sg"
  description = "SSH from operator only"
  vpc_id      = aws_vpc.redteam.id

  ingress {
    description = "SSH from operator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.operator_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Redirector SG ---
resource "aws_security_group" "redirector" {
  name        = "${var.engagement_name}-redirector-sg"
  description = "HTTP/S + DNS from anywhere, SSH from jumpbox"
  vpc_id      = aws_vpc.redteam.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "DNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "DNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "SSH from jumpbox"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jumpbox.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- C2 SG ---
resource "aws_security_group" "c2" {
  name        = "${var.engagement_name}-c2-sg"
  description = "C2 listeners from redirector, SSH from jumpbox"
  vpc_id      = aws_vpc.redteam.id

  ingress {
    description     = "HTTPS from redirector"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.redirector.id]
  }

  ingress {
    description     = "HTTP from redirector"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.redirector.id]
  }

  ingress {
    description     = "DNS from redirector"
    from_port       = 53
    to_port         = 53
    protocol        = "udp"
    security_groups = [aws_security_group.redirector.id]
  }

  ingress {
    description     = "SSH from jumpbox"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jumpbox.id]
  }

  ingress {
    description = "C2 management from operator"
    from_port   = 50050
    to_port     = 50050
    protocol    = "tcp"
    cidr_blocks = [var.operator_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Phishing SG ---
resource "aws_security_group" "phishing" {
  name        = "${var.engagement_name}-phishing-sg"
  description = "SMTP + HTTPS + GoPhish admin"
  vpc_id      = aws_vpc.redteam.id

  ingress {
    description = "SMTP"
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS (landing pages)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP (landing pages)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "GoPhish Admin"
    from_port   = 3333
    to_port     = 3333
    protocol    = "tcp"
    cidr_blocks = [var.operator_ip]
  }

  ingress {
    description     = "SSH from jumpbox"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jumpbox.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ──────────────────────────────────────────────
# EC2 Instances
# ──────────────────────────────────────────────

resource "aws_instance" "jumpbox" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_jumpbox
  key_name               = aws_key_pair.operator.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jumpbox.id]

  root_block_device {
    volume_size = 20
    encrypted   = true
  }

  tags = { Name = "${var.engagement_name}-jumpbox", Role = "jumpbox" }
}

resource "aws_instance" "redirector" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_redirector
  key_name               = aws_key_pair.operator.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.redirector.id]

  root_block_device {
    volume_size = 20
    encrypted   = true
  }

  tags = { Name = "${var.engagement_name}-redirector", Role = "redirector" }
}

resource "aws_instance" "c2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_c2
  key_name               = aws_key_pair.operator.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.c2.id]

  root_block_device {
    volume_size = 50
    encrypted   = true
  }

  tags = { Name = "${var.engagement_name}-c2", Role = "c2" }
}

resource "aws_instance" "phishing" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_phishing
  key_name               = aws_key_pair.operator.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.phishing.id]

  root_block_device {
    volume_size = 30
    encrypted   = true
  }

  tags = { Name = "${var.engagement_name}-phishing", Role = "phishing" }
}

# ──────────────────────────────────────────────
# Generate Ansible Inventory
# ──────────────────────────────────────────────
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
    [jumpbox]
    ${aws_instance.jumpbox.public_ip} ansible_user=ubuntu

    [redirectors]
    ${aws_instance.redirector.public_ip} ansible_user=ubuntu

    [c2_servers]
    ${aws_instance.c2.public_ip} ansible_user=ubuntu

    [phishing_servers]
    ${aws_instance.phishing.public_ip} ansible_user=ubuntu

    [all:vars]
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
    c2_internal_ip=${aws_instance.c2.private_ip}
    redirector_internal_ip=${aws_instance.redirector.private_ip}
  EOT
}
