# FIDO2

## Authentication Flow

<img width="900" height="800" alt="image" src="https://github.com/user-attachments/assets/35bde3f9-ee3b-4365-9bd9-0b1159d94f46" />

## Brief explanation

### 1) The user plugs the FIDO2 security key into their computer

### 2) The device detects the FIDO2 security key

### 3) The device sends an authentication request

### 4) Microsoft Entra ID sends back a nonce

### 5) The user completes their gesture to unlock the private key stored in the FIDO2 security key's secure enclave

### 6) The FIDO2 security key signs the nonce with the private key

### 7) The primary refresh token (PRT) token request with signed nonce is sent to Microsoft Entra ID

### 8) Microsoft Entra ID verifies the signed nonce using the FIDO2 public key

### 9) Microsoft Entra ID returns PRT to enable access to on-premises resources
