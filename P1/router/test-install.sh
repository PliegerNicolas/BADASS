#! /bin/sh

/usr/lib/frr/zebra -d -F traditional -A 127.0.0.1 -s 90000
/usr/lib/frr/bgpd -d -F traditional -A 127.0.0.1
/usr/lib/frr/ospfd -d -F traditional -A 127.0.0.1
/usr/lib/frr/isisd -d -F traditional -A 127.0.0.1
/bin/sh -c "while true; do TERM=vt100 /gns3/bin/busybox sh; done"
