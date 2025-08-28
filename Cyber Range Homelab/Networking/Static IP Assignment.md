# Static IP Assignment

#### 1) Attacker VM

In the PfSense administration portal, go to 

    Status -> DHCP Leases

In the Leases section, we should see the Kali Linux VM with its current IP address. Click on the highlighted + icon to assign a static IP to Kali Linux. The static IP will make it easier for us to apply firewall rules to interfaces that should only be able to reach the Kali VM.

In the IP Address input enter 10.0.0.2. Scroll to the bottom and click on Save. Then Apply Changes.

Now, refresh Kali IP Address with these commands:

### Check current IP Address

    ip a l eth0

### Release the current IP and use the static IP that was reserved instead

    sudo ip l set eth0 down && sudo ip l set eth0 up

### Check again to verify

    ip a l eth0

