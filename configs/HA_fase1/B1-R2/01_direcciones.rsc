/system identity set name=B1-R2
/ip address add address=10.2.254.2/32 interface=lo
/ipv6 address add address=fdce:f6ae:a8d8:20fe::2/128 interface=lo advertise=no
/ip address add address=10.2.255.2/30 interface=ether2 comment="enlace B1-R2-B1-R1"
/ipv6 address add address=fdce:f6ae:a8d8:20ff::1/127 interface=ether2 advertise=no comment="enlace B1-R2-B1-R1"
/ip address add address=203.0.113.18/30 interface=ether1 comment="WAN hacia ISP2"
/ipv6 address add address=2001:db8:ffff:4::2/64 interface=ether1 advertise=no comment="WAN hacia ISP2"
/ip route add dst-address=0.0.0.0/0 gateway=203.0.113.17 comment="ruta por defecto provisional"
