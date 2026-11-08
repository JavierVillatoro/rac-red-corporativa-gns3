/system identity set name=ISP1
/ip address add address=203.0.113.1/30 interface=ether3 comment="WAN ISP1-HQ-BORDER1"
/ipv6 address add address=2001:db8:ffff:1::1/64 interface=ether3 advertise=no comment="WAN ISP1-HQ-BORDER1"
/ip address add address=203.0.113.9/30 interface=ether4 comment="WAN ISP1-B1-R1"
/ipv6 address add address=2001:db8:ffff:3::1/64 interface=ether4 advertise=no comment="WAN ISP1-B1-R1"
/ip address add address=203.0.113.13/30 interface=ether5 comment="WAN ISP1-B2-R1"
/ip address add address=203.0.113.29/30 interface=ether1 comment="peering ISP1-ISP2"
/ipv6 address add address=2001:db8:ffff:6::1/64 interface=ether1 advertise=no comment="peering ISP1-ISP2"
/ip dhcp-client add interface=ether2 disabled=no
/ip firewall nat add chain=srcnat out-interface=ether2 action=masquerade
/ip route add dst-address=203.0.113.4/30 gateway=203.0.113.30
/ip route add dst-address=203.0.113.16/30 gateway=203.0.113.30
/ip route add dst-address=203.0.113.20/30 gateway=203.0.113.30
/ip route add dst-address=203.0.113.24/30 gateway=203.0.113.30
/ipv6 route add dst-address=2001:db8:ffff:2::/64 gateway=2001:db8:ffff:6::2
/ipv6 route add dst-address=2001:db8:ffff:4::/64 gateway=2001:db8:ffff:6::2
/ipv6 route add dst-address=2001:db8:ffff:5::/64 gateway=2001:db8:ffff:6::2
