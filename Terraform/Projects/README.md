# 🛡️ Terraform Cybersecurity Projects — Complete Structure & Guide

---

## 📁 Repository Structure

```
terraform-cybersecurity/
│
├── README.md
├── LICENSE
├── .gitignore
├── .pre-commit-config.yaml
├── Makefile
│
├── ──────────────────────────────────────────────────
│   AWS PROJECTS
│   ──────────────────────────────────────────────────
│
├── aws/
│   │
│   ├── 01-perimeter-defense/
│   │   ├── main.tf
│   │   ├── vpc.tf
│   │   ├── security_groups.tf
│   │   ├── waf.tf
│   │   ├── flow_logs.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── versions.tf
│   │   ├── terraform.tfvars.example
│   │   └── README.md
│   │
│   ├── 02-identity-fortress/
│   │   ├── main.tf
│   │   ├── password_policy.tf
│   │   ├── groups.tf
│   │   ├── users.tf
│   │   ├── policies_mfa.tf
│   │   ├── policies_readonly.tf
│   │   ├── access_analyzer.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── versions.tf
│   │   ├── terraform.tfvars.example
│   │   └── README.md
│   │
│   └── 03-threat-detection-hub/
│       ├── main.tf
│       ├── s3_audit_bucket.tf
│       ├── kms.tf
│       ├── cloudtrail.tf
│       ├── guardduty.tf
│       ├── securityhub.tf
│       ├── config.tf
│       ├── alerting.tf
│       ├── cloudwatch_alarms.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── versions.tf
│       ├── terraform.tfvars.example
│       └── README.md
│
├── ──────────────────────────────────────────────────
│   AZURE PROJECTS
│   ──────────────────────────────────────────────────
│
├── azure/
│   │
│   └── 04-zero-trust-network/
│       ├── main.tf
│       ├── resource_group.tf
│       ├── vnet.tf
│       ├── subnets.tf
│       ├── nsg_application.tf
│       ├── nsg_database.tf
│       ├── nsg_management.tf
│       ├── key_vault.tf
│       ├── private_endpoints.tf
│       ├── log_analytics.tf
│       ├── diagnostics.tf
│       ├── flow_logs.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── versions.tf
│       ├── terraform.tfvars.example
│       └── README.md
│
├── ──────────────────────────────────────────────────
│   GCP PROJECTS
│   ──────────────────────────────────────────────────
│
├── gcp/
│   │
│   └── 05-defense-in-depth/
│       ├── main.tf
│       ├── vpc.tf
│       ├── subnets.tf
│       ├── firewall_rules.tf
│       ├── cloud_nat.tf
│       ├── siem_bigquery.tf
│       ├── log_sinks.tf
│       ├── scc_notifications.tf
│       ├── org_policies.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── versions.tf
│       ├── terraform.tfvars.example
│       └── README.md
│
├── ──────────────────────────────────────────────────
│   SHARED MODULES
│   ──────────────────────────────────────────────────
│
├── modules/
│   │
│   ├── aws/
│   │   ├── kms-key/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── secure-s3-bucket/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── security-group/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── waf-acl/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── cloudtrail/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   └── sns-alerting/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   │
│   ├── azure/
│   │   ├── nsg/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── key-vault/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── private-endpoint/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   └── log-analytics/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   │
│   └── gcp/
│       ├── firewall-rule/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       │
│       ├── log-sink/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       │
│       └── org-policy/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
│
├── ──────────────────────────────────────────────────
│   ENVIRONMENT CONFIGURATIONS
│   ──────────────────────────────────────────────────
│
├── environments/
│   │
│   ├── dev/
│   │   ├── aws/
│   │   │   ├── backend.tf
│   │   │   ├── main.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── variables.tf
│   │   ├── azure/
│   │   │   ├── backend.tf
│   │   │   ├── main.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── variables.tf
│   │   └── gcp/
│   │       ├── backend.tf
│   │       ├── main.tf
│   │       ├── terraform.tfvars
│   │       └── variables.tf
│   │
│   ├── staging/
│   │   ├── aws/
│   │   │   ├── backend.tf
│   │   │   ├── main.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── variables.tf
│   │   ├── azure/
│   │   │   ├── backend.tf
│   │   │   ├── main.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── variables.tf
│   │   └── gcp/
│   │       ├── backend.tf
│   │       ├── main.tf
│   │       ├── terraform.tfvars
│   │       └── variables.tf
│   │
│   └── production/
│       ├── aws/
│       │   ├── backend.tf
│       │   ├── main.tf
│       │   ├── terraform.tfvars
│       │   └── variables.tf
│       ├── azure/
│       │   ├── backend.tf
│       │   ├── main.tf
│       │   ├── terraform.tfvars
│       │   └── variables.tf
│       └── gcp/
│           ├── backend.tf
│           ├── main.tf
│           ├── terraform.tfvars
│           └── variables.tf
│
├── ──────────────────────────────────────────────────
│   CI/CD & POLICIES
│   ──────────────────────────────────────────────────
│
├── policies/
│   ├── sentinel/
│   │   ├── enforce-encryption.sentinel
│   │   ├── restrict-public-access.sentinel
│   │   ├── require-tags.sentinel
│   │   └── sentinel.hcl
│   │
│   └── opa/
│       ├── deny_public_s3.rego
│       ├── require_encryption.rego
│       ├── restrict_instance_types.rego
│       └── README.md
│
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml
│       ├── terraform-apply.yml
│       ├── terraform-security-scan.yml
│       └── terraform-drift-detection.yml
│
├── scripts/
│   ├── init-backend.sh
│   ├── validate-all.sh
│   ├── security-scan.sh
│   └── destroy-all.sh
│
└── docs/
    ├── architecture/
    │   ├── aws-perimeter-defense.png
    │   ├── aws-identity-fortress.png
    │   ├── aws-threat-detection-hub.png
    │   ├── azure-zero-trust.png
    │   └── gcp-defense-in-depth.png
    │
    ├── runbooks/
    │   ├── incident-response.md
    │   ├── key-rotation.md
    │   ├── access-review.md
    │   └── disaster-recovery.md
    │
    └── compliance/
        ├── cis-benchmark-mapping.md
        ├── pci-dss-controls.md
        ├── soc2-controls.md
        └── gdpr-controls.md
```

