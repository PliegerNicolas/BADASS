# P2

## OSI model (layers)

[OSI model](https://en.wikipedia.org/wiki/OSI_model).

In P2 we only cover layers: 1, 2, 3.
- **Layer 1 (Physical):** Transmission and reception of raw bit streams over a physical medium (ethernet cable, radio waves...).
- **Layer 2 (Data Link):** Transmission of *data frames* between two nodes connected by layer 1 (a physical layer).
- **Layer 3 (Network):** Structuring and managing a multi-node network via addressing, routing and traffic control. This happens usually in software within network devices (routers and layer3 switches).

## Network devices

**Switch**: is a device that operates at OSI layer 2. Nowadays some support OSI layer 3 capabilities.
The primary function of a switch is to forward traffic within a LAN thus over OSI layer 2.
It builds a MAC address table to enable efficient communication.

**Router**: is a device that operates at OSI layer 3. It forward packets between different networks (LANs, WANs, internet...) using IP addresses. It builds a routing table to determine the best path forwarding an IP packet to it's destination, pointing to the best "next hop". The routing table can be built and updated using routing protocols such as BGP, OSPF and ISIS.
A router is also often used to expose one IP address to communicate with multiple underlying networks and connected services.

**Bridge**: is a device that operates at OSI layer 2 and functions similarly to a switch. Both devices forward frames based on MAC addresses and build a MAC address table. The bridge is considered the ancestor of the switch. It provides less functionalities but is more straight forward to setup.

## VXLAN (virtual extensible LAN)

[VXLAN](https://en.wikipedia.org/wiki/Virtual_Extensible_LAN) is a network virtualization technology. It simulates a Layer2 connection over Layer3.

The VXLAN base case is to connect two or more Layer3 network domains and make them look like a common Layer2 domain. This allows virtual machines or different subnets to communicate as if they were in the same layer 2 subnet.
It addresses usual scalability problems, popular in cloud computing deployments.

See [VXLAN's RFC7348](https://datatracker.ietf.org/doc/html/rfc7348) specifications here.
