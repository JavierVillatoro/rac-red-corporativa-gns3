# Decisiones de diseño (para la memoria)

Registro de cada decisión tomada durante la configuración: **qué** se decidió, **por qué** y qué **alternativas** se descartaron. Sirve de base para redactar la memoria.

## Generales

| Decisión | Motivo | Alternativas descartadas |
|---|---|---|
| Doble pila en HQ y B1 (IPv4 + IPv6); B2 solo IPv4 | Acordado con el profesor; es el diseño de la fase 1 | Solo IPv6 en HQ (se probó y se descartó) |
| Configuración por scripts `.rsc` aplicados con `push_config.py` | El repositorio es la referencia del grupo: reproducible, con historial y revisable. El resultado en el router es el mismo que a mano | Configurar a mano en la consola (no queda registro y no se puede repetir) |
| Entrega: proyecto portable de GNS3 + repositorio | El `.gns3` solo guarda la topología; la configuración vive en los discos de los nodos, que el portable sí incluye | Entregar solo el repositorio (el profesor vería los routers vacíos) |

## Fase 2: OSPF en HQ

| Decisión | Motivo | Alternativas descartadas |
|---|---|---|
| OSPFv2 (IPv4) y OSPFv3 (IPv6) en el área 0 | Enrutamiento dinámico: reacciona solo a fallos y reparte carga entre caminos iguales (ECMP), necesario para la alta disponibilidad | Rutas estáticas (no se adaptan a fallos) |
| Enlaces punto a punto (`type=ptp`) | Solo dos routers por enlace: no hace falta elegir router designado y se converge antes | Tipo broadcast (por defecto) |
| Loopbacks y redes de usuarios como interfaces **pasivas** | Se anuncian, pero no se envían *hello* donde no hay routers vecinos | Activas (tráfico OSPF inútil y riesgo de vecinos no deseados) |

**Incidencia corregida:** en RouterOS 7 `passive` es un *flag* sin valor. Con `passive=yes` el router daba `expected end of command` y no creaba la plantilla de la loopback, así que las loopbacks no se anunciaban. Se detectó porque el traceroute a la loopback de HQ-DIST2 salía por el ISP (ruta por defecto). Corregido en los 8 `02_ospf.rsc`.

**Prueba:** vecinos `Full` en HQ-CORE1 (5 en IPv4 y 5 en IPv6); ping IPv4/IPv6 de HQ-BORDER1 a la loopback de HQ-DIST2 (TTL 62 = 2 routers intermedios); traceroute por FW2 → CORE1 → DIST2.

## Fase 3: VLAN, RSTP, gateways redundantes, DHCP y SLAAC en HQ

| Decisión | Motivo | Alternativas descartadas |
|---|---|---|
| Una VLAN y una subred por departamento (plan del informe) | Separa departamentos (seguridad, *Zero Trust*) y limita los dominios de *broadcast* | Una sola red plana |
| HQ-DIST1/2 como switches multicapa (bridge con filtrado de VLAN + interfaz VLAN por departamento) | Enrutan entre VLAN cerca de los usuarios y hacia el CORE | Enrutar en el CORE o en el firewall (más carga y más saltos) |
| **RSTP** con HQ-DIST1 como raíz y HQ-DIST2 de respaldo; switches de acceso con prioridad máxima | Cada switch de acceso tiene dos uplinks, lo que crea bucles de nivel 2; RSTP bloquea un puerto y lo reactiva en segundos si falla un enlace. Se activa **antes** de crear las VLAN | Sin STP (tormenta de *broadcast*); STP clásico (converge en 30-50 s) |
| El enlace DIST1–DIST2 pasa a ser también troncal | Los dos DIST se ven directamente en cada VLAN: VRRP no depende de los cables de un switch de acceso y se evitan dos maestros a la vez si cae uno | Que se vean solo a través de los switches de acceso |
| **VRRP** en IPv4: pasarela virtual `.1`; DIST1 `.2`, DIST2 `.3`. DIST1 maestro en las VLAN 10, 20, 30 y 70; DIST2 en las 40, 50, 60, 80 y 99 | Si cae un DIST, el otro asume la `.1` y los equipos no notan el cambio. El reparto por VLAN pone a trabajar a los dos | Una sola pasarela (punto único de fallo); un único maestro para todo (el otro DIST, ocioso) |
| **DHCPv4 en los dos DIST, con el rango repartido** (DIST1 `.100–.174`, DIST2 `.175–.250`) | Servidor integrado en RouterOS: no añade equipos; si cae un DIST el otro sigue repartiendo; al no solaparse los rangos, nunca dan la misma IP a dos equipos | Servidor DHCP central con *relay* en los DIST (un equipo más que puede fallar y habría que duplicar) |
| **IPv6 con SLAAC**: los dos DIST envían RA con el prefijo /64 de cada VLAN y el DNS (RDNSS) | El equipo se configura solo, sin servidor; recibe dos routers por defecto y, si uno desaparece, usa el otro | DHCPv6 (no aporta nada aquí); VRRP para IPv6 (más complejo en RouterOS) |
| Servidores y AP con direcciones fijas | Deben estar siempre en la misma dirección para poder encontrarlos | DHCP con reserva |
| DNS provisional `8.8.8.8` / `2001:4860:4860::8888` | Aún no hay DNS interno (fase 4); no afecta a las pruebas de esta fase | — |
| Orden: 3.1 RSTP + VLAN → 3.2 direcciones + OSPF pasivo → 3.3 VRRP → 3.4 DHCP/SLAAC → 3.5 PCs. Switches de servidores después | Cada paso se prueba antes de pasar al siguiente; RSTP primero para no crear bucles | — |
