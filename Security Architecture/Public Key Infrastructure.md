### USER
write me commands and steps for PKI for different vendors

### ASSISTANT
# PKI (Public Key Infrastructure) Commands & Steps for Different Vendors

Below is a comprehensive guide covering PKI implementation across major vendors and platforms.

---

## 1. 🔐 Microsoft Windows Server (Active Directory Certificate Services - AD CS)

### Installation
```powershell
# Install AD CS Role
Install-WindowsFeature -Name AD-Certificate -IncludeManagementTools

# Install Certification Authority
Install-AdcsCertificationAuthority -CAType EnterpriseRootCA -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -KeyLength 2048 -HashAlgorithmName SHA256 -ValidityPeriod Years -ValidityPeriodUnits 10

# Install Web Enrollment
Install-AdcsWebEnrollment
```

### Certificate Management
```powershell
# Generate a CSR (Certificate Signing Request)
certreq -new request.inf request.csr

# Submit CSR to CA
certreq -submit -config "CA_Server\CA_Name" request.csr certificate.cer

# Install the issued certificate
certreq -accept certificate.cer

# List all certificates in the store
certutil -store My

# Export a certificate
certutil -exportPFX -p "password" My <SerialNumber> export.pfx

# Revoke a certificate
certutil -revoke <SerialNumber> 0

# Publish CRL
certutil -CRL

# View CA configuration
certutil -CAInfo

# Backup CA
Backup-CARoleService -Path "C:\CABackup" -Password (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force)
```

---

## 2. 🐧 OpenSSL (Linux/Cross-Platform)

### Setting Up a Root CA
```bash
# Create directory structure
mkdir -p /root/ca/{certs,crl,newcerts,private}
chmod 700 /root/ca/private
touch /root/ca/index.txt
echo 1000 > /root/ca/serial

# Generate Root CA private key
openssl genrsa -aes256 -out /root/ca/private/ca.key.pem 4096
chmod 400 /root/ca/private/ca.key.pem

# Create Root CA certificate
openssl req -config openssl.cnf -key /root/ca/private/ca.key.pem \
  -new -x509 -days 7300 -sha256 -extensions v3_ca \
  -out /root/ca/certs/ca.cert.pem

# Verify Root CA certificate
openssl x509 -noout -text -in /root/ca/certs/ca.cert.pem
```

### Intermediate CA
```bash
# Generate Intermediate CA key
openssl genrsa -aes256 -out /root/ca/intermediate/private/intermediate.key.pem 4096

# Generate Intermediate CSR
openssl req -config intermediate/openssl.cnf -new -sha256 \
  -key /root/ca/intermediate/private/intermediate.key.pem \
  -out /root/ca/intermediate/csr/intermediate.csr.pem

# Sign with Root CA
openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
  -days 3650 -notext -md sha256 \
  -in /root/ca/intermediate/csr/intermediate.csr.pem \
  -out /root/ca/intermediate/certs/intermediate.cert.pem
```

### Certificate Operations
```bash
# Generate a private key
openssl genrsa -out server.key 2048

# Generate CSR
openssl req -new -key server.key -out server.csr

# Sign the certificate
openssl ca -config openssl.cnf -extensions server_cert \
  -days 365 -notext -md sha256 \
  -in server.csr -out server.cert.pem

# Verify a certificate
openssl verify -CAfile ca-chain.cert.pem server.cert.pem

# View certificate details
openssl x509 -in server.cert.pem -text -noout

# Convert PEM to PKCS#12
openssl pkcs12 -export -out certificate.pfx -inkey server.key -in server.cert.pem -certfile ca-chain.cert.pem

# Convert PEM to DER
openssl x509 -outform der -in certificate.pem -out certificate.der

# Revoke a certificate
openssl ca -config openssl.cnf -revoke server.cert.pem

# Generate CRL
openssl ca -config openssl.cnf -gencrl -out /root/ca/crl/ca.crl.pem
```

---

## 3. 🔥 Cisco IOS/IOS-XE (Router/Switch PKI)

### Setting Up a Local CA
```
! Enable HTTP server (required for SCEP)
ip http server

! Configure the CA server
crypto pki server MY-CA
  database url flash:
  issuer-name CN=MY-CA, O=MyOrg, C=US
  lifetime ca-certificate 3650
  lifetime certificate 365
  grant auto
  no shutdown

! Verify CA status
show crypto pki server
```

### Enrolling a Certificate (Client)
```
! Generate RSA key pair
crypto key generate rsa label MY-KEYS modulus 2048

! Define the trustpoint
crypto pki trustpoint MY-CA
  enrollment url http://10.0.0.1
  serial-number
  subject-name CN=Router1, O=MyOrg, C=US
  rsakeypair MY-KEYS

! Authenticate the CA (get CA cert)
crypto pki authenticate MY-CA

! Enroll the device
crypto pki enroll MY-CA

! Verify certificates
show crypto pki certificates
show crypto pki certificates verbose

! Export certificate in PEM
crypto pki export MY-CA pem terminal
```

