/system identity set name=HQ-BORDER2
/ip address add address=10.1.254.2/32 interface=lo
/ipv6 address add address=fdce:f6ae:a8d8:10fe::2/128 interface=lo advertise=no
/ip address add address=10.1.255.9/30 interface=ether3 comment="L3 HQ-BORDER2-HQ-FW1"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::4/127 interface=ether3 advertise=no comment="L3 HQ-BORDER2-HQ-FW1"
/ip address add address=10.1.255.13/30 interface=ether4 comment="L4 HQ-BORDER2-HQ-FW2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::6/127 interface=ether4 advertise=no comment="L4 HQ-BORDER2-HQ-FW2"
/ip address add address=10.1.255.18/30 interface=ether2 comment="L5 HQ-BORDER1-HQ-BORDER2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::9/127 interface=ether2 advertise=no comment="L5 HQ-BORDER1-HQ-BORDER2"
/ip address add address=203.0.113.6/30 interface=ether1 comment="WAN hacia ISP2"
/ipv6 address add address=2001:db8:ffff:2::2/64 interface=ether1 advertise=no comment="WAN hacia ISP2"
/ip route add dst-address=0.0.0.0/0 gateway=203.0.113.5 comment="ruta por defecto provisional"
