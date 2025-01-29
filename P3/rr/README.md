# Router Reflector config

## entrypoint

```
ip addr add 10.1.1.1/30 dev eth0
ip link set eth0 up
ip addr add 10.1.1.5/30 dev eth1
ip link set eth1 up
ip addr add 10.1.1.9/30 dev eth2
ip link set eth2 up
```
Configuration of interface ethernet, eth0 link to leaf1, eth1 link to leaf2, eth2 link to leaf3.
We use mask /30 for addresse 10.1.1.x because a subnet has 4 addresses, with only 2 usable for routers (because first address is for identify the subnet, and last one is for broadcast). So, it allow to create smaller subnet than /24 but allow to avoid loop broadcast in the same way.
```
ip addr add 1.1.1.1/32 dev lo
ip link set lo up
```
A /32 mask means that this address is only accessible on this router. But it can be announce in routage protocole. We use loopback because it is always accessible. 
It will be use by protocole ospf : announce loopback to protocole allow others routers to know to reach this router.
It also be used by BGP to established session with leaf.

## frr.conf
```
router bgp 1
 neighbor LEAF_GROUP peer-group
 neighbor LEAF_GROUP remote-as 1
 neighbor LEAF_GROUP update-source lo
 bgp listen range 1.1.1.0/24 peer-group LEAF_GROUP
```
```
 address-family l2vpn evpn
  neighbor LEAF_GROUP activate
  neighbor LEAF_GROUP route-reflector-client
```
```
router ospf
 network 0.0.0.0/0 area 0 
```
