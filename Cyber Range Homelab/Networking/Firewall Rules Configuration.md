# Firewall Rules Configuration

### TIP: The order of the rules is important. If the order is not correct, drag the rules around till they match the images shown in this guide.

#### 1) Configure CYBER_RANGE LAN rules

In the PfSense administration portal, go to:

    Firewall -> Rules -> CYBER_RANGE

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

#### 2) Configure LAN firewall rules

Click "Add rule to the top of the list"

<img width="564" height="119" alt="image" src="https://github.com/user-attachments/assets/f304cc8b-0a13-4e64-9c2d-1acc912e5cfa" />

Then, create a rule with these parameters:

    Action: Block
    Address Family: Ipv4+IPv6
    Protocol: Any
    Source: LAN subnets
    Destination: WAN subnets
    Description: Block access to services on WAN interface

Click Save, then apply changes.

Final results

<img width="1883" height="588" alt="image" src="https://github.com/user-attachments/assets/f88fbd2b-0700-4047-a255-0acb286fe575" />

#### 3) Configure AD_LAB rules

Create a rule with the following:

    Action: Block
    Address Family: IPv4+IPv6
    Protocol: Any
    Source: AD_LAB subnets
    Destination: WAN subnets
    Description: Block access to services on WAN interface

Click Save

Create another rule by clicking "Add rule to end"

Rule details:

    Action: Block
    Address Family: IPv4+IPv6
    Protocol: Any
    Source: AD_LAB subnets    
    Destination: CYBER_RANGE subnets
    Description: Block traffic to CYBER_RANGE interface

Click Save

Create another "Add rule to end" rule with the following:

    Address Family: IPv4+IPv6
    Protocol: Any
    Source: AD_LAB subnets
    Description: Allow traffic to all other subnets and Internet

Click Save, then Apply Changes

Final result:

<img width="1914" height="889" alt="image" src="https://github.com/user-attachments/assets/d7fc8e71-4b33-4398-ba3d-402fe0a70295" />

    
#### 4) Reboot

Restart PfSense to make our created firewall rules persistent.

Go to

    Diagnostics -> Reboot

Click Submit

Once pfSense boots up, you will be redirected to the login page
