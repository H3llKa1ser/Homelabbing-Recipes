# Variables

### 1) Create a variables.tf file with content

    variable "container_name" {
      description = "Value of the name for the Docker container"
      type        = string
      default     = "ExampleNginxContainer"
    }

### 2) Update main.tf file with content

    resource "docker_container" "nginx" {
      image = docker_image.nginx.image_id
    - name  = "tutorial"
    + name  = var.container_name
      ports {
        internal = 80
        external = 8080
      }
    }

### 3) Apply configuration

    terraform apply

Apply again by passing in a variable

    terraform apply -var "container_name=YetAnotherName"

    
