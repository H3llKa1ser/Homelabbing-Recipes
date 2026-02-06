# ──────────────────────────────────────────────
# Resource Group
# ──────────────────────────────────────────────
resource "azurerm_resource_group" "redteam" {
  name     = "rg-${var.engagement_name}"
  location = var.azure_location

  tags = {
    Project     = "RedTeam-Infra"
    Engagement  = var.engagement_name
    ManagedBy   = "Terraform"
  }
}
