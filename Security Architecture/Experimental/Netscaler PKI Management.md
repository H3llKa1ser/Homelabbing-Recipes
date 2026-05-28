That format is **Citrix ADC (NetScaler)** CLI commands! Here's a comprehensive PKI management guide specifically for Citrix ADC/NetScaler.

---

# 🔐 Citrix ADC (NetScaler) — Complete PKI Command Reference

---

## 📋 Command Structure Overview

```
┌──────────────────────────────────────────────────────────────────┐
│              CITRIX ADC CLI COMMAND STRUCTURE                     │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Action    Object           Name        Parameters               │
│  ──────    ──────           ────        ──────────               │
│  add       ssl certKey      PROFILE     -cert -key -password     │
│  update    ssl certKey      PROFILE     -cert -key               │
│  show      ssl certKey      PROFILE                              │
│  rm        ssl certKey      PROFILE                              │
│  bind      ssl vserver      VS_NAME     -certkeyName             │
│  unbind    ssl vserver      VS_NAME     -certkeyName             │
│  link      ssl certKey      CHILD       -linkcert PARENT         │
│  save      ns config                                             │
│                                                                  │
│  Paths:                                                          │
│  /nsconfig/ssl/    → Default certificate storage                 │
│  /var/nsconfig/ssl/ → Persistent storage                         │
│  /var/tmp/          → Temporary upload directory                 │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 1. 📥 File Upload & Transfer

```bash
# ============================================
# UPLOAD CERTIFICATES & KEYS TO CITRIX ADC
# ============================================

# === Upload via SCP ===
scp server.crt nsroot@citrix-adc:/nsconfig/ssl/server.crt
scp server.key nsroot@citrix-adc:/nsconfig/ssl/server.key
scp ca-chain.crt nsroot@citrix-adc:/nsconfig/ssl/ca-chain.crt

# === Upload via SFTP ===
sftp nsroot@citrix-adc
put server.crt /nsconfig/ssl/server.crt
put server.key /nsconfig/ssl/server.key
put ca-chain.crt /nsconfig/ssl/ca-chain.crt
bye

# === Upload via WinSCP (Windows) ===
# Connect to Citrix ADC IP on port 22
# Navigate to /nsconfig/ssl/
# Drag and drop certificate files

# === Upload via Citrix ADC CLI (from URL) ===
# Not directly supported, but you can use shell:
shell
curl -o /nsconfig/ssl/server.crt https://pki.example.com/certs/server.crt
curl -o /nsconfig/ssl/server.key https://pki.example.com/keys/server.key
exit

# === Upload via Citrix ADC NITRO REST API ===
# Upload certificate file
curl -s -X POST "https://citrix-adc/nitro/v1/config/systemfile" \
  -H "Content-Type: application/json" \
  -H "X-NITRO-USER: nsroot" \
  -H "X-NITRO-PASS: nsroot_password" \
  -d '{
    "systemfile": {
      "filename": "server.crt",
      "filelocation": "/nsconfig/ssl/",
      "filecontent": "'$(base64 -w0 server.crt)'"
    }
  }'

# Upload key file
curl -s -X POST "https://citrix-adc/nitro/v1/config/systemfile" \
  -H "Content-Type: application/json" \
  -H "X-NITRO-USER: nsroot" \
  -H "X-NITRO-PASS: nsroot_password" \
  -d '{
    "systemfile": {
      "filename": "server.key",
      "filelocation": "/nsconfig/ssl/",
      "filecontent": "'$(base64 -w0 server.key)'"
    }
  }'

# === Verify Files Were Uploaded ===
shell
ls -la /nsconfig/ssl/
exit
```

---

## 2. 🔑 Key Pair Management

```bash
# ============================================
# RSA KEY PAIR OPERATIONS
# ============================================

# === Generate RSA Key Pair on the ADC ===
create ssl rsakey /nsconfig/ssl/server.key 2048 -exponent F4 -keyform PEM
create ssl rsakey /nsconfig/ssl/server.key 4096 -exponent F4 -keyform PEM

# === Generate RSA Key with DES3 Encryption ===
create ssl rsakey /nsconfig/ssl/server_enc.key 2048 -exponent F4 -keyform PEM -des3

# === Generate RSA Key with AES256 Encryption ===
create ssl rsakey /nsconfig/ssl/server_enc.key 4096 -exponent F4 -keyform PEM -aes256

# ============================================
# ECDSA KEY PAIR OPERATIONS
# ============================================

# === Generate ECDSA Key (P-256) ===
create ssl rsakey /nsconfig/ssl/server_ecc.key -curve P_256 -keyform PEM

# === Generate ECDSA Key (P-384) ===
create ssl rsakey /nsconfig/ssl/server_ecc.key -curve P_384 -keyform PEM

# ============================================
# KEY CONVERSION
# ============================================

# === Convert DER Key to PEM ===
convert ssl pkcs8 /nsconfig/ssl/server_der.key /nsconfig/ssl/server_pem.key -keyform DER -outform PEM

# === Convert PEM Key to DER ===
convert ssl pkcs8 /nsconfig/ssl/server_pem.key /nsconfig/ssl/server_der.key -keyform PEM -outform DER
```

---

## 3. 📝 CSR (Certificate Signing Request) Generation

```bash
# ============================================
# GENERATE CSR ON CITRIX ADC
# ============================================

# === Basic CSR ===
create ssl certreq /nsconfig/ssl/server.csr \
  -keyFile /nsconfig/ssl/server.key \
  -countryName US \
  -stateName "New York" \
  -organizationName "My Company LLC" \
  -commonName "www.example.com"

# === CSR with Full Details ===
create ssl certreq /nsconfig/ssl/server.csr \
  -keyFile /nsconfig/ssl/server.key \
  -keyForm PEM \
  -countryName US \
  -stateName "New York" \
  -localityName "New York City" \
  -organizationName "My Company LLC" \
  -organizationUnitName "IT Department" \
  -commonName "www.example.com" \
  -emailAddress "admin@example.com" \
  -digestMethod SHA256