---

## 🏗️ Project Descriptions

### Project 01 — AWS Perimeter Defense

| Item | Detail |
|------|--------|
| **Goal** | Build a hardened VPC with WAF, rate limiting, bot control, and full flow logging |
| **Key Resources** | `aws_vpc`, `aws_security_group`, `aws_wafv2_web_acl`, `aws_wafv2_ip_set`, `aws_flow_log`, `aws_kms_key` |
| **Security Controls** | IP whitelisting, rate limiting, SQL injection blocking, bot detection, encrypted flow logs |
| **Compliance** | CIS AWS 5.x (VPC), PCI DSS 1.x (Firewall) |

### Project 02 — AWS Identity Fortress

| Item | Detail |
|------|--------|
| **Goal** | Enforce strict IAM policies, MFA everywhere, least-privilege access for security analysts |
| **Key Resources** | `aws_iam_account_password_policy`, `aws_iam_group`, `aws_iam_user`, `aws_iam_policy`, `aws_accessanalyzer_analyzer` |
| **Security Controls** | 20-char passwords, MFA enforcement, scoped read-only policies, IAM Access Analyzer |
| **Compliance** | CIS AWS 1.x (IAM), NIST 800-53 AC-2 |

### Project 03 — AWS Threat Detection Hub

| Item | Detail |
|------|--------|
| **Goal** | Centralized logging, threat detection, compliance scanning, and real-time alerting |
| **Key Resources** | `aws_cloudtrail`, `aws_guardduty_detector`, `aws_securityhub_account`, `aws_config_configuration_recorder`, `aws_sns_topic`, `aws_cloudwatch_metric_alarm` |
| **Security Controls** | Multi-region CloudTrail, GuardDuty malware scanning, CIS/PCI benchmarks, unauthorized API alarms |
| **Compliance** | CIS AWS 3.x (Logging), PCI DSS 10.x (Audit Trail), SOC 2 CC7.x |

