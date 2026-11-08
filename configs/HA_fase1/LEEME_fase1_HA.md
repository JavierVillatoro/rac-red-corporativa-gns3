# Fase 1 (HA): direcciones, WAN y OSPF - proyecto `RAC_Red_HA`

**Scripts sin probar**. Si un comando da error, copiad el mensaje exacto. Un `.rsc` por equipo y fase.

## Orden

1. Arrancad solo los 14 routers (ISP1, ISP2, HQ-BORDER1/2, HQ-FW1/2, HQ-CORE1/2, HQ-DIST1/2, B1-R1/2, B2-R1/2). Esperad ~1-2 min (primer arranque del CHR).
2. Doble clic en el nodo = consola. Usuario `admin`, clave vacia (si pide una nueva, ponedla y apuntadla).
3. En cada router pegad su `01_direcciones.rsc` (clic derecho para pegar). Despues haced la **Prueba A**.
4. Solo en los 8 routers de HQ: pegad `02_ospf.rsc` y haced la **Prueba B**.
5. `03_bfd_opcional.rsc` solo cuando OSPF funcione (Prueba C).

## Prueba A: enlaces HQ (tras `01_direcciones.rsc` en los dos extremos)

| Enlace | Desde | Comando | Debe responder |
|---|---|---|---|
| L1 | HQ-BORDER1 | `/ping 10.1.255.2 count=3` y `/ping fdce:f6ae:a8d8:10ff::1 count=3` | Si (IPv4 e IPv6) |
| L2 | HQ-BORDER1 | `/ping 10.1.255.6 count=3` y `/ping fdce:f6ae:a8d8:10ff::3 count=3` | Si (IPv4 e IPv6) |
| L3 | HQ-BORDER2 | `/ping 10.1.255.10 count=3` y `/ping fdce:f6ae:a8d8:10ff::5 count=3` | Si (IPv4 e IPv6) |
| L4 | HQ-BORDER2 | `/ping 10.1.255.14 count=3` y `/ping fdce:f6ae:a8d8:10ff::7 count=3` | Si (IPv4 e IPv6) |
| L5 | HQ-BORDER1 | `/ping 10.1.255.18 count=3` y `/ping fdce:f6ae:a8d8:10ff::9 count=3` | Si (IPv4 e IPv6) |
| L6 | HQ-FW1 | `/ping 10.1.255.22 count=3` y `/ping fdce:f6ae:a8d8:10ff::b count=3` | Si (IPv4 e IPv6) |
| L7 | HQ-FW1 | `/ping 10.1.255.26 count=3` y `/ping fdce:f6ae:a8d8:10ff::d count=3` | Si (IPv4 e IPv6) |
| L8 | HQ-FW1 | `/ping 10.1.255.30 count=3` y `/ping fdce:f6ae:a8d8:10ff::f count=3` | Si (IPv4 e IPv6) |
| L9 | HQ-FW2 | `/ping 10.1.255.34 count=3` y `/ping fdce:f6ae:a8d8:10ff::11 count=3` | Si (IPv4 e IPv6) |
| L10 | HQ-FW2 | `/ping 10.1.255.38 count=3` y `/ping fdce:f6ae:a8d8:10ff::13 count=3` | Si (IPv4 e IPv6) |
| L11 | HQ-CORE1 | `/ping 10.1.255.42 count=3` y `/ping fdce:f6ae:a8d8:10ff::15 count=3` | Si (IPv4 e IPv6) |
| L12 | HQ-CORE1 | `/ping 10.1.255.46 count=3` y `/ping fdce:f6ae:a8d8:10ff::17 count=3` | Si (IPv4 e IPv6) |
| L13 | HQ-CORE1 | `/ping 10.1.255.50 count=3` y `/ping fdce:f6ae:a8d8:10ff::19 count=3` | Si (IPv4 e IPv6) |
| L14 | HQ-CORE2 | `/ping 10.1.255.54 count=3` y `/ping fdce:f6ae:a8d8:10ff::1b count=3` | Si (IPv4 e IPv6) |
| L15 | HQ-CORE2 | `/ping 10.1.255.58 count=3` y `/ping fdce:f6ae:a8d8:10ff::1d count=3` | Si (IPv4 e IPv6) |
| L16 | HQ-DIST1 | `/ping 10.1.255.62 count=3` y `/ping fdce:f6ae:a8d8:10ff::1f count=3` | Si (IPv4 e IPv6) |

## Prueba A2: WAN

| Desde | Comando | Debe responder |
|---|---|---|
| HQ-BORDER1 | `/ping 203.0.113.1 count=3` y `/ping 2001:db8:ffff:1::1 count=3` | Si |
| HQ-BORDER2 | `/ping 203.0.113.5 count=3` y `/ping 2001:db8:ffff:2::1 count=3` | Si |
| B1-R1 | `/ping 203.0.113.9 count=3` y `/ping 2001:db8:ffff:3::1 count=3` | Si |
| B1-R2 | `/ping 203.0.113.17 count=3` y `/ping 2001:db8:ffff:4::1 count=3` | Si |
| B2-R1 | `/ping 203.0.113.13 count=3` (B2: solo IPv4) | Si |
| B2-R2 | `/ping 203.0.113.21 count=3` (B2: solo IPv4) | Si |
| ISP2 | `/ping 203.0.113.29 count=3` (peering con ISP1) | Si |
| ISP1 | `/ip dhcp-client print` | `bound` (direccion del NAT de GNS3) |
| ISP1 | `/ping 8.8.8.8 count=3` | Si |
| ISP2 | `/ping 8.8.8.8 count=3` | Si (sale por ISP1) |

Estas pruebas A/A2 las ejecuta solas `python test_fase1.py` (lista en `tests_fase1.json`, informe en `logs/`).

Si algo falla: `/ip address print` e `/interface print` en los dos extremos (puerto *running*? direccion en el puerto correcto?).

## Prueba B: OSPF (tras `02_ospf.rsc` en los 8 de HQ)

- `/routing ospf neighbor print` en HQ-CORE1: vecinos FW1, FW2, CORE2, DIST1, DIST2 en estado *Full*.
- `/ip route print where ospf` y `/ipv6 route print where ospf`: loopbacks y redes de los demas.
- Desde HQ-BORDER1: `/ping 10.1.254.22 count=3` y `/ping fdce:f6ae:a8d8:10fe::22 count=3` (loopback de DIST2).
- `/tool traceroute 10.1.254.22`: ver el camino.

## Prueba C: convergencia (tras `03_bfd_opcional.rsc`)

1. En HQ-BORDER1: `/ping 10.1.254.22` continuo.
2. En GNS3, clic derecho sobre el enlace CORE1-DIST1 -> *Suspend* (o parad HQ-CORE1).
3. Contad cuantos pings se pierden hasta que vuelven. Apuntad el numero: es el tiempo de recuperacion que usaremos en el calculo de disponibilidad.

## Que NO hace esta fase

Sin VLAN, RSTP, VRRP, DHCP, NAT de los bordes, firewall, VPN ni OSPF en B1/B2 (llega con los tuneles). Vienen despues.