# === CSR with Subject Alternative Names (SAN) ===
create ssl certreq /nsconfig/ssl/server.csr \
  -keyFile /nsconfig/ssl/server.key \
  -countryName US \
  -stateName "New York" \
  -organizationName "My Company LLC" \
  -commonName "www.example.com" \
  -subjectAltName "DNS:www.example.com,DNS:example.com,DNS:api.example.com,IP:10.0.0.1" \
  -digestMethod SHA256

# === Wildcard CSR ===
create ssl certreq /nsconfig/ssl/wildcard.csr \
  -keyFile /nsconfig/ssl/wildcard.key \
  -countryName US \
  -stateName "New York" \
  -organizationName "My Company LLC" \
  -commonName "*.example.com" \
  -digestMethod SHA256

# === View CSR Contents ===
shell
openssl req -in /nsconfig/ssl/server.csr -noout -text
exit
```

---

## 4. 📜 Certificate Key Pair (certKey) Management

### Add Certificate Key Pairs
```bash
# ============================================
# ADD SSL CERTIFICATE KEY PAIRS
# ============================================

# === Add a Standard Certificate-Key Pair ===
add ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server.crt \
  -key /nsconfig/ssl/server.key

# === Add with Explicit Formats ===
add ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server.crt \
  -key /nsconfig/ssl/server.key \
  -certForm PEM \
  -keyForm PEM

# === Add with Encrypted Key (Password Protected) ===
add ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server.crt \
  -key /nsconfig/ssl/server_enc.key \
  -password "KeyP@ssword123"

# === Add Certificate Only (No Private Key — for CA Certs) ===
add ssl certKey RootCA_cert \
  -cert /nsconfig/ssl/rootCA.crt

add ssl certKey IntermediateCA_cert \
  -cert /nsconfig/ssl/intermediate.crt

# === Add with Expiry Notification ===
add ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server.crt \
  -key /nsconfig/ssl/server.key \
  -notificationPeriod 30

# === Add DER Format Certificate ===
add ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server.der \
  -key /nsconfig/ssl/server.key \
  -certForm DER

# === Add PKCS#12 / PFX Certificate ===
add ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server.pfx \
  -certForm PFX \
  -password "PfxP@ssword123"

# === Add Certificate Bundle (cert + key in one PFX) ===
add ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/bundle.pfx \
  -certForm PFX \
  -password "BundleP@ss"

# === Add PKCS#8 Key Format ===
add ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server.crt \
  -key /nsconfig/ssl/server_pkcs8.key \
  -keyForm PEM \
  -inform PKCS8
```

### Show / View Certificate Key Pairs
```bash
# ============================================
# VIEW CERTIFICATE KEY PAIRS
# ============================================

# === Show All certKey Pairs ===
show ssl certKey

# === Show Specific certKey Details ===
show ssl certKey www.example.com_cert

# === Show Certificate Details (Subject, Issuer, Dates, Serial) ===
show ssl certKey www.example.com_cert -detail

# === Show All Certificates with Expiry ===
show ssl certKey | grep -E "Name|Days"

# === Show Certificate Bindings (which vservers use it) ===
show ssl certKey www.example.com_cert -binding

# === Show All Expired Certificates ===
show ssl certKey | grep "EXPIRED"

# === Show Certificates Expiring Within 30 Days ===
show ssl certKey | grep -B2 "Days to expiration: [0-2][0-9]$"

# === Detailed Certificate Info via Shell ===
shell
openssl x509 -in /nsconfig/ssl/server.crt -noout -text
openssl x509 -in /nsconfig/ssl/server.crt -noout -subject -issuer -dates -serial -fingerprint
exit
```

### Update / Replace Certificate Key Pairs
```bash
# ============================================
# UPDATE / REPLACE CERTIFICATES (ROTATION)
# ============================================

# === Update Certificate and Key (Standard Rotation) ===
update ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server_new.crt \
  -key /nsconfig/ssl/server_new.key

# === Update Certificate Only (Same Key) ===
update ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server_renewed.crt

# === Update Key Only ===
update ssl certKey www.example.com_cert \
  -key /nsconfig/ssl/server_new.key

# === Update with Password-Protected Key ===
update ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server_new.crt \
  -key /nsconfig/ssl/server_new_enc.key \
  -password "NewKeyP@ss"

# === Update from PFX ===
update ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server_new.pfx \
  -certForm PFX \
  -password "PfxP@ss"

# === Update with Domain Check ===
# This verifies the CN/SAN matches before applying
update ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server_new.crt \
  -key /nsconfig/ssl/server_new.key \
  -noDomainCheck

# === IMPORTANT: No Service Interruption ===
# The "update" command applies the new cert LIVE
# without unbinding or restarting the vserver!
# All existing connections continue uninterrupted.
# New connections use the updated certificate.

# === Save Configuration After Update ===
save ns config
```

### Remove Certificate Key Pairs
```bash
# ============================================
# REMOVE CERTIFICATE KEY PAIRS
# ============================================

# === Remove a certKey (must be unbound first) ===
rm ssl certKey www.example.com_cert

# === Force Remove (removes bindings too) — USE WITH CAUTION ===
# First unbind, then remove
unbind ssl vserver vs_www -certkeyName www.example.com_cert
rm ssl certKey www.example.com_cert

# === Remove Certificate Files from Disk ===
shell
rm -f /nsconfig/ssl/server_old.crt
rm -f /nsconfig/ssl/server_old.key
exit
```

---

## 5. 🔗 Certificate Chain Linking

```bash
# ============================================
# CERTIFICATE CHAIN LINKING
# ============================================

