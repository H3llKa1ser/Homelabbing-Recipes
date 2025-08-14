# Firewall Rules Configuration

#### 1) Configure UserNetwork LAN rules

In the PfSense administration portal, go to:

    Firewall -> Rules -> USERNETWORK

Click "Add rule to the top of the list"

<img width="564" height="119" alt="image" src="https://github.com/user-attachments/assets/f304cc8b-0a13-4e64-9c2d-1acc912e5cfa" />

Then, create a rule with these parameters:

    Action: Block
    Address Family: Ipv4+IPv6
    Protocol: Any
    Source: USERNETWORK subnets
    Destination: WAN subnets
    Description: Block access to services on WAN interface

Scroll to the bottom and click on Save.

<img width="1917" height="827" alt="image" src="https://github.com/user-attachments/assets/7865362b-506d-43ac-a671-d60b3e6c3891" />

### TIP: The order of the rules is important. If the order is not correct. Drag the rules around till it matches the above image.
