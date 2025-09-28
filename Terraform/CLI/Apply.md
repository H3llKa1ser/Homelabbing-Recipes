# Apply

Apply makes the changes defined by your plan to create, update, or destroy resources.

### 1) Initialize your configuration

    terraform init

### 2) Apply configuration

    terraform apply

### 3) List the resources in your configuration

    terraform state list

### 4) Replace a resource (Reprovision the resource using the same configuration. Used if a resource becomes unhealthy or stops working.)

    terraform apply -replace "aws_instance.main[1]"

### 5) Clean up

    terraform destroy
