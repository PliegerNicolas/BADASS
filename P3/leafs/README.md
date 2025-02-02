# Leafs router configuration

Leafs are linked by vxlan.

## entrypoint
```
ip link set eth0 up
```
setting eth0 to link to host.

```
ip link add vxlan0 type vxlan id 10 [local 1.1.1.x] dstport 4789
ip link set dev vxlan0 up
```
setting vxlan. we can set the address 1.1.1.x (that are their respective loopback address) as source VTEP (tunnel endpoint of vxlan) for more stability. If we don't set up local source, Linux will automatically choose source depending on destination (but we have only one interface set, so it will automatically take this interface 10.1.1.x)

```
ip link add br0 type bridge
ip link set dev eth0 master br0
ip link set vxlan0 master br0
ip link set dev br0 up
```
create a bridge to connect eth0 (which is the link to our host) to vxlan (Which allow to propagate to others routers thanks to virtual network).

## frr.conf

```
interface eth1
 ip address 10.1.1.x/30
 ip ospf area 0
```
Setting eth1 (link to router reflector), with a mask /30, because it is a small subnet of only 4 addresses range.
Then, we set up ospf for this interface on the area 0 (main area). That will serve to shared OSPF route with RR, and allow to propagate its own prefixe to others.

```
interface lo
 ip address 1.1.1.x/32
 ip ospf area 0
```
Setting lo addresse. It is an unique and stable addresse that will serve as entry for vxlan, and serve as unique ID to bgp.
We also activate ospf on this interface.
It will allow to bgp to identify the leaf. It also allow to stay identified even if eth1 break down. So, activate ospf on lo allow to ensure connectivity in case of interface change.

```
router bgp 1
 neighbor 1.1.1.1 remote-as 1
 neighbor 1.1.1.1 update-source lo
```
Activate BGP and defined it on AS 1.
Then establish session with the route reflector (which as 1.1.1.1 as lo address and is on BGP 1 too)
Update source lo means that all changes have to be send to RR with our loopback interface, to ensure stability.
BGP will exchange route between all router configure on the same AS.

```
 address-family l2vpn evpn
  neighbor 1.1.1.1 activate
  advertise-all-vni
```
Activate EVPN, and then allow exchange with the neighbor 1.1.1.1 (our Route reflector).
Then announce all VNI (identifier of vxlan) configured on the router (in our case only vxlan id 10) to EVPN. So EVPN can link the vxlan on BGP session to transport information.