# === Understanding Chain Order ===
#
# Server Cert → Intermediate CA → Root CA
#     ↓              ↓               ↓
# www_cert    →  inter_cert   →  root_cert
#     link          link
#
# You link CHILD to PARENT (bottom-up)

# === Step 1: Add All Certificates in the Chain ===

# Add Root CA certificate
add ssl certKey RootCA \
  -cert /nsconfig/ssl/rootCA.crt

# Add Intermediate CA certificate
add ssl certKey IntermediateCA \
  -cert /nsconfig/ssl/intermediate.crt

# Add Server certificate with key
add ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server.crt \
  -key /nsconfig/ssl/server.key

# === Step 2: Link the Chain (Bottom-Up) ===

# Link Server cert → Intermediate CA
link ssl certKey www.example.com_cert \
  -linkcert IntermediateCA

# Link Intermediate CA → Root CA
link ssl certKey IntermediateCA \
  -linkcert RootCA

# === Verify the Chain ===
show ssl certKey www.example.com_cert
# Look for: "Linked Certificate Name: IntermediateCA"

show ssl certKey IntermediateCA
# Look for: "Linked Certificate Name: RootCA"

# === Unlink a Certificate from Chain ===
unlink ssl certKey www.example.com_cert
unlink ssl certKey IntermediateCA

# === Multiple Intermediate CAs ===
# Root CA → Intermediate CA 2 → Intermediate CA 1 → Server Cert
add ssl certKey RootCA -cert /nsconfig/ssl/root.crt
add ssl certKey InterCA2 -cert /nsconfig/ssl/inter2.crt
add ssl certKey InterCA1 -cert /nsconfig/ssl/inter1.crt
add ssl certKey ServerCert -cert /nsconfig/ssl/server.crt -key /nsconfig/ssl/server.key

link ssl certKey ServerCert -linkcert InterCA1
link ssl certKey InterCA1 -linkcert InterCA2
link ssl certKey InterCA2 -linkcert RootCA

# === Cross-Signed Certificate Chain ===
add ssl certKey CrossSignedCA -cert /nsconfig/ssl/cross_signed.crt
link ssl certKey IntermediateCA -linkcert CrossSignedCA
```

---

## 6. 🌐 Binding Certificates to Virtual Servers

### SSL VServer Bindings
```bash
# ============================================
# BIND CERTIFICATES TO SSL VSERVERS
# ============================================

# === Bind Server Certificate to SSL VServer ===
bind ssl vserver vs_www_ssl \
  -certkeyName www.example.com_cert

# === Bind SNI Certificate (Multiple Certs on Same VServer) ===
bind ssl vserver vs_www_ssl \
  -certkeyName www.example.com_cert \
  -sniCert

bind ssl vserver vs_www_ssl \
  -certkeyName api.example.com_cert \
  -sniCert

bind ssl vserver vs_www_ssl \
  -certkeyName portal.example.com_cert \
  -sniCert

# === Bind CA Certificate for Client Authentication ===
bind ssl vserver vs_www_ssl \
  -certkeyName RootCA \
  -CA

bind ssl vserver vs_www_ssl \
  -certkeyName IntermediateCA \
  -CA

# === Bind CA Certificate with OCSP Mandatory ===
bind ssl vserver vs_www_ssl \
  -certkeyName RootCA \
  -CA \
  -ocspCheck Mandatory

# === Bind CRL to VServer ===
bind ssl vserver vs_www_ssl \
  -crlCheck Mandatory

# === Unbind Certificate from VServer ===
unbind ssl vserver vs_www_ssl \
  -certkeyName www.example.com_cert

# === Unbind SNI Certificate ===
unbind ssl vserver vs_www_ssl \
  -certkeyName api.example.com_cert \
  -sniCert

# === Unbind CA Certificate ===
unbind ssl vserver vs_www_ssl \
  -certkeyName RootCA \
  -CA

# === Show All Bindings for a VServer ===
show ssl vserver vs_www_ssl

# === Show Which VServers Use a Specific Certificate ===
show ssl certKey www.example.com_cert -binding
```

### SSL Service / Service Group Bindings
```bash
# ============================================
# BIND CERTIFICATES TO SSL SERVICES
# ============================================

# === Bind to an SSL Service (Backend) ===
bind ssl service svc_web_ssl \
  -certkeyName backend_cert

# === Bind to SSL Service Group ===
bind ssl serviceGroup sg_web_ssl \
  -certkeyName backend_cert

# === Bind CA Certificate to Service (for Backend Verification) ===
bind ssl service svc_web_ssl \
  -certkeyName RootCA \
  -CA

# === Show SSL Service Bindings ===
show ssl service svc_web_ssl
show ssl serviceGroup sg_web_ssl
```

### SSL Monitor Bindings
```bash
# ============================================
# BIND CERTIFICATES TO SSL MONITORS
# ============================================

# === Bind Certificate to HTTPS Monitor ===
bind ssl monitor https_monitor \
  -certkeyName monitor_cert

# === Show Monitor SSL Bindings ===
show ssl monitor https_monitor
```

---

## 7. ⚙️ SSL Profile Configuration

```bash
# ============================================
# SSL PROFILE MANAGEMENT
# ============================================

# === Create Frontend SSL Profile ===
add ssl profile ssl_profile_frontend \
  -sslProfileType FrontEnd \
  -ssl3 DISABLED \
  -tls1 DISABLED \
  -tls11 DISABLED \
  -tls12 ENABLED \
  -tls13 ENABLED \
  -denySSLReneg NONSECURE \
  -HSTS ENABLED \
  -maxage 157680000 \
  -IncludeSubdomains YES \
  -sessReuse ENABLED \
  -sessTimeout 120 \
  -ocspStapling ENABLED

# === Create Backend SSL Profile ===
add ssl profile ssl_profile_backend \
  -sslProfileType BackEnd \
  -ssl3 DISABLED \
  -tls1 DISABLED \
  -tls11 DISABLED \
  -tls12 ENABLED \
  -tls13 ENABLED \
  -serverAuth ENABLED \
  -commonName "backend.example.com"

