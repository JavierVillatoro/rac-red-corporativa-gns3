# SW-HQ-ACC1 (Open vSwitch) - Fase 3.1. Pegar en la consola del nodo (bash). Persiste en /etc/openvswitch.
# eth0 -> HQ-DIST1, eth1 -> HQ-DIST2 (troncales) | eth2 INV, eth3 COM, eth4 VEN (acceso)
ovs-vsctl set bridge br0 rstp_enable=true other_config:rstp-priority=61440
ovs-vsctl set port eth0 trunks=10,20,30,99
ovs-vsctl set port eth1 trunks=10,20,30,99
ovs-vsctl set port eth2 tag=10 other_config:rstp-port-admin-edge=true
ovs-vsctl set port eth3 tag=20 other_config:rstp-port-admin-edge=true
ovs-vsctl set port eth4 tag=30 other_config:rstp-port-admin-edge=true
