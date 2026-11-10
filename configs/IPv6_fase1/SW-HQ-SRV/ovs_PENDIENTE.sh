# SW-HQ-SRV1 / SW-HQ-SRV2 (Open vSwitch) - PREPARADO, SIN APLICAR.
# Despues de aplicarlo, activar ether6/ether7 en los dos DIST:
#   /interface bridge port enable [find interface=ether6]
#   /interface bridge port enable [find interface=ether7]

# --- SW-HQ-SRV1 ---
ovs-vsctl set port eth0 trunks=70,80,99
ovs-vsctl set port eth1 trunks=70,80,99
ovs-vsctl set port eth2 tag=70   # HQ-SRV-STO1
ovs-vsctl set port eth3 tag=80   # HQ-SRV-CPU1
ovs-vsctl set port eth4 tag=99   # HQ-MON
ovs-vsctl set port eth5 tag=99   # HQ-GRAFANA
ovs-vsctl set bridge br0 rstp_enable=true
ovs-vsctl set bridge br0 other_config:rstp-priority=61440

# --- SW-HQ-SRV2 ---
ovs-vsctl set port eth0 trunks=70,80,99
ovs-vsctl set port eth1 trunks=70,80,99
ovs-vsctl set port eth2 tag=70   # HQ-SRV-STO2
ovs-vsctl set port eth3 tag=80   # HQ-SRV-CPU2
ovs-vsctl set port eth4 tag=99   # HQ-RADIUS
ovs-vsctl set bridge br0 rstp_enable=true
ovs-vsctl set bridge br0 other_config:rstp-priority=61440
