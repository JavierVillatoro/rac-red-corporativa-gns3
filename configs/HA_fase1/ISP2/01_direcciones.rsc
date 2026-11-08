/system identity set name=ISP2
/ip address add address=203.0.113.5/30 interface=ether3 comment="WAN ISP2-HQ-BORDER2"
/ipv6 address add address=2001:db8:ffff:2::1/64 interface=ether3 advertise=no comment="WAN ISP2-HQ-BORDER2"
/ip address add address=203.0.113.17/30 interface=ether4 comment="WAN ISP2-B1-R2"
/ipv6 address add address=2001:db8:ffff:4::1/64 interface=ether4 advertise=no comment="WAN ISP2-B1-R2"
/ip address add address=203.0.113.21/30 interface=ether5 comment="WAN ISP2-B2-R2"
/ip address add address=203.0.113.25/30 interface=ether2 comment="Teletrabajador"
/ipv6 address add address=2001:db8:ffff:5::1/64 interface=ether2 advertise=no comment="Teletrabajador"
/ip address add address=203.0.113.30/30 interface=ether1 comment="peering ISP1-ISP2"
/ipv6 address add address=2001:db8:ffff:6::2/64 interface=ether1 advertise=no comment="peering ISP1-ISP2"
/ip route add dst-address=0.0.0.0/0 gateway=203.0.113.29
/ipv6 route add dst-address=::/0 gateway=2001:db8:ffff:6::1
