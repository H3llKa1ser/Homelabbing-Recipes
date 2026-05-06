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

### USER
write me commands for the process of rotating expired certificates for new ones

### ASSISTANT
# 🔄 Certificate Rotation Process — Complete Commands for All Major Vendors

Below is a comprehensive, step-by-step guide for rotating expired certificates across all major platforms and vendors.

---

## 📋 General Certificate Rotation Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  1. Identify Expired/Expiring Certificates                  │
│  2. Backup Existing Certificates & Keys                     │
│  3. Generate New Key Pair (recommended) or Reuse Key        │
│  4. Generate New CSR                                        │
│  5. Submit CSR & Obtain New Certificate                     │
│  6. Validate the New Certificate                            │
│  7. Install/Replace the New Certificate                     │
│  8. Update All Dependent Services & Bindings                │
│  9. Test & Verify Connectivity                              │
│  10. Remove/Archive Old Certificate                         │
│  11. Document & Update Monitoring                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 1. 🐧 OpenSSL (Linux / Generic)

### Step 1: Identify Expired Certificates
```bash
# Check certificate expiry date
openssl x509 -in /etc/ssl/certs/server.crt -noout -enddate

# Check how many days until expiry
openssl x509 -in /etc/ssl/certs/server.crt -noout -checkend 2592000
# Returns exit code 1 if cert expires within 30 days (2592000 seconds)

# Check remote server certificate expiry
echo | openssl s_client -connect server.example.com:443 -servername server.example.com 2>/dev/null | openssl x509 -noout -dates

# Scan multiple certificates in a directory
for cert in /etc/ssl/certs/*.crt; do
  echo "=== $cert ==="
  openssl x509 -in "$cert" -noout -subject -enddate
done

# Find all expiring certs on the system (within 30 days)
find /etc/ssl /etc/pki -name "*.crt" -o -name "*.pem" 2>/dev/null | while read cert; do
  if openssl x509 -in "$cert" -noout -checkend 2592000 2>/dev/null; then
    :
  else
    echo "EXPIRING SOON: $cert ($(openssl x509 -in "$cert" -noout -enddate))"
  fi
done
```

### Step 2: Backup Existing Certificate & Key
```bash
# Create backup directory with timestamp
BACKUP_DIR="/etc/ssl/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup certificate, key, and chain
cp /etc/ssl/certs/server.crt "$BACKUP_DIR/server.crt.bak"
cp /etc/ssl/private/server.key "$BACKUP_DIR/server.key.bak"
cp /etc/ssl/certs/ca-chain.crt "$BACKUP_DIR/ca-chain.crt.bak"

# Verify backup integrity
openssl x509 -in "$BACKUP_DIR/server.crt.bak" -noout -subject -enddate
echo "Backup completed: $BACKUP_DIR"
```

### Step 3: Generate New Key Pair
```bash
# Generate new RSA private key (2048 or 4096 bit)
openssl genrsa -aes256 -out /etc/ssl/private/server_new.key 4096
chmod 400 /etc/ssl/private/server_new.key

# OR generate ECC key (recommended for modern deployments)
openssl ecparam -genkey -name prime256v1 -out /etc/ssl/private/server_new.key
chmod 400 /etc/ssl/private/server_new.key
```

### Step 4: Generate New CSR
```bash
# Generate CSR with SAN (Subject Alternative Names)
openssl req -new -key /etc/ssl/private/server_new.key \
  -out /etc/ssl/certs/server_new.csr \
  -subj "/C=US/ST=State/L=City/O=MyOrg/OU=IT/CN=server.example.com" \
  -addext "subjectAltName=DNS:server.example.com,DNS:www.example.com,IP:10.0.0.1"

# Verify CSR content
openssl req -in /etc/ssl/certs/server_new.csr -noout -text

# Generate CSR reusing the subject from the old cert
openssl x509 -in /etc/ssl/certs/server.crt -noout -subject | sed 's/subject=//' > /tmp/old_subject.txt
openssl req -new -key /etc/ssl/private/server_new.key \
  -out /etc/ssl/certs/server_new.csr \
  -subj "$(cat /tmp/old_subject.txt)"
```

### Step 5: Sign the Certificate (Internal CA)
```bash
# Sign with your CA
openssl ca -config /root/ca/openssl.cnf \
  -extensions server_cert \
  -days 365 -notext -md sha256 \
  -in /etc/ssl/certs/server_new.csr \
  -out /etc/ssl/certs/server_new.crt

# OR sign directly with CA key (without ca command)
openssl x509 -req -in /etc/ssl/certs/server_new.csr \
  -CA /root/ca/certs/ca.cert.pem \
  -CAkey /root/ca/private/ca.key.pem \
  -CAcreateserial \
  -out /etc/ssl/certs/server_new.crt \
  -days 365 -sha256 \
  -extfile <(printf "subjectAltName=DNS:server.example.com,DNS:www.example.com")
```

### Step 6: Validate the New Certificate
```bash
# Verify the new cert against the CA chain
openssl verify -CAfile /etc/ssl/certs/ca-chain.crt /etc/ssl/certs/server_new.crt

# Verify key matches certificate
CERT_MD5=$(openssl x509 -noout -modulus -in /etc/ssl/certs/server_new.crt | openssl md5)
KEY_MD5=$(openssl rsa -noout -modulus -in /etc/ssl/private/server_new.key | openssl md5)
if [ "$CERT_MD5" = "$KEY_MD5" ]; then
  echo "✅ Key and Certificate MATCH"
else
  echo "❌ Key and Certificate DO NOT MATCH"
fi

# View full certificate details
openssl x509 -in /etc/ssl/certs/server_new.crt -noout -text

# Verify certificate chain is complete
openssl verify -verbose -CAfile /root/ca/certs/ca.cert.pem \
  -untrusted /root/ca/intermediate/certs/intermediate.cert.pem \
  /etc/ssl/certs/server_new.crt
```

### Step 7: Replace & Restart Services
```bash
# Replace old cert and key with new ones
mv /etc/ssl/certs/server.crt /etc/ssl/certs/server.crt.old
mv /etc/ssl/private/server.key /etc/ssl/private/server.key.old
mv /etc/ssl/certs/server_new.crt /etc/ssl/certs/server.crt
mv /etc/ssl/private/server_new.key /etc/ssl/private/server.key

# Build full chain file
cat /etc/ssl/certs/server.crt /etc/ssl/certs/intermediate.crt /etc/ssl/certs/ca.crt > /etc/ssl/certs/fullchain.pem

# --- Restart dependent services ---

# Nginx
nginx -t && systemctl reload nginx

# Apache
apachectl configtest && systemctl reload apache2

# HAProxy
haproxy -c -f /etc/haproxy/haproxy.cfg && systemctl reload haproxy

# Postfix (Mail)
systemctl reload postfix

# Dovecot (IMAP)
systemctl reload dovecot
```

### Step 8: Verify After Rotation
```bash
# Test the new certificate on the live server
echo | openssl s_client -connect server.example.com:443 -servername server.example.com 2>/dev/null | openssl x509 -noout -subject -dates -issuer

# Full SSL/TLS test
echo | openssl s_client -connect server.example.com:443 -servername server.example.com -showcerts

# Verify with curl
curl -vI https://server.example.com 2>&1 | grep -E "expire|subject|issuer|SSL"
```

### Step 9: Revoke Old Certificate
```bash
# Revoke the expired/old certificate
openssl ca -config /root/ca/openssl.cnf -revoke /etc/ssl/certs/server.crt.old

# Regenerate the CRL
openssl ca -config /root/ca/openssl.cnf -gencrl -out /root/ca/crl/ca.crl.pem

# Distribute updated CRL
cp /root/ca/crl/ca.crl.pem /var/www/html/pki/crl/
```

---

## 2. 🔐 Microsoft Windows Server (AD CS)

### Step 1: Identify Expired Certificates
```powershell
# List all certificates expiring within 30 days
Get-ChildItem Cert:\LocalMachine\My | Where-Object {
  $_.NotAfter -lt (Get-Date).AddDays(30)
} | Format-Table Subject, Thumbprint, NotAfter -AutoSize

# Check all stores for expiring certs
$stores = @("My", "WebHosting", "Root", "CA")
foreach ($store in $stores) {
  Get-ChildItem "Cert:\LocalMachine\$store" | Where-Object {
    $_.NotAfter -lt (Get-Date).AddDays(30)
  } | Select-Object @{N='Store';E={$store}}, Subject, Thumbprint, NotAfter
}

# Check remote server certificate
$url = "https://server.example.com"
$request = [Net.HttpWebRequest]::Create($url)
$request.GetResponse() | Out-Null
$cert = $request.ServicePoint.Certificate
Write-Host "Expires: $($cert.GetExpirationDateString())"

# List all certificates on the CA that are expired
certutil -view -restrict "NotAfter<=$(Get-Date -Format 'MM/dd/yyyy')" -out "RequestID,CommonName,NotAfter,Disposition"

# List certificates expiring in next 30 days from CA
certutil -view -restrict "NotAfter<=$((Get-Date).AddDays(30).ToString('MM/dd/yyyy')),NotAfter>=$(Get-Date -Format 'MM/dd/yyyy')" -out "RequestID,CommonName,NotAfter"
```

### Step 2: Backup Existing Certificate
```powershell
# Export the certificate with private key (PFX)
$cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*server.example.com*" }
$password = ConvertTo-SecureString -String "BackupP@ss123" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath "C:\CertBackup\server_old_$(Get-Date -Format 'yyyyMMdd').pfx" -Password $password

# OR using certutil
certutil -exportPFX -p "BackupP@ss123" My <Thumbprint> C:\CertBackup\server_backup.pfx

# Backup the CA database
Backup-CARoleService -Path "C:\CABackup\$(Get-Date -Format 'yyyyMMdd')" -DatabaseOnly
```

### Step 3: Generate New CSR
```powershell
# Create an INF file for the CSR
@"
[NewRequest]
Subject = "CN=server.example.com, O=MyOrg, L=City, S=State, C=US"
KeyLength = 2048
KeySpec = 1
KeyUsage = 0xA0
MachineKeySet = TRUE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
RequestType = PKCS10
HashAlgorithm = SHA256

[Extensions]
2.5.29.17 = "{text}"
_continue_ = "dns=server.example.com&"
_continue_ = "dns=www.example.com&"
_continue_ = "ipaddress=10.0.0.1"

[RequestAttributes]
CertificateTemplate = WebServer
"@ | Out-File -FilePath "C:\CertRenewal\request.inf" -Encoding ASCII

# Generate the CSR
certreq -new C:\CertRenewal\request.inf C:\CertRenewal\server_new.csr
```

### Step 4: Submit CSR & Obtain New Certificate
```powershell
# Submit to internal CA
certreq -submit -config "CA-Server\CA-Name" C:\CertRenewal\server_new.csr C:\CertRenewal\server_new.cer

# If pending approval, check request ID
certutil -config "CA-Server\CA-Name" -view -out "RequestID,Disposition"

# Approve a pending request (on the CA)
certutil -resubmit <RequestID>

# Retrieve the approved certificate
certreq -retrieve <RequestID> C:\CertRenewal\server_new.cer
```

### Step 5: Install the New Certificate
```powershell
# Accept/install the new certificate
certreq -accept C:\CertRenewal\server_new.cer

# Verify installation
Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*server.example.com*" } |
  Format-Table Subject, Thumbprint, NotBefore, NotAfter -AutoSize

# OR import from PFX
$password = ConvertTo-SecureString -String "CertP@ss123" -Force -AsPlainText
Import-PfxCertificate -FilePath "C:\CertRenewal\server_new.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $password
```

### Step 6: Update Service Bindings

#### IIS
```powershell
# Get new certificate thumbprint
$newCert = Get-ChildItem Cert:\LocalMachine\My | Where-Object {
  $_.Subject -like "*server.example.com*" -and $_.NotAfter -gt (Get-Date)
} | Sort-Object NotAfter -Descending | Select-Object -First 1

# Update IIS HTTPS binding
Import-Module WebAdministration

# Remove old binding
Get-WebBinding -Name "Default Web Site" -Protocol https | Remove-WebBinding

# Add new binding
New-WebBinding -Name "Default Web Site" -Protocol https -Port 443 -HostHeader "server.example.com" -SslFlags 1
$binding = Get-WebBinding -Name "Default Web Site" -Protocol https
$binding.AddSslCertificate($newCert.Thumbprint, "My")

# Restart IIS
iisreset /restart
```

#### RDP (Remote Desktop)
```powershell
# Update RDP certificate
$newThumbprint = $newCert.Thumbprint
wmic /namespace:\\root\cimv2\TerminalServices PATH Win32_TSGeneralSetting Set SSLCertificateSHA1Hash="$newThumbprint"

# Restart Remote Desktop Services
Restart-Service -Name "TermService" -Force
```

#### LDAPS (Active Directory)
```powershell
# The DC will auto-select the newest valid cert, but you can force it:
# Export the new cert to the NTDS\Personal store
certutil -dspublish -f C:\CertRenewal\server_new.cer NTAuthCA

# Restart NTDS
Restart-Service NTDS -Force
```

### Step 7: Remove Old Certificate
```powershell
# Remove old expired certificate from the store
$oldCert = Get-ChildItem Cert:\LocalMachine\My | Where-Object {
  $_.Subject -like "*server.example.com*" -and $_.NotAfter -lt (Get-Date)
}
Remove-Item -Path "Cert:\LocalMachine\My\$($oldCert.Thumbprint)"

# Revoke old certificate on the CA
certutil -revoke <OldSerialNumber> 6   # 6 = Certificate Hold / can use 0 for unspecified

# Publish new CRL
certutil -CRL
```

---

## 3. 🔥 Cisco IOS / IOS-XE

### Step 1: Identify Expired Certificates
```
! View all certificates with expiry
show crypto pki certificates

! View certificate details
show crypto pki certificates verbose

! Check trustpoint status
show crypto pki trustpoints status

! Show timer for auto-enrollment
show crypto pki timers
```

### Step 2: Backup Existing Certificate
```
! Export current certificate and key to terminal
crypto pki export MY-TRUSTPOINT pem terminal

! Export to PKCS12 file on flash
crypto pki export MY-TRUSTPOINT pkcs12 flash:cert_backup.p12 password BackupPass123

! Copy backup off the device
copy flash:cert_backup.p12 tftp://10.0.0.100/cert_backup.p12
```

### Step 3: Remove Old Certificate & Keys
```
! Delete the old trustpoint certificate (this removes the identity cert)
no crypto pki certificate chain MY-TRUSTPOINT
  no certificate <serial_number>

! OR delete entire enrollment
crypto pki trustpoint MY-TRUSTPOINT
  no enrollment

! Delete the old RSA keys if generating new ones
crypto key zeroize rsa MY-OLD-KEYS
```

### Step 4: Generate New Key Pair
```
! Generate new RSA key pair
crypto key generate rsa general-keys label MY-NEW-KEYS modulus 2048 exportable

! Verify new keys
show crypto key mypubkey rsa MY-NEW-KEYS
```

### Step 5: Re-enroll for New Certificate
```
! Update the trustpoint with new key
crypto pki trustpoint MY-TRUSTPOINT
  rsakeypair MY-NEW-KEYS
  enrollment url http://10.0.0.1/certsrv/mscep/mscep.dll
  subject-name CN=Router1.example.com, O=MyOrg, C=US
  revocation-check crl
  auto-enroll 80       ! Auto-renew at 80% of lifetime
  exit

! Re-authenticate the CA (if CA cert also changed)
crypto pki authenticate MY-TRUSTPOINT

! Re-enroll the device
crypto pki enroll MY-TRUSTPOINT

! Verify new certificate
show crypto pki certificates MY-TRUSTPOINT
```

### Step 6: Update Services Using the Certificate
```
! Update SSL VPN (WebVPN)
webvpn gateway MY-GATEWAY
  ssl trustpoint MY-TRUSTPOINT

! Update SIP TLS
voice service voip
  sip
    crypto signaling default trustpoint MY-TRUSTPOINT

! Update HTTPS Server
ip http secure-trustpoint MY-TRUSTPOINT
ip http secure-server

! Update SSH (if using PKI-based SSH)
ip ssh server certificate profile
  server
    trustpoint sign MY-TRUSTPOINT

! Update ISE/RADIUS DTLS
radius server ISE
  dtls trustpoint client MY-TRUSTPOINT

! Verify services
show ip http server secure status
show webvpn gateway
```

### Enable Auto-Enrollment for Future Rotations
```
! Configure auto-enrollment (renew at 80% of lifetime)
crypto pki trustpoint MY-TRUSTPOINT
  auto-enroll 80 regenerate
  exit

! Verify auto-enrollment timer
show crypto pki timers
```

---

## 4. 🔥 Palo Alto Networks Firewall

### Step 1: Identify Expired Certificates
```
# List all certificates and check expiry
> show certificate summary

# View specific certificate details
> show sslmgr-store certificate-info certificate-name "server-cert"

# Check certificate expiry from CLI
> debug sslmgr view cert certificate-name "server-cert"

# Show device certificates
> show system certificate
```

### Step 2: Backup/Export Old Certificate
```
# Export certificate in PEM format
> scp export certificate certificate-name "server-cert" format pem to user@backup-server:/backups/

# Export with private key
> request certificate export certificate-name "server-cert" format pkcs12 passphrase "ExportPass123" to /tmp/server_cert_backup.p12

# Copy to external server
> scp export certificate-file /tmp/server_cert_backup.p12 to user@10.0.0.100:/backups/
```

### Step 3: Generate New Key & Certificate
```
# Option A: Generate new cert signed by on-box CA
> request certificate generate signed-by "PA-Root-CA" certificate-name "server-cert-new" \
    name "fw.example.com" algorithm RSA rsa-nbits 2048 digest sha256 \
    days-till-expiry 365 \
    alt-name-dns "fw.example.com" alt-name-dns "vpn.example.com" \
    alt-name-ip "10.0.0.1"

# Option B: Generate CSR for external CA signing
> request certificate generate certificate-name "server-cert-new" \
    name "fw.example.com" algorithm RSA rsa-nbits 2048 digest sha256 \
    alt-name-dns "fw.example.com" alt-name-dns "vpn.example.com"

# Export the CSR
> request certificate export certificate-name "server-cert-new" format pem to /tmp/server_new.csr

# After external CA signs it, import the signed cert
> request certificate import certificate-name "server-cert-new" format pem \
    certificate-file /tmp/signed_cert.pem

# Import the CA chain if needed
> request certificate import certificate-name "External-CA" format pem \
    certificate-file /tmp/ca-chain.pem
```

