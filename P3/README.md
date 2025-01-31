# P3

!! TO DO traduction:
Tout d’abord, tous les routeurs configure leur interfce  physique ethx.
Ensuire ospf va etablir une connectivite de base entre ces routeur, via les interface precedemment set. Ainsi le RR va voir les 3 leafs grace a ospf, via les addresse 10.1.1.x Et chaque leafs va etablir un lien avec RR via leur eth1. Grace a cela le RR va apprendre les routes vers les addresses loopback des leaf, et les leaf vont apprendre la route vers l’addresse loopback de RR. Ce qui est essentiel puisque bgp va passer par les addresse loopback 1.1.1.x
Ensuite BGP se met en place. RR va etablir des sessions et va ecouter sur 1.1.1.1 toute les demande provenant de 1.1.1.x.. et de leur cote, les leaf etablissent aussi une connexion avec 1.1.1.1 du RR. Il y a desormais un pont entre leur propre loopback et le loopback du RR. BGP peut ainsi commencer a echanger les route evpn (c’est a dire une rouet qui comporte 3 info principale : les VNI, les addresses MAC et les addresses IP). 
Donc a l’activation de l’EVPN, les leaf  vont envoyer leur VNI vers RR via BGP-EVPN, et le RR retransmet l’information aux autres leaf. (Si vxlan0 n’etait  pas encore set up, il ne se transmet rien pour l’instant. Des que vxlan0 est set up sur l’id 10, FRR detetcte dynamiquement que le VNI10 est actif, et les annonce via BGP-EVPN peuvent avoir lieux). Donc leaf1 dit « j’ai un VNI 10 » et RR envoie aux 2 autre leafs « leaf1 a un vni 10, et inversement.
Une fois que les leaf sait qui participe au VNI 10 grace a BGP-EVPN il cree automatiquement les tunnels vxlan vers les autres leafs, ainsi chaque leaf peut echanger du trafic de niveau 2 entre eux.
Resume :
    • Interfaces (ethX, lo).
    • OSPF démarre et apprend les routes entre les Leafs et le RR via 10.1.1.x.
    • BGP → Établissement des sessions avec le RR via les loopbacks (1.1.1.x)
    • EVPN → Annonce des VNI.
    • VXLAN → Création et attachement des tunnels Les tunnels VXLAN s’établissent et permettent l’échange de trafic.

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
