/system identity set name=HQ-FW1
/ip address add address=10.1.254.3/32 interface=lo
/ipv6 address add address=fdce:f6ae:a8d8:10fe::3/128 interface=lo advertise=no
/ip address add address=10.1.255.2/30 interface=ether1 comment="L1 HQ-BORDER1-HQ-FW1"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::1/127 interface=ether1 advertise=no comment="L1 HQ-BORDER1-HQ-FW1"
/ip address add address=10.1.255.10/30 interface=ether2 comment="L3 HQ-BORDER2-HQ-FW1"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::5/127 interface=ether2 advertise=no comment="L3 HQ-BORDER2-HQ-FW1"
/ip address add address=10.1.255.21/30 interface=ether3 comment="L6 HQ-FW1-HQ-FW2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::a/127 interface=ether3 advertise=no comment="L6 HQ-FW1-HQ-FW2"
/ip address add address=10.1.255.25/30 interface=ether4 comment="L7 HQ-FW1-HQ-CORE1"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::c/127 interface=ether4 advertise=no comment="L7 HQ-FW1-HQ-CORE1"
/ip address add address=10.1.255.29/30 interface=ether5 comment="L8 HQ-FW1-HQ-CORE2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::e/127 interface=ether5 advertise=no comment="L8 HQ-FW1-HQ-CORE2"
