# Manage Microsoft Entra ID users and groups

Repo link: https://github.com/hashicorp-education/learn-terraform-azure-ad

## Prerequisites

- The Terraform 1.0.4+ CLI installed locally.

- An Azure account with an Entra ID tenant.

- A configured Azure CLI.

You must have an Entra ID tenant to follow this tutorial. An Entra ID tenant represents an organization that allows you to use the Microsoft identity platform in your applications for identity and access management.

Link: https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-create-new-tenant

### 1) Authenticate Entra ID provider

First, log in to the Azure CLI and follow the instructions in the prompt. Since Entra ID tenants can exist without a subscription, use the --allow-no-subscriptions flag to list all tenants.

    az login --alow-no-subscriptions

Specify the tenant by setting the ARM_TENANT_ID environment variable to your preferred tenant ID (tenantId field from the previous command's output).

    export ARM_TENANT_ID=

### 2) Review users.csv file

In the users.csv file, add the users you want to add.

### 3) Create AD users

    terraform init

Then, apply

    terraform apply

List all resources

    terraform state list

Retrieve a user's AD user information

    terraform state show 'azuread_user.users["USERNAME"]'

Verify user creation

    az ad user list --filter "department eq 'DEPARTMENT_NAME'" --query "[].{ department: department, name: displayName, jobTitle: jobTitle, pname: userPrincipalName }"

### 4) Create AD Groups and assign members

Create a new file named groups.tf (file is inside the "Entra ID" folder here)

Apply

    terraform apply

Verify group creation and user assignment

    az ad group list --query "[?contains(displayName,'Education')].{ name: displayName }" --output tsv

List all the users in the Education department group

    az ad group member list --group "Education Department" --query "[].{ name: displayName }" --output tsv

List all users in the managers group

    az ad group member list --group "Education - Managers" --query "[].{ name: displayName }" --output tsv

List all users in the engineers group

    az ad group member list --group "Education - Engineers" --query "[].{ name: displayName }" --output tsv

### 5) Manage new users

Add new users to your users.csv file in this format:

    Dwight,Schrute,Education,Engineer
    Phyllis,Vance,Education,Engineer
    Kelly,Kapoor,Education,Customer Success

Add a new group to the groups.tf file with the following configuration:

    resource "azuread_group" "customer_success" {
      display_name = "Education - Customer Success"
      security_enabled = true
    }

    resource "azuread_group_member" "customer_success" {
      for_each = { for u in azuread_user.users: u.mail_nickname => u if u.job_title == "Customer Success" }

      group_object_id  = azuread_group.customer_success.id
      member_object_id = each.value.id
    }

Create new users

    terraform apply -target azuread_user.users

Update group assignments

    terraform apply

### 6) Verify resource creation and user assignment

Retrieve newly created users

    az ad user list --filter "department eq 'Education'" --query "[].{ department: department, name: displayName, jobTitle: jobTitle, pname: userPrincipalName }"

Verify the creation of the newly defined groups

    az ad group list --query "[?contains(displayName,'Education')].{ name: displayName }" --output tsv

List all the users in the Education department group

    az ad group member list --group "Education Department" --query "[].{ name: displayName }" --output tsv

List all the users in the engineers group

    az ad group member list --group "Education - Engineers" --query "[].{ name: displayName }" --output tsv

List all users in the customer success group

    az ad group member list --group "Education - Customer Success" --query "[].{ name: displayName }" --output tsv

### 7) Clean up

    terraform destroy
