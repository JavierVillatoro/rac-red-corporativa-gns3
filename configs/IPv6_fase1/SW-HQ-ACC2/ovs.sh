# SW-HQ-ACC2 (Open vSwitch) - consola del nodo. Se guarda en /etc/openvswitch (persistente).
# eth0 -> HQ-DIST1, eth1 -> HQ-DIST2 (troncales) | eth2..eth5 -> PCs y AP (acceso)
ovs-vsctl set port eth0 trunks=40,50,60,65,99
ovs-vsctl set port eth1 trunks=40,50,60,65,99
ovs-vsctl set port eth2 tag=40   # HQ-PC-CUR
ovs-vsctl set port eth3 tag=50   # HQ-PC-SOP
ovs-vsctl set port eth4 tag=60   # HQ-PC-GUEST
ovs-vsctl set port eth5 tag=65   # HQ-AP-WIFI
ovs-vsctl set bridge br0 rstp_enable=true
ovs-vsctl set bridge br0 other_config:rstp-priority=61440
