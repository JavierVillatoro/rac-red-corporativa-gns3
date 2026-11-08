/system identity set name=B2-R2
/ip address add address=10.3.254.2/32 interface=lo
/ip address add address=10.3.255.2/30 interface=ether2 comment="enlace B2-R2-B2-R1"
/ip address add address=203.0.113.22/30 interface=ether1 comment="WAN hacia ISP2"
/ip route add dst-address=0.0.0.0/0 gateway=203.0.113.21 comment="ruta por defecto provisional"