# === Bind SSL Profile to VServer ===
set ssl vserver vs_www_ssl \
  -sslProfile ssl_profile_frontend

# === Bind SSL Profile to Service ===
set ssl service svc_web_ssl \
  -sslProfile ssl_profile_backend

# === Set Cipher Groups on SSL Profile ===
unbind ssl profile ssl_profile_frontend -cipherName ALL

bind ssl profile ssl_profile_frontend \
  -cipherName TLS1.3-AES256-GCM-SHA384 -cipherPriority 1

bind ssl profile ssl_profile_frontend \
  -cipherName TLS1.3-CHACHA20-POLY1305-SHA256 -cipherPriority 2

bind ssl profile ssl_profile_frontend \
  -cipherName TLS1.2-ECDHE-RSA-AES256-GCM-SHA384 -cipherPriority 3

bind ssl profile ssl_profile_frontend \
  -cipherName TLS1.2-ECDHE-RSA-AES128-GCM-SHA256 -cipherPriority 4

# === Show SSL Profile ===
show ssl profile ssl_profile_frontend
show ssl profile ssl_profile_backend

# === Show All SSL Profiles ===
show ssl profile

# === Modify Existing SSL Profile ===
set ssl profile ssl_profile_frontend \
  -tls13 ENABLED \
  -HSTS ENABLED \
  -maxage 31536000

# === Remove SSL Profile ===
rm ssl profile ssl_profile_frontend
```

---

## 8. 🔒 SSL VServer Configuration

```bash
# ============================================
# SSL VSERVER SETTINGS
# ============================================

# === Enable/Disable TLS Versions (Without Profile) ===
set ssl vserver vs_www_ssl \
  -ssl3 DISABLED \
  -tls1 DISABLED \
  -tls11 DISABLED \
  -tls12 ENABLED \
  -tls13 ENABLED

# === Enable HSTS ===
set ssl vserver vs_www_ssl \
  -HSTS ENABLED \
  -maxage 157680000 \
  -IncludeSubdomains YES

# === Enable OCSP Stapling ===
set ssl vserver vs_www_ssl \
  -ocspStapling ENABLED

# === Enable Client Certificate Authentication ===
set ssl vserver vs_www_ssl \
  -clientAuth ENABLED \
  -clientCert Mandatory

# === Optional Client Certificate ===
set ssl vserver vs_www_ssl \
  -clientAuth ENABLED \
  -clientCert Optional

# === Disable Client Certificate ===
set ssl vserver vs_www_ssl \
  -clientAuth DISABLED

# === Set Cipher Suites (Without Profile) ===
unbind ssl vserver vs_www_ssl -cipherName ALL

bind ssl vserver vs_www_ssl \
  -cipherName TLS1.2-ECDHE-RSA-AES256-GCM-SHA384 -cipherPriority 1

bind ssl vserver vs_www_ssl \
  -cipherName TLS1.2-ECDHE-RSA-AES128-GCM-SHA256 -cipherPriority 2

# === Enable SSL Session Reuse ===
set ssl vserver vs_www_ssl \
  -sessReuse ENABLED \
  -sessTimeout 120

# === Enable SSL Redirect (HTTP to HTTPS) ===
add responder action http_to_https_act respondwith \
  "\"HTTP/1.1 301 Moved Permanently\r\nLocation: https://\" + HTTP.REQ.HOSTNAME + HTTP.REQ.URL.HTTP_URL_SAFE + \"\r\n\r\n\""
add responder policy http_to_https_pol "HTTP.REQ.IS_VALID" http_to_https_act
bind lb vserver vs_www_http -policyName http_to_https_pol -priority 100

# === Enable Deny SSL Renegotiation ===
set ssl vserver vs_www_ssl \
  -denySSLReneg NONSECURE

# === Enable SNI (Server Name Indication) ===
set ssl vserver vs_www_ssl -SNIEnable ENABLED

# === Show Full VServer SSL Configuration ===
show ssl vserver vs_www_ssl
```

---

## 9. 🔄 Complete Certificate Rotation Process

```bash
# ============================================
# FULL CERTIFICATE ROTATION — STEP BY STEP
# ============================================

# =============================================
# STEP 1: Identify Expiring Certificates
# =============================================
show ssl certKey
# Look for "Days to expiration" values

# Check specific certificate
show ssl certKey www.example.com_cert