### Project 04 — Azure Zero Trust Network

| Item | Detail |
|------|--------|
| **Goal** | Segmented VNet with deny-all NSGs, private Key Vault, private endpoints, and traffic analytics |
| **Key Resources** | `azurerm_virtual_network`, `azurerm_network_security_group`, `azurerm_key_vault`, `azurerm_private_endpoint`, `azurerm_log_analytics_workspace`, `azurerm_network_watcher_flow_log` |
| **Security Controls** | Deny-all-first NSGs, tier-based segmentation, private endpoints, Key Vault with purge protection, flow log analytics |
| **Compliance** | CIS Azure 6.x (Networking), PCI DSS 2.x (Configuration) |

### Project 05 — GCP Defense In Depth

| Item | Detail |
|------|--------|
| **Goal** | Locked-down VPC with deny-all firewall, Cloud NAT, SIEM via BigQuery, SCC alerting, org policy enforcement |
| **Key Resources** | `google_compute_network`, `google_compute_firewall`, `google_compute_router_nat`, `google_bigquery_dataset`, `google_logging_project_sink`, `google_scc_notification_config`, `google_project_organization_policy` |
| **Security Controls** | Deny-all ingress/egress, no public IPs, audit log aggregation to BigQuery, SCC critical alerts, org-level policy constraints |
| **Compliance** | CIS GCP 3.x (Networking), NIST 800-53 AU-2 (Logging) |

---

## 🔧 File Responsibilities

### Root Project Files

| File | Purpose |
|------|---------|
| `main.tf` | Primary resource definitions or module calls |
| `variables.tf` | Input variable declarations with types, defaults, and descriptions |
| `outputs.tf` | Exported values (IDs, ARNs, URIs) for downstream use |
| `providers.tf` | Provider configuration (region, features, default tags) |
| `versions.tf` | `terraform` block with `required_version` and `required_providers` |
| `terraform.tfvars.example` | Example variable values (never commit real `.tfvars` to git) |
| `README.md` | Project-specific documentation, usage, and examples |

### Per-Resource Files (Recommended Split)

| File | Contents |
|------|----------|
| `vpc.tf` / `vnet.tf` | Virtual network and subnet definitions |
| `security_groups.tf` / `nsg_*.tf` | Network access control rules |
| `waf.tf` | WAF rules, IP sets, and web ACLs |
| `firewall_rules.tf` | GCP compute firewall rules |
| `kms.tf` | Encryption key definitions and policies |
| `cloudtrail.tf` | AWS CloudTrail configuration |
| `guardduty.tf` | AWS GuardDuty detector and settings |
| `securityhub.tf` | AWS Security Hub and compliance standards |
| `config.tf` | AWS Config recorder and delivery channel |
| `key_vault.tf` | Azure Key Vault with network ACLs |
| `private_endpoints.tf` | Azure private endpoint connections |
| `log_analytics.tf` | Azure Log Analytics workspace |
| `diagnostics.tf` | Azure diagnostic settings |
| `flow_logs.tf` | VPC/NSG flow log configuration |
| `cloud_nat.tf` | GCP Cloud NAT for private egress |
| `siem_bigquery.tf` | GCP BigQuery dataset for log aggregation |
| `log_sinks.tf` | GCP logging sinks to BigQuery/Pub/Sub |
| `scc_notifications.tf` | GCP Security Command Center alerting |
| `org_policies.tf` | GCP organization policy constraints |
| `alerting.tf` | SNS topics, subscriptions, EventBridge rules |
| `cloudwatch_alarms.tf` | CloudWatch metric filters and alarms |

### Module Files

