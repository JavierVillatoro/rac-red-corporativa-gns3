/system identity set name=B2-R1
/ip address add address=10.3.254.1/32 interface=lo
/ip address add address=10.3.255.1/30 interface=ether2 comment="enlace B2-R1-B2-R2"
/ip address add address=203.0.113.14/30 interface=ether1 comment="WAN hacia ISP1"
/ip route add dst-address=0.0.0.0/0 gateway=203.0.113.13 comment="ruta por defecto provisional"