# Find all expiring within 30 days via shell
shell
for crt in /nsconfig/ssl/*.crt; do
  EXPIRY=$(openssl x509 -in "$crt" -noout -enddate 2>/dev/null | cut -d= -f2)
  DAYS=$(( ($(date -d "$EXPIRY" +%s) - $(date +%s)) / 86400 ))
  if [ "$DAYS" -lt 30 ] 2>/dev/null; then
    echo "⚠️  $crt — Expires: $EXPIRY ($DAYS days)"
  fi
done
exit

# =============================================
# STEP 2: Backup Current Certificate & Key
# =============================================
shell
mkdir -p /nsconfig/ssl/backup/$(date +%Y%m%d)
cp /nsconfig/ssl/server.crt /nsconfig/ssl/backup/$(date +%Y%m%d)/server.crt.bak
cp /nsconfig/ssl/server.key /nsconfig/ssl/backup/$(date +%Y%m%d)/server.key.bak
exit

# =============================================
# STEP 3: Generate New Key Pair (on ADC)
# =============================================
create ssl rsakey /nsconfig/ssl/server_new.key 2048 -exponent F4 -keyform PEM

# =============================================
# STEP 4: Generate New CSR
# =============================================
create ssl certreq /nsconfig/ssl/server_new.csr \
  -keyFile /nsconfig/ssl/server_new.key \
  -countryName US \
  -stateName "New York" \
  -organizationName "My Company LLC" \
  -commonName "www.example.com" \
  -subjectAltName "DNS:www.example.com,DNS:example.com" \
  -digestMethod SHA256

# =============================================
# STEP 5: Submit CSR to CA & Get Signed Cert
# =============================================
# Download the CSR from ADC
# scp nsroot@citrix-adc:/nsconfig/ssl/server_new.csr .
#
# Submit to your CA (Sectigo, DigiCert, Let's Encrypt, Internal CA)
# Receive signed certificate back
#
# Upload signed certificate to ADC
# scp server_new.crt nsroot@citrix-adc:/nsconfig/ssl/server_new.crt
# scp ca-chain.crt nsroot@citrix-adc:/nsconfig/ssl/ca-chain.crt (if chain changed)

# =============================================
# STEP 6: Verify New Certificate (Before Applying)
# =============================================
shell
# Verify cert matches key
CERT_MOD=$(openssl x509 -noout -modulus -in /nsconfig/ssl/server_new.crt | openssl md5)
KEY_MOD=$(openssl rsa -noout -modulus -in /nsconfig/ssl/server_new.key | openssl md5)
echo "Cert: $CERT_MOD"
echo "Key:  $KEY_MOD"
if [ "$CERT_MOD" = "$KEY_MOD" ]; then echo "✅ MATCH"; else echo "❌ MISMATCH"; fi

# Verify chain
openssl verify -CAfile /nsconfig/ssl/ca-chain.crt /nsconfig/ssl/server_new.crt

# View new certificate details
openssl x509 -in /nsconfig/ssl/server_new.crt -noout -subject -issuer -dates -serial
exit

# =============================================
# STEP 7: Update certKey (LIVE — No Downtime!)
# =============================================
update ssl certKey www.example.com_cert \
  -cert /nsconfig/ssl/server_new.crt \
  -key /nsconfig/ssl/server_new.key

# =============================================
# STEP 8: Update Chain If Needed
# =============================================
# If intermediate/root CA changed:
update ssl certKey IntermediateCA \
  -cert /nsconfig/ssl/intermediate_new.crt

update ssl certKey RootCA \
  -cert /nsconfig/ssl/rootCA_new.crt

# =============================================
# STEP 9: Verify the Update
# =============================================
show ssl certKey www.example.com_cert
# Confirm new "Valid from" and "Valid to" dates
# Confirm new serial number

# Check which vservers are using it
show ssl certKey www.example.com_cert -binding

# =============================================
# STEP 10: Test from External Client
# =============================================
shell
curl -vI https://www.example.com 2>&1 | grep -E "subject|expire|issuer"
echo | openssl s_client -connect www.example.com:443 -servername www.example.com 2>/dev/null | openssl x509 -noout -subject -dates
exit

# =============================================
# STEP 11: Save Configuration
# =============================================
save ns config

# =============================================
# STEP 12: Clean Up Old Files
# =============================================
shell
rm -f /nsconfig/ssl/server_old.crt
rm -f /nsconfig/ssl/server_old.key
rm -f /nsconfig/ssl/server_new.csr
exit
```

---

## 10. 🔐 CRL (Certificate Revocation List) Management

```bash
# ============================================
# CRL MANAGEMENT
# ============================================

# === Add a CRL ===
add ssl crl MyCRL \
  -crlPath /nsconfig/ssl/ca.crl \
  -inform PEM

# === Add CRL with Auto-Refresh (HTTP) ===
add ssl crl MyCRL \
  -crlPath /nsconfig/ssl/ca.crl \
  -inform PEM \
  -refresh ENABLED \
  -url "http://pki.example.com/crl/ca.crl" \
  -interval MONTHLY \
  -day 1 \
  -time "02:00"

# === Add CRL with Auto-Refresh (LDAP) ===
add ssl crl MyCRL \
  -crlPath /nsconfig/ssl/ca.crl \
  -inform PEM \
  -refresh ENABLED \
  -method LDAP \
  -server "ldap.example.com" \
  -port 389 \
  -baseDN "cn=CA,dc=example,dc=com"

# === Bind CRL Check to VServer ===
set ssl vserver vs_www_ssl \
  -crlCheck Mandatory

# === Force CRL Refresh ===
update ssl crl MyCRL

# === Show CRL ===
show ssl crl
show ssl crl MyCRL

# === Remove CRL ===
rm ssl crl MyCRL
```

---

## 11. 🌐 OCSP (Online Certificate Status Protocol)

```bash
# ============================================
# OCSP CONFIGURATION
# ============================================

# === Add OCSP Responder ===
add ssl ocspResponder MyOCSP \
  -url "http://ocsp.example.com" \
  -cache ENABLED \
  -cacheTimeout 3600 \
  -batchingDepth 10 \
  -batchingDelay 500 \
  -respondercert OCSPSigner_cert \
  -trustResponder YES \
  -signingCert IntermediateCA

# === Enable OCSP Stapling on VServer ===
set ssl vserver vs_www_ssl \
  -ocspStapling ENABLED

# === Bind OCSP Responder to certKey ===
bind ssl certKey IntermediateCA \
  -ocspResponder MyOCSP -priority 1

# === Show OCSP Configuration ===
show ssl ocspResponder
show ssl ocspResponder MyOCSP

# === Clear OCSP Cache ===
flush ssl ocspResponder MyOCSP

# === Show OCSP Stapling Status ===
stat ssl
show ssl stats

# === Remove OCSP Responder ===
rm ssl ocspResponder MyOCSP
```

---

## 12. 🔧 Cipher Suite Management

```bash
# ============================================
# CIPHER SUITE MANAGEMENT
# ============================================

# === Show All Available Ciphers ===
show ssl cipher

# === Show Specific Cipher Group ===
show ssl cipher DEFAULT
show ssl cipher ALL

# === Create Custom Cipher Group ===
add ssl cipher CUSTOM_SECURE_CIPHERS

# === Add Ciphers to Custom Group ===
bind ssl cipher CUSTOM_SECURE_CIPHERS \
  -cipherName TLS1.3-AES256-GCM-SHA384 -cipherPriority 1

bind ssl cipher CUSTOM_SECURE_CIPHERS \
  -cipherName TLS1.3-CHACHA20-POLY1305-SHA256 -cipherPriority 2

bind ssl cipher CUSTOM_SECURE_CIPHERS \
  -cipherName TLS1.3-AES128-GCM-SHA256 -cipherPriority 3

bind ssl cipher CUSTOM_SECURE_CIPHERS \
  -cipherName TLS1.2-ECDHE-RSA-AES256-GCM-SHA384 -cipherPriority 4

bind ssl cipher CUSTOM_SECURE_CIPHERS \
  -cipherName TLS1.2-ECDHE-RSA-AES128-GCM-SHA256 -cipherPriority 5

bind ssl cipher CUSTOM_SECURE_CIPHERS \
  -cipherName TLS1.2-ECDHE-ECDSA-AES256-GCM-SHA384 -cipherPriority 6

bind ssl cipher CUSTOM_SECURE_CIPHERS \
  -cipherName TLS1.2-ECDHE-ECDSA-AES128-GCM-SHA256 -cipherPriority 7

# === Apply Custom Cipher Group to VServer ===
unbind ssl vserver vs_www_ssl -cipherName ALL
bind ssl vserver vs_www_ssl -cipherName CUSTOM_SECURE_CIPHERS

# === Apply to SSL Profile ===
unbind ssl profile ssl_profile_frontend -cipherName ALL
bind ssl profile ssl_profile_frontend -cipherName CUSTOM_SECURE_CIPHERS

# === Remove a Cipher from Group ===
unbind ssl cipher CUSTOM_SECURE_CIPHERS \
  -cipherName TLS1.2-ECDHE-RSA-AES128-GCM-SHA256

# === Remove Cipher Group ===
rm ssl cipher CUSTOM_SECURE_CIPHERS

# === Show Ciphers Bound to VServer ===
show ssl vserver vs_www_ssl
```

---

## 13. 📊 SSL Monitoring & Statistics

```bash
# ============================================
# SSL MONITORING & STATISTICS
# ============================================

# === Show SSL Stats ===
stat ssl

# === Show SSL VServer Stats ===
stat ssl vserver vs_www_ssl

# === Show Certificate Expiry Overview ===
show ssl certKey

# === Monitor Certificate Expiry via SNMP ===
# OID: 1.3.6.1.4.1.5951.4.1.1.56 (sslCertDaysToExpire)
# Configure SNMP traps for certificate expiry

# === Show SSL Session Info ===
show ssl session

# === Show SSL Cached Sessions ===
stat ssl | grep -i session

# === Show Current SSL Connections ===
show ns connectiontable -filterexpression "SSLVSERVER.EQ(vs_www_ssl)"

# === SSL Debug/Trace ===
set audit syslogParams -logLevel ALL
set audit syslogParams -ssl ALL

# Packet trace for SSL handshake
start nstrace -size 0 -filter "CONNECTION.SSL.IS_SSL"
# ... reproduce the issue ...
stop nstrace

# === Show SSL Hardware Acceleration ===
show ssl hardware
stat ssl | grep -i "SSL card"

# === Show FIPS Status (If Using FIPS) ===
show ssl fips

# === Comprehensive Health Check Script ===
shell
echo "========== CITRIX ADC SSL HEALTH CHECK =========="
echo "Date: $(date)"
echo ""
echo "--- Certificate Expiry Summary ---"
cli_script="show ssl certKey"
nsapimgr_wr.sh -d "show ssl certKey" 2>/dev/null | grep -E "Name|Days to"
echo ""
echo "--- TLS Version Status ---"
nsapimgr_wr.sh -d "show ssl vserver" 2>/dev/null | grep -E "Name|SSL3|TLS1"
echo ""
echo "--- SSL Statistics ---"
nsapimgr_wr.sh -d "stat ssl" 2>/dev/null | head -30
echo "================================================="
exit
```

---

## 14. 🛡️ Advanced SSL Features

### Client Certificate Authentication (mTLS)
```bash
# ============================================
# MUTUAL TLS (mTLS) CONFIGURATION
# ============================================

# Step 1: Add CA certificates for client validation
add ssl certKey ClientRootCA \
  -cert /nsconfig/ssl/client_rootCA.crt

add ssl certKey ClientInterCA \
  -cert /nsconfig/ssl/client_interCA.crt

# Link the client CA chain
link ssl certKey ClientInterCA -linkcert ClientRootCA

# Step 2: Bind CA certs to vserver
bind ssl vserver vs_www_ssl -certkeyName ClientRootCA -CA
bind ssl vserver vs_www_ssl -certkeyName ClientInterCA -CA

# Step 3: Enable client authentication
set ssl vserver vs_www_ssl \
  -clientAuth ENABLED \
  -clientCert Mandatory

# Step 4: Configure SSL policy to extract client cert info
add ssl action extract_client_cert \
  -clientCert ENABLED \
  -certHeader "X-Client-Cert" \
  -clientCertSerialNumber ENABLED \
  -certSerialHeader "X-Client-Serial" \
  -clientCertSubject ENABLED \
  -certSubjectHeader "X-Client-Subject" \
  -clientCertIssuer ENABLED \
  -certIssuerHeader "X-Client-Issuer" \
  -clientCertFingerprint ENABLED \
  -certFingerprintHeader "X-Client-Fingerprint"

add ssl policy extract_client_cert_pol \
  -rule TRUE \
  -action extract_client_cert

bind ssl vserver vs_www_ssl \
  -policyName extract_client_cert_pol \
  -priority 100

# Step 5: Restrict access by client cert CN
add responder action deny_action respondwith \
  "\"HTTP/1.1 403 Forbidden\r\n\r\nAccess Denied: Invalid Client Certificate\""

add responder policy deny_invalid_client \
  "CLIENT.SSL.CLIENT_CERT.SUBJECT.CONTAINS(\"CN=Allowed-User\").NOT" \
  deny_action

bind lb vserver vs_www_ssl \
  -policyName deny_invalid_client \
  -priority 100
```

### SSL Bridge / End-to-End Encryption
```bash
# ============================================
# SSL BRIDGE (END-TO-END SSL)
# ============================================

# === SSL Offloading (Terminate at ADC) ===
add lb vserver vs_www_ssl SSL 10.0.0.100 443
add service svc_web HTTP 10.0.0.10 80
bind lb vserver vs_www_ssl svc_web
bind ssl vserver vs_www_ssl -certkeyName www.example.com_cert

# === SSL Bridge (Pass-Through) ===
add lb vserver vs_www_bridge SSL_BRIDGE 10.0.0.100 443
add service svc_web_ssl SSL_BRIDGE 10.0.0.10 443
bind lb vserver vs_www_bridge svc_web_ssl

# === SSL Re-Encryption (Decrypt + Re-Encrypt to Backend) ===
add lb vserver vs_www_ssl SSL 10.0.0.100 443
add service svc_web_ssl SSL 10.0.0.10 443
bind lb vserver vs_www_ssl svc_web_ssl

# Frontend certificate
bind ssl vserver vs_www_ssl -certkeyName www.example.com_cert

# Backend certificate
bind ssl service svc_web_ssl -certkeyName backend_cert

# Enable backend server certificate verification
set ssl service svc_web_ssl \
  -serverAuth ENABLED \
  -commonName "backend.example.com"

bind ssl service svc_web_ssl \
  -certkeyName RootCA -CA
```

### SSL Policy Actions
```bash
# ============================================
# SSL POLICIES & ACTIONS
# ============================================

# === Redirect Based on Certificate ===
add ssl action redirect_no_cert_action -clientCert DISABLED
add ssl policy redirect_no_cert_pol \
  -rule "CLIENT.SSL.CLIENT_CERT.EXISTS.NOT" \
  -action redirect_no_cert_action

# === Insert Client Certificate Headers ===
add ssl action insert_cert_headers \
  -clientCert ENABLED \
  -certHeader "X-SSL-Client-Cert" \
  -clientCertSubject ENABLED \
  -certSubjectHeader "X-SSL-Subject" \
  -clientCertIssuer ENABLED \
  -certIssuerHeader "X-SSL-Issuer" \
  -clientCertSerialNumber ENABLED \
  -certSerialHeader "X-SSL-Serial" \
  -clientCertNotBefore ENABLED \
  -certNotBeforeHeader "X-SSL-NotBefore" \
  -clientCertNotAfter ENABLED \
  -certNotAfterHeader "X-SSL-NotAfter"

add ssl policy insert_cert_headers_pol -rule TRUE -action insert_cert_headers

bind ssl vserver vs_www_ssl \
  -policyName insert_cert_headers_pol \
  -priority 100 \
  -type REQUEST

# === SSL Expressions for Policies ===
# Check if connection is SSL
# CLIENT.SSL.IS_SSL
#
# Check client certificate exists
# CLIENT.SSL.CLIENT_CERT.EXISTS
#
# Get client certificate subject
# CLIENT.SSL.CLIENT_CERT.SUBJECT
#
# Get client certificate issuer
# CLIENT.SSL.CLIENT_CERT.ISSUER
#
# Get client certificate serial
# CLIENT.SSL.CLIENT_CERT.SERIAL_NUMBER
#
# Check client cert expiry
# CLIENT.SSL.CLIENT_CERT.DAYS_TO_EXPIRE
#
# Get SSL protocol version
# CLIENT.SSL.VERSION
#
# Get cipher name
# CLIENT.SSL.CIPHER_NAME
#
# Get cipher bits
# CLIENT.SSL.CIPHER_BITS
```

---

## 15. 🖥️ NITRO REST API Commands

```bash
# ============================================
# NITRO REST API FOR SSL OPERATIONS
# ============================================

NSIP="https://citrix-adc"
AUTH_HEADER="-H 'X-NITRO-USER: nsroot' -H 'X-NITRO-PASS: nsroot_password'"

# === List All certKeys ===
curl -s -X GET "${NSIP}/nitro/v1/config/sslcertkey" \
  -H "X-NITRO-USER: nsroot" \
  -H "X-NITRO-PASS: nsroot_password" \
  -H "Content-Type: application/json" | jq '.sslcertkey[] | {certkey, subject, clientcertnotafter, daystoexpiration}'

# === Add a certKey ===
curl -s -X POST "${NSIP}/nitro/v1/config/sslcertkey" \
  -H "X-NITRO-USER: nsroot" \
  -H "X-NITRO-PASS: nsroot_password" \
  -H "Content-Type: application/json" \
  -d '{
    "sslcertkey": {
      "certkey": "www.example.com_cert",
      "cert": "/nsconfig/ssl/server.crt",
      "key": "/nsconfig/ssl/server.key",
      "notificationperiod": 30
    }
  }'

# === Update a certKey ===
curl -s -X POST "${NSIP}/nitro/v1/config/sslcertkey?action=update" \
  -H "X-NITRO-USER: nsroot" \
  -H "X-NITRO-PASS: nsroot_password" \
  -H "Content-Type: application/json" \
  -d '{
    "sslcertkey": {
      "certkey": "www.example.com_cert",
      "cert": "/nsconfig/ssl/server_new.crt",
      "key": "/nsconfig/ssl/server_new.key",
      "nodomaincheck": true
    }
  }'

# === Link certKey ===
curl -s -X POST "${NSIP}/nitro/v1/config/sslcertkey?action=link" \
  -H "X-NITRO-USER: nsroot" \
  -H "X-NITRO-PASS: nsroot_password" \
  -H "Content-Type: application/json" \
  -d '{
    "sslcertkey": {
      "certkey": "www.example.com_cert",
      "linkcertkeyname": "IntermediateCA"
    }
  }'

# === Bind certKey to VServer ===
curl -s -X PUT "${NSIP}/nitro/v1/config/sslvserver_sslcertkey_binding" \
  -H "X-NITRO-USER: nsroot" \
  -H "X-NITRO-PASS: nsroot_password" \
  -H "Content-Type: application/json" \
  -d '{
    "sslvserver_sslcertkey_binding": {
      "vservername": "vs_www_ssl",
      "certkeyname": "www.example.com_cert",
      "snicert": false
    }
  }'

# === Delete a certKey ===
curl -s -X DELETE "${NSIP}/nitro/v1/config/sslcertkey/www.example.com_cert" \
  -H "X-NITRO-USER: nsroot" \
  -H "X-NITRO-PASS: nsroot_password"

# === Get SSL Stats ===
curl -s -X GET "${NSIP}/nitro/v1/stat/ssl" \
  -H "X-NITRO-USER: nsroot" \
  -H "X-NITRO-PASS: nsroot_password" | jq .

# === Get SSL VServer Stats ===
curl -s -X GET "${NSIP}/nitro/v1/stat/sslvserver/vs_www_ssl" \
  -H "X-NITRO-USER: nsroot" \
  -H "X-NITRO-PASS: nsroot_password" | jq .

# === Save Config via API ===
curl -s -X POST "${NSIP}/nitro/v1/config/nsconfig?action=save" \
  -H "X-NITRO-USER: nsroot" \
  -H "X-NITRO-PASS: nsroot_password" \
  -H "Content-Type: application/json" \
  -d '{"nsconfig": {}}'

# === Get Expiring Certificates (API Script) ===
curl -s -X GET "${NSIP}/nitro/v1/config/sslcertkey" \
  -H "X-NITRO-USER: nsroot" \
  -H "X-NITRO-PASS: nsroot_password" | \
  jq '.sslcertkey[] | select(.daystoexpiration < 30 and .daystoexpiration >= 0) | {certkey, daystoexpiration, subject}'
```

---

## 16. 📋 Quick Reference Command Table

| Task | Command |
|------|---------|
| **Generate RSA Key** | `create ssl rsakey /nsconfig/ssl/server.key 2048` |
| **Generate CSR** | `create ssl certreq /nsconfig/ssl/server.csr -keyFile /nsconfig/ssl/server.key -commonName "www.example.com"` |
| **Add certKey** | `add ssl certKey PROFILE -cert CERT.crt -key KEY.key` |
| **Add certKey (PFX)** | `add ssl certKey PROFILE -cert CERT.pfx -certForm PFX -password "pass"` |
| **Update certKey** | `update ssl certKey PROFILE -cert NEW.crt -key NEW.key` |
| **Show certKey** | `show ssl certKey PROFILE` |
| **Show All certKeys** | `show ssl certKey` |
| **Show Bindings** | `show ssl certKey PROFILE -binding` |
| **Remove certKey** | `rm ssl certKey PROFILE` |
| **Link Chain** | `link ssl certKey CHILD -linkcert PARENT` |
| **Unlink Chain** | `unlink ssl certKey CHILD` |
| **Bind to VServer** | `bind ssl vserver VS -certkeyName PROFILE` |
| **Bind SNI Cert** | `bind ssl vserver VS -certkeyName PROFILE -sniCert` |
| **Bind CA Cert** | `bind ssl vserver VS -certkeyName CA_PROFILE -CA` |
| **Unbind from VServer** | `unbind ssl vserver VS -certkeyName PROFILE` |
| **Bind to Service** | `bind ssl service SVC -certkeyName PROFILE` |
| **Set TLS Versions** | `set ssl vserver VS -tls12 ENABLED -tls13 ENABLED` |
| **Enable Client Auth** | `set ssl vserver VS -clientAuth ENABLED -clientCert Mandatory` |
| **Enable HSTS** | `set ssl vserver VS -HSTS ENABLED -maxage 157680000` |
| **Enable OCSP Stapling** | `set ssl vserver VS -ocspStapling ENABLED` |
| **Enable SNI** | `set ssl vserver VS -SNIEnable ENABLED` |
| **Add CRL** | `add ssl crl MyCRL -crlPath /nsconfig/ssl/ca.crl` |
| **Add OCSP Responder** | `add ssl ocspResponder MyOCSP -url "http://ocsp.example.com"` |
| **Add SSL Profile** | `add ssl profile PROF -sslProfileType FrontEnd -tls12 ENABLED` |
| **Bind Cipher** | `bind ssl vserver VS -cipherName CIPHER -cipherPriority 1` |
| **Show SSL Stats** | `stat ssl` |
| **Show VServer SSL** | `show ssl vserver VS` |
| **Save Config** | `save ns config` |

---

> 💡 **Key Best Practices for Citrix ADC PKI:**
> - **Always use `update ssl certKey`** for rotations — it's zero-downtime and updates live
> - **Always `save ns config`** after any certificate change
> - **Link certificate chains properly** — missing intermediates cause trust failures
> - **Use SSL Profiles** (Citrix recommends profiles over per-vserver SSL settings)
> - **Enable SNI** when hosting multiple domains on the same VIP
> - **Disable SSLv3, TLSv1.0, TLSv1.1** — only enable TLS 1.2 and 1.3
> - **Set notification periods** on certKeys for proactive expiry alerts
> - **Use OCSP Stapling** to improve TLS handshake performance
> - **Test with `openssl s_client`** after every certificate change
> - **Keep backups** of certificate and key files before rotation
> - **Use the NITRO API** for automation and bulk operations
