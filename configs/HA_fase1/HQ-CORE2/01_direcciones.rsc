/system identity set name=HQ-CORE2
/ip address add address=10.1.254.12/32 interface=lo
/ipv6 address add address=fdce:f6ae:a8d8:10fe::12/128 interface=lo advertise=no
/ip address add address=10.1.255.30/30 interface=ether1 comment="L8 HQ-FW1-HQ-CORE2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::f/127 interface=ether1 advertise=no comment="L8 HQ-FW1-HQ-CORE2"
/ip address add address=10.1.255.38/30 interface=ether2 comment="L10 HQ-FW2-HQ-CORE2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::13/127 interface=ether2 advertise=no comment="L10 HQ-FW2-HQ-CORE2"
/ip address add address=10.1.255.42/30 interface=ether3 comment="L11 HQ-CORE1-HQ-CORE2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::15/127 interface=ether3 advertise=no comment="L11 HQ-CORE1-HQ-CORE2"
/ip address add address=10.1.255.53/30 interface=ether4 comment="L14 HQ-CORE2-HQ-DIST1"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::1a/127 interface=ether4 advertise=no comment="L14 HQ-CORE2-HQ-DIST1"
/ip address add address=10.1.255.57/30 interface=ether5 comment="L15 HQ-CORE2-HQ-DIST2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::1c/127 interface=ether5 advertise=no comment="L15 HQ-CORE2-HQ-DIST2"
