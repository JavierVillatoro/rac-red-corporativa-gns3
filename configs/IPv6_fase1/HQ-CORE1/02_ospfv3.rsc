# HQ-CORE1 - OSPFv3, area 0. ether1/ether2 (FW) incluidos ya; se activan al configurar los FW.
/routing ospf instance add name=ospf-v3 version=3 router-id=3.3.3.1
/routing ospf area add name=backbone-v3 area-id=0.0.0.0 instance=ospf-v3
/routing ospf interface-template add area=backbone-v3 interfaces=ether1,ether2,ether3,ether4,ether5 type=ptp
/routing ospf interface-template add area=backbone-v3 interfaces=lo passive
