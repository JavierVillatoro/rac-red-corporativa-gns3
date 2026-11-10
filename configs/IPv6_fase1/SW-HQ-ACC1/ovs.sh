# SW-HQ-ACC1 (Open vSwitch) - consola del nodo. Se guarda en /etc/openvswitch (persistente).
# eth0 -> HQ-DIST1, eth1 -> HQ-DIST2 (troncales) | eth2..eth4 -> PCs (acceso)
ovs-vsctl set port eth0 trunks=10,20,30,99
ovs-vsctl set port eth1 trunks=10,20,30,99
ovs-vsctl set port eth2 tag=10   # HQ-PC-INV
ovs-vsctl set port eth3 tag=20   # HQ-PC-COM
ovs-vsctl set port eth4 tag=30   # HQ-PC-VEN
ovs-vsctl set bridge br0 rstp_enable=true
ovs-vsctl set bridge br0 other_config:rstp-priority=61440