| File | Purpose |
|------|---------|
| `modules/<provider>/<name>/main.tf` | Reusable resource definitions |
| `modules/<provider>/<name>/variables.tf` | Module input variables |
| `modules/<provider>/<name>/outputs.tf` | Module output values |

### Environment Files

| File | Purpose |
|------|---------|
| `environments/<env>/<provider>/backend.tf` | Remote state backend configuration (S3, Azure Blob, GCS) |
| `environments/<env>/<provider>/main.tf` | Module calls with environment-specific parameters |
| `environments/<env>/<provider>/terraform.tfvars` | Environment-specific variable values |
| `environments/<env>/<provider>/variables.tf` | Variable declarations for the environment |

---

## 🔒 .gitignore

```gitignore
# Terraform state (never commit)
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# Sensitive variables (never commit)
terraform.tfvars
*.auto.tfvars
secrets.tf

# OS files
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp
*.swo

# Crash logs
crash.log
crash.*.log

# Plan files
*.tfplan
```

---

## ⚙️ Makefile

```makefile
.PHONY: init plan apply destroy validate format lint scan

PROJECT ?= aws/01-perimeter-defense
ENV     ?= dev

init:
	cd $(PROJECT) && terraform init

validate:
	cd $(PROJECT) && terraform validate

format:
	terraform fmt -recursive .

lint:
	tflint --recursive

scan:
	tfsec .
	checkov -d .

plan:
	cd $(PROJECT) && terraform plan -out=tfplan

apply:
	cd $(PROJECT) && terraform apply tfplan

destroy:
	cd $(PROJECT) && terraform destroy

plan-all:
	@for dir in aws/01-* aws/02-* aws/03-* azure/04-* gcp/05-*; do \
		echo "=== Planning $$dir ==="; \
		cd $$dir && terraform init -backend=false && terraform validate && cd ../..; \
	done
```

---

## 🚀 CI/CD Pipeline — GitHub Actions

### `.github/workflows/terraform-plan.yml`

```yaml
name: Terraform Plan

on:
  pull_request:
    branches: [main]
    paths:
      - 'aws/**'
      - 'azure/**'
      - 'gcp/**'
      - 'modules/**'

jobs:
  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: tfsec
        uses: aquasecurity/tfsec-action@v1.0.0
        with:
          soft_fail: false

      - name: checkov
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: .
          framework: terraform
          soft_fail: false

  plan:
    name: Terraform Plan
    runs-on: ubuntu-latest
    needs: security-scan
    strategy:
      matrix:
        project:
          - aws/01-perimeter-defense
          - aws/02-identity-fortress
          - aws/03-threat-detection-hub
          - azure/04-zero-trust-network
          - gcp/05-defense-in-depth
    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.7.0

      - name: Terraform Init
        working-directory: ${{ matrix.project }}
        run: terraform init -backend=false

      - name: Terraform Validate
        working-directory: ${{ matrix.project }}
        run: terraform validate

      - name: Terraform Plan
        working-directory: ${{ matrix.project }}
        run: terraform plan -no-color
```

### `.github/workflows/terraform-security-scan.yml`

```yaml
name: Nightly Security Scan

on:
  schedule:
    - cron: '0 2 * * *'  # Every night at 2 AM
  workflow_dispatch:

jobs:
  scan:
    name: Full Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: tfsec with SARIF
        uses: aquasecurity/tfsec-action@v1.0.0
        with:
          format: sarif
          out: tfsec-results.sarif

      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: tfsec-results.sarif

      - name: checkov
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: .
          output_format: cli
          soft_fail: false

      - name: terrascan
        uses: tenable/terrascan-action@main
        with:
          iac_type: terraform
          policy_type: aws,azure,gcp
          sarif_upload: true
```

---

## 📜 Pre-Commit Hooks

