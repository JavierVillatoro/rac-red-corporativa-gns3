/system identity set name=HQ-DIST2
/ip address add address=10.1.254.22/32 interface=lo
/ipv6 address add address=fdce:f6ae:a8d8:10fe::22/128 interface=lo advertise=no
/ip address add address=10.1.255.50/30 interface=ether1 comment="L13 HQ-CORE1-HQ-DIST2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::19/127 interface=ether1 advertise=no comment="L13 HQ-CORE1-HQ-DIST2"
/ip address add address=10.1.255.58/30 interface=ether2 comment="L15 HQ-CORE2-HQ-DIST2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::1d/127 interface=ether2 advertise=no comment="L15 HQ-CORE2-HQ-DIST2"
/ip address add address=10.1.255.62/30 interface=ether3 comment="L16 HQ-DIST1-HQ-DIST2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::1f/127 interface=ether3 advertise=no comment="L16 HQ-DIST1-HQ-DIST2"
