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

Before creating the rules for USERNETWORK, we need to create an Alias. 

Go to:

    Firewall -> Aliases -> IP

Click Add, then enter the following:

    Name: RFC1918
    Description: Private IPv4 Address Space
    Type: Network(s)
    Network 1: 10.0.0.0/8    
    Network 2: 172.16.0.0/12    
    Network 3: 192.168.0.0/16
    Network 4: 169.254.0.0/16
    Network 5: 127.0.0.0/8

Click Save to create an Alias

Then, click "Apply Changes"

Now go to:

    Firewall -> Rules

And select the USERNETWORK tab

Select the "Add rule to the end of the list" button

Enter the following:

    Address Family: IPv4+IPv6
    Protocol: Any
    Source: CYBER_RANGE subnets
    Destination: CYBER_RANGE address
    Description: Allow traffic to all devices on the USERNETWORK network

Click Save

Create another rule "Add rule to end"

Enter the following

    Protocol: Any
    Source: USERNETWORK subnets
    Destination: Address or Alias - 10.0.0.2
    Description: Allow traffic to Attacker VM (Kali)

Click Save

Create another rule "Add rule to end"

Enter the following

    Protocol: Any
    Source: CYBER_RANGE subnets
    Destination: Address or Alias - RFC1918 (Select Invert match)
    Description: Allow to any non-private IPv4 Address

Click Save

Create another rule "Add rule to end"

    Action: Block
    Address Family: IPv4+IPv6
    Protocol: Any
    Source: USERNETWORK subnets
    Description: Block access to everything

Click Save

Final results

<img width="1920" height="823" alt="image" src="https://github.com/user-attachments/assets/89a9173a-eae3-49ea-b179-26ab8d4c795c" />

