# Plan

Plan allows you to preview the changes Terraform will make before you apply them.

### 1) Initialize your configuration

    terraform init

### 2) Create a plan

    terraform plan 
    
OPTIONAL: Save the plan with the -out flag. 

    terraform plan -out "tfplan" 

Print out the saved plan

    terrafrom show "tfplan"

Convert the saved plan into JSON, pass it to jq to format it, and save the output into a new file

    terraform show -json "tfplan" | jq > tfplan.json

### 3) Review the plan

Review plan version

    jq '.terraform_version, .format_version' tfplan.json

Review plan configuration

    jq '.configuration.provider_config' tfplan.json

The configuration section further organizes your resources defined in your top level root_module.

    jq '.configuration.root_module.resources' tfplan.json

The module_calls section contains the details of the modules used, their input variables and outputs, and the resources to create.

    jq '.configuration.root_module.module_calls' tfplan.json

The configuration object also records any references to other resources in a resource's written configuration, which helps Terraform determine the correct order of operations when it applies your plan.

    jq '.configuration.root_module.module_calls.hello.expressions.hellos.references' tfplan.json

Review planned resource changes (Module is just an example, it can be any module)

    jq '.resource_changes[] | select( .address == "module.ec2-instance.aws_instance.main")' tfplan.json

Review planned values

    jq '.planned_values' tfplan.json

### 4) Apply saved plan

    terraform apply "tfplan"

### 5) Modify configuration

Open the variables.tf file in the top-level configuration directory. Add the configuration below to define a new input variable to use for the hello module.

    variable "secret_key" {
      type        = string
      sensitive   = true
      description = "Secret key for hello module"
    }

Then, create a terraform.tfvars file, and set the new secret_key input variable value.

    secret_key = "TOPSECRET"


CAUTION: NEVER COMMIT .tfvars FILES TO VERSION CONTROL!

Finally, update the hello module configuration in main.tf to reference the new input variable.

    module "hello" {
      source  = "joatmon08/hello/random"
      version = "6.0.0"

      hellos = {
        hello        = random_pet.instance.id
        second_hello = "World"
      }

      some_key = var.secret_key
    }

### 6) Create a new plan

    terraform plan -out "tfplan-input-var"

Convert the new plan file into a machine-readable JSON format.

    terraform show -json tfplan-input-var | jq > tfplan-input-var.json

### 7) Review new plan

Review plan input variables

    jq '.variables' tfplan-input-var.json

WARNING: Although you marked the input variable as sensitive, Terraform still stores the value in plaintext in the plan file. Since Terraform plan files can contain sensitive information, you should keep them secure and never commit them to version control.

Review plan prior_state

    jq '.prior_state' tfplan-input-var.json

Review plan resource changes

    jq '.resource_changes[] | select( .address == "module.hello.random_pet.server")' tfplan-input-var.json

### 8) Destroy infrastructure

    terraform plan -destroy -out "tfplan-destroy"

When you use the -destroy flag, Terraform creates a plan to destroy all of the resources in the configuration. Apply the plan to destroy your resources.

    terraform apply "tfplan-destroy"