---

## 4. 🔥 Palo Alto Networks Firewall

### Via CLI
```
# Generate a self-signed Root CA certificate
> request certificate generate ca yes certificate-name "PA-Root-CA" name "PA-Root-CA" algorithm RSA rsa-nbits 2048 digest sha256 days-till-expiry 3650

# Generate a CSR
> request certificate generate signed-by "PA-Root-CA" certificate-name "server-cert" name "server.example.com" algorithm RSA rsa-nbits 2048 digest sha256 days-till-expiry 365

# Import a certificate
> request certificate import certificate-name "imported-cert" format pem certificate-file /path/to/cert.pem

# Import a private key
> request certificate import certificate-name "imported-cert" format pem private-key-file /path/to/key.pem passphrase "password"

# Export a certificate
> request certificate export certificate-name "server-cert" format pem include-key yes passphrase "password"

# View certificates
> show sslmgr-store certificate-info certificate-name "server-cert"

# Create an SSL/TLS Service Profile
> set shared ssl-tls-service-profile "my-tls-profile" certificate "server-cert" min-version tls1-2

# Revoke a certificate via OCSP
> set shared certificate-profile "my-cert-profile" use-ocsp yes
```

### Via GUI Steps
1. **Device → Certificate Management → Certificates**
2. Click **Generate** to create a new certificate
3. Fill in CN, Algorithm, Key Size
4. Check **Certificate Authority** for CA certs
5. Click **Generate**

---

## 5. 🔵 Fortinet FortiGate

```
# Generate a local CA certificate
config certificate local
  edit "FortiCA"
    set password "capassword"
    set ca enable
    set key-type rsa
    set key-size 2048
  next
end

# Generate a CSR
execute certificate local generate rsa 2048 "server-cert" 365 "CN=fw.example.com,O=MyOrg,C=US"

# Import a CA certificate
config certificate ca
  edit "External-CA"
    set ca "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----"
  next
end

# Import a local certificate (via CLI)
execute certificate local import tftp cert.pem 10.0.0.100

# View certificates
get certificate local
diagnose certificate local list

# View CA certificates
get certificate ca
diagnose certificate ca list

# Configure SSL inspection with custom CA
config firewall ssl-ssh-profile
  edit "custom-ssl-profile"
    config ssl
      set inspect-all deep-inspection
    end
    set caname "FortiCA"
  next
end
```

---

## 6. ☁️ AWS (ACM - AWS Certificate Manager)

```bash
# Request a public certificate
aws acm request-certificate \
  --domain-name "example.com" \
  --subject-alternative-names "*.example.com" \
  --validation-method DNS

# Import a certificate
aws acm import-certificate \
  --certificate fileb://cert.pem \
  --private-key fileb://key.pem \
  --certificate-chain fileb://chain.pem

# List certificates
aws acm list-certificates

# Describe a certificate
aws acm describe-certificate --certificate-arn arn:aws:acm:region:account:certificate/id

# Delete a certificate
aws acm delete-certificate --certificate-arn arn:aws:acm:region:account:certificate/id

# Export a certificate (private certs only)
aws acm export-certificate \
  --certificate-arn arn:aws:acm:region:account:certificate/id \
  --passphrase $(echo -n "password" | base64)

# Create a Private CA (ACM PCA)
aws acm-pca create-certificate-authority \
  --certificate-authority-configuration '{
    "KeyAlgorithm":"RSA_2048",
    "SigningAlgorithm":"SHA256WITHRSA",
    "Subject":{
      "Country":"US",
      "Organization":"MyOrg",
      "CommonName":"My Private CA"
    }
  }' \
  --certificate-authority-type "ROOT"

# Issue a certificate from Private CA
aws acm-pca issue-certificate \
  --certificate-authority-arn arn:aws:acm-pca:region:account:certificate-authority/id \
  --csr fileb://server.csr \
  --signing-algorithm "SHA256WITHRSA" \
  --validity Value=365,Type="DAYS"
```

---

## 7. ☁️ Azure (Key Vault & App Service Certificates)

```bash
# Create a Key Vault
az keyvault create --name "MyKeyVault" --resource-group "MyRG" --location "eastus"

# Create a self-signed certificate
az keyvault certificate create \
  --vault-name "MyKeyVault" \
  --name "MyCert" \
  --policy @policy.json

# Import a certificate
az keyvault certificate import \
  --vault-name "MyKeyVault" \
  --name "ImportedCert" \
  --file certificate.pfx \
  --password "pfxpassword"

# Download a certificate
az keyvault certificate download \
  --vault-name "MyKeyVault" \
  --name "MyCert" \
  --file cert.pem \
  --encoding PEM

# List certificates
az keyvault certificate list --vault-name "MyKeyVault"

# Show certificate details
az keyvault certificate show --vault-name "MyKeyVault" --name "MyCert"

# Delete a certificate
az keyvault certificate delete --vault-name "MyKeyVault" --name "MyCert"

# Create a certificate with CSR (manual issuance)
az keyvault certificate create \
  --vault-name "MyKeyVault" \
  --name "ManualCert" \
  --policy '{"issuerParameters":{"name":"Unknown"},"x509CertificateProperties":{"subject":"CN=example.com"}}'
```

