# Firewall Rules Configuration

#### 1) Configure CYBER_RANGE LAN rules

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

### TIP: The order of the rules is important. If the order is not correct. Drag the rules around till it matches the above image.

Before creating the rules for CYBER_RANGE, we need to create an Alias. 

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

And select the CYBER_RANGE tab

Select the "Add rule to the end of the list" button

Enter the following:

    Address Family: IPv4+IPv6
    Protocol: Any
    Source: CYBER_RANGE subnets
    Destination: CYBER_RANGE address
    Description: Allow traffic to all devices on the CYBER_RANGE network

Click Save

Create another rule "Add rule to end"

Enter the following

    Protocol: Any
    Source: CYBER_RANGE subnets
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
    Source: CYBER_RANGE subnets
    Description: Block access to everything

Click Save

Final results

<img width="1920" height="915" alt="image" src="https://github.com/user-attachments/assets/0769ae71-09d5-4be6-8236-03be0aa93585" />

#### ) Reboot

Go to

    Diagnostics -> Reboot

Click Submit

Once pfSense boots up, you will be redirected to the login page
