# HQ-DIST2 - Fase 3.4: DHCPv4 (rango .175-.250) y RA para SLAAC en las VLAN 10-60. Aplicar despues de 06.
# Gateway entregado = .1 (VRRP). authoritative=no: no rechazar las IP que reparte el otro DIST.
# RA solo en las VLAN de usuarios (se desactiva la entrada por defecto, que abarca todas las interfaces).
/ip dns set servers=8.8.8.8,2001:4860:4860::8888
/ip pool add name=pool10 ranges=10.1.10.175-10.1.10.250 comment="VLAN 10 INV"
/ip dhcp-server network add address=10.1.10.0/24 gateway=10.1.10.1 dns-server=8.8.8.8 comment="VLAN 10 INV"
/ip dhcp-server add name=dhcp10 interface=vlan10-INV address-pool=pool10 lease-time=1h authoritative=no
/ip pool add name=pool20 ranges=10.1.20.175-10.1.20.250 comment="VLAN 20 COM"
/ip dhcp-server network add address=10.1.20.0/24 gateway=10.1.20.1 dns-server=8.8.8.8 comment="VLAN 20 COM"
/ip dhcp-server add name=dhcp20 interface=vlan20-COM address-pool=pool20 lease-time=1h authoritative=no
/ip pool add name=pool30 ranges=10.1.30.175-10.1.30.250 comment="VLAN 30 VEN"
/ip dhcp-server network add address=10.1.30.0/24 gateway=10.1.30.1 dns-server=8.8.8.8 comment="VLAN 30 VEN"
/ip dhcp-server add name=dhcp30 interface=vlan30-VEN address-pool=pool30 lease-time=1h authoritative=no
/ip pool add name=pool40 ranges=10.1.40.175-10.1.40.250 comment="VLAN 40 CUR"
/ip dhcp-server network add address=10.1.40.0/24 gateway=10.1.40.1 dns-server=8.8.8.8 comment="VLAN 40 CUR"
/ip dhcp-server add name=dhcp40 interface=vlan40-CUR address-pool=pool40 lease-time=1h authoritative=no
/ip pool add name=pool50 ranges=10.1.50.175-10.1.50.250 comment="VLAN 50 SOP"
/ip dhcp-server network add address=10.1.50.0/24 gateway=10.1.50.1 dns-server=8.8.8.8 comment="VLAN 50 SOP"
/ip dhcp-server add name=dhcp50 interface=vlan50-SOP address-pool=pool50 lease-time=1h authoritative=no
/ip pool add name=pool60 ranges=10.1.60.175-10.1.60.250 comment="VLAN 60 GUEST"
/ip dhcp-server network add address=10.1.60.0/24 gateway=10.1.60.1 dns-server=8.8.8.8 comment="VLAN 60 GUEST"
/ip dhcp-server add name=dhcp60 interface=vlan60-GUEST address-pool=pool60 lease-time=1h authoritative=no
/ipv6 nd set [find default=yes] disabled=yes
/ipv6 nd add interface=vlan10-INV ra-interval=3s-10s ra-lifetime=30s advertise-dns=yes
/ipv6 address set [find interface=vlan10-INV dynamic=no] advertise=yes
/ipv6 nd add interface=vlan20-COM ra-interval=3s-10s ra-lifetime=30s advertise-dns=yes
/ipv6 address set [find interface=vlan20-COM dynamic=no] advertise=yes
/ipv6 nd add interface=vlan30-VEN ra-interval=3s-10s ra-lifetime=30s advertise-dns=yes
/ipv6 address set [find interface=vlan30-VEN dynamic=no] advertise=yes
/ipv6 nd add interface=vlan40-CUR ra-interval=3s-10s ra-lifetime=30s advertise-dns=yes
/ipv6 address set [find interface=vlan40-CUR dynamic=no] advertise=yes
/ipv6 nd add interface=vlan50-SOP ra-interval=3s-10s ra-lifetime=30s advertise-dns=yes
/ipv6 address set [find interface=vlan50-SOP dynamic=no] advertise=yes
/ipv6 nd add interface=vlan60-GUEST ra-interval=3s-10s ra-lifetime=30s advertise-dns=yes
/ipv6 address set [find interface=vlan60-GUEST dynamic=no] advertise=yes
