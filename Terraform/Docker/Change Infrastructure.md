# Change Infrastructure

### 1) Update configuration

Example

    resource "docker_container" "nginx" {
      image = docker_image.nginx.latest
      name  = "tutorial"
      hostname = "learn-terraform-docker"
      ports {
        internal = 80
    -   external = 8000
    +   external = 8080
      }
    }

### 2) Apply Changes

    terraform apply
