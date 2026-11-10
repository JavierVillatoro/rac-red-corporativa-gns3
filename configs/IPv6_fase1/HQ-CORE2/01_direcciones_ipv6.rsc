# HQ-CORE2 - Variante "solo IPv6". Solo encamina: enlaces punto a punto, sin VLAN.

/system identity set name=HQ-CORE2
/interface ethernet set ether1 comment="to HQ-FW1"
/interface ethernet set ether2 comment="to HQ-FW2"
/interface ethernet set ether3 comment="to HQ-CORE1"
/interface ethernet set ether4 comment="to HQ-DIST1"
/interface ethernet set ether5 comment="to HQ-DIST2"

/ipv6 address add address=2001:db8:1:ffff::22/128 interface=lo advertise=no
/ipv6 address add address=2001:db8:1:ff42::2/64 interface=ether1 advertise=no
/ipv6 address add address=2001:db8:1:ff52::2/64 interface=ether2 advertise=no
/ipv6 address add address=2001:db8:1:ff60::2/64 interface=ether3 advertise=no
/ipv6 address add address=2001:db8:1:ff81::1/64 interface=ether4 advertise=no
/ipv6 address add address=2001:db8:1:ff82::1/64 interface=ether5 advertise=no
