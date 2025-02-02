# P3

## Steps
First of all, in our topology, all routers will configure their ethX interfaces.
Then OSPF will establish a connectivity between theses routers thanks to ethX. So the route reflector will see the 3 leaves thanks to OSPF, via 192.16.1.x addresses. And each leaves will establish a link with RR thanks to their eth1.
Thanks to OSPF and this primary link established, the RR can learn route to loopback address of each leaves, and each leaves can learn the route to the loopback of RR. This is essential because BGP will use the loopback addresses 1.1.1.x.
BGP can now start its work : RR will establish BGP sessions et listen on 1.1.1.1 all request from 1.1.1.x. Each leaves will also establish connexion with 1.1.1.1 of RR. We can now exchange between leaf loopback and RR loopback. So BGP can now exchange evpn route (which have 3 informations: VNI (vxlan identifier), MAC addresses, IP addresses).
So when we activate EVPN, leaves will send their available VNI to RR thanks to BGP-EVPN. RR will transmit this information to others leaves. (if VXLAN was not set yet, nothing is transmit at this point. But as soon as vxlan0 will be set up on vxlan id 10, FRR will detect that VNI 10 is actve and the routers leafs will anniounce it immediatly to RR thanks to bgp-evpn).
exemple: leaf1 say "I have a VNI 10", and RR send it to 2 others leafs "leaf1 has a VNI 10" and vice versa.
Once leaves kno who is on VNI 10 thanks to BGP-EVPN, it will automatically create VXLAN tunnels to the others leaves, so now each leaves can exchange layer 2 trafic with others.

Resume :
    • Interfaces (ethX, lo).
    • OSPF start and learn routes between leafs and RR via 192.16.1.x.
    • BGP → Establishment of session with RR via loopbacks (1.1.1.x)
    • EVPN → Announce VNI.
    • VXLAN → Creation and attachment of tunnels. VXLAN tunnels will be established and will allow trafic.

## Route Reflector
The route reflector is use in BGP network to simplify the management of BGP session. In basic BGP, all routers have to establish a peer-to-peer relation with all others routers (full mesh model), but it is not appropriate for a large network.
So, the route reflector allow to centralize routage informations, so the leafs only need to send to RR and not to all routers. Each routers connected to the RR is a client of it. Each client send routage informations to RR and RR propagate theses information to all client into same groups.

## Leafs
The leafs are clients of Route reflector, they are switches or routers (in this project, routers) that connect hosts to the network. Thanks to the RR, the leafs learn routes of others leafs. It send data localy (if intra leaf) or send to a spine (inter-leaf).

## lo
Loopback interface is generally associate to loop address 127.0.0.1. But in routage contexte (OSPF, BGP), lo is used differently and we have to attribute it an other address, unic and stable. It allow to give an identifier stable to a router because the loopback never breaks down.
So the new IP address attribute to lo allow to :
- give a Router ID to BGP and OSPF protocol
- get an endpoint stable for VXLAN

For router ID, if we don't set a loopback address, ospf and bgp will choose highest address but this one can change and create instability on the network.

## EVPN
Ethernet Virtual Private Network use BGP to propagate informations without flooding. Without EVPN, when a switch learn MAC addresse and if it don't know a MAC addresse it flood on all port. In a data center, it can cause problem of massive flooding.
So with EVPN, each router announce MAC and IP addresses of its hosts thanks to bgp. So when an host want to send a packet, the router already know where to transmit it.
exemple:

Leaf1 and leaf2 are linked by a vxlan. host1 is connected to leaf1. leaf1 learn MAC and IP address of host1. Leaf1 announce these addresse thanks to bgp, (route type 2). leaf2 now know that if he need to send to host1, it need to pass by leaf1 without send to everyone.

## route type 2
Route type 2 is use for unicast trafic.
When EVPN uses BGP route type 2, it announces IP and MAC addresse that are connected to VTEP of VXLAN. When a switch or router detect a new MAC address on local port it create a route type 2 and announce this MAC addresse (and IP address if one is associated to MAC addresse) thanks to BGP EVPN. Other node receive this information and stocks it in their routage table.

## route type 3
Route type 3 is use for BUM (Broadcast/Unknown Unicast/Multicast). 
A router use this route to receive data destinated to Broadcast, unknown Unicast or multicast.
For exemple:
Leaf1, leaf2 and leaf3 are connected by VXLAN and bgp EVPN. When they join the vxlan, they automatically announce a route type 3 via BGP. So anyone on vxlan know hat is they receive a broadcast to transmit, it can send to anyone that previously announce a route type 3.

## OSPF
Open Shortest Path First allow to find the shortest path to a destination. It works automatically (no need to manually configure static route). 
It works on intern network.
OSPF send "hello packet" to detect neighbor, then routeur discovered share information on their own link. With new information, ospf calcul shortest path.
In VXLAN context, ospf allow to share route between VTEP (vxlan tunnel endpoint that encapsulate and deencapsulate ethernet frame) and give a ubderlay network stable to vxlan. In EVPN context, it allow connexion between many data centers.
