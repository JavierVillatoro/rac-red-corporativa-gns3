# HQ-DIST2 - Fase 3.1: bridge con RSTP y VLAN (nivel 2). Aplicar despues de 01 y 02.
# DIST2 es la raiz de respaldo de RSTP. ether3 (L16) pasa a troncal y sus IP a la VLAN 255.
/interface bridge add name=br-hq protocol-mode=rstp priority=0x2000 vlan-filtering=no comment="bridge de HQ, raiz de respaldo RSTP"
/interface bridge port add bridge=br-hq interface=ether3 frame-types=admit-only-vlan-tagged comment="troncal a HQ-DIST1"
/interface bridge port add bridge=br-hq interface=ether4 frame-types=admit-only-vlan-tagged comment="troncal a SW-HQ-ACC1"
/interface bridge port add bridge=br-hq interface=ether5 frame-types=admit-only-vlan-tagged comment="troncal a SW-HQ-ACC2"
/interface bridge vlan add bridge=br-hq vlan-ids=10,20,30 tagged=br-hq,ether3,ether4 comment="usuarios en SW-HQ-ACC1"
/interface bridge vlan add bridge=br-hq vlan-ids=40,50,60 tagged=br-hq,ether3,ether5 comment="usuarios en SW-HQ-ACC2"
/interface bridge vlan add bridge=br-hq vlan-ids=70,80 tagged=br-hq,ether3 comment="servidores (SW-HQ-SRV1/2 mas adelante)"
/interface bridge vlan add bridge=br-hq vlan-ids=99 tagged=br-hq,ether3,ether4,ether5 comment="gestion"
/interface bridge vlan add bridge=br-hq vlan-ids=255 tagged=br-hq,ether3 comment="transito DIST1-DIST2 (L16)"
/interface vlan add name=vlan10-INV interface=br-hq vlan-id=10
/interface vlan add name=vlan20-COM interface=br-hq vlan-id=20
/interface vlan add name=vlan30-VEN interface=br-hq vlan-id=30
/interface vlan add name=vlan40-CUR interface=br-hq vlan-id=40
/interface vlan add name=vlan50-SOP interface=br-hq vlan-id=50
/interface vlan add name=vlan60-GUEST interface=br-hq vlan-id=60
/interface vlan add name=vlan70-STO interface=br-hq vlan-id=70
/interface vlan add name=vlan80-CPU interface=br-hq vlan-id=80
/interface vlan add name=vlan99-MGMT interface=br-hq vlan-id=99
/interface vlan add name=vlan255-TRANS interface=br-hq vlan-id=255
/ip address remove [find interface=ether3]
/ipv6 address remove [find interface=ether3 dynamic=no]
/ip address add address=10.1.255.62/30 interface=vlan255-TRANS comment="L16 HQ-DIST1-HQ-DIST2 (VLAN 255)"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::1f/127 interface=vlan255-TRANS advertise=no comment="L16 HQ-DIST1-HQ-DIST2 (VLAN 255)"
/interface bridge set br-hq vlan-filtering=yes
