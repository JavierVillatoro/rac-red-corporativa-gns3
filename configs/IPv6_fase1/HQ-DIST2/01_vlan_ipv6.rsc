# HQ-DIST2 - Variante "solo IPv6" (pendiente de confirmar con el profesor)
# Bridge con VLAN + RSTP (root de respaldo), interfaces VLAN con ::3, RA para SLAAC.
# Aplicado y probado a mano en la consola.

/system identity set name=HQ-DIST2
/interface ethernet set ether1 comment="to HQ-CORE1"
/interface ethernet set ether2 comment="to HQ-CORE2"
/interface ethernet set ether3 comment="to HQ-DIST1 troncal"
/interface ethernet set ether4 comment="to SW-HQ-ACC1"
/interface ethernet set ether5 comment="to SW-HQ-ACC2"
/interface ethernet set ether6 comment="to SW-HQ-SRV1"
/interface ethernet set ether7 comment="to SW-HQ-SRV2"

# Bridge: DIST2 es root de respaldo
/interface bridge add name=br-hq protocol-mode=rstp priority=0x2000 vlan-filtering=no

# Puertos troncales. ether6/ether7 desactivados hasta configurar RSTP en SW-HQ-SRV1/2
/interface bridge port add bridge=br-hq interface=ether3 frame-types=admit-only-vlan-tagged
/interface bridge port add bridge=br-hq interface=ether4 frame-types=admit-only-vlan-tagged
/interface bridge port add bridge=br-hq interface=ether5 frame-types=admit-only-vlan-tagged
/interface bridge port add bridge=br-hq interface=ether6 frame-types=admit-only-vlan-tagged disabled=yes
/interface bridge port add bridge=br-hq interface=ether7 frame-types=admit-only-vlan-tagged disabled=yes

# Tabla de VLAN
/interface bridge vlan add bridge=br-hq vlan-ids=10,20,30 tagged=br-hq,ether3,ether4
/interface bridge vlan add bridge=br-hq vlan-ids=40,50,60,65 tagged=br-hq,ether3,ether5
/interface bridge vlan add bridge=br-hq vlan-ids=70,80 tagged=br-hq,ether3,ether6,ether7
/interface bridge vlan add bridge=br-hq vlan-ids=99 tagged=br-hq,ether3,ether4,ether5,ether6,ether7

# Interfaces de capa 3, una por VLAN
/interface vlan add name=vlan10-INV interface=br-hq vlan-id=10
/interface vlan add name=vlan20-COM interface=br-hq vlan-id=20
/interface vlan add name=vlan30-VEN interface=br-hq vlan-id=30
/interface vlan add name=vlan40-CUR interface=br-hq vlan-id=40
/interface vlan add name=vlan50-SOP interface=br-hq vlan-id=50
/interface vlan add name=vlan60-GUEST interface=br-hq vlan-id=60
/interface vlan add name=vlan65-WIFI interface=br-hq vlan-id=65
/interface vlan add name=vlan70-STO interface=br-hq vlan-id=70
/interface vlan add name=vlan80-CPU interface=br-hq vlan-id=80
/interface vlan add name=vlan99-MGMT interface=br-hq vlan-id=99

# Direcciones IPv6
/ipv6 address add address=2001:db8:1:ffff::32/128 interface=lo advertise=no
/ipv6 address add address=2001:db8:1:ff72::2/64 interface=ether1 advertise=no
/ipv6 address add address=2001:db8:1:ff82::2/64 interface=ether2 advertise=no
/ipv6 address add address=2001:db8:1:10::3/64 interface=vlan10-INV
/ipv6 address add address=2001:db8:1:20::3/64 interface=vlan20-COM
/ipv6 address add address=2001:db8:1:30::3/64 interface=vlan30-VEN
/ipv6 address add address=2001:db8:1:40::3/64 interface=vlan40-CUR
/ipv6 address add address=2001:db8:1:50::3/64 interface=vlan50-SOP
/ipv6 address add address=2001:db8:1:60::3/64 interface=vlan60-GUEST
/ipv6 address add address=2001:db8:1:65::3/64 interface=vlan65-WIFI
/ipv6 address add address=2001:db8:1:70::3/64 interface=vlan70-STO
/ipv6 address add address=2001:db8:1:80::3/64 interface=vlan80-CPU
/ipv6 address add address=2001:db8:1:99::3/64 interface=vlan99-MGMT

/ipv6 nd set [find default=yes] ra-interval=3s-10s ra-lifetime=30s

# Siempre lo ultimo
/interface bridge set br-hq vlan-filtering=yes
