# Home Network Setup

## Step 1: Connect the Modem

The first step is to connect your modem to your ISP's service line.

- Cable Internet: Connect the coaxial cable from your wall outlet to the "Cable In" or "RF In" port on your cable modem.

- DSL Internet: Connect the phone line from your wall jack (often through a DSL filter) to the "DSL" port on your DSL modem.

- Fiber Internet (ONT): The fiber optic line usually terminates at an Optical Network Terminal (ONT) installed by your ISP. The ONT will have an Ethernet output port. This is effectively your "modem" in a fiber setup.

- Power On: Plug the modem's power adapter into an electrical outlet and turn it on. Wait a few minutes for the modem to establish a connection with your ISP. You'll typically see indicator lights on the modem turn solid (e.g., Power, DSL/Cable/Optical Link, Internet/WAN) to confirm it's online. Refer to your modem's manual for specific light indicators.

## Step 2: Connect the Router

Once your modem is online, you can connect your wireless router.

### 1) Ethernet Cable Connection: 

Take an Ethernet cable (typically included with your router) and connect one end to the Ethernet port on your modem. Connect the other end to the WAN (Wide Area Network) or Internet port on your router. This port is usually a different color (e.g., blue) and clearly labeled, distinguishing it from the LAN ports.

### 2) Power On: 

Plug the router's power adapter into an electrical outlet and turn it on. Wait for the router to boot up. Like the modem, the router will have indicator lights. Look for a solid "Internet" or "WAN" light, indicating it's receiving a signal from the modem. Also, look for a Wi-Fi indicator light.

## Step 3: Initial Router Configuration (Wired Connection Recommended)

Before configuring wireless settings, it's often easiest and most reliable to connect a computer directly to the router via an Ethernet cable. This ensures you have a stable connection during the initial setup.

### 1) Connect Computer: 

Connect an Ethernet cable from one of the router's LAN ports (usually yellow or black, labeled 1, 2, 3, 4) to the Ethernet port on your computer's NIC.

### 2) Access Router Interface:

- Open a web browser (e.g., Chrome, Firefox, Edge) on the connected computer.

- In the address bar, type your router's default IP address. Common default IP addresses are 192.168.0.1, 192.168.1.1, or 192.168.1.254. This IP address is your router's local address, which also serves as the default gateway for devices on your network. (You can find this IP on a sticker on the router or in its manual.)

- Press Enter. You'll be prompted for a username and password. Default credentials are often admin/admin, admin/password, or admin with no password. It is crucial to change these default credentials immediately for security reasons.

### 3) Run Setup Wizard: 

Most modern routers have a setup wizard that guides you through the initial configuration steps.

## Step 4: Configure Basic Router Settings

Within the router's web interface, you'll configure essential settings.

### 1) Change Default Login Credentials: 

Navigate to the "Administration," "System," or "Security" section and change the default username and password for accessing the router's interface. This prevents unauthorized access to your network settings.

### 2) WAN (Internet) Settings:

- For most home users, the router will automatically obtain an IP address from the ISP via DHCP (Dynamic Host Configuration Protocol). Confirm this setting is typically "Dynamic IP" or "DHCP Client".

- In some cases, your ISP might require a PPPoE (Point-to-Point Protocol over Ethernet) username and password or a static IP address. Follow your ISP's instructions if this applies.

### 3) LAN (Local Area Network) Settings:

- The router's LAN IP address (e.g., 192.168.1.1) is the default gateway for all devices on your home network.

- Confirm that the DHCP server is enabled. This ensures that all new devices that connect to your network (wired or wireless) will automatically receive an IP address, subnet mask, and default gateway from your router. This prepares students for the detailed IP addressing and DHCP lesson in Module 3.

## Step 5: Configure Wireless Settings (Wi-Fi)

This is a critical step for connecting your wireless devices.

### 1) Wireless Network Name (SSID):

- Navigate to the "Wireless" or "Wi-Fi" section.

- Set a unique and recognizable SSID (Service Set Identifier), which is the name of your Wi-Fi network (e.g., "MyHomeNetwork", "Family_Wi-Fi"). Avoid using your personal name or address for privacy.

### 2) Security Protocol:

- Choose a strong encryption protocol. WPA2-PSK (AES) is the current minimum recommended standard, with WPA3 being the latest and most secure. Avoid WEP or WPA/WPA-PSK (TKIP) as they are less secure. This relates back to our Wireless Networking lesson.

### 3) Wireless Password (Pre-Shared Key):

- Enter a strong, complex password (also known as a passphrase or Pre-Shared Key - PSK) for your Wi-Fi network. It should be at least 12-16 characters long and include a mix of uppercase and lowercase letters, numbers, and symbols.

### 4) Channel Selection (Optional but Recommended):

- While most routers automatically select the best wireless channel, you might manually adjust it if you experience interference or slow speeds. For the 2.4 GHz band, channels 1, 6, and 11 are non-overlapping. For the 5 GHz band, there are more non-overlapping channels. Use a Wi-Fi analyzer app on your phone to see what channels your neighbors are using and choose a less congested one.

### 5) Save Settings: 

After making changes, click "Apply," "Save," or "OK" to store your configurations. The router may reboot.

## Step 6: Connect Devices to Your Network

With your router configured, you can now connect all your devices.

- Wired Devices: Plug an Ethernet cable from the device's NIC into an available LAN port on your router (or an external switch if you're using one). The device should automatically obtain an IP address from your router's DHCP server.

- Wireless Devices:

1. On your device (laptop, smartphone, tablet, smart TV), open the Wi-Fi settings.
2. Scan for available networks.
3. Select your newly created SSID (e.g., "MyHomeNetwork").
4. Enter the wireless password you set.
5. The device should connect and obtain an IP address from the router.

## Step 7: Verify Connectivity

After connecting devices, confirm they have internet access and can communicate locally.

### 1) Internet Access: 

Open a web browser on a connected device and try to navigate to a website (e.g., google.com). If it loads, you have internet access.

### 2) Check IP Address and Default Gateway:

- Windows: Open Command Prompt and type ipconfig. Look for your Wi-Fi adapter or Ethernet adapter. You should see an IPv4 Address (e.g., 192.168.1.100) and a Default Gateway (which should be your router's LAN IP, e.g., 192.168.1.1).

- macOS/Linux: Open Terminal and type ifconfig or ip a. Look for your network interface (e.g., en0 for Ethernet, en1 or wlan0 for Wi-Fi). You'll find similar IP address and gateway information.

### 3) Basic Local Network Test: 

To confirm local network communication, you can ping your router's IP address from a connected device. For example, in Command Prompt or Terminal, type ping 192.168.1.1 (replace with your router's actual IP). You should receive replies, indicating successful communication within your LAN.
