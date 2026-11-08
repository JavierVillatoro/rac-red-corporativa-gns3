/system identity set name=B1-R1
/ip address add address=10.2.254.1/32 interface=lo
/ipv6 address add address=fdce:f6ae:a8d8:20fe::1/128 interface=lo advertise=no
/ip address add address=10.2.255.1/30 interface=ether2 comment="enlace B1-R1-B1-R2"
/ipv6 address add address=fdce:f6ae:a8d8:20ff::/127 interface=ether2 advertise=no comment="enlace B1-R1-B1-R2"
/ip address add address=203.0.113.10/30 interface=ether1 comment="WAN hacia ISP1"
/ipv6 address add address=2001:db8:ffff:3::2/64 interface=ether1 advertise=no comment="WAN hacia ISP1"
/ip route add dst-address=0.0.0.0/0 gateway=203.0.113.9 comment="ruta por defecto provisional"
