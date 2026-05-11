# perimeter.tf — Multi-Layer Perimeter Security
# AWS Perimeter Defense - VPC, WAF and Shield

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = "perimeter-defense"
      CostCenter  = "security-ops"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "whitelisted_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}

# --- Isolated VPC ---
resource "aws_vpc" "fortress" {
  cidr_block           = "10.100.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "fortress-vpc" }
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.fortress.id
  cidr_block              = "10.100.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = { Name = "private-subnet-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.fortress.id
  cidr_block              = "10.100.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags = { Name = "private-subnet-b" }
}

# --- Restrictive Security Group ---
resource "aws_security_group" "perimeter" {
  name        = "perimeter-sg"
  description = "Strict perimeter — deny all except HTTPS from whitelisted sources"
  vpc_id      = aws_vpc.fortress.id

  ingress {
    description = "HTTPS from trusted CIDRs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.whitelisted_cidrs
  }

  egress {
    description = "HTTPS outbound only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "perimeter-sg" }
}

# --- VPC Flow Logs for Forensics ---
resource "aws_flow_log" "vpc_flow" {
  vpc_id               = aws_vpc.fortress.id
  traffic_type         = "ALL"
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = aws_iam_role.flow_log_role.arn
  max_aggregation_interval = 60

  tags = { Name = "fortress-vpc-flow-logs" }
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/vpc/fortress/flow-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.log_encryption.arn
}

resource "aws_kms_key" "log_encryption" {
  description             = "Encrypt VPC flow logs"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_iam_role" "flow_log_role" {
  name = "vpc-flow-log-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "flow_log_policy" {
  name = "vpc-flow-log-policy"
  role = aws_iam_role.flow_log_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

# --- WAFv2 with IP Rate Limiting & Bot Control ---
resource "aws_wafv2_ip_set" "blocked_ips" {
  name               = "blocked-threat-ips"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["198.51.100.0/24", "203.0.113.0/24"]
}

resource "aws_wafv2_web_acl" "perimeter_waf" {
  name  = "perimeter-waf"
  scope = "REGIONAL"

  default_action { allow {} }

  # Rule 1: Block known malicious IPs
  rule {
    name     = "BlockMaliciousIPs"
    priority = 1
    action { block {} }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blocked_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockedIPs"
      sampled_requests_enabled   = true
    }
  }

  # Rule 2: Rate limiting (2000 requests per 5 min)
  rule {
    name     = "RateLimiting"
    priority = 2
    action { block {} }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimited"
      sampled_requests_enabled   = true
    }
  }

  # Rule 3: AWS Managed Bot Control
  rule {
    name     = "BotControl"
    priority = 3

    override_action { none {} }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BotControl"
      sampled_requests_enabled   = true
    }
  }

  # Rule 4: Block SQL Injection
  rule {
    name     = "SQLInjectionProtection"
    priority = 4

    override_action { none {} }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiBlocked"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "PerimeterWAF"
    sampled_requests_enabled   = true
  }
}

# --- Outputs ---
output "vpc_id" {
  value = aws_vpc.fortress.id
}

output "waf_acl_arn" {
  value = aws_wafv2_web_acl.perimeter_waf.arn
}
