# Install Terraform on Linux

## Ubuntu/Debian

### 1) Ensure the system is up-to-date and that you have installed the gnupg and software-properties-common packages.

    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

### 2) Install HashiCorp's GPG key

    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

### 3) Verify the GPG key's fingerprint

    gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

Reported key fingerprint

    /usr/share/keyrings/hashicorp-archive-keyring.gpg
    -------------------------------------------------
    pub   rsa4096 XXXX-XX-XX [SC]
    AAAA AAAA AAAA AAAA
    uid         [ unknown] HashiCorp Security (HashiCorp Package Signing) <security+packaging@hashicorp.com>
    sub   rsa4096 XXXX-XX-XX [E]

### 4) Add the official HashiCorp repository to your system

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

### 5) Update apt

    sudo apt update

### 6) Install Terraform

    sudo apt-get install terraform

### 7) Verify installation (open new terminal)

    terraform --help

### 8) Enable tab completion

    touch ~/.zshrc (or touch ~/.bashrc) depending on your shell

### 9) Install autocomplete package

    terraform -install-autocomplete

### 10) Restart shell to enable it
