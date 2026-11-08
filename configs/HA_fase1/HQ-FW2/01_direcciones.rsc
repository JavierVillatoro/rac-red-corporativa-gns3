/system identity set name=HQ-FW2
/ip address add address=10.1.254.4/32 interface=lo
/ipv6 address add address=fdce:f6ae:a8d8:10fe::4/128 interface=lo advertise=no
/ip address add address=10.1.255.6/30 interface=ether1 comment="L2 HQ-BORDER1-HQ-FW2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::3/127 interface=ether1 advertise=no comment="L2 HQ-BORDER1-HQ-FW2"
/ip address add address=10.1.255.14/30 interface=ether2 comment="L4 HQ-BORDER2-HQ-FW2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::7/127 interface=ether2 advertise=no comment="L4 HQ-BORDER2-HQ-FW2"
/ip address add address=10.1.255.22/30 interface=ether3 comment="L6 HQ-FW1-HQ-FW2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::b/127 interface=ether3 advertise=no comment="L6 HQ-FW1-HQ-FW2"
/ip address add address=10.1.255.33/30 interface=ether4 comment="L9 HQ-FW2-HQ-CORE1"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::10/127 interface=ether4 advertise=no comment="L9 HQ-FW2-HQ-CORE1"
/ip address add address=10.1.255.37/30 interface=ether5 comment="L10 HQ-FW2-HQ-CORE2"
/ipv6 address add address=fdce:f6ae:a8d8:10ff::12/127 interface=ether5 advertise=no comment="L10 HQ-FW2-HQ-CORE2"
