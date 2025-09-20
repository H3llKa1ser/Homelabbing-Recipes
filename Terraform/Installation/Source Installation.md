# Compile from Source

### 1) Clone the Terraform repository

    git clone https://github.com/hashicorp/terraform

### 2) Navigate to the new directory

    cd terraform

### 3) Compile the binary

    go install

### 4) Add binary to a path that is within the PATH variable to execute it anywhere on the system

    mv ~/Downloads/terraform /usr/local/bin/