### Step 4: Update All Profiles & Services
```
# Update SSL/TLS Service Profile (Management, GlobalProtect, etc.)
> configure
# set shared ssl-tls-service-profile "mgmt-tls-profile" certificate "server-cert-new"
# set shared ssl-tls-service-profile "gp-tls-profile" certificate "server-cert-new"

# Update GlobalProtect Portal
# set network interface tunnel units tunnel.1 ip 10.10.10.1/24
# set shared certificate-profile "gp-cert-profile" CA "External-CA"

# Update SSL Decryption Forward Trust Certificate
# set shared ssl-decrypt forward-trust-certificate-rsa "server-cert-new"

# Update Management Interface SSL Cert
> set deviceconfig system ssl-tls-service-profile "mgmt-tls-profile"

# Commit changes
> commit
```

### Step 5: Verify New Certificate
```
# Verify certificate is active
> show certificate summary
> show sslmgr-store certificate-info certificate-name "server-cert-new"

# Test GlobalProtect connectivity
> test vpn ipsec-sa

# Test management access
> show system info | match ssl
```

### Step 6: Delete Old Certificate
```
> configure
# delete shared certificate "server-cert"
> commit

# OR from operational mode
> request certificate delete certificate-name "server-cert"
```

---

## 5. 🔵 Fortinet FortiGate

### Step 1: Identify Expired Certificates
```
# List all local certificates
get certificate local

# List all CA certificates
get certificate ca

# Detailed certificate info
diagnose certificate local list
diagnose certificate ca list

# Check specific certificate details
diagnose certificate local list | grep -A 10 "server-cert"

# View expiry dates
execute certificate local info "server-cert"
```

### Step 2: Backup Old Certificate
```
# Export certificate via CLI to TFTP
execute certificate local export tftp "server-cert" cert.pem 10.0.0.100
execute certificate local export-key tftp "server-cert" key.pem 10.0.0.100 "keypassword"

# Full config backup (includes certs)
execute backup full-config tftp config_backup.conf 10.0.0.100
```

### Step 3: Generate New CSR
```
# Generate a new CSR
execute certificate local generate rsa 2048 "server-cert-new" 365 \
  "CN=fw.example.com,O=MyOrg,OU=IT,L=City,ST=State,C=US" \
  "fw.example.com" "vpn.example.com"

# View the CSR
execute certificate local show "server-cert-new"

# Export CSR for external CA signing
execute certificate local export tftp "server-cert-new" server_new.csr 10.0.0.100
```

### Step 4: Import Signed Certificate
```
# Import the signed certificate from TFTP
execute certificate local import tftp signed_cert.pem 10.0.0.100

# Import via CLI inline
config certificate local
  edit "server-cert-new"
    set certificate "-----BEGIN CERTIFICATE-----
    <paste certificate content>
    -----END CERTIFICATE-----"
  next
end

# Import CA chain
config certificate ca
  edit "External-CA"
    set ca "-----BEGIN CERTIFICATE-----
    <paste CA cert>
    -----END CERTIFICATE-----"
  next
end

# Import via GUI: System → Certificates → Import → Local Certificate
```

### Step 5: Update All Services
```
# Update HTTPS admin access
config system global
  set admin-server-cert "server-cert-new"
end

# Update SSL VPN
config vpn ssl settings
  set servercert "server-cert-new"
end

# Update SSL Inspection Profile
config firewall ssl-ssh-profile
  edit "deep-inspection"
    set caname "FortiCA-new"
    config ssl
      set cert "server-cert-new"
    end
  next
end

# Update LDAPS connection
config user ldap
  edit "LDAP-Server"
    set ca-cert "External-CA"
  next
end

# Update FortiGuard connection certificate
config log fortianalyzer setting
  set certificate "server-cert-new"
end

# Update IPsec VPN
config vpn ipsec phase1-interface
  edit "VPN-Tunnel-1"
    set certificate "server-cert-new"
  next
end
```

### Step 6: Verify & Clean Up
```
# Verify new cert is in use
diagnose certificate local list
get system status | grep cert

# Test SSL VPN connectivity
diagnose vpn ssl list

# Test admin HTTPS
diagnose sys tcp 443

# Delete old certificate
config certificate local
  delete "server-cert-old"
end
```

---

## 6. ☁️ AWS (ACM — Certificate Manager)

### Step 1: Identify Expired/Expiring Certificates
```bash
# List all certificates and their statuses
aws acm list-certificates --query 'CertificateSummaryList[*].[DomainName,CertificateArn,Status]' --output table

# Find certificates expiring within 30 days
aws acm list-certificates --query 'CertificateSummaryList[*].CertificateArn' --output text | tr '\t' '\n' | while read arn; do
  EXPIRY=$(aws acm describe-certificate --certificate-arn "$arn" --query 'Certificate.NotAfter' --output text)
  DOMAIN=$(aws acm describe-certificate --certificate-arn "$arn" --query 'Certificate.DomainName' --output text)
  EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s 2>/dev/null || date -jf "%Y-%m-%dT%H:%M:%S" "$EXPIRY" +%s)
  NOW_EPOCH=$(date +%s)
  DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))
  if [ "$DAYS_LEFT" -lt 30 ]; then
    echo "⚠️  $DOMAIN - Expires: $EXPIRY ($DAYS_LEFT days left) - $arn"
  fi
done

# Describe a specific certificate
aws acm describe-certificate --certificate-arn arn:aws:acm:us-east-1:123456789:certificate/abc-123 \
  --query 'Certificate.{Domain:DomainName,Status:Status,Expiry:NotAfter,InUse:InUseBy}'
```

### Step 2: Rotate ACM Public Certificates (Auto-Renewed)
```bash
# ACM public certificates auto-renew! But if validation failed:

# Check renewal status
aws acm describe-certificate --certificate-arn <ARN> \
  --query 'Certificate.RenewalSummary'

# Re-validate via DNS (if CNAME removed)
aws acm describe-certificate --certificate-arn <ARN> \
  --query 'Certificate.DomainValidationOptions'

# Add the returned CNAME to your DNS, then AWS auto-renews
```

### Step 3: Rotate Imported Certificates (Manual)
```bash
# Generate new key and CSR
openssl genrsa -out new_server.key 2048
openssl req -new -key new_server.key -out new_server.csr -subj "/CN=example.com"

# After getting the signed cert from your CA, re-import to the SAME ARN
aws acm import-certificate \
  --certificate-arn arn:aws:acm:us-east-1:123456789:certificate/abc-123 \
  --certificate fileb://new_server.crt \
  --private-key fileb://new_server.key \
  --certificate-chain fileb://ca-chain.crt

# The certificate is automatically updated on all attached resources
# (ALB, CloudFront, API Gateway, etc.)
```

### Step 4: Request a Brand New Certificate
```bash
# Request new public cert
aws acm request-certificate \
  --domain-name "example.com" \
  --subject-alternative-names "*.example.com" "api.example.com" \
  --validation-method DNS \
  --tags Key=Environment,Value=Production Key=RotationDate,Value=$(date +%Y-%m-%d)

# Get the new ARN
NEW_ARN=$(aws acm list-certificates --query 'CertificateSummaryList[?DomainName==`example.com`].CertificateArn' --output text | head -1)

# Complete DNS validation
aws acm describe-certificate --certificate-arn "$NEW_ARN" \
  --query 'Certificate.DomainValidationOptions[*].ResourceRecord'

# Wait for validation
aws acm wait certificate-validated --certificate-arn "$NEW_ARN"
```

### Step 5: Update Resource Bindings
```bash
# Update ALB/NLB listener
aws elbv2 modify-listener \
  --listener-arn arn:aws:elasticloadbalancing:us-east-1:123456789:listener/app/my-alb/abc/123 \
  --certificates CertificateArn="$NEW_ARN"

# Update CloudFront distribution
aws cloudfront update-distribution --id E1234567890 \
  --viewer-certificate ACMCertificateArn="$NEW_ARN",SSLSupportMethod=sni-only,MinimumProtocolVersion=TLSv1.2_2021

# Update API Gateway custom domain
aws apigateway update-domain-name \
  --domain-name "api.example.com" \
  --patch-operations op=replace,path=/certificateArn,value="$NEW_ARN"
```

### Step 6: Delete Old Certificate
```bash
# Verify old cert is no longer in use
aws acm describe-certificate --certificate-arn <OLD_ARN> --query 'Certificate.InUseBy'

# Delete the old certificate (only if InUseBy is empty)
aws acm delete-certificate --certificate-arn <OLD_ARN>
```

---

## 7. ☁️ Azure (Key Vault)

### Step 1: Identify Expired Certificates
```bash
# List all certificates with expiry
az keyvault certificate list --vault-name "MyKeyVault" \
  --query "[].{Name:name, Expires:attributes.expires, Enabled:attributes.enabled}" --output table

# Check specific certificate
az keyvault certificate show --vault-name "MyKeyVault" --name "MyCert" \
  --query "{Name:name, Expires:attributes.expires, Thumbprint:x509ThumbprintHex}"

# Find expiring certs (PowerShell)
$certs = Get-AzKeyVaultCertificate -VaultName "MyKeyVault"
$certs | Where-Object { $_.Expires -lt (Get-Date).AddDays(30) } |
  Select-Object Name, Expires, Thumbprint | Format-Table
```

### Step 2: Backup Certificate
```bash
# Backup certificate
az keyvault certificate backup --vault-name "MyKeyVault" --name "MyCert" --file cert_backup.blob

# Download current cert
az keyvault certificate download --vault-name "MyKeyVault" --name "MyCert" --file old_cert.pem --encoding PEM

# Download the private key (as secret)
az keyvault secret download --vault-name "MyKeyVault" --name "MyCert" --file old_cert_with_key.pem --encoding utf-8
```

### Step 3: Create New Certificate Version
```bash
# Option A: Renew with same policy (creates a new version)
az keyvault certificate create --vault-name "MyKeyVault" --name "MyCert" \
  --policy "$(az keyvault certificate get-default-policy)"

# Option B: Create with custom policy
az keyvault certificate create --vault-name "MyKeyVault" --name "MyCert" \
  --policy '{
    "issuerParameters": { "name": "Self" },
    "keyProperties": { "keyType": "RSA", "keySize": 2048, "reuseKey": false },
    "x509CertificateProperties": {
      "subject": "CN=server.example.com",
      "subjectAlternativeNames": {
        "dnsNames": ["server.example.com", "www.example.com"]
      },
      "validityInMonths": 12
    },
    "lifetimeActions": [{
      "action": { "actionType": "AutoRenew" },
      "trigger": { "daysBeforeExpiry": 30 }
    }]
  }'

# Option C: Import externally signed certificate
az keyvault certificate import --vault-name "MyKeyVault" --name "MyCert" \
  --file new_certificate.pfx --password "PfxPass123"
```

### Step 4: Update Dependent Azure Resources
```bash
# Update App Service SSL binding
az webapp config ssl bind --name "MyWebApp" --resource-group "MyRG" \
  --certificate-thumbprint <NEW_THUMBPRINT> --ssl-type SNI

# Update Application Gateway
az network application-gateway ssl-cert update \
  --resource-group "MyRG" --gateway-name "MyAppGW" --name "mySslCert" \
  --key-vault-secret-id "$(az keyvault certificate show --vault-name MyKeyVault --name MyCert --query sid -o tsv)"

# Update Azure Front Door
az afd secret update --resource-group "MyRG" --profile-name "MyFrontDoor" \
  --secret-name "mySecret" \
  --secret-source "/subscriptions/<sub>/resourceGroups/MyRG/providers/Microsoft.KeyVault/vaults/MyKeyVault/certificates/MyCert"

# Update AKS ingress (via Key Vault CSI driver - redeployment)
kubectl rollout restart deployment my-app -n production
```

### Step 5: Enable Auto-Rotation
```bash
# Set auto-renewal policy
az keyvault certificate set-attributes --vault-name "MyKeyVault" --name "MyCert" \
  --policy '{
    "lifetimeActions": [{
      "action": { "actionType": "AutoRenew" },
      "trigger": { "daysBeforeExpiry": 30 }
    }]
  }'

# Set up alerts for expiring certs
az monitor metrics alert create --name "CertExpiryAlert" \
  --resource-group "MyRG" \
  --scopes "/subscriptions/<sub>/resourceGroups/MyRG/providers/Microsoft.KeyVault/vaults/MyKeyVault" \
  --condition "avg ExpiringCertificateCount > 0" \
  --action "/subscriptions/<sub>/resourceGroups/MyRG/providers/Microsoft.Insights/actionGroups/CertAlertGroup"
```

---

## 8. 🖥️ F5 BIG-IP

### Step 1: Identify Expired Certificates
```bash
# List all certificates with expiry
tmsh list sys crypto cert | grep -E "cert-name|expiration"

# Detailed certificate info
tmsh show sys crypto cert server.crt

# Check all expiring soon (via bash)
for cert in $(tmsh list sys crypto cert one-line | awk '{print $4}'); do
  EXPIRY=$(tmsh list sys crypto cert $cert | grep expiration | awk '{print $2}')
  echo "$cert - Expires: $EXPIRY"
done

# Check from iControl REST
curl -sk -u admin:password https://localhost/mgmt/tm/sys/crypto/cert | jq '.items[] | {name, expirationString}'
```

### Step 2: Backup
```bash
# Export current cert and key
tmsh run sys crypto cert-key export cert server.crt key server.key file /var/tmp/server_backup.p12 passphrase "BackupPass"

# Copy off device
scp /var/tmp/server_backup.p12 user@backup-server:/backups/

# Save running config
tmsh save sys config
```

### Step 3: Generate New Key & CSR
```bash
# Generate new key
tmsh create sys crypto key server_new.key key-size 2048 gen-rsa

# Generate CSR
tmsh create sys crypto csr server_new.csr key server_new.key \
  common-name "lb.example.com" \
  organization "MyOrg" \
  ou "IT" \
  country "US" \
  state "State" \
  city "City" \
  subject-alternative-name "DNS:lb.example.com,DNS:www.example.com,IP:10.0.0.1"

# Export CSR
cat /config/ssl/ssl.csr/server_new.csr
```

### Step 4: Install New Certificate
```bash
# Copy signed cert to F5
scp signed_cert.pem admin@f5.example.com:/var/tmp/

# Install the new certificate
tmsh install sys crypto cert server_new.crt from-local-file /var/tmp/signed_cert.pem

# Install CA chain/bundle
tmsh install sys crypto cert ca-chain.crt from-local-file /var/tmp/ca-chain.pem

# Verify installation
tmsh list sys crypto cert server_new.crt
```

### Step 5: Update SSL Profiles
```bash
# Update Client SSL Profile
tmsh modify ltm profile client-ssl my-clientssl \
  cert server_new.crt \
  key server_new.key \
  chain ca-chain.crt

# Update Server SSL Profile (if applicable)
tmsh modify ltm profile server-ssl my-serverssl \
  cert server_new.crt \
  key server_new.key \
  chain ca-chain.crt

# Update management SSL certificate
tmsh modify sys httpd ssl-certfile /etc/httpd/conf/ssl.crt/server_new.crt
tmsh modify sys httpd ssl-certkeyfile /etc/httpd/conf/ssl.key/server_new.key
tmsh restart sys service httpd

# Save config
tmsh save sys config
```

### Step 6: Verify & Clean Up
```bash
# Test SSL connection to virtual server
echo | openssl s_client -connect lb.example.com:443 -servername lb.example.com 2>/dev/null | openssl x509 -noout -dates -subject

# Verify the profile is using the new cert
tmsh list ltm profile client-ssl my-clientssl cert key chain

# Remove old certificate and key
tmsh delete sys crypto cert server.crt
tmsh delete sys crypto key server.key
```

---

## 9. 🔑 Java Keytool (JKS/PKCS12)

### Step 1: Identify Expired Certificates
```bash
# List all entries with expiry
keytool -list -v -keystore keystore.jks -storepass changeit | grep -E "Alias|Valid from|until"

# Check specific alias
keytool -list -v -keystore keystore.jks -storepass changeit -alias myserver

# Script to find expiring certs
keytool -list -v -keystore keystore.jks -storepass changeit | grep -A1 "Alias" | while read -r line; do
  echo "$line"
done
```

### Step 2: Backup Keystore
```bash
# Full keystore backup
cp keystore.jks "keystore_backup_$(date +%Y%m%d).jks"

# Export specific entry to PKCS12
keytool -importkeystore -srckeystore keystore.jks -srcstorepass changeit \
  -srcalias myserver -destkeystore backup_myserver.p12 \
  -deststoretype PKCS12 -deststorepass changeit
```

### Step 3: Generate New Key & CSR
```bash
# Delete old entry (or use a different alias)
keytool -delete -alias myserver -keystore keystore.jks -storepass changeit

# Generate new key pair
keytool -genkeypair -alias myserver -keyalg RSA -keysize 2048 \
  -validity 365 -keystore keystore.jks -storepass changeit \
  -dname "CN=server.example.com, O=MyOrg, L=City, ST=State, C=US" \
  -ext SAN=dns:server.example.com,dns:www.example.com,ip:10.0.0.1

# Generate CSR
keytool -certreq -alias myserver -keystore keystore.jks -storepass changeit \
  -file server_new.csr \
  -ext SAN=dns:server.example.com,dns:www.example.com
```

### Step 4: Import Signed Certificate Chain
```bash
# Import Root CA certificate
keytool -importcert -alias rootca -file rootCA.crt -keystore keystore.jks \
  -storepass changeit -trustcacerts -noprompt

# Import Intermediate CA certificate
keytool -importcert -alias intermediateca -file intermediateCA.crt -keystore keystore.jks \
  -storepass changeit -trustcacerts -noprompt

# Import the signed server certificate
keytool -importcert -alias myserver -file signed_server.crt -keystore keystore.jks \
  -storepass changeit -trustcacerts

# Verify the full chain
keytool -list -v -keystore keystore.jks -storepass changeit -alias myserver
```

### Step 5: Restart Java Application
```bash
# Restart Tomcat
systemctl restart tomcat

# Restart Spring Boot application
systemctl restart myapp

# Restart WildFly/JBoss
/opt/wildfly/bin/jboss-cli.sh --connect --command="reload"
```

### Step 6: Verify
```bash
# Test connection
echo | openssl s_client -connect server.example.com:8443 -servername server.example.com 2>/dev/null | openssl x509 -noout -dates -subject

# Verify keystore content
keytool -list -v -keystore keystore.jks -storepass changeit -alias myserver | grep -E "Alias|Owner|Issuer|Valid|Serial"
```

---

## 10. 🐧 Let's Encrypt (Certbot)

### Step 1: Check Existing Certificates
```bash
# List all managed certificates
sudo certbot certificates

# Check specific domain
sudo certbot certificates -d example.com
```

### Step 2: Renew Certificates
```bash
# Renew all expiring certificates
sudo certbot renew

# Force renew a specific certificate
sudo certbot renew --cert-name example.com --force-renewal

# Renew with hooks (restart services)
sudo certbot renew --deploy-hook "systemctl reload nginx"

# Dry run (test renewal without making changes)
sudo certbot renew --dry-run
```

