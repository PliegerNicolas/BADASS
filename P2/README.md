# P1

## VXLAN (virtual extensible LAN)

[VXLAN](https://en.wikipedia.org/wiki/Virtual_Extensible_LAN) is a network virtualization technology. It is a Layer 4 technology that simulates a Layer 2 network relative to the [OSI model](https://en.wikipedia.org/wiki/OSI_model).

The layer 2 ethernet frame is encapsulated in a new packet that is constructed for transport over an IP network (layer 3). It uses UDP (at layer 4) to ensure lightweight and fast communication without needing connectio acknowlegement and etc. At layer 4 an UDP VXLAN header is added for tracking purposes.

It addresses usual scalability problems, popular in cloud computing deployments.
