# P3

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


