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
