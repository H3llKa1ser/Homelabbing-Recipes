# Microsoft Cloud Adoption Framework enterprise-scale module

Tutorial Link: https://developer.hashicorp.com/terraform/tutorials/azure/microsoft-caf-enterprise-scale

## Prerequisites

 - The Terraform 1.0.4+ CLI installed locally.

 - An Azure account with one or more Subscriptions.

 - A configured Azure CLI.

### 1) Clone example repo

    git clone https://github.com/hashicorp-education/learn-terraform-microsoft-caf-enterprise-scale

### 2) Deploy enterprise-scale resources

Deploy the core and demo enterprise scale landing zones.

First, rename the terraform.tfvars.example to terraform.tfvars.

    mv terraform.tfvars.example terraform.tfvars

Then, in terraform.tfvars, replace the security contact email address with your email address.

    security_contact_email_address = "security.contact@replace_me"

Initialize

    terraform init

Apply

    terraform apply

### 3) Verify core and demo landing zones

Open the Azure Portal's Management group page.

https://portal.azure.com/#blade/Microsoft_Azure_ManagementGroups/ManagementGroupBrowseBlade/MGBrowse_overview

Here, you will find the management groups provisioned by the caf-enterprise-scale module.

Click the Expand/Collapse all button to view all the management groups in the Learn Terraform ES management group.

Under Landing Zones, notice there are three management groups (Corp, Online, and SAP), each one mapping to the demo landing zones you defined in the enterprise-scale module.

### 4) Deploy custom landing zones

Define a new management group with default policies and access control (IAM) settings by adding the following code snippet to the enterprise_scale module in main.tf.

    # Define an additional "LearnTerraform" Management Group.
    custom_landing_zones = {
      "${local.root_id}-learn-tf" = {
        display_name               = "LearnTerraform"
        parent_management_group_id = "${local.root_id}-landing-zones"
        subscription_ids           = []
        archetype_config = {
          archetype_id   = "default_empty"
          parameters     = {}
          access_control = {}
        }
      }
    }

Next, apply the configuration. Once prompted, respond yes to deploy the custom landing zone. The module automatically nests the custom landing zone in the root parent management group.

    terraform apply

Verify custom landing zone

Once the deployment completes, open the Azure Portal's Management group page.

Under Landing Zones, there is a new landing zone named "LearnTerraform".

Select the LearnTerraform landing zone to review its policies and access control (IAM) settings, which follow Microsoft's best practices. The caf-enterprise-scale module codifies these recommendations, helping you easily provision secure and scalable cloud environments.

Select Access control (IAM) in the left navigation, then Roles. You will find a CustomRole named [TF-CAFES] Network-Subnet-Contributor, a standard role defined by the module.

### 5) Deploy Management Resources

Deploy a new management group that will enable logging and security resources, covering all your landing zones.

Add the following code snippet to the enterprise_scale module block in main.tf

    # Configuration settings for management resources.
    # These are used to ensure Azure Policy is correctly configured with the same 
    # settings as the resources deployed by module.enterprise_scale_management.
    # Please refer to file: settings.management.tf
    deploy_management_resources    = true
    configure_management_resources = local.configure_management_resources
    subscription_id_management     = data.azurerm_client_config.management.subscription_id

Add subscription_id_management = SUBSCRIPTION_ID to your terraform.tfvars file to deploy your management resources in another subscription.

Next, create a new file named settings.management.tf with the following configuration to enable Log Analytics and Security Center in the new landing zone.

    locals {
      configure_management_resources = {
        settings = {
          log_analytics = {
            enabled = true
            config = {
              retention_in_days                           = 30
              enable_monitoring_for_arc                   = true
              enable_monitoring_for_vm                    = true
              enable_monitoring_for_vmss                  = true
              enable_solution_for_agent_health_assessment = true
              enable_solution_for_anti_malware            = true
              enable_solution_for_azure_activity          = true
              enable_solution_for_change_tracking         = true
              enable_solution_for_service_map             = true
              enable_solution_for_sql_assessment          = true
              enable_solution_for_updates                 = true
              enable_solution_for_vm_insights             = true
              enable_sentinel                             = true
            }
          }
          security_center = {
            enabled = true
            config = {
              email_security_contact             = local.security_contact_email_address
              enable_defender_for_acr            = true
              enable_defender_for_app_services   = true
              enable_defender_for_arm            = true
              enable_defender_for_dns            = true
              enable_defender_for_key_vault      = true
              enable_defender_for_kubernetes     = true
              enable_defender_for_servers        = true
              enable_defender_for_sql_servers    = true
              enable_defender_for_sql_server_vms = true
              enable_defender_for_storage        = true
            }
          }
        }

        location = null
        tags     = null
        advanced = null
      }
    }
