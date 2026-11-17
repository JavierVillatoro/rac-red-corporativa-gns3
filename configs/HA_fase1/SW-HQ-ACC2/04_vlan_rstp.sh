# SW-HQ-ACC2 (Open vSwitch) - Fase 3.1. Pegar en la consola del nodo (bash). Persiste en /etc/openvswitch.
# eth0 -> HQ-DIST1, eth1 -> HQ-DIST2 (troncales) | eth2 CUR, eth3 SOP, eth4 GUEST, eth5 AP-WIFI (acceso)
ovs-vsctl set bridge br0 rstp_enable=true other_config:rstp-priority=61440
ovs-vsctl set port eth0 trunks=40,50,60,99
ovs-vsctl set port eth1 trunks=40,50,60,99
ovs-vsctl set port eth2 tag=40 other_config:rstp-port-admin-edge=true
ovs-vsctl set port eth3 tag=50 other_config:rstp-port-admin-edge=true
ovs-vsctl set port eth4 tag=60 other_config:rstp-port-admin-edge=true
ovs-vsctl set port eth5 tag=60 other_config:rstp-port-admin-edge=true