---

## 8. 🐧 Linux (Let's Encrypt / Certbot)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx   # Debian/Ubuntu
sudo yum install certbot python3-certbot-nginx    # RHEL/CentOS

# Obtain a certificate (Nginx)
sudo certbot --nginx -d example.com -d www.example.com

# Obtain a certificate (Apache)
sudo certbot --apache -d example.com

# Obtain a certificate (standalone)
sudo certbot certonly --standalone -d example.com

# Obtain a wildcard certificate (DNS challenge)
sudo certbot certonly --manual --preferred-challenges dns -d "*.example.com"

# Renew all certificates
sudo certbot renew

# Dry run renewal
sudo certbot renew --dry-run

# Revoke a certificate
sudo certbot revoke --cert-path /etc/letsencrypt/live/example.com/cert.pem

# List certificates
sudo certbot certificates

# Delete a certificate
sudo certbot delete --cert-name example.com
```

---

## 9. 🖥️ F5 BIG-IP

```bash
# Generate a key pair
create sys crypto key mykey key-size 2048 key-type rsa-private

# Generate a CSR
create sys crypto csr mycsr key mykey common-name "lb.example.com" organization "MyOrg" country US

# Import a certificate
install sys crypto cert mycert from-local-file /var/tmp/cert.pem

# Import a key
install sys crypto key mykey from-local-file /var/tmp/key.pem

# Create an SSL Client Profile
create ltm profile client-ssl my-clientssl cert mycert key mykey chain mychain

# List certificates
list sys crypto cert

# List keys
list sys crypto key

# View certificate details
list sys crypto cert mycert all-properties

# Create a Certificate Bundle
modify sys file ssl-cert /Common/myCA source-path file:///var/tmp/ca-bundle.crt
```

---

## 10. 🔑 Java Keytool (JKS/PKCS12)

```bash
# Generate a key pair and self-signed cert
keytool -genkeypair -alias mykey -keyalg RSA -keysize 2048 \
  -validity 365 -keystore keystore.jks -storepass changeit

# Generate a CSR
keytool -certreq -alias mykey -keystore keystore.jks -file server.csr

# Import a CA certificate
keytool -importcert -alias rootca -file ca.cert.pem \
  -keystore keystore.jks -storepass changeit -trustcacerts

# Import a signed certificate
keytool -importcert -alias mykey -file signed-cert.pem \
  -keystore keystore.jks -storepass changeit

# List keystore contents
keytool -list -keystore keystore.jks -storepass changeit -v

# Export a certificate
keytool -exportcert -alias mykey -keystore keystore.jks \
  -file exported.cer -storepass changeit

# Delete an entry
keytool -delete -alias mykey -keystore keystore.jks -storepass changeit

# Convert JKS to PKCS12
keytool -importkeystore -srckeystore keystore.jks \
  -destkeystore keystore.p12 -deststoretype PKCS12

# Change keystore password
keytool -storepasswd -keystore keystore.jks
```

---

## 📋 Quick Reference Table

| Task | OpenSSL | Windows | Cisco | AWS |
|------|---------|---------|-------|-----|
| **Generate Key** | `openssl genrsa` | `certreq -new` | `crypto key generate rsa` | N/A (managed) |
| **Create CSR** | `openssl req -new` | `certreq -new` | `crypto pki enroll` | `acm-pca issue-certificate` |
| **Sign Cert** | `openssl ca` | `certreq -submit` | `grant auto` | `acm request-certificate` |
| **Verify Cert** | `openssl verify` | `certutil -verify` | `show crypto pki cert` | `acm describe-certificate` |
| **Revoke Cert** | `openssl ca -revoke` | `certutil -revoke` | N/A | `acm-pca revoke-certificate` |
| **Generate CRL** | `openssl ca -gencrl` | `certutil -CRL` | Automatic | N/A (managed) |

---

> 💡 **Best Practices:**
> - Always use **2048-bit RSA** or **256-bit ECC** keys minimum
> - Use **SHA-256** or stronger hashing algorithms
> - Set appropriate **validity periods** (Root CA: 10-20 years, Intermediate: 5-10 years, End-entity: 1-2 years)
> - Protect **private keys** with strong passphrases and proper file permissions
> - Implement **CRL** or **OCSP** for certificate revocation
> - Maintain **offline Root CAs** for maximum security
> - Regularly **audit and rotate** certificates before expiry
