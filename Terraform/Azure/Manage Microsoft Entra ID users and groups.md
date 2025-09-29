# Manage Microsoft Entra ID users and groups

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

