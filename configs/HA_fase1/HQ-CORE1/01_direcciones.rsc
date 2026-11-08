/system identity set name=HQ-CORE1
/ip address add address=10.1.254.11/32 interface=lo
/ipv6 address add address=fdce:f6ae:a8d8:10fe::11/128 interface=lo advertise=no
/ip address add address=10.1.255.26/30 interface=ether1 comment="L7 HQ-FW1-HQ-CORE1"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::d/127 interface=ether1 advertise=no comment="L7 HQ-FW1-HQ-CORE1"
/ip address add address=10.1.255.34/30 interface=ether2 comment="L9 HQ-FW2-HQ-CORE1"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::11/127 interface=ether2 advertise=no comment="L9 HQ-FW2-HQ-CORE1"
/ip address add address=10.1.255.41/30 interface=ether3 comment="L11 HQ-CORE1-HQ-CORE2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::14/127 interface=ether3 advertise=no comment="L11 HQ-CORE1-HQ-CORE2"
/ip address add address=10.1.255.45/30 interface=ether4 comment="L12 HQ-CORE1-HQ-DIST1"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::16/127 interface=ether4 advertise=no comment="L12 HQ-CORE1-HQ-DIST1"
/ip address add address=10.1.255.49/30 interface=ether5 comment="L13 HQ-CORE1-HQ-DIST2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::18/127 interface=ether5 advertise=no comment="L13 HQ-CORE1-HQ-DIST2"
