# identity.tf — Identity & Access Management Hardening
# AWS Identity Fortress - IAM, SSO and Access Policies

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
  region = "us-east-1"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "security_team_members" {
  type    = list(string)
  default = ["alice", "bob", "carol"]
}

# --- Strict Password Policy ---
resource "aws_iam_account_password_policy" "hardened" {
  minimum_password_length        = 20
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 60
  password_reuse_prevention      = 24
  hard_expiry                    = true
}

# --- Security Analyst Group ---
resource "aws_iam_group" "security_analysts" {
  name = "security-analysts"
  path = "/security/"
}

resource "aws_iam_user" "analysts" {
  for_each      = toset(var.security_team_members)
  name          = each.value
  path          = "/security/"
  force_destroy = false

  tags = {
    Team = "security-operations"
    Role = "analyst"
  }
}

resource "aws_iam_group_membership" "analysts" {
  name  = "security-analyst-membership"
  group = aws_iam_group.security_analysts.name
  users = [for u in aws_iam_user.analysts : u.name]
}

# --- Scoped Read-Only Policy (GuardDuty, CloudTrail, Config) ---
resource "aws_iam_policy" "security_readonly" {
  name        = "SecurityToolsReadOnly"
  path        = "/security/"
  description = "Read-only access to security services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SecurityServicesRead"
        Effect = "Allow"
        Action = [
          "guardduty:Get*",
          "guardduty:List*",
          "cloudtrail:Describe*",
          "cloudtrail:Get*",
          "cloudtrail:LookupEvents",
          "config:Describe*",
          "config:Get*",
          "securityhub:Get*",
          "securityhub:List*",
          "inspector2:List*",
          "inspector2:Get*",
          "access-analyzer:Get*",
          "access-analyzer:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "ViewCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "analysts_readonly" {
  group      = aws_iam_group.security_analysts.name
  policy_arn = aws_iam_policy.security_readonly.arn
}

# --- Enforce MFA On Everything ---
resource "aws_iam_policy" "enforce_mfa" {
  name        = "EnforceMFAPolicy"
  description = "Deny all actions if MFA is not active"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowMFASelfManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ResyncMFADevice",
          "iam:ListMFADevices",
          "iam:GetUser",
          "iam:ChangePassword"
        ]
        Resource = [
          "arn:aws:iam::${var.account_id}:mfa/$${aws:username}",
          "arn:aws:iam::${var.account_id}:user/$${aws:username}"
        ]
      },
      {
        Sid    = "BlockEverythingWithoutMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = { "aws:MultiFactorAuthPresent" = "false" }
        }
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "enforce_mfa" {
  group      = aws_iam_group.security_analysts.name
  policy_arn = aws_iam_policy.enforce_mfa.arn
}

# --- IAM Access Analyzer ---
resource "aws_accessanalyzer_analyzer" "account" {
  analyzer_name = "account-access-analyzer"
  type          = "ACCOUNT"

  tags = { Purpose = "detect-external-access" }
}

# --- Outputs ---
output "security_group_arn" {
  value = aws_iam_group.security_analysts.arn
}

output "analyst_users" {
  value = [for u in aws_iam_user.analysts : u.name]
}
