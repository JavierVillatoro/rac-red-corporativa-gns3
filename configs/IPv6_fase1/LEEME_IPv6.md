# Variante "solo IPv6" en HQ (pendiente de confirmar con el profesor)

Alternativa a `configs/HA_fase1/` (doble pila, de Javi). **No sustituye a nada**: según lo que diga el profesor, se usa una carpeta u otra.

- Solo IPv6 → esta carpeta.
- Doble pila → `configs/HA_fase1/`, a la que se añaden las VLAN de aquí.

## Plan

- HQ: `2001:db8:1::/48`. VLAN X → `2001:db8:1:X::/64`. En cada VLAN: `::1` reservada (gateway virtual), `::2` DIST1, `::3` DIST2, `::10`+ servidores.
- Enlaces entre routers: `2001:db8:1:ffXX::/64`. Loopbacks: `2001:db8:1:ffff::N/128`.
- PCs por **SLAAC** (RA de los DIST); servidores y AP con dirección estática.

| VLAN | Uso | Prefijo |
|---|---|---|
| 10 | Investigación | `2001:db8:1:10::/64` |
| 20 | Comercial | `2001:db8:1:20::/64` |
| 30 | Ventas | `2001:db8:1:30::/64` |
| 40 | Cursos | `2001:db8:1:40::/64` |
| 50 | Soporte | `2001:db8:1:50::/64` |
| 60 | Invitados | `2001:db8:1:60::/64` |
| 65 | Wi-Fi corporativa | `2001:db8:1:65::/64` |
| 70 | Almacenamiento | `2001:db8:1:70::/64` |
| 80 | Cómputo | `2001:db8:1:80::/64` |
| 90 | DMZ (gateway en los FW) | `2001:db8:1:90::/64` |
| 99 | Gestión | `2001:db8:1:99::/64` |

## Contenido y estado

| Fichero | Estado |
|---|---|
| `HQ-PCs/interfaces` | Aplicado en los 6 PCs (VLAN 10–60) ✅ |
| `SW-HQ-ACC1/ovs.sh`, `SW-HQ-ACC2/ovs.sh` | Aplicado; persiste tras reiniciar ✅ |
| `HQ-DIST1/01_vlan_ipv6.rsc`, `HQ-DIST2/01_vlan_ipv6.rsc` | Aplicado ✅ |
| `SW-HQ-SRV/ovs_PENDIENTE.sh` | Preparado, sin aplicar |

## Pruebas hechas

- Aislamiento entre VLAN en el mismo switch: el ping `fe80::` entre INV y COM deja de responder al etiquetar los puertos ✅
- Configuración de OVS persistente tras reiniciar ✅
- Los PCs reciben `2001:db8:1:<vlan>:<EUI-64>` por SLAAC ✅
- Encaminamiento entre VLAN: ping de HQ-PC-INV a HQ-PC-CUR ✅

## Diferencias con `HA_fase1` (a tener en cuenta si se cambia)

- `HA_fase1` usa IPv4 `/30` + ULA `/127` en enlaces y loopbacks `10.1.254.N` / `fdce:f6ae:a8d8:10fe::N`; aquí, `2001:db8:1:ffXX::/64` y `2001:db8:1:ffff::N`.
- En `HA_fase1`, **ether3 (DIST1↔DIST2) es un enlace enrutado**; aquí es una **troncal del bridge**. Al pasar a doble pila hay que sacar ether3 del bridge (`/interface bridge port remove [find interface=ether3]`) y quitar ether3 de `tagged=` en `/interface bridge vlan`.
- Las VLAN de usuario (`2001:db8:1:<vlan>::/64`), el reparto `::1/::2/::3` y los switches de acceso coinciden en las dos variantes.
