# FRRouting config.

See documentation [here](https://docs.frrouting.org/en/latest/setup.html).

## Systemd

The FRRouting docker image doesn't provide **OpenRC** nor **systemd** as it is meant to be lightweight.
We do not plan using those services to startup frr thus we won't configure it even though the file is available in `./config/frr.service` in case of.
If you still want to configure it, check out documentation.

## Daemons

To activate the necessary daemons, we set them up in the `daemons` file.
We have set the following:

```
bgpd=yes    # BGPD
ospfd=yes   # OSPFD
isisd=yes   #IS-IS
```

As specified by the comments in the file, watchfrr, zebra and staticd are started up by default.

## FRR: Services

As we are using alpine. FRR services ports are defined automatically.
You can check if the following are defined in `/etc/services` using commands such as `cat /etc/services | grep 'ospfd'`.

```
zebrasrv      2600/tcp                 # zebra service
zebra         2601/tcp                 # zebra vty
ripd          2602/tcp                 # RIPd vty
ripngd        2603/tcp                 # RIPngd vty
ospfd         2604/tcp                 # OSPFd vty
bgpd          2605/tcp                 # BGPd vty
ospf6d        2606/tcp                 # OSPF6d vty
ospfapi       2607/tcp                 # ospfapi
isisd         2608/tcp                 # ISISd vty
babeld        2609/tcp                 # BABELd vty
nhrpd         2610/tcp                 # nhrpd vty
pimd          2611/tcp                 # PIMd vty
ldpd          2612/tcp                 # LDPd vty
eigprd        2613/tcp                 # EIGRPd vty
bfdd          2617/tcp                 # bfdd vty
fabricd       2618/tcp                 # fabricd vty
vrrpd         2619/tcp                 # vrrpd vty
```

## Vtysh

No configuration file needed with FRRouting/frr docker image (cf. /etc/frr/vtysh.conf).