### Step 3: Obtain a Completely New Certificate
```bash
# New cert with Nginx plugin
sudo certbot --nginx -d example.com -d www.example.com --force-renewal

# New cert with Apache plugin
sudo certbot --apache -d example.com --force-renewal

# Standalone (stops webserver temporarily)
sudo certbot certonly --standalone -d example.com --force-renewal

# DNS challenge (for wildcard)
sudo certbot certonly --manual --preferred-challenges dns -d "*.example.com" -d example.com
```

### Step 4: Set Up Auto-Renewal
```bash
# Test the renewal timer
sudo systemctl status certbot.timer

# Enable auto-renewal
sudo systemctl enable --now certbot.timer

# OR set up a cron job
echo "0 3 * * * root certbot renew --quiet --deploy-hook 'systemctl reload nginx'" | sudo tee /etc/cron.d/certbot-renew

# Verify timer is working
sudo certbot renew --dry-run
```

---

## 📋 Master Rotation Checklist

| Step | Action | Status |
|------|--------|--------|
| 1 | 🔍 Identify all expired/expiring certificates | ☐ |
| 2 | 📋 Document current cert details (CN, SAN, issuer, serial) | ☐ |
| 3 | 💾 Backup existing certificates and keys | ☐ |
| 4 | 🔑 Generate new key pair (don't reuse compromised keys) | ☐ |
| 5 | 📝 Generate new CSR with correct SAN entries | ☐ |
| 6 | ✍️ Submit CSR to CA and obtain signed certificate | ☐ |
| 7 | ✅ Validate new cert (chain, key match, dates, SAN) | ☐ |
| 8 | 📥 Install new certificate on target system | ☐ |
| 9 | 🔗 Update ALL service bindings (web, VPN, mail, etc.) | ☐ |
| 10 | 🔄 Restart/reload dependent services | ☐ |
| 11 | 🧪 Test connectivity and TLS handshake | ☐ |
| 12 | 🗑️ Revoke and archive old certificate | ☐ |
| 13 | 📊 Update monitoring and set expiry alerts | ☐ |
| 14 | 📝 Document the rotation for audit trail | ☐ |

---

> ⚠️ **Critical Reminders:**
> - **Always generate new key pairs** during rotation (don't reuse keys from expired/compromised certs)
> - **Test in staging** before rotating production certificates
> - **Schedule maintenance windows** for certificate rotations that require service restarts
> - **Verify the complete chain** — missing intermediate certs is the #1 cause of rotation failures
> - **Update ALL services** that reference the old cert — missed bindings cause outages
> - **Set up automated monitoring** (e.g., Nagios, Prometheus, AWS Config) to alert before expiry
> - **Enable auto-renewal** wherever possible (ACM, Let's Encrypt, Cisco auto-enroll, Azure auto-renew)

### USER
any other ideas/commands for PKI management?

### ASSISTANT
# 🔐 Advanced PKI Management — Extended Commands, Ideas & Best Practices

Beyond basic certificate rotation, here's a comprehensive collection of advanced PKI management techniques across all major platforms.

---

## 1. 📊 Certificate Monitoring & Auditing

### OpenSSL — Bulk Certificate Health Checks
```bash
# Comprehensive certificate scanner script
#!/bin/bash
echo "========== CERTIFICATE HEALTH REPORT =========="
echo "Generated: $(date)"
echo "================================================"

# Scan all certs in a directory
find /etc/ssl /etc/pki /etc/nginx /etc/apache2 -type f \( -name "*.crt" -o -name "*.pem" -o -name "*.cer" \) 2>/dev/null | while read cert; do
  if openssl x509 -in "$cert" -noout 2>/dev/null; then
    SUBJECT=$(openssl x509 -in "$cert" -noout -subject 2>/dev/null | sed 's/subject=//')
    ISSUER=$(openssl x509 -in "$cert" -noout -issuer 2>/dev/null | sed 's/issuer=//')
    ENDDATE=$(openssl x509 -in "$cert" -noout -enddate 2>/dev/null | sed 's/notAfter=//')
    SERIAL=$(openssl x509 -in "$cert" -noout -serial 2>/dev/null | sed 's/serial=//')
    SIGALG=$(openssl x509 -in "$cert" -noout -text 2>/dev/null | grep "Signature Algorithm" | head -1 | awk '{print $3}')
    KEYSIZE=$(openssl x509 -in "$cert" -noout -text 2>/dev/null | grep "Public-Key" | grep -oP '\d+')
    SAN=$(openssl x509 -in "$cert" -noout -ext subjectAltName 2>/dev/null | tail -1)

    # Calculate days remaining
    EXPIRY_EPOCH=$(date -d "$ENDDATE" +%s 2>/dev/null)
    NOW_EPOCH=$(date +%s)
    DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

    # Status indicator
    if [ "$DAYS_LEFT" -lt 0 ]; then
      STATUS="❌ EXPIRED"
    elif [ "$DAYS_LEFT" -lt 7 ]; then
      STATUS="🔴 CRITICAL"
    elif [ "$DAYS_LEFT" -lt 30 ]; then
      STATUS="🟡 WARNING"
    elif [ "$DAYS_LEFT" -lt 90 ]; then
      STATUS="🟠 ATTENTION"
    else
      STATUS="✅ OK"
    fi

    # Weak key check
    if [ "$KEYSIZE" -lt 2048 ]; then
      KEYCHECK="⚠️  WEAK KEY ($KEYSIZE-bit)"
    else
      KEYCHECK="✅ $KEYSIZE-bit"
    fi

    # Weak algorithm check
    if echo "$SIGALG" | grep -qi "sha1\|md5"; then
      ALGCHECK="⚠️  WEAK ALGORITHM ($SIGALG)"
    else
      ALGCHECK="✅ $SIGALG"
    fi

    echo ""
    echo "--- $cert ---"
    echo "  Subject:    $SUBJECT"
    echo "  Issuer:     $ISSUER"
    echo "  Serial:     $SERIAL"
    echo "  SAN:        $SAN"
    echo "  Expires:    $ENDDATE ($DAYS_LEFT days) [$STATUS]"
    echo "  Key Size:   $KEYCHECK"
    echo "  Sig Algo:   $ALGCHECK"
  fi
done
```

### Scan Remote Hosts for Certificate Issues
```bash
# Scan a list of hosts/ports for certificate expiry
#!/bin/bash
HOSTS=(
  "web.example.com:443"
  "mail.example.com:993"
  "ldap.example.com:636"
  "api.example.com:8443"
  "vpn.example.com:443"
  "ftp.example.com:990"
)

echo "| Host:Port | Subject | Days Left | Status | Key Size | Issuer |"
echo "|-----------|---------|-----------|--------|----------|--------|"

for HOST_PORT in "${HOSTS[@]}"; do
  HOST=$(echo "$HOST_PORT" | cut -d: -f1)
  PORT=$(echo "$HOST_PORT" | cut -d: -f2)

  CERT_INFO=$(echo | timeout 5 openssl s_client -connect "$HOST_PORT" -servername "$HOST" 2>/dev/null)

  if [ $? -eq 0 ]; then
    SUBJECT=$(echo "$CERT_INFO" | openssl x509 -noout -subject 2>/dev/null | sed 's/subject=//;s/^ *//')
    ENDDATE=$(echo "$CERT_INFO" | openssl x509 -noout -enddate 2>/dev/null | sed 's/notAfter=//')
    ISSUER=$(echo "$CERT_INFO" | openssl x509 -noout -issuer 2>/dev/null | sed 's/issuer=//;s/^ *//')
    KEYSIZE=$(echo "$CERT_INFO" | openssl x509 -noout -text 2>/dev/null | grep "Public-Key" | grep -oP '\d+')

    EXPIRY_EPOCH=$(date -d "$ENDDATE" +%s 2>/dev/null)
    NOW_EPOCH=$(date +%s)
    DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

    if [ "$DAYS_LEFT" -lt 0 ]; then STATUS="EXPIRED"
    elif [ "$DAYS_LEFT" -lt 30 ]; then STATUS="WARNING"
    else STATUS="OK"; fi

    echo "| $HOST_PORT | $SUBJECT | $DAYS_LEFT | $STATUS | $KEYSIZE | $ISSUER |"
  else
    echo "| $HOST_PORT | CONNECTION FAILED | - | ERROR | - | - |"
  fi
done
```

### Check Certificate Transparency Logs
```bash
# Search Certificate Transparency logs for your domain
# Using crt.sh
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq '.[] | {id, name_value, not_after, issuer_name}'

# Find unauthorized/rogue certificates for your domain
curl -s "https://crt.sh/?q=example.com&output=json" | jq -r '.[] | "\(.not_after) | \(.issuer_name) | \(.name_value)"' | sort -u

# Monitor for new certs issued for your domain
curl -s "https://crt.sh/?q=example.com&output=json" | jq '[.[] | select(.not_after > "2026-01-01")] | length'
```

### Windows — Advanced Certificate Auditing
```powershell
# Comprehensive audit of all certificate stores
$allStores = @(
    @{Location="LocalMachine"; Names=@("My","Root","CA","TrustedPeople","WebHosting","AuthRoot","TrustedPublisher")},
    @{Location="CurrentUser"; Names=@("My","Root","CA","TrustedPeople","TrustedPublisher")}
)

$report = @()
foreach ($storeConfig in $allStores) {
    foreach ($storeName in $storeConfig.Names) {
        try {
            $store = New-Object System.Security.Cryptography.X509Certificates.X509Store($storeName, $storeConfig.Location)
            $store.Open("ReadOnly")
            foreach ($cert in $store.Certificates) {
                $daysLeft = ($cert.NotAfter - (Get-Date)).Days
                $status = switch {
                    ($daysLeft -lt 0)  { "EXPIRED" }
                    ($daysLeft -lt 7)  { "CRITICAL" }
                    ($daysLeft -lt 30) { "WARNING" }
                    ($daysLeft -lt 90) { "ATTENTION" }
                    default            { "OK" }
                }
                $report += [PSCustomObject]@{
                    Store       = "$($storeConfig.Location)\$storeName"
                    Subject     = $cert.Subject
                    Issuer      = $cert.Issuer
                    Thumbprint  = $cert.Thumbprint
                    NotAfter    = $cert.NotAfter
                    DaysLeft    = $daysLeft
                    Status      = $status
                    KeySize     = $cert.PublicKey.Key.KeySize
                    SignatureAlg = $cert.SignatureAlgorithm.FriendlyName
                    HasPrivateKey = $cert.HasPrivateKey
                    SerialNumber = $cert.SerialNumber
                }
            }
            $store.Close()
        } catch { }
    }
}

# Display report sorted by days left
$report | Sort-Object DaysLeft | Format-Table -AutoSize

# Export to CSV
$report | Export-Csv -Path "C:\Reports\CertAudit_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation

# Show only problematic certs
$report | Where-Object { $_.Status -ne "OK" } | Format-Table -AutoSize

# Check for weak keys (< 2048 bit)
$report | Where-Object { $_.KeySize -lt 2048 } | Select-Object Store, Subject, KeySize

# Check for weak signing algorithms (SHA1, MD5)
$report | Where-Object { $_.SignatureAlg -match "sha1|md5" } | Select-Object Store, Subject, SignatureAlg
```

---

## 2. 🔒 Certificate Revocation Management

### OpenSSL — Full CRL & OCSP Management
```bash
# === CRL (Certificate Revocation List) ===

# Revoke a certificate with reason
openssl ca -config /root/ca/openssl.cnf -revoke /path/to/cert.pem -crl_reason keyCompromise
# Reasons: unspecified, keyCompromise, CACompromise, affiliationChanged,
#          superseded, cessationOfOperation, certificateHold, removeFromCRL

# Generate new CRL
openssl ca -config /root/ca/openssl.cnf -gencrl -out /root/ca/crl/ca.crl.pem

# Convert CRL to DER format (for distribution)
openssl crl -in /root/ca/crl/ca.crl.pem -outform DER -out /root/ca/crl/ca.crl

# View CRL contents
openssl crl -in /root/ca/crl/ca.crl.pem -noout -text

# Verify a certificate against CRL
openssl verify -crl_check -CAfile ca-chain.crt -CRLfile ca.crl.pem server.crt

# Verify against CRL for the entire chain
openssl verify -crl_check_all -CAfile ca-chain.crt -CRLfile ca.crl.pem server.crt

# Publish CRL to web server
cp /root/ca/crl/ca.crl /var/www/html/pki/crl/
chmod 644 /var/www/html/pki/crl/ca.crl

# Download and check a remote CRL
curl -s http://pki.example.com/crl/ca.crl | openssl crl -inform DER -noout -text

# === OCSP (Online Certificate Status Protocol) ===

# Start an OCSP responder
openssl ocsp -port 2560 \
  -index /root/ca/index.txt \
  -CA /root/ca/certs/ca.cert.pem \
  -rsigner /root/ca/certs/ocsp.cert.pem \
  -rkey /root/ca/private/ocsp.key.pem \
  -nrequest 1

# Query OCSP for certificate status
openssl ocsp \
  -issuer /root/ca/certs/ca.cert.pem \
  -cert /path/to/server.cert.pem \
  -url http://ocsp.example.com:2560 \
  -resp_text

# Check OCSP status of a remote server
openssl s_client -connect server.example.com:443 -status 2>/dev/null | grep -A 20 "OCSP Response"

# Check OCSP with stapling
echo | openssl s_client -connect server.example.com:443 -servername server.example.com -status 2>/dev/null | head -30

# Generate OCSP signing certificate
openssl req -new -key /root/ca/private/ocsp.key.pem \
  -out /root/ca/csr/ocsp.csr.pem \
  -subj "/C=US/O=MyOrg/CN=OCSP Responder"

openssl ca -config /root/ca/openssl.cnf \
  -extensions ocsp -days 365 -notext -md sha256 \
  -in /root/ca/csr/ocsp.csr.pem \
  -out /root/ca/certs/ocsp.cert.pem
```

### Windows — CRL & OCSP Management
```powershell
# Publish CRL manually
certutil -CRL

# View CRL
certutil -dump "C:\Windows\System32\CertSrv\CertEnroll\*.crl"

# Check certificate revocation status
certutil -verify -urlfetch server.cer

# Check OCSP response
certutil -url server.cer   # Opens GUI URL checker

# Configure CRL Distribution Point
certutil -setreg CA\CRLPublicationURLs "1:%WINDIR%\System32\CertSrv\CertEnroll\%3%8%9.crl\n2:http://pki.example.com/crl/%3%8%9.crl"

# Configure AIA (Authority Information Access)
certutil -setreg CA\CACertPublicationURLs "1:%WINDIR%\System32\CertSrv\CertEnroll\%1_%3%4.crt\n2:http://pki.example.com/aia/%1_%3%4.crt"

# Configure OCSP responder URL
certutil -setreg CA\CACertPublicationURLs "32:http://ocsp.example.com/ocsp"

# Restart CA service after changes
Restart-Service CertSvc

# View the CA database for revoked certs
certutil -view -restrict "Disposition=21" -out "RequestID,CommonName,SerialNumber,RevokedWhen,RevokedReason"
```

---

## 3. 🔑 Key Management & Protection

### HSM (Hardware Security Module) Integration
```bash
# === OpenSSL with PKCS#11 (HSM) ===

# List tokens/slots on the HSM
pkcs11-tool --list-slots
pkcs11-tool --list-objects --type privkey

# Generate key pair on HSM
pkcs11-tool --module /usr/lib/libsofthsm2.so --login --pin 1234 \
  --keypairgen --key-type RSA:2048 --id 01 --label "server-key"

# Generate CSR using HSM key via OpenSSL engine
openssl req -engine pkcs11 -new \
  -keyform engine -key "pkcs11:object=server-key;type=private" \
  -out server.csr \
  -subj "/CN=server.example.com"

# Sign with CA using HSM-stored CA key
openssl ca -engine pkcs11 \
  -keyform engine -keyfile "pkcs11:object=ca-key;type=private" \
  -config openssl.cnf \
  -in server.csr -out server.crt

# === SoftHSM2 (Software HSM for Testing) ===

# Initialize a token
softhsm2-util --init-token --slot 0 --label "TestToken" --pin 1234 --so-pin 5678

# List tokens
softhsm2-util --show-slots

# Delete a token
softhsm2-util --delete-token --serial <serial>
```

### Key Escrow & Recovery
```powershell
# === Windows CA Key Archival ===

# Enable key archival on CA
certutil -setreg CA\KRAFlags +KRAF_ENABLEARCHIVEALL

# Configure Key Recovery Agent
certutil -setreg CA\KRACertCount 1
certutil -setreg CA\KRACertHash <KRA_Cert_Hash>

# Recover an archived key
certutil -getkey <SearchToken> outputblob.pfx
certutil -recoverkey outputblob.pfx recovered.pfx
```

### Private Key Security Checks
```bash
# Check if a private key is encrypted
openssl rsa -in server.key -check -noout
# If encrypted, it will prompt for password

# Check key strength
openssl rsa -in server.key -text -noout | head -5

# Verify key has correct permissions
ls -la /etc/ssl/private/server.key
# Should be: -r-------- (400) or -rw------- (600)

# Set secure permissions
chmod 400 /etc/ssl/private/server.key
chown root:root /etc/ssl/private/server.key

# Encrypt an unencrypted private key
openssl rsa -aes256 -in unencrypted.key -out encrypted.key

# Remove encryption from a key (for automated services)
openssl rsa -in encrypted.key -out decrypted.key

# Verify key integrity
openssl rsa -in server.key -check
# Should output: "RSA key ok"

# Check if key matches certificate
diff <(openssl x509 -in cert.pem -noout -modulus) <(openssl rsa -in key.pem -noout -modulus)
```

---

## 4. 🏗️ Certificate Template & Policy Management

### Windows AD CS — Certificate Templates
```powershell
# List all available templates
certutil -template

# List templates on the CA
certutil -CATemplates

# View a specific template
certutil -dsTemplate "WebServer"

# Duplicate and create a custom template via PowerShell
$configContext = ([ADSI]"LDAP://RootDSE").configurationNamingContext
$templateContainer = "CN=Certificate Templates,CN=Public Key Services,CN=Services,$configContext"

# List all templates
Get-ADObject -SearchBase $templateContainer -Filter {objectClass -eq "pKICertificateTemplate"} | Select-Object Name

# Add a template to the CA
certutil -setcatemplates "+CustomWebServer"

# Remove a template from the CA
certutil -setcatemplates "-CustomWebServer"

# Configure auto-enrollment GPO (via PowerShell)
Set-GPRegistryValue -Name "Certificate Auto-Enrollment" `
  -Key "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment" `
  -ValueName "AEPolicy" -Type DWord -Value 7

# Force Group Policy update for auto-enrollment
gpupdate /force
certutil -pulse
```

### OpenSSL — Policy & Extensions Configuration
```ini
# === Advanced openssl.cnf Policy Configuration ===

# Custom policy for certificate issuance
[ policy_strict ]
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ policy_loose ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

# Server certificate extensions
[ server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
crlDistributionPoints = URI:http://pki.example.com/crl/ca.crl
authorityInfoAccess = OCSP;URI:http://ocsp.example.com:2560, caIssuers;URI:http://pki.example.com/aia/ca.crt

# Client certificate extensions
[ client_cert ]
basicConstraints = CA:FALSE
nsCertType = client, email
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer

# Code signing certificate extensions
[ codesign_cert ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, codeSigning, msCodeInd, msCodeCom
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer

# OCSP signing extensions
[ ocsp ]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning

# Timestamp authority extensions
[ timestamp_cert ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, timeStamping
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer

[ alt_names ]
DNS.1 = server.example.com
DNS.2 = www.example.com
DNS.3 = *.example.com
IP.1 = 10.0.0.1
IP.2 = 192.168.1.1
email.1 = admin@example.com
URI.1 = https://example.com
```

---

## 5. 🔄 Cross-Platform Certificate Conversion

```bash
# ========================================
# FORMAT CONVERSIONS
# ========================================

# PEM to DER
openssl x509 -in cert.pem -outform DER -out cert.der

# DER to PEM
openssl x509 -in cert.der -inform DER -outform PEM -out cert.pem

# PEM to PKCS#7 (P7B)
openssl crl2pkcs7 -nocrl -certfile cert.pem -certfile ca-chain.pem -out cert.p7b

# PKCS#7 to PEM
openssl pkcs7 -in cert.p7b -print_certs -out cert.pem

# PEM to PKCS#12 (PFX)
openssl pkcs12 -export -out cert.pfx -inkey key.pem -in cert.pem -certfile ca-chain.pem -name "My Certificate"

# PKCS#12 to PEM (extract all)
openssl pkcs12 -in cert.pfx -out all.pem -nodes

# PKCS#12 — extract certificate only
openssl pkcs12 -in cert.pfx -clcerts -nokeys -out cert.pem

# PKCS#12 — extract private key only
openssl pkcs12 -in cert.pfx -nocerts -nodes -out key.pem

# PKCS#12 — extract CA chain only
openssl pkcs12 -in cert.pfx -cacerts -nokeys -chain -out ca-chain.pem

# JKS to PKCS#12
keytool -importkeystore -srckeystore keystore.jks -srcstoretype JKS \
  -destkeystore keystore.p12 -deststoretype PKCS12

# PKCS#12 to JKS
keytool -importkeystore -srckeystore keystore.p12 -srcstoretype PKCS12 \
  -destkeystore keystore.jks -deststoretype JKS

# PEM to JKS (requires PKCS12 intermediate step)
openssl pkcs12 -export -in cert.pem -inkey key.pem -certfile ca-chain.pem -out temp.p12
keytool -importkeystore -srckeystore temp.p12 -srcstoretype PKCS12 -destkeystore keystore.jks

# Convert RSA key to PKCS#8 format
openssl pkcs8 -topk8 -inform PEM -outform PEM -in rsa_key.pem -out pkcs8_key.pem -nocrypt

# Convert EC key to PKCS#8 format
openssl pkcs8 -topk8 -inform PEM -outform PEM -in ec_key.pem -out pkcs8_ec.pem

# Convert PEM cert to Windows-compatible CER (Base64)
openssl x509 -in cert.pem -out cert.cer

# ========================================
# KEY CONVERSIONS
# ========================================

# Convert RSA private key from traditional to PKCS#8
openssl pkcs8 -topk8 -in traditional.key -out pkcs8.key -nocrypt

# Convert PKCS#8 to traditional RSA format
openssl rsa -in pkcs8.key -out traditional.key

# Extract public key from private key
openssl rsa -in private.key -pubout -out public.key

# Extract public key from certificate
openssl x509 -in cert.pem -noout -pubkey > public.key

# Convert EC private key
openssl ec -in ec_private.key -outform DER -out ec_private.der
```

---

## 6. 📜 Certificate Chain Building & Validation

```bash
# Build a complete certificate chain file
cat server.crt intermediate.crt root.crt > fullchain.pem

# Verify the chain order is correct
openssl crl2pkcs7 -nocrl -certfile fullchain.pem | openssl pkcs7 -print_certs -noout

# Verify certificate chain step by step
echo "=== Verifying server cert against intermediate ==="
openssl verify -CAfile intermediate.crt server.crt

echo "=== Verifying intermediate cert against root ==="
openssl verify -CAfile root.crt intermediate.crt

echo "=== Verifying full chain ==="
openssl verify -CAfile root.crt -untrusted intermediate.crt server.crt

# Download and verify a remote server's chain
echo | openssl s_client -connect server.example.com:443 -servername server.example.com -showcerts 2>/dev/null | \
  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ print }' > remote_chain.pem

# Split a chain file into individual certificates
csplit -f cert- -b '%02d.pem' fullchain.pem '/-----BEGIN CERTIFICATE-----/' '{*}'

# Verify OCSP stapling is working on server
echo | openssl s_client -connect server.example.com:443 -servername server.example.com -status 2>/dev/null | grep "OCSP Response Status"

# Check the certificate's AIA (Authority Information Access)
openssl x509 -in server.crt -noout -text | grep -A5 "Authority Information Access"

# Download intermediate cert from AIA URL
AIA_URL=$(openssl x509 -in server.crt -noout -text | grep "CA Issuers" | grep -oP 'URI:\K.*')
curl -s "$AIA_URL" -o intermediate_from_aia.der
openssl x509 -in intermediate_from_aia.der -inform DER -out intermediate_from_aia.pem

# Verify a certificate against the system's trust store
openssl verify -verbose server.crt

# Check for missing intermediates (common issue)
openssl s_client -connect server.example.com:443 -servername server.example.com 2>/dev/null | grep "Verify return code"
# "Verify return code: 21 (unable to verify the first certificate)" = missing intermediate!
```

---

## 7. 🛡️ Certificate Pinning

### Nginx — HPKP (HTTP Public Key Pinning)
```nginx
# Generate pin hash for your certificate
# Note: HPKP is deprecated but concepts apply to app-level pinning

# Get the SPKI hash of your certificate
openssl x509 -in server.crt -pubkey -noout | \
  openssl pkey -pubin -outform DER | \
  openssl dgst -sha256 -binary | base64

# Get the SPKI hash of your backup key
openssl rsa -in backup.key -pubout -outform DER | \
  openssl dgst -sha256 -binary | base64

# Nginx configuration for HSTS (recommended alternative)
server {
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options "nosniff" always;
}
```

### Application-Level Pinning
```bash
# Generate certificate fingerprint for app pinning
openssl x509 -in server.crt -noout -fingerprint -sha256
# Output: SHA256 Fingerprint=AA:BB:CC:DD:...

# Generate public key pin for mobile apps
openssl x509 -in server.crt -pubkey -noout | \
  openssl pkey -pubin -outform DER | \
  openssl dgst -sha256 -binary | openssl enc -base64
```

---

## 8. 🤖 Automation & Scripting

### Automated Certificate Request & Deployment (Bash)
```bash
#!/bin/bash
# ================================================
# Automated Certificate Rotation Script
# ================================================

set -euo pipefail

# Configuration
DOMAIN="server.example.com"
SANS="DNS:server.example.com,DNS:www.example.com,IP:10.0.0.1"
KEY_SIZE=4096
VALIDITY=365
CA_CONFIG="/root/ca/openssl.cnf"
CA_CERT="/root/ca/certs/ca.cert.pem"
CA_KEY="/root/ca/private/ca.key.pem"
CERT_DIR="/etc/ssl/certs"
KEY_DIR="/etc/ssl/private"
BACKUP_DIR="/etc/ssl/backup/$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/var/log/cert_rotation.log"
SERVICES=("nginx" "postfix" "dovecot")

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

# Step 1: Pre-flight checks
log "Starting certificate rotation for $DOMAIN"
if ! openssl x509 -in "$CA_CERT" -noout -checkend 0; then
  log "ERROR: CA certificate is expired! Aborting."
  exit 1
fi

# Step 2: Backup
log "Creating backup in $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp "$CERT_DIR/$DOMAIN.crt" "$BACKUP_DIR/" 2>/dev/null || true
cp "$KEY_DIR/$DOMAIN.key" "$BACKUP_DIR/" 2>/dev/null || true

# Step 3: Generate new key
log "Generating new $KEY_SIZE-bit RSA key"
openssl genrsa -out "$KEY_DIR/${DOMAIN}_new.key" "$KEY_SIZE" 2>/dev/null
chmod 400 "$KEY_DIR/${DOMAIN}_new.key"

# Step 4: Generate CSR
log "Generating CSR with SAN: $SANS"
openssl req -new \
  -key "$KEY_DIR/${DOMAIN}_new.key" \
  -out "/tmp/${DOMAIN}_new.csr" \
  -subj "/C=US/ST=State/L=City/O=MyOrg/CN=$DOMAIN" \
  -addext "subjectAltName=$SANS"

# Step 5: Sign certificate
log "Signing certificate with CA"
openssl x509 -req \
  -in "/tmp/${DOMAIN}_new.csr" \
  -CA "$CA_CERT" \
  -CAkey "$CA_KEY" \
  -CAcreateserial \
  -out "$CERT_DIR/${DOMAIN}_new.crt" \
  -days "$VALIDITY" \
  -sha256 \
  -extfile <(printf "subjectAltName=$SANS")

# Step 6: Validate
log "Validating new certificate"
KEY_MOD=$(openssl rsa -noout -modulus -in "$KEY_DIR/${DOMAIN}_new.key" | openssl md5)
CERT_MOD=$(openssl x509 -noout -modulus -in "$CERT_DIR/${DOMAIN}_new.crt" | openssl md5)
if [ "$KEY_MOD" != "$CERT_MOD" ]; then
  log "ERROR: Key and certificate modulus mismatch! Aborting."
  exit 1
fi
log "✅ Key and certificate match"

openssl verify -CAfile "$CA_CERT" "$CERT_DIR/${DOMAIN}_new.crt"
log "✅ Certificate chain validated"

# Step 7: Swap certificates
log "Swapping old certificate with new one"
mv "$CERT_DIR/$DOMAIN.crt" "$CERT_DIR/$DOMAIN.crt.old" 2>/dev/null || true
mv "$KEY_DIR/$DOMAIN.key" "$KEY_DIR/$DOMAIN.key.old" 2>/dev/null || true
mv "$CERT_DIR/${DOMAIN}_new.crt" "$CERT_DIR/$DOMAIN.crt"
mv "$KEY_DIR/${DOMAIN}_new.key" "$KEY_DIR/$DOMAIN.key"

# Step 8: Restart services
for service in "${SERVICES[@]}"; do
  if systemctl is-active --quiet "$service"; then
    log "Reloading $service"
    systemctl reload "$service" 2>/dev/null || systemctl restart "$service"
    log "✅ $service reloaded successfully"
  else
    log "⚠️  $service is not running, skipping"
  fi
done

# Step 9: Post-deployment verification
sleep 2
log "Verifying live certificate"
LIVE_SERIAL=$(echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -serial)
NEW_SERIAL=$(openssl x509 -in "$CERT_DIR/$DOMAIN.crt" -noout -serial)
if [ "$LIVE_SERIAL" = "$NEW_SERIAL" ]; then
  log "✅ Live certificate matches new certificate"
else
  log "❌ WARNING: Live certificate does NOT match! Rolling back..."
  mv "$CERT_DIR/$DOMAIN.crt.old" "$CERT_DIR/$DOMAIN.crt"
  mv "$KEY_DIR/$DOMAIN.key.old" "$KEY_DIR/$DOMAIN.key"
  for service in "${SERVICES[@]}"; do
    systemctl reload "$service" 2>/dev/null || true
  done
  log "Rollback complete"
  exit 1
fi

# Step 10: Cleanup
rm -f "/tmp/${DOMAIN}_new.csr"
log "🎉 Certificate rotation completed successfully for $DOMAIN"
```

### PowerShell — Automated Rotation with Email Alerts
```powershell
# ================================================
# Automated Certificate Monitoring & Alert Script
# ================================================

param(
    [int]$WarningDays = 30,
    [int]$CriticalDays = 7,
    [string]$SmtpServer = "smtp.example.com",
    [string]$AlertEmail = "pki-admin@example.com"
)

$report = @()
$alertsNeeded = $false

# Check local machine certificates
$stores = @("My", "WebHosting", "Root")
foreach ($store in $stores) {
    Get-ChildItem "Cert:\LocalMachine\$store" | ForEach-Object {
        $daysLeft = ($_.NotAfter - (Get-Date)).Days
        $severity = if ($daysLeft -lt 0) { "EXPIRED" }
                    elseif ($daysLeft -lt $CriticalDays) { "CRITICAL" }
                    elseif ($daysLeft -lt $WarningDays) { "WARNING" }
                    else { "OK" }

        if ($severity -ne "OK") { $alertsNeeded = $true }

        $report += [PSCustomObject]@{
            Store      = $store
            Subject    = $_.Subject
            Thumbprint = $_.Thumbprint
            Expires    = $_.NotAfter
            DaysLeft   = $daysLeft
            Severity   = $severity
        }
    }
}

# Check remote servers
$remoteHosts = @(
    @{Host="web.example.com"; Port=443},
    @{Host="mail.example.com"; Port=993},
    @{Host="ldap.example.com"; Port=636}
)

foreach ($remote in $remoteHosts) {
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient($remote.Host, $remote.Port)
        $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, { $true })
        $sslStream.AuthenticateAsClient($remote.Host)
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)

        $daysLeft = ($cert.NotAfter - (Get-Date)).Days
        $severity = if ($daysLeft -lt 0) { "EXPIRED" }
                    elseif ($daysLeft -lt $CriticalDays) { "CRITICAL" }
                    elseif ($daysLeft -lt $WarningDays) { "WARNING" }
                    else { "OK" }

        if ($severity -ne "OK") { $alertsNeeded = $true }

        $report += [PSCustomObject]@{
            Store      = "Remote:$($remote.Host):$($remote.Port)"
            Subject    = $cert.Subject
            Thumbprint = $cert.Thumbprint
            Expires    = $cert.NotAfter
            DaysLeft   = $daysLeft
            Severity   = $severity
        }
        $sslStream.Close()
        $tcpClient.Close()
    } catch {
        $report += [PSCustomObject]@{
            Store      = "Remote:$($remote.Host):$($remote.Port)"
            Subject    = "CONNECTION FAILED"
            Thumbprint = "N/A"
            Expires    = "N/A"
            DaysLeft   = -999
            Severity   = "ERROR"
        }
    }
}

# Generate HTML report
$htmlBody = $report | ConvertTo-Html -Title "PKI Certificate Report" -PreContent "<h2>Certificate Health Report - $(Get-Date)</h2>"

# Send alert email if needed
if ($alertsNeeded) {
    $alertCerts = $report | Where-Object { $_.Severity -in @("EXPIRED", "CRITICAL", "WARNING") }
    Send-MailMessage -From "pki-monitor@example.com" -To $AlertEmail `
        -Subject "⚠️ PKI Alert: Certificates Expiring" `
        -Body ($alertCerts | Out-String) `
        -SmtpServer $SmtpServer
}

# Output report
$report | Sort-Object DaysLeft | Format-Table -AutoSize
```

---

## 9. 🌐 Vendor-Specific Advanced Commands

### Cisco — Advanced PKI
```
! === Certificate-Based Authentication for VPN ===
crypto ikev2 profile CERT-PROFILE
  match identity remote fqdn domain example.com
  identity local fqdn router1.example.com
  authentication remote rsa-sig
  authentication local rsa-sig
  pki trustpoint MY-TRUSTPOINT
  dpd 10 2 periodic

! === Cross-Certification (Trust Another CA) ===
crypto pki trustpoint PARTNER-CA
  enrollment terminal
  revocation-check crl
  crl query http://pki.partner.com/crl/partner.crl

crypto pki authenticate PARTNER-CA
! (paste partner CA certificate)

! === Certificate Map (Match Specific Certs) ===
crypto pki certificate map CERT-MAP 1
  subject-name co "O=MyOrg"
  issuer-name eq "CN=MY-CA"

! === EST (Enrollment over Secure Transport) ===
crypto pki trustpoint EST-TRUSTPOINT
  enrollment profile EST-PROFILE

crypto pki profile enrollment EST-PROFILE
  enrollment url https://est.example.com:443/.well-known/est
  authentication url https://est.example.com:443/.well-known/est

! === Monitor PKI events ===
debug crypto pki transactions
debug crypto pki messages
debug crypto pki validation

! === Show commands for troubleshooting ===
show crypto pki certificates
show crypto pki trustpoints status
show crypto pki server
show crypto pki server requests
show crypto pki timers
show crypto ca certificates
show crypto key mypubkey rsa
```

### Palo Alto — Advanced PKI
```
# === SSL/TLS Decryption Certificate Management ===

# Create a forward trust CA for SSL decryption
> request certificate generate ca yes certificate-name "SSL-Decrypt-CA" \
    name "SSL Decryption CA" algorithm RSA rsa-nbits 2048 digest sha256 \
    days-till-expiry 1825

# Configure SSL decryption profile
> configure
# set shared ssl-decrypt forward-trust-certificate-rsa "SSL-Decrypt-CA"
# set shared ssl-decrypt forward-untrust-certificate-rsa "SSL-Untrust-Cert"

# === Certificate-Based Admin Authentication ===
# set shared certificate-profile "admin-cert-profile" CA "Root-CA" use-crl yes use-ocsp yes
# set deviceconfig system certificate-profile "admin-cert-profile"

# === GlobalProtect Certificate-Based Auth ===
# set network tunnel global-protect-gateway GP-GW client-auth certificate-profile "gp-cert-profile"

# === Troubleshooting ===
> debug sslmgr view cert certificate-name "server-cert"
> debug sslmgr view stats
> show system certificate-associations
> test certificate-profile "my-profile" certificate "test-cert"

# === Bulk Certificate Operations ===
> request batch certificate-import format pem certificate-folder /tmp/certs/
```

### FortiGate — Advanced PKI
```
# === SCEP (Simple Certificate Enrollment Protocol) ===
config certificate local
  edit "scep-cert"
    set enroll-protocol scep
    set scep-url "http://scep.example.com/certsrv/mscep/mscep.dll"
    set scep-password "SCEPChallenge123"
  next
end

# === CMP (Certificate Management Protocol) ===
config certificate local
  edit "cmp-cert"
    set enroll-protocol cmp
    set cmp-server "cmp.example.com"
    set cmp-path "/cmp"
  next
end

# === Certificate-Based VPN Authentication ===
config vpn ipsec phase1-interface
  edit "VPN-PKI"
    set type static
    set interface "wan1"
    set peertype any
    set proposal aes256-sha256
    set certificate "server-cert"
    set authmethod signature
    set peer "Remote-Peer"
    set peergrp "VPN-Peer-Group"
  next
end

# === FortiToken PKI Certificates ===
config user certificate
  edit "user-cert-ca"
    set ca "Root-CA"
    set type ca
  next
end

# === Deep Inspection CA Certificate Deployment ===
# Export the FortiGate CA cert for GPO distribution
execute certificate local export tftp "Fortinet_CA_SSL" fortinet_ca.cer 10.0.0.100

# === Diagnostics ===
diagnose vpn ike log-filter dst-addr4 <peer_ip>
diagnose debug application fnbamd -1
diagnose certificate local list detailed
diagnose certificate ca list detailed
diagnose certificate crl list
```

### F5 BIG-IP — Advanced PKI
```bash
# === Certificate Bundle Management ===
# Create a certificate bundle (for trusted CAs)
tmsh create sys crypto cert-bundle my-ca-bundle certs add { root-ca.crt intermediate-ca.crt }

# === OCSP Configuration ===
tmsh create sys crypto cert-ocsp my-ocsp \
  cert my-ocsp-cert.crt \
  key my-ocsp-key.key \
  responder-url http://ocsp.example.com \
  sign-hash sha256

# === Certificate Monitoring via iCall ===
# Create an iCall script to monitor certificate expiry
tmsh create sys icall script cert-monitor {
  definition {
    set certs [tmsh::get_config /sys crypto cert]
    foreach cert $certs {
      # Parse and check expiry
      set expiry [tmsh::get_field_value $cert expiration-string]
      # Alert if expiring within 30 days
    }
  }
}

# Create periodic handler (runs daily)
tmsh create sys icall handler periodic cert-monitor-handler \
  interval 86400 \
  script cert-monitor

# === Certificate Stapling (OCSP Stapling) ===
tmsh modify ltm profile client-ssl my-clientssl \
  ocsp-stapling enabled \
  cert-lookup-by-ipaddr-port disabled

# === Client Certificate Authentication ===
tmsh modify ltm profile client-ssl my-clientssl \
  client-cert-ca ca-bundle.crt \
  peer-cert-mode require \
  authenticate always \
  retain-certificate true

# === iControl REST API Certificate Operations ===
# List all certificates via REST
curl -sk -u admin:password https://localhost/mgmt/tm/sys/crypto/cert | jq '.items[].name'

# Upload and install certificate via REST
curl -sk -u admin:password \
  -X POST https://localhost/mgmt/shared/file-transfer/uploads/new_cert.pem \
  -H "Content-Type: application/octet-stream" \
  --data-binary @new_cert.pem

curl -sk -u admin:password \
  -X POST https://localhost/mgmt/tm/sys/crypto/cert \
  -H "Content-Type: application/json" \
  -d '{"command":"install","name":"new_cert.crt","from-local-file":"/var/config/rest/downloads/new_cert.pem"}'
```

---

## 10. 📱 Modern PKI Protocols & Tools

### ACME Protocol (Beyond Let's Encrypt)
```bash
# === Using acme.sh (alternative to certbot) ===

# Install acme.sh
curl https://get.acme.sh | sh

# Issue cert with DNS-01 challenge (Cloudflare example)
export CF_Token="your_cloudflare_api_token"
acme.sh --issue --dns dns_cf -d example.com -d "*.example.com"

# Issue with HTTP-01 challenge
acme.sh --issue -d example.com -w /var/www/html

# Deploy to Nginx
acme.sh --install-cert -d example.com \
  --key-file /etc/nginx/ssl/key.pem \
  --fullchain-file /etc/nginx/ssl/fullchain.pem \
  --reloadcmd "systemctl reload nginx"

# Deploy to Apache
acme.sh --install-cert -d example.com \
  --cert-file /etc/apache2/ssl/cert.pem \
  --key-file /etc/apache2/ssl/key.pem \
  --fullchain-file /etc/apache2/ssl/fullchain.pem \
  --reloadcmd "systemctl reload apache2"

# Revoke a certificate
acme.sh --revoke -d example.com

# Use a different ACME CA (e.g., ZeroSSL, BuyPass, Google)
acme.sh --set-default-ca --server zerossl
acme.sh --set-default-ca --server buypass
acme.sh --set-default-ca --server google
```

### EST (Enrollment over Secure Transport)
```bash
# Request a certificate via EST
curl --cacert ca.pem \
  --cert client.pem --key client.key \
  https://est.example.com/.well-known/est/simpleenroll \
  -H "Content-Type: application/pkcs10" \
  --data-binary @server.csr \
  -o new_cert.p7

# Get CA certificates via EST
curl --cacert ca.pem \
  https://est.example.com/.well-known/est/cacerts \
  -o ca_certs.p7

# Convert EST response (PKCS7) to PEM
openssl pkcs7 -in new_cert.p7 -inform DER -print_certs -out new_cert.pem
```

### CMPv2 (Certificate Management Protocol)
```bash
# Request a certificate via CMP (using OpenSSL 3.x)
openssl cmp -cmd ir \
  -server cmp.example.com:8080 \
  -path /cmp \
  -ref "MyReference" \
  -secret "pass:SharedSecret" \
  -newkey server.key \
  -subject "/CN=server.example.com/O=MyOrg" \
  -certout new_cert.pem \
  -cacertsout ca_chain.pem

# Renew (Key Update Request)
openssl cmp -cmd kur \
  -server cmp.example.com:8080 \
  -cert current_cert.pem \
  -key current_key.pem \
  -newkey new_key.pem \
  -certout renewed_cert.pem

# Revoke via CMP
openssl cmp -cmd rr \
  -server cmp.example.com:8080 \
  -cert cert_to_revoke.pem \
  -key key.pem \
  -revreason keyCompromise
```

---

## 11. 📊 PKI Inventory & Compliance Dashboard Script

```bash
#!/bin/bash
# ================================================
# PKI Infrastructure Inventory & Compliance Report
# ================================================

OUTPUT="/tmp/pki_inventory_$(date +%Y%m%d).html"

cat > "$OUTPUT" << 'HEADER'
<!DOCTYPE html>
<html><head><title>PKI Inventory Report</title>
<style>
  body { font-family: Arial; margin: 20px; }
  table { border-collapse: collapse; width: 100%; margin-bottom: 30px; }
  th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
  th { background-color: #4472C4; color: white; }
  .expired { background-color: #FF6B6B; }
  .critical { background-color: #FFA500; }
  .warning { background-color: #FFD93D; }
  .ok { background-color: #6BCB77; }
  h1 { color: #2C3E50; }
  h2 { color: #4472C4; border-bottom: 2px solid #4472C4; }
  .summary { display: flex; gap: 20px; margin-bottom: 20px; }
  .stat-box { padding: 15px; border-radius: 8px; color: white; text-align: center; min-width: 120px; }
</style></head><body>
<h1>🔐 PKI Infrastructure Inventory Report</h1>
<p>Generated: $(date)</p>
HEADER

echo "<h2>Certificate Inventory</h2>" >> "$OUTPUT"
echo "<table><tr><th>Host</th><th>Port</th><th>Subject</th><th>Issuer</th><th>Serial</th><th>Key Size</th><th>Sig Algo</th><th>Not Before</th><th>Not After</th><th>Days Left</th><th>Status</th></tr>" >> "$OUTPUT"

# Scan hosts
HOSTS="web.example.com:443 mail.example.com:993 api.example.com:8443"
TOTAL=0; EXPIRED=0; CRITICAL=0; WARNING=0; OK=0

for HOST_PORT in $HOSTS; do
  HOST=$(echo "$HOST_PORT" | cut -d: -f1)
  PORT=$(echo "$HOST_PORT" | cut -d: -f2)
  TOTAL=$((TOTAL+1))

  CERT_DATA=$(echo | timeout 5 openssl s_client -connect "$HOST_PORT" -servername "$HOST" 2>/dev/null)
  if [ $? -eq 0 ] && echo "$CERT_DATA" | openssl x509 -noout 2>/dev/null; then
    SUBJECT=$(echo "$CERT_DATA" | openssl x509 -noout -subject | sed 's/subject=//')
    ISSUER=$(echo "$CERT_DATA" | openssl x509 -noout -issuer | sed 's/issuer=//')
    SERIAL=$(echo "$CERT_DATA" | openssl x509 -noout -serial | sed 's/serial=//')
    STARTDATE=$(echo "$CERT_DATA" | openssl x509 -noout -startdate | sed 's/notBefore=//')
    ENDDATE=$(echo "$CERT_DATA" | openssl x509 -noout -enddate | sed 's/notAfter=//')
    KEYSIZE=$(echo "$CERT_DATA" | openssl x509 -noout -text | grep "Public-Key" | grep -oP '\d+')
    SIGALG=$(echo "$CERT_DATA" | openssl x509 -noout -text | grep "Signature Algorithm" | head -1 | awk '{print $3}')

    EXPIRY_EPOCH=$(date -d "$ENDDATE" +%s 2>/dev/null)
    NOW_EPOCH=$(date +%s)
    DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

    if [ "$DAYS_LEFT" -lt 0 ]; then STATUS="expired"; EXPIRED=$((EXPIRED+1))
    elif [ "$DAYS_LEFT" -lt 7 ]; then STATUS="critical"; CRITICAL=$((CRITICAL+1))
    elif [ "$DAYS_LEFT" -lt 30 ]; then STATUS="warning"; WARNING=$((WARNING+1))
    else STATUS="ok"; OK=$((OK+1)); fi

    echo "<tr class='$STATUS'><td>$HOST</td><td>$PORT</td><td>$SUBJECT</td><td>$ISSUER</td><td>$SERIAL</td><td>$KEYSIZE</td><td>$SIGALG</td><td>$STARTDATE</td><td>$ENDDATE</td><td>$DAYS_LEFT</td><td>${STATUS^^}</td></tr>" >> "$OUTPUT"
  fi
done

echo "</table>" >> "$OUTPUT"
echo "</body></html>" >> "$OUTPUT"

echo "Report generated: $OUTPUT"
```

---

## 12. 🔧 Troubleshooting Commands Cheat Sheet

```bash
# ============================================
# UNIVERSAL TROUBLESHOOTING COMMANDS
# ============================================

# --- Connection & Handshake Debugging ---
# Full TLS handshake debug
openssl s_client -connect host:443 -servername host -debug -msg

# Test specific TLS version
openssl s_client -connect host:443 -tls1_2
openssl s_client -connect host:443 -tls1_3

# Test specific cipher suite
openssl s_client -connect host:443 -cipher ECDHE-RSA-AES256-GCM-SHA384

# List supported ciphers
openssl ciphers -v 'ALL:eNULL' | column -t

# Test client certificate authentication
openssl s_client -connect host:443 -cert client.crt -key client.key -CAfile ca.crt

# Test STARTTLS protocols
openssl s_client -connect mail:25 -starttls smtp
openssl s_client -connect mail:143 -starttls imap
openssl s_client -connect mail:110 -starttls pop3
openssl s_client -connect ftp:21 -starttls ftp
openssl s_client -connect ldap:389 -starttls ldap
openssl s_client -connect xmpp:5222 -starttls xmpp

# --- Certificate Debugging ---
# Decode a certificate fully
openssl x509 -in cert.pem -text -noout

# Decode a CSR fully
openssl req -in request.csr -text -noout

# Decode a CRL fully
openssl crl -in crl.pem -text -noout

# Decode a PKCS#12 file
openssl pkcs12 -in cert.pfx -info -noout

# Decode a PKCS#7 file
openssl pkcs7 -in cert.p7b -print_certs -text

# Decode ASN.1 structure
openssl asn1parse -in cert.pem

# --- Common Error Solutions ---
# "unable to get local issuer certificate"
# → Missing intermediate CA certificate in chain

# "certificate has expired"
# → Certificate end date has passed

# "self signed certificate in certificate chain"
# → Root CA not in trust store

# "certificate signature failure"
# → Certificate tampered or wrong CA

# "unable to verify the first certificate"
# → Server not sending intermediate certificates

# --- Verify Everything Matches ---
echo "Certificate Modulus Hash:"
openssl x509 -noout -modulus -in cert.pem | openssl md5

echo "Key Modulus Hash:"
openssl rsa -noout -modulus -in key.pem | openssl md5

echo "CSR Modulus Hash:"
openssl req -noout -modulus -in csr.pem | openssl md5
# All three should match!
```

---

## 13. 📋 PKI Best Practices Reference

| Area | Recommendation |
|------|---------------|
| **Key Algorithm** | RSA 2048+ or ECC P-256/P-384 (prefer ECC for performance) |
| **Signature Hash** | SHA-256 minimum, SHA-384/512 for high security |
| **Root CA Lifetime** | 15–25 years, kept OFFLINE |
| **Intermediate CA Lifetime** | 5–10 years |
| **End-Entity Cert Lifetime** | 90 days–1 year (shorter is better) |
| **CRL Refresh** | Every 24 hours minimum |
| **OCSP Response** | Cache for max 4 hours |
| **Key Storage** | HSM for CA keys, encrypted storage for server keys |
| **Backup** | Encrypted offline backup of CA keys, tested quarterly |
| **Monitoring** | Alert at 90, 60, 30, 14, 7, and 1 day(s) before expiry |
| **Audit Logging** | Log all issuance, revocation, and key generation events |
| **Name Constraints** | Use on Intermediate CAs to limit scope |
| **Certificate Pinning** | Pin at app level with backup pin and rotation plan |
| **CT Logging** | Mandatory for public certificates, monitor for rogue certs |
| **Auto-Renewal** | Enable wherever possible (ACME, auto-enroll, ACM) |
| **Key Rotation** | Generate new keys with each certificate renewal |
| **Dual-Key** | Maintain backup keys/certs for disaster recovery |
| **Network Segmentation** | Isolate CA infrastructure on separate network segment |
| **Multi-Person Control** | Require M-of-N authorization for CA key operations |

---

> 💡 **Key Takeaways:**
> - **Automate everything** — manual certificate management doesn't scale
> - **Monitor proactively** — don't discover expired certs from outage tickets
> - **Test revocation** — CRL/OCSP infrastructure is often neglected until needed
> - **Document your PKI** — maintain a certificate inventory and CA hierarchy diagram
> - **Practice DR** — regularly test CA backup/restore procedures
> - **Stay current** — migrate away from SHA-1, weak keys, and TLS < 1.2
> - **Use short-lived certs** — reduces exposure window if compromised (90 days ideal)
> - **Certificate Transparency** — monitor CT logs for unauthorized issuance against your domains

### USER
Suggest me free homelab projects related to PKI

### ASSISTANT
# 🏠 Free Homelab PKI Projects

Here's a comprehensive list of hands-on PKI projects you can build in your homelab using entirely free and open-source tools.

---

## 📋 Project Overview Map

```
┌─────────────────────────────────────────────────────────────────────┐
│                    🏠 HOMELAB PKI PROJECT ROADMAP                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  BEGINNER          INTERMEDIATE           ADVANCED                  │
│  ────────          ────────────           ────────                  │
│                                                                     │
│  1. Build a        4. Mutual TLS          8. ACME Server            │
│     Root CA           (mTLS) Lab             (Step-CA)              │
│                                                                     │
│  2. Two-Tier       5. HashiCorp Vault     9. PKI Monitoring         │
│     CA Hierarchy      PKI Engine             Dashboard              │
│                                                                     │
│  3. SSL/TLS for    6. Active Directory    10. Zero Trust with       │
│     Home Services     PKI (AD CS)              Certificates         │
│                                                                     │
│                    7. Kubernetes PKI      11. Certificate            │
│                       with cert-manager       Transparency Log      │
│                                                                     │
│                                           12. HSM Simulation        │
│                                               with SoftHSM          │
│                                                                     │
│                                           13. Automated PKI         │
│                                               Pipeline (CI/CD)      │
│                                                                     │
│                                           14. SCEP/EST/CMP          │
│                                               Protocol Lab          │
│                                                                     │
│                                           15. Code Signing &        │
│                                               Email Encryption      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🟢 BEGINNER PROJECTS

---

### Project 1: Build Your Own Root Certificate Authority

**Goal:** Create a fully functional offline Root CA using OpenSSL

**What You'll Learn:**
- PKI fundamentals and trust hierarchies
- Key generation and certificate signing
- CSR creation and management
- Certificate extensions and policies

**Tools Needed (Free):**
- Any Linux VM (Ubuntu/Debian/CentOS)
- OpenSSL (pre-installed on most Linux distros)

**Lab Architecture:**
```
┌──────────────────────────┐
│   Offline Root CA VM     │
│   (Air-gapped ideally)   │
│                          │
│   - Root CA Key (4096)   │
│   - Root CA Certificate  │
│   - CRL Management       │
│   - Signs Intermediate   │
└──────────┬───────────────┘
           │ Signs
           ▼
┌──────────────────────────┐
│   Test Server VM         │
│                          │
│   - Server Certificate   │
│   - Nginx/Apache HTTPS   │
│   - Browser Trust Test   │
└──────────────────────────┘
```

**Steps to Build:**
```bash
# 1. Create directory structure
mkdir -p ~/myCA/{rootCA,intermediateCA,server}/{certs,crl,csr,newcerts,private}
chmod 700 ~/myCA/rootCA/private ~/myCA/intermediateCA/private

# 2. Initialize CA databases
touch ~/myCA/rootCA/index.txt
echo 1000 > ~/myCA/rootCA/serial
echo 0100 > ~/myCA/rootCA/crlnumber

# 3. Create Root CA openssl.cnf
cat > ~/myCA/rootCA/openssl.cnf << 'EOF'
[ca]
default_ca = CA_default

[CA_default]
dir               = /root/myCA/rootCA
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/private/.rand
private_key       = $dir/private/rootCA.key
certificate       = $dir/certs/rootCA.crt
crlnumber         = $dir/crlnumber
crl               = $dir/crl/rootCA.crl
crl_extensions    = crl_ext
default_crl_days  = 30
default_md        = sha256
name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_strict

[policy_strict]
countryName             = match
stateOrProvinceName     = match
organizationName        = match
commonName              = supplied

[req]
default_bits        = 4096
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256
x509_extensions     = v3_ca

[req_distinguished_name]
countryName                = Country Name
stateOrProvinceName        = State
organizationName           = Organization
commonName                 = Common Name

[v3_ca]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[v3_intermediate_ca]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[server_cert]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[crl_ext]
authorityKeyIdentifier = keyid:always
EOF

# 4. Generate Root CA key and certificate
openssl genrsa -aes256 -out ~/myCA/rootCA/private/rootCA.key 4096
openssl req -config ~/myCA/rootCA/openssl.cnf \
  -key ~/myCA/rootCA/private/rootCA.key \
  -new -x509 -days 7300 -sha256 \
  -extensions v3_ca \
  -out ~/myCA/rootCA/certs/rootCA.crt \
  -subj "/C=US/ST=HomeLab/O=MyHomeLab/CN=HomeLab Root CA"

# 5. Generate a server certificate
openssl genrsa -out ~/myCA/server/private/webserver.key 2048
openssl req -new -key ~/myCA/server/private/webserver.key \
  -out ~/myCA/server/csr/webserver.csr \
  -subj "/C=US/ST=HomeLab/O=MyHomeLab/CN=web.homelab.local"

openssl ca -config ~/myCA/rootCA/openssl.cnf \
  -extensions server_cert -days 365 -notext -md sha256 \
  -in ~/myCA/server/csr/webserver.csr \
  -out ~/myCA/server/certs/webserver.crt

# 6. Deploy to Nginx and test
sudo cp ~/myCA/server/certs/webserver.crt /etc/nginx/ssl/
sudo cp ~/myCA/server/private/webserver.key /etc/nginx/ssl/

# 7. Import Root CA into your browser to trust it
# Copy rootCA.crt to your workstation and import into browser trust store
```

**Bonus Challenges:**
- ☐ Import your Root CA into Windows, macOS, and Linux trust stores
- ☐ Generate certificates for 5 different homelab services
- ☐ Create a CRL and test revocation
- ☐ Set up a web server to serve CRL files
- ☐ Write a script to automate certificate issuance

---

### Project 2: Two-Tier CA Hierarchy (Root + Intermediate)

**Goal:** Build a production-like PKI with offline Root CA and online Intermediate CA

**What You'll Learn:**
- Multi-tier CA architecture
- Certificate chain building
- Intermediate CA constraints
- Proper key separation

**Tools Needed (Free):**
- 2 Linux VMs (1 for Root CA, 1 for Intermediate CA)
- OpenSSL

**Lab Architecture:**
```
┌────────────────────────────┐
│    🔒 OFFLINE ROOT CA       │
│    VM1 (Air-gapped)        │
│                            │
│    Root CA Key (4096-bit)  │
│    Root CA Cert (20 years) │
│    Only powers on to sign  │
│    Intermediate CA certs   │
└──────────┬─────────────────┘
           │ Signs (offline)
           ▼
┌────────────────────────────┐
│    🟢 ONLINE INTERMEDIATE   │
│    VM2 (Issuing CA)        │
│                            │
│    Inter CA Key (4096-bit) │
│    Inter CA Cert (5 years) │
│    Issues server/client    │
│    certificates daily      │
│    Hosts CRL & OCSP        │
├────────────────────────────┤
│    CRL: http://pki/crl     │
│    OCSP: http://pki:2560   │
│    AIA: http://pki/aia     │
└──────────┬─────────────────┘
           │ Issues
           ▼
┌────────────────────────────┐
│    End-Entity Certificates │
│    - Web Servers           │
│    - VPN Gateways          │
│    - Mail Servers          │
│    - Client Authentication │
└────────────────────────────┘
```

**Key Steps:**
```bash
# On Root CA VM (VM1):
# Generate Root CA (same as Project 1)
# Sign the Intermediate CA CSR
# Shut down Root CA VM and store securely

# On Intermediate CA VM (VM2):
# Generate Intermediate CA key
openssl genrsa -aes256 -out intermediate/private/intermediate.key 4096

# Generate CSR (transfer to Root CA for signing)
openssl req -config intermediate/openssl.cnf -new -sha256 \
  -key intermediate/private/intermediate.key \
  -out intermediate/csr/intermediate.csr \
  -subj "/C=US/ST=HomeLab/O=MyHomeLab/CN=HomeLab Intermediate CA"

# After Root CA signs it, build the chain
cat intermediate.crt rootCA.crt > ca-chain.crt

# Now issue end-entity certificates from Intermediate CA
# Set up CRL distribution and OCSP responder
openssl ocsp -port 2560 -index index.txt \
  -CA intermediate.crt -rsigner ocsp.crt -rkey ocsp.key

# Set up Nginx to serve CRL and AIA
# http://pki.homelab.local/crl/intermediate.crl
# http://pki.homelab.local/aia/intermediate.crt
```

**Bonus Challenges:**
- ☐ Simulate Root CA compromise — rebuild from backup
- ☐ Implement path length constraints on Intermediate CA
- ☐ Set up name constraints to limit what domains Intermediate can sign for
- ☐ Create a third tier (Policy CA) between Root and Issuing

---

### Project 3: Secure All Home Services with SSL/TLS

**Goal:** Issue and deploy certificates to every service in your homelab

**What You'll Learn:**
- Real-world certificate deployment
- Different service configurations
- Certificate troubleshooting
- Full-chain trust management

**Services to Secure:**
```
┌─────────────────────────────────────────────────┐
│           Services to Secure with TLS           │
├─────────────────────────────────────────────────┤
│                                                 │
│  🌐 Web Services:                               │
│     - Nginx reverse proxy (443)                 │
│     - Apache web server (443)                   │
│     - Traefik / Caddy                           │
│     - Proxmox Web UI (8006)                     │
│     - Portainer (9443)                          │
│     - Grafana (3000)                            │
│     - Home Assistant (8123)                     │
│                                                 │
│  📧 Mail Services:                               │
│     - Postfix SMTP (465/587)                    │
│     - Dovecot IMAP (993)                        │
│                                                 │
│  🗄️ Database Services:                           │
│     - PostgreSQL (5432)                         │
│     - MySQL/MariaDB (3306)                      │
│     - MongoDB (27017)                           │
│                                                 │
│  📂 File Services:                               │
│     - Nextcloud                                 │
│     - Syncthing                                 │
│     - MinIO (S3-compatible)                     │
│                                                 │
│  🔐 Infrastructure:                              │
│     - OpenVPN / WireGuard                       │
│     - SSH (certificate-based)                   │
│     - LDAPS (OpenLDAP)                          │
│     - Docker Registry (5000)                    │
│     - Pi-hole Admin                             │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Example — Secure Docker Registry:**
```bash
# Generate certificate for Docker Registry
openssl req -new -key registry.key -out registry.csr \
  -subj "/CN=registry.homelab.local" \
  -addext "subjectAltName=DNS:registry.homelab.local,IP:192.168.1.50"

# Sign with your Intermediate CA
openssl ca -config intermediate.cnf -extensions server_cert \
  -in registry.csr -out registry.crt

# Deploy to Docker Registry
docker run -d -p 5000:5000 --name registry \
  -v /certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  registry:2

# Configure Docker daemon to trust your CA
sudo mkdir -p /etc/docker/certs.d/registry.homelab.local:5000
sudo cp ca-chain.crt /etc/docker/certs.d/registry.homelab.local:5000/ca.crt
sudo systemctl restart docker
```

---

## 🟡 INTERMEDIATE PROJECTS

---

### Project 4: Mutual TLS (mTLS) Authentication Lab

**Goal:** Build a system where both client AND server authenticate via certificates

**What You'll Learn:**
- Client certificate generation and management
- Mutual TLS configuration
- Certificate-based access control
- Certificate mapping to user identities

**Tools Needed (Free):**
- Linux VM with Nginx or Apache
- OpenSSL
- Your homelab CA from Project 1 or 2

**Lab Architecture:**
```
┌──────────────────┐          mTLS           ┌──────────────────┐
│   Client Device  │ ◄─────────────────────► │   Nginx Server   │
│                  │                          │                  │
│  client.crt      │  1. Client Hello        │  server.crt      │
│  client.key      │  2. Server Hello +      │  server.key      │
│  ca-chain.crt    │     Server Cert         │  ca-chain.crt    │
│                  │  3. Certificate Request  │                  │
│                  │  4. Client Cert          │  Validates:      │
│                  │  5. Verify Both Sides    │  - Client cert   │
│                  │  6. Encrypted Channel    │  - Client CN     │
│                  │                          │  - Revocation    │
└──────────────────┘                          └──────────────────┘
```

**Build Steps:**
```bash
# === 1. Generate Client Certificate ===
# Generate client key
openssl genrsa -out client.key 2048

# Generate client CSR
openssl req -new -key client.key -out client.csr \
  -subj "/C=US/ST=HomeLab/O=MyHomeLab/OU=Users/CN=john.doe"

# Sign with CA (using client_cert extensions)
openssl ca -config intermediate.cnf -extensions client_cert \
  -days 365 -notext -md sha256 \
  -in client.csr -out client.crt

# Create PKCS#12 for browser import
openssl pkcs12 -export -out john_doe.p12 \
  -inkey client.key -in client.crt -certfile ca-chain.crt \
  -name "John Doe Client Certificate"

# === 2. Configure Nginx for mTLS ===
cat > /etc/nginx/conf.d/mtls.conf << 'EOF'
server {
    listen 443 ssl;
    server_name secure.homelab.local;

    # Server certificate
    ssl_certificate     /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    # Client certificate verification
    ssl_client_certificate /etc/nginx/ssl/ca-chain.crt;
    ssl_verify_client on;
    ssl_verify_depth 2;

    # Optional: CRL checking
    ssl_crl /etc/nginx/ssl/intermediate.crl;

    # Pass client cert info to application
    location / {
        proxy_set_header X-Client-CN $ssl_client_s_dn_cn;
        proxy_set_header X-Client-Serial $ssl_client_serial;
        proxy_set_header X-Client-Verify $ssl_client_verify;

        # Only allow specific CNs
        if ($ssl_client_s_dn_cn !~ "^(john\.doe|jane\.smith|admin)$") {
            return 403;
        }

        root /var/www/secure;
        index index.html;
    }
}
EOF

# === 3. Test mTLS Connection ===
# With client certificate (should succeed)
curl --cacert ca-chain.crt --cert client.crt --key client.key \
  https://secure.homelab.local

# Without client certificate (should fail)
curl --cacert ca-chain.crt https://secure.homelab.local
# Expected: 400 Bad Request - No required SSL certificate was sent
```

**Bonus Challenges:**
- ☐ Map client certificates to different authorization levels
- ☐ Set up mTLS for a microservices environment (service-to-service)
- ☐ Implement certificate-based SSH authentication
- ☐ Revoke a client certificate and verify access is denied
- ☐ Build an mTLS-protected API with client cert header forwarding

---

### Project 5: HashiCorp Vault PKI Secrets Engine

**Goal:** Deploy Vault as an automated certificate authority with API-driven issuance

**What You'll Learn:**
- Dynamic secret management
- Short-lived certificates
- API-driven PKI operations
- Role-based certificate issuance
- Auto-rotation of certificates

**Tools Needed (Free):**
- HashiCorp Vault (open source)
- Linux VM or Docker
- Optional: Consul for storage backend

**Lab Architecture:**
```
┌───────────────────────────────────────────────────────┐
│                  HashiCorp Vault                       │
│                                                       │
│  ┌─────────────┐    ┌─────────────┐    ┌───────────┐ │
│  │  Root PKI    │───►│ Inter PKI   │───►│ Roles     │ │
│  │  Engine      │    │ Engine      │    │           │ │
│  │             │    │             │    │ web-role  │ │
│  │ pki/        │    │ pki_int/    │    │ api-role  │ │
│  │             │    │             │    │ client    │ │
│  └─────────────┘    └──────┬──────┘    └─────┬─────┘ │
│                            │                 │       │
│                     Issues Certificates      │       │
│                     via API / CLI            │       │
└────────────────────────────┼─────────────────┼───────┘
                             │                 │
              ┌──────────────┴──────┐    ┌─────┴──────┐
              │   Web Servers       │    │  API Apps   │
              │   (auto-rotation)   │    │  (dynamic) │
              └─────────────────────┘    └────────────┘
```

**Build Steps:**
```bash
# === 1. Install Vault ===
# Docker method
docker run -d --name vault \
  --cap-add=IPC_LOCK \
  -p 8200:8200 \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=homelab-root-token' \
  -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
  hashicorp/vault:latest

export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='homelab-root-token'

# === 2. Enable Root PKI Engine ===
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki

# Generate Root CA
vault write -format=json pki/root/generate/internal \
  common_name="HomeLab Root CA" \
  issuer_name="homelab-root" \
  ttl=87600h > root_ca.json

# Extract Root CA certificate
cat root_ca.json | jq -r '.data.certificate' > root_ca.crt

# Configure CA and CRL URLs
vault write pki/config/urls \
  issuing_certificates="http://vault.homelab.local:8200/v1/pki/ca" \
  crl_distribution_points="http://vault.homelab.local:8200/v1/pki/crl"

# === 3. Enable Intermediate PKI Engine ===
vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int

# Generate Intermediate CSR
vault write -format=json pki_int/intermediate/generate/internal \
  common_name="HomeLab Intermediate CA" \
  issuer_name="homelab-intermediate" > intermediate_csr.json

# Sign with Root CA
vault write -format=json pki/root/sign-intermediate \
  csr="$(cat intermediate_csr.json | jq -r '.data.csr')" \
  format=pem_bundle \
  ttl=43800h > signed_intermediate.json

# Set the signed certificate
vault write pki_int/intermediate/set-signed \
  certificate="$(cat signed_intermediate.json | jq -r '.data.certificate')"

# === 4. Create Roles (Certificate Templates) ===
# Web server role (short-lived: 30 days)
vault write pki_int/roles/web-servers \
  allowed_domains="homelab.local" \
  allow_subdomains=true \
  allow_bare_domains=false \
  max_ttl=720h \
  key_type=rsa \
  key_bits=2048 \
  require_cn=true \
  server_flag=true \
  client_flag=false

# Client certificate role
vault write pki_int/roles/client-certs \
  allowed_domains="homelab.local" \
  allow_any_name=true \
  max_ttl=720h \
  key_type=rsa \
  key_bits=2048 \
  server_flag=false \
  client_flag=true \
  email_protection_flag=true

# Short-lived certificates role (24 hours - great for microservices)
vault write pki_int/roles/ephemeral-certs \
  allowed_domains="homelab.local,service.consul" \
  allow_subdomains=true \
  max_ttl=24h \
  key_type=ec \
  key_bits=256 \
  generate_lease=true

# === 5. Issue Certificates ===
# Issue a web server certificate
vault write -format=json pki_int/issue/web-servers \
  common_name="web.homelab.local" \
  alt_names="www.homelab.local" \
  ip_sans="192.168.1.10" \
  ttl=720h > web_cert.json

# Extract certificate, key, and chain
cat web_cert.json | jq -r '.data.certificate' > web.crt
cat web_cert.json | jq -r '.data.private_key' > web.key
cat web_cert.json | jq -r '.data.ca_chain[]' > ca-chain.crt

# Issue a client certificate
vault write -format=json pki_int/issue/client-certs \
  common_name="john.doe@homelab.local" \
  ttl=720h > client_cert.json

# === 6. Revoke & Tidy ===
# Revoke a certificate
vault write pki_int/revoke serial_number="$(cat web_cert.json | jq -r '.data.serial_number')"

# Tidy the certificate store
vault write pki_int/tidy \
  tidy_cert_store=true \
  tidy_revoked_certs=true \
  safety_buffer=72h

# === 7. Create Policies for Automation ===
vault policy write web-team - << EOF
path "pki_int/issue/web-servers" {
  capabilities = ["create", "update"]
}
path "pki_int/sign/web-servers" {
  capabilities = ["create", "update"]
}
EOF

# Create a token for the web team
vault token create -policy=web-team -ttl=8760h
```

**Bonus Challenges:**
- ☐ Set up Vault auto-unseal with a second Vault instance
- ☐ Integrate Vault with Consul for service mesh mTLS
- ☐ Build a script that auto-rotates Nginx certs from Vault
- ☐ Set up Vault Agent for automatic certificate renewal
- ☐ Create different roles for different teams/environments
- ☐ Integrate with LDAP/AD for authentication

---

### Project 6: Active Directory Certificate Services (AD CS) Lab

**Goal:** Build a full Microsoft PKI environment with auto-enrollment

**What You'll Learn:**
- Enterprise PKI in Windows environments
- Auto-enrollment via Group Policy
- Certificate templates
- NDES/SCEP for network devices

**Tools Needed (Free):**
- Windows Server Evaluation (180 days free)
- Windows 10/11 VM (for client testing)
- VirtualBox or Proxmox (free hypervisors)

**Lab Architecture:**
```
┌──────────────────────────────┐
│  DC01 - Domain Controller    │
│  + Offline Root CA           │
│  Windows Server 2022 Eval    │
│                              │
│  Roles:                      │
│  - AD DS                     │
│  - AD CS (Root CA)           │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────┐
│  CA01 - Issuing CA           │
│  Windows Server 2022 Eval    │
│                              │
│  Roles:                      │
│  - AD CS (Enterprise Sub CA) │
│  - NDES (SCEP)               │
│  - Web Enrollment             │
│  - OCSP Responder            │
└──────────┬───────────────────┘
           │ Auto-enrolls
           ▼
┌──────────────────────────────┐
│  WIN-CLIENT                  │
│  Windows 10/11               │
│                              │
│  - Auto-enrolled user cert   │
│  - Auto-enrolled machine cert│
│  - Smart card logon test     │
│  - EFS encryption test       │
└──────────────────────────────┘
```

**Key Steps:**
```powershell
# === On DC01: Install Root CA ===
Install-WindowsFeature AD-Certificate -IncludeManagementTools
Install-AdcsCertificationAuthority -CAType StandaloneRootCA `
  -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
  -KeyLength 4096 -HashAlgorithmName SHA256 `
  -ValidityPeriod Years -ValidityPeriodUnits 20 `
  -CACommonName "HomeLab Root CA"

# === On CA01: Install Enterprise Subordinate CA ===
Install-WindowsFeature AD-Certificate, ADCS-Web-Enrollment, ADCS-Online-Cert -IncludeManagementTools
Install-AdcsCertificationAuthority -CAType EnterpriseSubordinateCA `
  -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
  -KeyLength 4096 -HashAlgorithmName SHA256 `
  -CACommonName "HomeLab Issuing CA"

Install-AdcsWebEnrollment
Install-AdcsOnlineResponder

# === Configure Auto-Enrollment GPO ===
# Group Policy: Computer Config → Policies → Windows Settings →
# Security Settings → Public Key Policies → Certificate Services Client -
# Auto-Enrollment → Enabled

# === Configure NDES for Network Devices ===
Install-AdcsNetworkDeviceEnrollmentService -ServiceAccountName "HOMELAB\NDESSvc" `
  -ServiceAccountPassword (ConvertTo-SecureString "P@ss" -AsPlainText -Force) `
  -CAConfig "CA01.homelab.local\HomeLab Issuing CA"

# === Create Custom Certificate Templates ===
# Open certtmpl.msc → Duplicate "Web Server" template
# Customize: Key size, validity, auto-enrollment permissions
# Publish template on CA: certsrv.msc → Certificate Templates → New → Template to Issue
```

**Bonus Challenges:**
- ☐ Configure NDES and enroll a Cisco router via SCEP
- ☐ Set up smart card authentication simulation
- ☐ Configure EFS (Encrypted File System) with certificates
- ☐ Set up 802.1X authentication with NPS and certificates
- ☐ Deploy certificates to domain computers via auto-enrollment
- ☐ Configure Key Recovery Agent for key archival

---

### Project 7: Kubernetes PKI with cert-manager

**Goal:** Automate certificate lifecycle in Kubernetes using cert-manager

**What You'll Learn:**
- Kubernetes TLS secrets management
- Automated certificate issuance and renewal
- Ingress TLS configuration
- Integration with multiple CA backends

**Tools Needed (Free):**
- Minikube, K3s, or Kind (free Kubernetes)
- cert-manager (open source)
- kubectl
- Helm

**Lab Architecture:**
```
┌──────────────────────────────────────────────────────┐
│                Kubernetes Cluster                     │
│                                                      │
│  ┌────────────────┐     ┌──────────────────────────┐ │
│  │  cert-manager   │────►│  ClusterIssuer           │ │
│  │  Controller     │     │  (Self-signed / CA /     │ │
│  │                │     │   Vault / ACME)           │ │
│  └───────┬────────┘     └──────────────────────────┘ │
│          │                                           │
│          │ Auto-creates/renews                       │
│          ▼                                           │
│  ┌────────────────┐     ┌──────────────────────────┐ │
│  │  Certificate    │────►│  TLS Secret              │ │
│  │  Resources      │     │  (auto-generated)        │ │
│  └────────────────┘     └──────────┬───────────────┘ │
│                                    │                 │
│                          ┌─────────▼───────────┐     │
│                          │  Ingress / Gateway   │     │
│                          │  (uses TLS secret)   │     │
│                          └─────────────────────┘     │
└──────────────────────────────────────────────────────┘
```

**Build Steps:**
```bash
# === 1. Install K3s (lightweight Kubernetes) ===
curl -sfL https://get.k3s.io | sh -

# === 2. Install cert-manager ===
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
kubectl wait --for=condition=Ready pods -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=120s

# === 3. Create a Self-Signed ClusterIssuer ===
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
EOF

# === 4. Create a CA Issuer (using your homelab CA) ===
# First, create a secret with your CA cert and key
kubectl create secret tls homelab-ca-secret \
  --cert=intermediate.crt \
  --key=intermediate.key \
  -n cert-manager

cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: homelab-ca-issuer
spec:
  ca:
    secretName: homelab-ca-secret
EOF

# === 5. Create a Vault Issuer (if using Vault from Project 5) ===
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: vault-issuer
spec:
  vault:
    path: pki_int/sign/web-servers
    server: http://vault.homelab.local:8200
    auth:
      tokenSecretRef:
        name: vault-token
        key: token
EOF

# === 6. Request a Certificate ===
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: web-app-cert
  namespace: default
spec:
  secretName: web-app-tls
  duration: 720h        # 30 days
  renewBefore: 168h     # Renew 7 days before expiry
  issuerRef:
    name: homelab-ca-issuer
    kind: ClusterIssuer
  commonName: app.homelab.local
  dnsNames:
    - app.homelab.local
    - www.homelab.local
  ipAddresses:
    - 192.168.1.100
  privateKey:
    algorithm: RSA
    size: 2048
EOF

# === 7. Use with Ingress (auto TLS) ===
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-app-ingress
  annotations:
    cert-manager.io/cluster-issuer: "homelab-ca-issuer"
spec:
  tls:
    - hosts:
        - app.homelab.local
      secretName: web-app-tls-auto
  rules:
    - host: app.homelab.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-app
                port:
                  number: 80
EOF

# === 8. Monitor Certificates ===
kubectl get certificates -A
kubectl describe certificate web-app-cert
kubectl get certificaterequests -A
kubectl get secrets web-app-tls -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -text
```

**Bonus Challenges:**
- ☐ Set up ACME issuer with Let's Encrypt staging
- ☐ Configure trust-manager to distribute CA bundles across namespaces
- ☐ Build a Helm chart that auto-requests certificates for each deployment
- ☐ Implement pod-to-pod mTLS using cert-manager + Istio/Linkerd
- ☐ Set up monitoring with Prometheus for certificate expiry alerts

---

## 🔴 ADVANCED PROJECTS

---

### Project 8: ACME Server with Smallstep step-ca

**Goal:** Run your own ACME-compatible CA (like Let's Encrypt, but private)

**What You'll Learn:**
- ACME protocol internals
- Automated certificate lifecycle
- Private ACME infrastructure
- Integration with Certbot and other ACME clients

**Tools Needed (Free):**
- [step-ca](https://smallstep.com/docs/step-ca) (open source)
- [step CLI](https://smallstep.com/docs/step-cli)
- Certbot or acme.sh (as ACME clients)

**Lab Architecture:**
```
┌─────────────────────────────────────────────────────┐
│              Smallstep step-ca Server                │
│                                                     │
│  ┌─────────────┐  ┌────────────┐  ┌──────────────┐ │
│  │ ACME         │  │ JWK        │  │ OIDC         │ │
│  │ Provisioner  │  │ Provisioner│  │ Provisioner  │ │
│  │              │  │            │  │ (Google/SSO) │ │
│  └──────┬───────┘  └─────┬──────┘  └──────┬───────┘ │
│         │                │                │         │
│         └────────────────┼────────────────┘         │
│                          │                          │
│              ┌───────────▼──────────┐               │
│              │  Certificate Engine  │               │
│              │  - Short-lived certs │               │
│              │  - Auto-renewal      │               │
│              │  - Revocation        │               │
│              └──────────────────────┘               │
└───────────────────────┬─────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
  ┌──────────┐   ┌──────────┐   ┌──────────────┐
  │ Certbot   │   │ acme.sh  │   │ cert-manager │
  │ Client    │   │ Client   │   │ (K8s)        │
  └──────────┘   └──────────┘   └──────────────┘
```

**Build Steps:**
```bash
# === 1. Install step CLI and step-ca ===
wget https://dl.smallstep.com/gh-release/cli/docs-cli-install/v0.25.2/step-cli_0.25.2_amd64.deb
sudo dpkg -i step-cli_0.25.2_amd64.deb

wget https://dl.smallstep.com/gh-release/certificates/docs-ca-install/v0.25.2/step-ca_0.25.2_amd64.deb
sudo dpkg -i step-ca_0.25.2_amd64.deb

# === 2. Initialize step-ca ===
step ca init \
  --name="HomeLab ACME CA" \
  --dns="ca.homelab.local" \
  --address=":8443" \
  --provisioner="admin" \
  --deployment-type standalone

# === 3. Add ACME Provisioner ===
step ca provisioner add acme --type ACME

# === 4. Start step-ca ===
step-ca $(step path)/config/ca.json &

# === 5. Bootstrap trust ===
step ca bootstrap --ca-url https://ca.homelab.local:8443 --fingerprint <ROOT_FINGERPRINT>

# Install root CA into system trust store
step certificate install $(step path)/certs/root_ca.crt

# === 6. Use with Certbot (ACME client) ===
sudo REQUESTS_CA_BUNDLE=$(step path)/certs/root_ca.crt \
  certbot certonly --standalone \
  --server https://ca.homelab.local:8443/acme/acme/directory \
  -d web.homelab.local \
  --agree-tos --no-eff-email --email admin@homelab.local

# === 7. Use with acme.sh ===
acme.sh --issue --standalone \
  --server https://ca.homelab.local:8443/acme/acme/directory \
  -d api.homelab.local \
  --ca-bundle $(step path)/certs/root_ca.crt

# === 8. Use with cert-manager in Kubernetes ===
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: step-ca-issuer
spec:
  acme:
    server: https://ca.homelab.local:8443/acme/acme/directory
    privateKeySecretRef:
      name: step-ca-account-key
    caBundle: $(base64 -w0 $(step path)/certs/root_ca.crt)
    solvers:
      - http01:
          ingress:
            class: nginx
EOF

# === 9. Issue a quick certificate via step CLI ===
step ca certificate "app.homelab.local" app.crt app.key \
  --ca-url https://ca.homelab.local:8443 \
  --not-after=24h

# === 10. Renew a certificate ===
step ca renew app.crt app.key --force

# === 11. Set up automatic renewal daemon ===
step ca renew --daemon app.crt app.key \
  --exec "systemctl reload nginx"
```

**Bonus Challenges:**
- ☐ Set up OIDC provisioner (authenticate via Google/GitHub before getting certs)
- ☐ Configure SSH certificate authority with step-ca
- ☐ Build auto-enrollment for all homelab VMs using cloud-init + step
- ☐ Set up step-ca in HA mode with multiple instances
- ☐ Integrate with Nebula mesh networking for certificate-based overlay network

---

### Project 9: PKI Monitoring Dashboard

**Goal:** Build a real-time monitoring dashboard for all certificates in your infrastructure

**What You'll Learn:**
- Certificate metrics and alerting
- Prometheus exporters
- Grafana dashboard creation
- Proactive expiry management

**Tools Needed (Free):**
- Prometheus (open source)
- Grafana (open source)
- x509-certificate-exporter or ssl_exporter
- Alertmanager

**Lab Architecture:**
```
┌─────────────────────────────────────────────────────────────┐
│                   PKI Monitoring Stack                       │
│                                                             │
│  ┌─────────────────┐     ┌──────────────────┐              │
│  │  Prometheus      │◄────│ x509-cert-       │              │
│  │                 │     │ exporter          │              │
│  │  Scrapes every  │     │                  │              │
│  │  5 minutes      │     │ Monitors:        │              │
│  │                 │     │ - Local certs    │              │
│  └────────┬────────┘     │ - Remote hosts   │              │
│           │              │ - Kubernetes     │              │
│           │              │ - File paths     │              │
│           ▼              └──────────────────┘              │
│  ┌─────────────────┐                                       │
│  │  Grafana         │     ┌──────────────────┐              │
│  │  Dashboard       │     │  Alertmanager    │              │
│  │                 │     │                  │              │
│  │  - Expiry       │     │  Alerts via:     │              │
│  │    timeline     │     │  - Email         │              │
│  │  - Key sizes    │     │  - Slack         │              │
│  │  - Algorithms   │     │  - PagerDuty     │              │
│  │  - Issuers      │     │  - Webhook       │              │
│  │  - Chain status │     │                  │              │
│  └─────────────────┘     └──────────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

**Build Steps:**
```bash
# === 1. Deploy with Docker Compose ===
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  x509-exporter:
    image: enix/x509-certificate-exporter:latest
    ports:
      - "9793:9793"
    volumes:
      - /etc/ssl/certs:/certs:ro
      - ./targets.yaml:/targets.yaml:ro
    command:
      - --watch-file=/certs/*.crt
      - --watch-file=/certs/*.pem
      - --trim-path-components=0

  ssl-exporter:
    image: ribbybibby/ssl-exporter:latest
    ports:
      - "9219:9219"

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./alert-rules.yml:/etc/prometheus/alert-rules.yml

  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana

volumes:
  grafana-data:
EOF

# === 2. Prometheus Configuration ===
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 60s
  evaluation_interval: 60s

rule_files:
  - alert-rules.yml

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

scrape_configs:
  - job_name: 'x509-certificates'
    static_configs:
      - targets: ['x509-exporter:9793']

  - job_name: 'ssl-probe'
    metrics_path: /probe
    static_configs:
      - targets:
          - web.homelab.local:443
          - mail.homelab.local:993
          - api.homelab.local:8443
          - vault.homelab.local:8200
          - proxmox.homelab.local:8006
          - grafana.homelab.local:3000
          - nextcloud.homelab.local:443
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: ssl-exporter:9219
EOF

# === 3. Alert Rules ===
cat > alert-rules.yml << 'EOF'
groups:
  - name: certificate-alerts
    rules:
      - alert: CertificateExpiringSoon
        expr: x509_cert_not_after - time() < 30 * 24 * 3600
        for: 1h
        labels:
          severity: warning
        annotations:
          summary: "Certificate expiring within 30 days"
          description: "Certificate {{ $labels.subject }} expires in {{ $value | humanizeDuration }}"

      - alert: CertificateExpiryCritical
        expr: x509_cert_not_after - time() < 7 * 24 * 3600
        for: 1h
        labels:
          severity: critical
        annotations:
          summary: "Certificate expiring within 7 days!"
          description: "CRITICAL: {{ $labels.subject }} expires in {{ $value | humanizeDuration }}"

      - alert: CertificateExpired
        expr: x509_cert_not_after - time() < 0
        for: 0m
        labels:
          severity: critical
        annotations:
          summary: "Certificate has EXPIRED!"
          description: "{{ $labels.subject }} has expired!"

      - alert: CertificateWeakKey
        expr: x509_cert_not_after > 0 and x509_cert_key_size < 2048
        for: 1h
        labels:
          severity: warning
        annotations:
          summary: "Certificate using weak key"
          description: "{{ $labels.subject }} uses {{ $value }}-bit key"

      - alert: SSLProbeExpiringSoon
        expr: ssl_cert_not_after - time() < 30 * 24 * 3600
        for: 1h
        labels:
          severity: warning
        annotations:
          summary: "Remote SSL certificate expiring"
          description: "Certificate on {{ $labels.instance }} expires soon"

      - alert: SSLProbeFailed
        expr: ssl_tls_connect_success == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "SSL/TLS connection failed"
          description: "Cannot establish TLS to {{ $labels.instance }}"
EOF

# === 4. Alertmanager Configuration ===
cat > alertmanager.yml << 'EOF'
global:
  smtp_smarthost: 'smtp.homelab.local:587'
  smtp_from: 'pki-alerts@homelab.local'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 24h
  receiver: 'pki-team'

  routes:
    - match:
        severity: critical
      receiver: 'pki-critical'
      repeat_interval: 1h

receivers:
  - name: 'pki-team'
    email_configs:
      - to: 'admin@homelab.local'
        subject: '⚠️ PKI Alert: {{ .GroupLabels.alertname }}'

  - name: 'pki-critical'
    email_configs:
      - to: 'admin@homelab.local'
        subject: '🔴 CRITICAL PKI Alert: {{ .GroupLabels.alertname }}'
    # webhook_configs:
    #   - url: 'https://hooks.slack.com/services/...'
EOF

# === 5. Start everything ===
docker-compose up -d

# === 6. Import Grafana Dashboard ===
# Navigate to http://grafana.homelab.local:3000
# Import dashboard ID: 13922 (x509 Certificate Exporter)
# Or create custom dashboards with the ssl_* and x509_* metrics
```

---

### Project 10: Zero Trust Network with Certificate-Based Authentication

**Goal:** Build a zero-trust architecture where every connection requires certificate authentication

**What You'll Learn:**
- Zero trust principles
- Service mesh with mTLS
- Network segmentation with certificates
- Identity-based access control

**Tools Needed (Free):**
- WireGuard or Nebula (mesh VPN)
- Istio or Linkerd (service mesh)
- SPIFFE/SPIRE (identity framework)
- step-ca (certificate authority)

**Lab Architecture:**
```
┌──────────────────────────────────────────────────────────────────┐
│                    ZERO TRUST PKI ARCHITECTURE                    │
│                                                                  │
│  ┌──────────┐    SPIFFE IDs     ┌──────────────────┐            │
│  │  SPIRE    │─────────────────►│  Service Identity │            │
│  │  Server   │                  │  spiffe://homelab/ │            │
│  └──────────┘                  │  service/web       │            │
│       │                        └──────────────────┘            │
│       │ Issues SVIDs                                            │
│       ▼                                                         │
│  ┌──────────────────────────────────────────────┐               │
│  │              Service Mesh (Istio)             │               │
│  │                                              │               │
│  │   ┌──────┐  mTLS  ┌──────┐  mTLS  ┌──────┐ │               │
│  │   │Web   │◄──────►│API   │◄──────►│DB    │ │               │
│  │   │Proxy │        │Svc   │        │Proxy │ │               │
│  │   └──────┘        └──────┘        └──────┘ │               │
│  │      ▲                                ▲     │               │
│  │      │           ALL traffic          │     │               │
│  │      │          encrypted with        │     │               │
│  │      │        mutual TLS (mTLS)       │     │               │
│  │      │                                │     │               │
│  └──────┼────────────────────────────────┼─────┘               │
│         │                                │                      │
│  ┌──────┴──────┐                  ┌──────┴──────┐              │
│  │ Nebula Node  │    Encrypted    │ Nebula Node  │              │
│  │ (cert-based  │◄──────────────►│ (cert-based  │              │
│  │  overlay)    │    overlay      │  overlay)    │              │
│  └─────────────┘    network      └─────────────┘              │
└──────────────────────────────────────────────────────────────────┘
```

**Build Steps — Nebula Mesh VPN:**
```bash
# === Nebula: Certificate-Based Overlay Network ===

# 1. Download Nebula
wget https://github.com/slackhq/nebula/releases/download/v1.8.2/nebula-linux-amd64.tar.gz
tar xzf nebula-linux-amd64.tar.gz

# 2. Create Nebula CA
./nebula-cert ca -name "HomeLab Nebula CA" -duration 8760h

# 3. Sign node certificates
./nebula-cert sign -name "lighthouse" -ip "10.42.42.1/24" \
  -groups "infra,lighthouse"
./nebula-cert sign -name "webserver" -ip "10.42.42.10/24" \
  -groups "web,production"
./nebula-cert sign -name "database" -ip "10.42.42.20/24" \
  -groups "database,production"
./nebula-cert sign -name "workstation" -ip "10.42.42.100/24" \
  -groups "users,admin"

# 4. Configure lighthouse node
cat > lighthouse-config.yml << 'EOF'
pki:
  ca: /etc/nebula/ca.crt
  cert: /etc/nebula/lighthouse.crt
  key: /etc/nebula/lighthouse.key
  # blocklist:
  #   - "<fingerprint_of_revoked_cert>"

static_host_map:
  "10.42.42.1": ["<PUBLIC_IP>:4242"]

lighthouse:
  am_lighthouse: true

listen:
  host: 0.0.0.0
  port: 4242

firewall:
  outbound:
    - port: any
      proto: any
      host: any

  inbound:
    # Only web group can access port 443
    - port: 443
      proto: tcp
      groups:
        - web
        - users

    # Only database group internal access
    - port: 5432
      proto: tcp
      groups:
        - database

    # Admin group can access everything
    - port: any
      proto: any
      groups:
        - admin
EOF

# 5. Start Nebula
./nebula -config lighthouse-config.yml

# 6. Revoke a compromised node
# Add the certificate fingerprint to the blocklist in config
# ./nebula-cert print -path compromised_node.crt
# Add fingerprint to pki.blocklist in all configs
```

**Build Steps — SPIFFE/SPIRE:**
```bash
# === SPIFFE/SPIRE: Workload Identity ===

# 1. Install SPIRE Server
wget https://github.com/spiffe/spire/releases/download/v1.9.0/spire-1.9.0-linux-amd64-musl.tar.gz
tar xzf spire-*.tar.gz

# 2. Configure SPIRE Server
cat > server.conf << 'EOF'
server {
    bind_address = "0.0.0.0"
    bind_port = "8081"
    socket_path = "/tmp/spire-server/private/api.sock"
    trust_domain = "homelab.local"
    data_dir = "/opt/spire/data/server"
    log_level = "DEBUG"

    ca_key_type = "ec-p256"
    default_x509_svid_ttl = "1h"
    ca_ttl = "24h"
}

plugins {
    DataStore "sql" {
        plugin_data {
            database_type = "sqlite3"
            connection_string = "/opt/spire/data/server/datastore.sqlite3"
        }
    }
    NodeAttestor "join_token" {
        plugin_data {}
    }
    KeyManager "disk" {
        plugin_data {
            keys_path = "/opt/spire/data/server/keys.json"
        }
    }
}
EOF

# 3. Start SPIRE Server
./spire-server run -config server.conf &

# 4. Create registration entries (workload identities)
./spire-server entry create \
  -spiffeID spiffe://homelab.local/web-frontend \
  -parentID spiffe://homelab.local/spire/agent/join_token/xxx \
  -selector unix:uid:1000

./spire-server entry create \
  -spiffeID spiffe://homelab.local/api-backend \
  -parentID spiffe://homelab.local/spire/agent/join_token/xxx \
  -selector docker:label:app:api

# 5. Workloads automatically get X.509 SVIDs (certificates)
# with identities like: spiffe://homelab.local/web-frontend
```

---

### Project 11: SSH Certificate Authority

**Goal:** Replace SSH key-based authentication with certificate-based authentication

**What You'll Learn:**
- SSH certificate types (user and host)
- Short-lived SSH credentials
- Centralized SSH access management
- No more managing authorized_keys files

**Tools Needed (Free):**
- OpenSSH (built-in)
- step-ca (optional, for automation)

**Lab Architecture:**
```
┌─────────────────────┐
│   SSH CA Server      │
│                     │
│   - User CA Key     │  Signs user certificates
│   - Host CA Key     │  Signs host certificates
│                     │
└──────────┬──────────┘
           │
    ┌──────┴──────┐
    ▼             ▼
┌─────────┐  ┌─────────┐
│ SSH Host │  │  User   │
│ (trusts  │  │ (gets   │
│ User CA) │  │ signed  │
│          │  │ cert)   │
│ Has host │  │         │
│ cert     │  │ No more │
│ signed   │  │ TOFU!   │
│ by Host  │  │         │
│ CA       │  │         │
└─────────┘  └─────────┘
```

**Build Steps:**
```bash
# === 1. Create SSH CA Keys ===
mkdir -p /etc/ssh/ca

# User CA (signs user certificates)
ssh-keygen -t ed25519 -f /etc/ssh/ca/user_ca -C "SSH User CA"

# Host CA (signs host certificates)
ssh-keygen -t ed25519 -f /etc/ssh/ca/host_ca -C "SSH Host CA"

# === 2. Sign Host Certificates ===
# Sign each server's host key
ssh-keygen -s /etc/ssh/ca/host_ca \
  -I "webserver.homelab.local" \
  -h \
  -n "webserver.homelab.local,webserver,192.168.1.10" \
  -V +52w \
  /etc/ssh/ssh_host_ed25519_key.pub

# Configure the host to present the signed certificate
# Add to /etc/ssh/sshd_config on each host:
echo "HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub" >> /etc/ssh/sshd_config
systemctl restart sshd

# === 3. Sign User Certificates ===
# Sign a user's public key with principals (roles)
ssh-keygen -s /etc/ssh/ca/user_ca \
  -I "john.doe@homelab.local" \
  -n "john,admin,webadmin" \
  -V +24h \
  -O source-address=192.168.1.0/24 \
  -O no-port-forwarding \
  ~/.ssh/id_ed25519.pub

# View the certificate
ssh-keygen -L -f ~/.ssh/id_ed25519-cert.pub

# === 4. Configure Hosts to Trust the User CA ===
# Add to /etc/ssh/sshd_config:
echo "TrustedUserCAKeys /etc/ssh/ca/user_ca.pub" >> /etc/ssh/sshd_config

# Map principals to system users
echo 'AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u' >> /etc/ssh/sshd_config

# Create principal mappings
mkdir -p /etc/ssh/auth_principals
echo -e "admin\nwebadmin" > /etc/ssh/auth_principals/root
echo -e "john\nwebadmin" > /etc/ssh/auth_principals/webuser

systemctl restart sshd

# === 5. Configure Clients to Trust the Host CA ===
# Add to ~/.ssh/known_hosts or /etc/ssh/ssh_known_hosts:
echo "@cert-authority *.homelab.local $(cat /etc/ssh/ca/host_ca.pub)" >> ~/.ssh/known_hosts
# Now clients will trust ANY host signed by the Host CA — no more TOFU warnings!

# === 6. Test ===
ssh -i ~/.ssh/id_ed25519 -o CertificateFile=~/.ssh/id_ed25519-cert.pub john@webserver.homelab.local

# === 7. Automate with step-ca (Optional) ===
# Configure step-ca for SSH certificates
step ca init --ssh

# Issue SSH user certificate
step ssh certificate john@homelab.local ~/.ssh/id_ed25519 \
  --principal john --principal admin

# Issue SSH host certificate
step ssh certificate webserver.homelab.local /etc/ssh/ssh_host_ecdsa_key.pub \
  --host --principal webserver.homelab.local --sign

# List SSH certificate authority keys
step ssh config --roots
```

**Bonus Challenges:**
- ☐ Build a web portal for users to request SSH certificates
- ☐ Integrate with OIDC (Google/GitHub) for authentication before signing
- ☐ Set up certificate-based SSH bastion/jump host
- ☐ Create different certificate validity periods based on user role
- ☐ Implement emergency certificate revocation via KRL (Key Revocation List)

---

### Project 12: HSM Simulation with SoftHSM

**Goal:** Learn HSM operations using SoftHSM2 (software-based HSM)

**What You'll Learn:**
- PKCS#11 interface
- Hardware security module concepts
- Key protection and non-exportability
- Integration with OpenSSL and other tools

**Build Steps:**
```bash
# === 1. Install SoftHSM2 ===
sudo apt install softhsm2 opensc libengine-pkcs11-openssl

# === 2. Initialize Tokens ===
softhsm2-util --init-token --slot 0 --label "RootCA-Token" \
  --pin 1234 --so-pin 5678

softhsm2-util --init-token --slot 1 --label "IntermediateCA-Token" \
  --pin 1234 --so-pin 5678

# List slots
softhsm2-util --show-slots

# === 3. Generate Keys Inside the HSM ===
# Generate RSA key pair inside HSM
pkcs11-tool --module /usr/lib/softhsm/libsofthsm2.so \
  --login --pin 1234 \
  --keypairgen --key-type RSA:4096 \
  --id 01 --label "RootCA-Key" \
  --token-label "RootCA-Token"

# List objects in the token
pkcs11-tool --module /usr/lib/softhsm/libsofthsm2.so \
  --login --pin 1234 \
  --list-objects --token-label "RootCA-Token"

# === 4. Use HSM Key with OpenSSL ===
# Configure OpenSSL to use PKCS#11 engine
export OPENSSL_CONF=/etc/ssl/openssl-pkcs11.cnf

cat > /etc/ssl/openssl-pkcs11.cnf << 'EOF'
openssl_conf = openssl_init

[openssl_init]
engines = engine_section

[engine_section]
pkcs11 = pkcs11_section

[pkcs11_section]
engine_id = pkcs11
MODULE_PATH = /usr/lib/softhsm/libsofthsm2.so
init = 0
EOF

# Generate CSR using HSM-stored key
openssl req -engine pkcs11 -new \
  -keyform engine \
  -key "pkcs11:object=RootCA-Key;type=private;pin-value=1234" \
  -out rootCA.csr \
  -subj "/C=US/ST=HomeLab/O=MyHomeLab/CN=HomeLab Root CA (HSM)"

# Self-sign to create Root CA cert
openssl x509 -engine pkcs11 -req \
  -keyform engine \
  -signkey "pkcs11:object=RootCA-Key;type=private;pin-value=1234" \
  -in rootCA.csr \
  -out rootCA.crt \
  -days 7300 -sha256

# === 5. Sign Certificates Using HSM Key ===
openssl x509 -engine pkcs11 -req \
  -keyform engine \
  -CAkey "pkcs11:object=RootCA-Key;type=private;pin-value=1234" \
  -CA rootCA.crt \
  -CAcreateserial \
  -in server.csr \
  -out server.crt \
  -days 365 -sha256

# === 6. Backup and Restore Tokens ===
# Backup (copy the token database files)
cp -r /var/lib/softhsm/tokens/ /backup/softhsm-tokens/

# The key point: in a real HSM, keys are NON-EXPORTABLE
# SoftHSM simulates this behavior for learning purposes
```

---

### Project 13: Automated PKI Pipeline (CI/CD)

**Goal:** Build a GitOps-driven PKI where certificate requests are code-reviewed and auto-deployed

**Tools Needed (Free):**
- Gitea or GitLab CE (self-hosted Git)
- Jenkins or Drone CI (free CI/CD)
- Ansible or Terraform
- Your homelab CA

**Lab Architecture:**
```
┌──────────┐    PR/MR     ┌──────────┐    Trigger    ┌──────────┐
│ Engineer  │────────────►│  Gitea    │──────────────►│ Jenkins  │
│           │             │  (Git)    │               │ (CI/CD)  │
│ Creates   │             │           │               │          │
│ cert      │  Code       │ Review &  │               │ Pipeline:│
│ request   │  Review     │ Approve   │               │ 1. Lint  │
│ YAML      │             │           │               │ 2. Sign  │
└──────────┘             └──────────┘               │ 3. Deploy│
                                                      │ 4. Verify│
                                                      └─────┬────┘
                                                            │
                                                            ▼
                                                     ┌──────────┐
                                                     │  Ansible  │
                                                     │  Deploy   │
                                                     │           │
                                                     │  Pushes   │
                                                     │  certs to │
                                                     │  servers  │
                                                     └──────────┘
```

**Example Certificate Request YAML:**
```yaml
# cert-requests/web-server.yml
certificate:
  common_name: "web.homelab.local"
  organization: "HomeLab"
  san:
    dns:
      - "web.homelab.local"
      - "www.homelab.local"
    ip:
      - "192.168.1.10"
  key:
    algorithm: RSA
    size: 4096
  validity_days: 365
  usage:
    - serverAuth
  deploy_targets:
    - host: web.homelab.local
      cert_path: /etc/nginx/ssl/server.crt
      key_path: /etc/nginx/ssl/server.key
      reload_command: "systemctl reload nginx"
```

**Jenkins Pipeline (Jenkinsfile):**
```groovy
pipeline {
    agent any
    stages {
        stage('Validate Request') {
            steps {
                sh '''
                    # Validate YAML syntax
                    python3 -c "import yaml; yaml.safe_load(open('cert-requests/web-server.yml'))"
                    # Check for minimum key size
                    # Check for valid SANs
                    # Ensure no wildcard abuse
                '''
            }
        }
        stage('Generate & Sign Certificate') {
            steps {
                sh '''
                    # Parse YAML and generate certificate
                    openssl genrsa -out /tmp/server.key 4096
                    openssl req -new -key /tmp/server.key -out /tmp/server.csr \
                      -subj "/CN=web.homelab.local/O=HomeLab"
                    openssl ca -config /opt/ca/openssl.cnf -batch \
                      -in /tmp/server.csr -out /tmp/server.crt \
                      -days 365 -extensions server_cert
                '''
            }
        }
        stage('Deploy Certificate') {
            steps {
                sh '''
                    ansible-playbook deploy-cert.yml \
                      -e "cert_file=/tmp/server.crt" \
                      -e "key_file=/tmp/server.key" \
                      -e "target_host=web.homelab.local"
                '''
            }
        }
        stage('Verify Deployment') {
            steps {
                sh '''
                    echo | openssl s_client -connect web.homelab.local:443 \
                      -servername web.homelab.local 2>/dev/null | \
                      openssl x509 -noout -dates -subject
                '''
            }
        }
    }
}
```

---

### Project 14: Code Signing & S/MIME Email Encryption

**Goal:** Issue certificates for code signing and encrypted email

**Build Steps:**
```bash
# === Code Signing Certificate ===

# Generate key for code signing
openssl genrsa -aes256 -out codesign.key 4096

# Generate CSR
openssl req -new -key codesign.key -out codesign.csr \
  -subj "/C=US/ST=HomeLab/O=MyHomeLab/CN=HomeLab Code Signing"

# Sign with extended key usage for code signing
openssl x509 -req -in codesign.csr \
  -CA intermediate.crt -CAkey intermediate.key -CAcreateserial \
  -out codesign.crt -days 365 -sha256 \
  -extfile <(printf "keyUsage=critical,digitalSignature\nextendedKeyUsage=critical,codeSigning\nbasicConstraints=CA:FALSE")

# Sign a script
openssl dgst -sha256 -sign codesign.key -out script.sh.sig script.sh

# Verify the signature
openssl dgst -sha256 -verify <(openssl x509 -in codesign.crt -pubkey -noout) \
  -signature script.sh.sig script.sh

# === S/MIME Email Certificate ===

# Generate key for email
openssl genrsa -aes256 -out email.key 2048

# Generate email certificate
openssl req -new -key email.key -out email.csr \
  -subj "/C=US/O=MyHomeLab/CN=John Doe/emailAddress=john@homelab.local"

openssl x509 -req -in email.csr \
  -CA intermediate.crt -CAkey intermediate.key -CAcreateserial \
  -out email.crt -days 365 -sha256 \
  -extfile <(printf "keyUsage=critical,digitalSignature,keyEncipherment\nextendedKeyUsage=emailProtection\nbasicConstraints=CA:FALSE\nsubjectAltName=email:john@homelab.local")

# Export as PKCS#12 for Thunderbird/Outlook import
openssl pkcs12 -export -out john_email.p12 \
  -inkey email.key -in email.crt -certfile ca-chain.crt \
  -name "John Doe Email Certificate"

# Sign an email
openssl smime -sign -in message.txt -out signed_message.eml \
  -signer email.crt -inkey email.key -certfile ca-chain.crt

# Encrypt an email (need recipient's public cert)
openssl smime -encrypt -aes256 -in message.txt -out encrypted_message.eml \
  recipient_email.crt

# Decrypt an email
openssl smime -decrypt -in encrypted_message.eml \
  -recip email.crt -inkey email.key

# Verify a signed email
openssl smime -verify -in signed_message.eml -CAfile ca-chain.crt
```

---

### Project 15: Full PKI Disaster Recovery Lab

**Goal:** Practice CA backup, recovery, and compromise response

**Scenarios to Practice:**

```
┌──────────────────────────────────────────────────────────┐
│              DISASTER RECOVERY SCENARIOS                  │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Scenario 1: Intermediate CA Key Compromised             │
│  → Revoke intermediate cert                              │
│  → Issue new intermediate from Root CA                   │
│  → Re-issue ALL end-entity certificates                  │
│  → Distribute new CRL and update trust stores            │
│                                                          │
│  Scenario 2: Root CA Server Hardware Failure              │
│  → Restore Root CA from encrypted backup                 │
│  → Verify key integrity                                  │
│  → Resume operations                                     │
│                                                          │
│  Scenario 3: CRL Distribution Point Down                  │
│  → Deploy backup CRL distribution                        │
│  → Test OCSP failover                                    │
│  → Verify certificate validation still works             │
│                                                          │
│  Scenario 4: Rogue Certificate Issued                     │
│  → Identify the unauthorized cert                        │
│  → Revoke immediately                                    │
│  → Audit all recently issued certificates                │
│  → Update certificate policies                           │
│                                                          │
│  Scenario 5: Complete PKI Rebuild                         │
│  → Build new Root CA from scratch                        │
│  → Migrate all services to new PKI                       │
│  → Decommission old PKI                                  │
│  → Update all trust stores                               │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## 📚 Recommended Learning Path

```
WEEK 1-2:     Project 1 (Root CA) → Project 3 (Secure Services)
                 ↓
WEEK 3-4:     Project 2 (Two-Tier CA) → Project 4 (mTLS)
                 ↓
WEEK 5-6:     Project 5 (Vault PKI) → Project 7 (Kubernetes cert-manager)
                 ↓
WEEK 7-8:     Project 8 (step-ca ACME) → Project 11 (SSH Certificates)
                 ↓
WEEK 9-10:    Project 9 (Monitoring) → Project 10 (Zero Trust)
                 ↓
WEEK 11-12:   Project 12 (HSM) → Project 13 (CI/CD) → Project 14 & 15
```

---

## 🧰 Free Tools & Resources Summary

| Tool | Purpose | URL |
|------|---------|-----|
| **OpenSSL** | Core PKI operations | Pre-installed on Linux |
| **step-ca** | ACME CA server | smallstep.com |
| **HashiCorp Vault** | Secret & PKI management | vaultproject.io |
| **cert-manager** | Kubernetes certificate automation | cert-manager.io |
| **SoftHSM2** | HSM simulation | opendnssec.org |
| **EJBCA CE** | Full-featured CA server | ejbca.org |
| **Dogtag PKI** | Red Hat PKI system | dogtagpki.org |
| **Nebula** | Certificate-based mesh VPN | github.com/slackhq/nebula |
| **SPIRE** | SPIFFE identity framework | spiffe.io |
| **Lemur** | Certificate management (Netflix) | github.com/Netflix/lemur |
| **cfssl** | Cloudflare's PKI toolkit | github.com/cloudflare/cfssl |
| **mkcert** | Local development certs | github.com/FiloSottile/mkcert |
| **Prometheus** | Monitoring | prometheus.io |
| **Grafana** | Dashboards | grafana.com |
| **XCA** | GUI Certificate Manager | hohnstaedt.de/xca |

---

> 💡 **Tips for Success:**
> - **Start simple** — Project 1 teaches fundamentals everything else builds on
> - **Document everything** — Keep a lab notebook/wiki of what you build
> - **Break things on purpose** — Expire certs, revoke certs, corrupt keys, then fix them
> - **Use VMs/Containers** — Snapshot before experiments so you can roll back
> - **Combine projects** — The real power comes from integrating multiple projects together
> - **Simulate real incidents** — Practice the disaster recovery scenarios in Project 15
> - **Share your work** — Blog about it, put configs on GitHub, build your portfolio
