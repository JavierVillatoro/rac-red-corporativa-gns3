/system identity set name=HQ-DIST1
/ip address add address=10.1.254.21/32 interface=lo
/ipv6 address add address=fdce:f6ae:a8d8:10fe::21/128 interface=lo advertise=no
/ip address add address=10.1.255.46/30 interface=ether1 comment="L12 HQ-CORE1-HQ-DIST1"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::17/127 interface=ether1 advertise=no comment="L12 HQ-CORE1-HQ-DIST1"
/ip address add address=10.1.255.54/30 interface=ether2 comment="L14 HQ-CORE2-HQ-DIST1"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::1b/127 interface=ether2 advertise=no comment="L14 HQ-CORE2-HQ-DIST1"
/ip address add address=10.1.255.61/30 interface=ether3 comment="L16 HQ-DIST1-HQ-DIST2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::1e/127 interface=ether3 advertise=no comment="L16 HQ-DIST1-HQ-DIST2"
