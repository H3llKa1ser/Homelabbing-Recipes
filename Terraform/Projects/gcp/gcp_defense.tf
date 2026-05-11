# gcp_defense.tf — Defense In Depth on Google Cloud
# GCP Defense in Depth - VPC Service Controls, Firewall and SIEM Logging

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "org_id" {
  type = string
}

variable "trusted_source_ranges" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}

variable "siem_dataset_retention_days" {
  type    = number
  default = 365
}

# --- Secure VPC ---
resource "google_compute_network" "hardened" {
  name                    = "hardened-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "workloads" {
  name                     = "workloads-subnet"
  ip_cidr_range            = "10.10.0.0/20"
  region                   = var.region
  network                  = google_compute_network.hardened.id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
    filter_expr          = "true"
  }

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.30.0.0/20"
  }
}

resource "google_compute_subnetwork" "data" {
  name                     = "data-subnet"
  ip_cidr_range            = "10.11.0.0/20"
  region                   = var.region
  network                  = google_compute_network.hardened.id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# --- Firewall Rules: Deny All → Whitelist ---
resource "google_compute_firewall" "deny_all_ingress" {
  name     = "fw-deny-all-ingress"
  network  = google_compute_network.hardened.name
  priority = 65530

  deny { protocol = "all" }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  log_config { metadata = "INCLUDE_ALL_METADATA" }
}

resource "google_compute_firewall" "deny_all_egress" {
  name     = "fw-deny-all-egress"
  network  = google_compute_network.hardened.name
  priority = 65530

  deny { protocol = "all" }

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]

  log_config { metadata = "INCLUDE_ALL_METADATA" }
}

resource "google_compute_firewall" "allow_internal" {
  name     = "fw-allow-internal"
  network  = google_compute_network.hardened.name
  priority = 100

  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }

  direction     = "INGRESS"
  source_ranges = ["10.10.0.0/20", "10.11.0.0/20"]
  target_tags   = ["internal"]

  log_config { metadata = "INCLUDE_ALL_METADATA" }
}

resource "google_compute_firewall" "allow_https_trusted" {
  name     = "fw-allow-https-trusted"
  network  = google_compute_network.hardened.name
  priority = 200

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  direction     = "INGRESS"
  source_ranges = var.trusted_source_ranges
  target_tags   = ["web-frontend"]

  log_config { metadata = "INCLUDE_ALL_METADATA" }
}

resource "google_compute_firewall" "allow_egress_https" {
  name     = "fw-allow-egress-https"
  network  = google_compute_network.hardened.name
  priority = 200

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["internet-access"]

  log_config { metadata = "INCLUDE_ALL_METADATA" }
}

# --- Cloud NAT (No Public IPs on VMs) ---
resource "google_compute_router" "main" {
  name    = "secure-router"
  region  = var.region
  network = google_compute_network.hardened.id
}

resource "google_compute_router_nat" "main" {
  name                               = "secure-nat"
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# --- SIEM: Log Sink to BigQuery ---
resource "google_bigquery_dataset" "security_logs" {
  dataset_id                 = "security_audit_logs"
  friendly_name              = "Security Audit Logs"
  location                   = "EU"
  default_table_expiration_ms = var.siem_dataset_retention_days * 86400000

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  labels = {
    environment = "production"
    purpose     = "siem"
  }
}

resource "google_logging_project_sink" "audit_to_bigquery" {
  name        = "audit-sink-bigquery"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.security_logs.dataset_id}"

  filter = <<-EOT
    logName:"cloudaudit.googleapis.com"
    OR logName:"compute.googleapis.com/firewall"
    OR logName:"dns.googleapis.com/dns_queries"
    OR logName:"vpc_flows"
  EOT

  unique_writer_identity = true
  bigquery_options {
    use_partitioned_tables = true
  }
}

resource "google_bigquery_dataset_iam_member" "sink_writer" {
  dataset_id = google_bigquery_dataset.security_logs.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.audit_to_bigquery.writer_identity
}

# --- SCC Notification for Critical Findings ---
resource "google_pubsub_topic" "scc_findings" {
  name = "scc-critical-findings"

  labels = {
    environment = "production"
    purpose     = "security-alerts"
  }
}

resource "google_pubsub_subscription" "scc_pull" {
  name  = "scc-findings-pull"
  topic = google_pubsub_topic.scc_findings.name

  message_retention_duration = "604800s"  # 7 days
  retain_acked_messages      = true
  ack_deadline_seconds       = 30

  expiration_policy {
    ttl = ""  # never expires
  }
}

resource "google_scc_notification_config" "critical_alerts" {
  config_id    = "critical-security-alerts"
  organization = var.org_id
  description  = "Notifications for active high/critical SCC findings"
  pubsub_topic = google_pubsub_topic.scc_findings.id

  streaming_config {
    filter = "state = \"ACTIVE\" AND (severity = \"HIGH\" OR severity = \"CRITICAL\")"
  }
}

# --- Organization Policy Constraints ---
resource "google_project_organization_policy" "disable_serial_port" {
  project    = var.project_id
  constraint = "compute.disableSerialPortAccess"

  boolean_policy {
    enforced = true
  }
}

resource "google_project_organization_policy" "require_os_login" {
  project    = var.project_id
  constraint = "compute.requireOsLogin"

  boolean_policy {
    enforced = true
  }
}

resource "google_project_organization_policy" "disable_default_sa" {
  project    = var.project_id
  constraint = "iam.automaticIamGrantsForDefaultServiceAccounts"

  boolean_policy {
    enforced = true
  }
}

# --- Outputs ---
output "vpc_id" {
  value = google_compute_network.hardened.id
}

output "scc_pubsub_topic" {
  value = google_pubsub_topic.scc_findings.id
}

output "bigquery_dataset" {
  value = google_bigquery_dataset.security_logs.dataset_id
}
