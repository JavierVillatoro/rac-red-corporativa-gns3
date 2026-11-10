# HQ-DIST1 - OSPFv3, area 0. Enlaces a los CORE en ptp; VLAN y loopback en pasivo
# (se anuncian, pero no se buscan vecinos hacia los PCs).
/routing ospf instance add name=ospf-v3 version=3 router-id=4.4.4.1
/routing ospf area add name=backbone-v3 area-id=0.0.0.0 instance=ospf-v3
/routing ospf interface-template add area=backbone-v3 interfaces=ether1,ether2 type=ptp
/routing ospf interface-template add area=backbone-v3 interfaces=lo,vlan10-INV,vlan20-COM,vlan30-VEN,vlan40-CUR,vlan50-SOP,vlan60-GUEST,vlan65-WIFI,vlan70-STO,vlan80-CPU,vlan99-MGMT passive
