# HQ-CORE1 - Variante "solo IPv6". Solo encamina: enlaces punto a punto, sin VLAN.
# Prefijo de enlace 2001:db8:1:ffXX::/64 -> equipo de capa superior ::1, inferior ::2

/system identity set name=HQ-CORE1
/interface ethernet set ether1 comment="to HQ-FW1"
/interface ethernet set ether2 comment="to HQ-FW2"
/interface ethernet set ether3 comment="to HQ-CORE2"
/interface ethernet set ether4 comment="to HQ-DIST1"
/interface ethernet set ether5 comment="to HQ-DIST2"

/ipv6 address add address=2001:db8:1:ffff::21/128 interface=lo advertise=no
/ipv6 address add address=2001:db8:1:ff41::2/64 interface=ether1 advertise=no
/ipv6 address add address=2001:db8:1:ff51::2/64 interface=ether2 advertise=no
/ipv6 address add address=2001:db8:1:ff60::1/64 interface=ether3 advertise=no
/ipv6 address add address=2001:db8:1:ff71::1/64 interface=ether4 advertise=no
/ipv6 address add address=2001:db8:1:ff72::1/64 interface=ether5 advertise=no
