# Outputs

### 1) Create outputs.tf file with the configuration below

    output "container_id" {
      description = "ID of the Docker container"
      value       = docker_container.nginx.id
    }

    output "image_id" {
      description = "ID of the Docker image"
      value       = docker_image.nginx.id
    }

### 2) Apply configuration

    terraform apply

### 3) Query outputs

    terraform output

### 4) Destroy Infrastructure

    terraform destroy
