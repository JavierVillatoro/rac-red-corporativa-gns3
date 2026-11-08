/system identity set name=HQ-BORDER1
/ip address add address=10.1.254.1/32 interface=lo
/ipv6 address add address=fdce:f6ae:a8d8:10fe::1/128 interface=lo advertise=no
/ip address add address=10.1.255.1/30 interface=ether3 comment="L1 HQ-BORDER1-HQ-FW1"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::0/127 interface=ether3 advertise=no comment="L1 HQ-BORDER1-HQ-FW1"
/ip address add address=10.1.255.5/30 interface=ether4 comment="L2 HQ-BORDER1-HQ-FW2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::2/127 interface=ether4 advertise=no comment="L2 HQ-BORDER1-HQ-FW2"
/ip address add address=10.1.255.17/30 interface=ether2 comment="L5 HQ-BORDER1-HQ-BORDER2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::8/127 interface=ether2 advertise=no comment="L5 HQ-BORDER1-HQ-BORDER2"
/ip address add address=203.0.113.2/30 interface=ether1 comment="WAN hacia ISP1"
/ipv6 address add address=2001:db8:ffff:1::2/64 interface=ether1 advertise=no comment="WAN hacia ISP1"
/ip route add dst-address=0.0.0.0/0 gateway=203.0.113.1 comment="ruta por defecto provisional"