### `.pre-commit-config.yaml`

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-tf
    rev: v1.88.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
        args:
          - --hook-config=--path-to-file=README.md
          - --hook-config=--add-to-existing-file=true
          - --hook-config=--create-file-if-not-exist=true
      - id: terraform_tflint
        args:
          - --args=--config=__GIT_WORKING_DIR__/.tflint.hcl
      - id: terraform_tfsec

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: check-merge-conflict
      - id: end-of-file-fixer
      - id: trailing-whitespace
      - id: detect-private-key
      - id: check-added-large-files
        args: ['--maxkb=500']
      - id: no-commit-to-branch
        args: ['--branch', 'main']
```

---

## 🗺️ Security Controls Matrix

| # | Control | AWS Resource | Azure Resource | GCP Resource |
|---|---------|-------------|----------------|-------------|
| 1 | Network Segmentation | `aws_vpc` + `aws_security_group` | `azurerm_virtual_network` + `azurerm_network_security_group` | `google_compute_network` + `google_compute_firewall` |
| 2 | WAF / DDoS | `aws_wafv2_web_acl` | `azurerm_web_application_firewall_policy` | `google_compute_security_policy` |
| 3 | Secrets Management | `aws_secretsmanager_secret` | `azurerm_key_vault` | `google_secret_manager_secret` |
| 4 | Encryption at Rest | `aws_kms_key` | `azurerm_key_vault_key` | `google_kms_crypto_key` |
| 5 | Audit Logging | `aws_cloudtrail` | `azurerm_monitor_diagnostic_setting` | `google_logging_project_sink` |
| 6 | Threat Detection | `aws_guardduty_detector` | `azurerm_security_center_subscription_pricing` | `google_scc_notification_config` |
| 7 | Compliance Scanning | `aws_securityhub_account` | `azurerm_policy_assignment` | `google_project_organization_policy` |
| 8 | Configuration Audit | `aws_config_configuration_recorder` | `azurerm_policy_definition` | `google_project_organization_policy` |
| 9 | Real-Time Alerts | `aws_sns_topic` + `aws_cloudwatch_event_rule` | `azurerm_monitor_action_group` | `google_pubsub_topic` |
| 10 | Flow / Traffic Logs | `aws_flow_log` | `azurerm_network_watcher_flow_log` | VPC Flow Logs via `log_config` |
| 11 | Private Networking | VPC Endpoints | `azurerm_private_endpoint` | Private Google Access + Cloud NAT |
| 12 | Identity Hardening | `aws_iam_account_password_policy` + MFA | Azure AD Conditional Access | Org Policy Constraints |

---

## 📝 Quick Start

### Prerequisites

```bash
# Install Terraform
brew install terraform          # macOS
# or
choco install terraform         # Windows

# Install security scanning tools
brew install tfsec tflint checkov

# Install pre-commit
pip install pre-commit
pre-commit install
```

### Deploy a Project

```bash
# 1. Navigate to a project
cd aws/01-perimeter-defense

# 2. Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars

# 3. Initialize
terraform init

# 4. Security scan
tfsec .

# 5. Plan
terraform plan -out=tfplan

# 6. Review the plan carefully, then apply
terraform apply tfplan
```

### Deploy via Makefile

```bash
# Plan a specific project
make plan PROJECT=aws/03-threat-detection-hub

# Full validation of all projects
make plan-all

# Security scan everything
make scan
```

---

## 📚 References

| Resource | URL |
|----------|-----|
| Terraform AWS Provider | https://registry.terraform.io/providers/hashicorp/aws/latest |
| Terraform Azure Provider | https://registry.terraform.io/providers/hashicorp/azurerm/latest |
| Terraform GCP Provider | https://registry.terraform.io/providers/hashicorp/google/latest |
| CIS AWS Benchmark | https://www.cisecurity.org/benchmark/amazon_web_services |
| CIS Azure Benchmark | https://www.cisecurity.org/benchmark/azure |
| CIS GCP Benchmark | https://www.cisecurity.org/benchmark/google_cloud_computing_platform |
| tfsec | https://github.com/aquasecurity/tfsec |
| checkov | https://github.com/bridgecrewio/checkov |
| Terraform Best Practices | https://www.terraform-best-practices.com |
