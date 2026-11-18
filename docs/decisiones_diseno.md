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
| Enlace L16 (DIST1–DIST2) movido a una **VLAN de tránsito 255** (`vlan255-TRANS`), con las mismas IP | Al ser ether3 troncal, entra en el bridge y un puerto del bridge no puede tener IP propia. La plantilla OSPF busca la red `10.1.255.60/30`, así que el vecino sigue solo en la nueva interfaz | Dejar ether3 enrutado (los DIST solo se verían a través de los switches de acceso) |
| Poda de VLAN: cada troncal lleva solo las VLAN que necesita (ACC1: 10, 20, 30, 99; ACC2: 40, 50, 60, 99) | Menos tráfico de *broadcast* inútil y menos superficie de ataque | Pasar todas las VLAN por todos los troncales |
| Troncales con `admit-only-vlan-tagged` | Si se conecta por error un equipo sin etiquetas a un troncal, sus tramas se descartan | Admitir tramas sin etiqueta (VLAN nativa) |
| Puertos de PC como *edge* en RSTP (`rstp-port-admin-edge`) | Un equipo final no crea bucles: el puerto pasa a enviar al instante, sin esperar a RSTP | Puerto normal (el PC tarda segundos en tener red) |
| AP Wi-Fi en la VLAN 60 (invitados) | El plan dice que la Wi-Fi es para invitados, que solo tienen Internet | VLAN propia para la Wi-Fi (no está en el plan) |

**Ficheros:** `HQ-DIST1/04_vlan_rstp.rsc` y `HQ-DIST2/04_vlan_rstp.rsc` (con `push_config.py 04`); `SW-HQ-ACC1/04_vlan_rstp.sh` y `SW-HQ-ACC2/04_vlan_rstp.sh` (se pegan en la consola del switch: el script solo habla con RouterOS).

**Pruebas del paso 3.1 (17/11/2026):**
- HQ-DIST1: `root-bridge: yes` (`bridge-id 0x1000`). Vecino OSPF con DIST2 en `Full` por `vlan255-TRANS` (v2 y v3); ping a `10.1.255.62` 3/3 con TTL 64.
- SW-HQ-ACC1 (`ovs-appctl rstp/show`): reconoce a DIST1 como raíz (prioridad 4096), `root-port eth0`.
- HQ-DIST2 (`/interface bridge port monitor`): ether3 `root-port`; ether4 y ether5 `alternate-port` sin reenviar. **Los dos bucles quedan cortados.**
- **Observación:** el bloqueo está en DIST2 y no en los switches de acceso, como se esperaba al principio. Los costes RSTP por defecto difieren entre fabricantes (OVS 2000 por puerto, MikroTik 20000), así que en el enlace DIST2–ACC el switch de acceso está "más cerca" de la raíz y queda como designado. El resultado sigue sin bucles; en una red real se fijarían los costes a mano.

### Paso 3.2: direcciones de las VLAN y OSPF

| Decisión | Motivo | Alternativas descartadas |
|---|---|---|
| DIST1 `.2` / `::2` y DIST2 `.3` / `::3` en cada VLAN; tercer octeto IPv4 = número de VLAN | Cada DIST tiene una interfaz en cada departamento para enrutar entre VLAN; el número de VLAN se lee en la dirección | — |
| IPv6 según la VLAN: usuarios (10-50) GUA + ULA; invitados (60) solo GUA; almacenamiento, cómputo y gestión (70, 80, 99) solo ULA | Los invitados solo necesitan Internet; los servicios internos no tienen dirección global, así que no se pueden alcanzar desde Internet aunque falle el firewall (seguridad por diseño) | Las dos familias en todas las VLAN |
| Redes de las VLAN en OSPF como **pasivas** | Se anuncian al resto de HQ, pero no se envían *hello* a los equipos de usuario: un equipo con OSPF no puede hacerse pasar por router e inyectar rutas | Interfaces activas |
| Los dos DIST anuncian las mismas VLAN | El CORE tiene dos caminos de igual coste (ECMP) hacia cada VLAN; si cae un DIST, OSPF retira su ruta | — |
| `advertise=no` en las direcciones IPv6 de este paso | RouterOS envía RA en cuanto una interfaz tiene una /64; se activan en el paso 3.4 para que cada paso haga una sola cosa | — |
| Líneas de configuración de menos de 200 caracteres | La consola del router mide 200 columnas; las líneas más largas se parten y confunden a `push_config.py` | — |

**Ficheros:** `HQ-DIST1/05_vlan_ip.rsc` y `HQ-DIST2/05_vlan_ip.rsc` (con `push_config.py 05`).

**Pruebas del paso 3.2 (17/11/2026):**
- HQ-DIST1 → `10.1.10.3` y `2001:db8:1:40::3` (DIST2): 3/3 con TTL 64. Los dos DIST comparten cada VLAN a través del troncal ether3.
- HQ-CORE1: dos rutas `DAo+` hacia `10.1.10.0/24`, por DIST1 (ether4) y por DIST2 (ether5). Hay ECMP.
- HQ-BORDER1 → `10.1.40.3` y `fdce:f6ae:a8d8:1099::2`: 3/3 con TTL 62 (FW y CORE en medio). Las VLAN, también las internas en ULA, se anuncian por OSPFv2 y OSPFv3.

### Paso 3.3: VRRP (pasarela virtual)

| Decisión | Motivo | Alternativas descartadas |
|---|---|---|
| Una interfaz VRRP por VLAN con la pasarela `.1/32`; VRID = número de VLAN | Los equipos usan siempre la `.1`; el VRID identifica la pareja de DIST en cada VLAN y coincide con la VLAN para leerlo fácil. MikroTik recomienda `/32` para la dirección virtual, porque la red ya está en la interfaz de la VLAN | Dar a los equipos la `.2` o la `.3` (si cae ese DIST, se quedan sin salida) |
| Prioridad 200 para el maestro y 100 para el respaldo: DIST1 maestro en las VLAN 10, 20, 30 y 70; DIST2 en las 40, 50, 60, 80 y 99 | Reparto de carga: cada DIST es la pasarela principal de "su" switch de acceso y respaldo del otro | Un solo maestro para todo (el otro DIST, ocioso) |
| *Preemption* activado (por defecto) | Cuando el DIST caído vuelve, recupera sus VLAN y el reparto de carga se restablece solo | Sin *preemption* (el reparto quedaría descompensado tras un fallo) |
| VRRP solo en IPv4 | En IPv6 la redundancia la dan los RA de los dos DIST (paso 3.4) | VRRP también para IPv6 |

**Cómo funciona:** el maestro envía un anuncio cada segundo (multicast `224.0.0.18`) por la VLAN, que llega al otro DIST por el troncal ether3. Si el respaldo pasa unos 3 s sin oírlo, asume la `.1` con la **misma MAC virtual** `00:00:5E:00:01:<VRID en hexadecimal>`, así que los equipos no tienen que actualizar su ARP.

**Ficheros:** `HQ-DIST1/06_vrrp.rsc` y `HQ-DIST2/06_vrrp.rsc` (con `push_config.py 06`).

**Pruebas del paso 3.3 (18/11/2026):**
- `/interface vrrp print`: DIST1 `RM` (*running master*) en las VLAN 10, 20, 30 y 70 y `B` (*backup*) en el resto; DIST2 al revés. MAC virtual `00:00:5E:00:01:0A` en la VLAN 10 (`0A` = 10).
- HQ-BORDER1 → `10.1.10.1` y `10.1.40.1`: 3/3 (TTL 62). La primera la responde DIST1 y la segunda DIST2.
- Fallo simulado (`/interface vrrp disable vrrp10-INV` en DIST1): DIST2 pasa `vrrp10-INV` de `B` a `RM` y asume la pasarela. Al reactivarlo, DIST1 vuelve a ser maestro (*preemption*).
- Pendiente: prueba de fallo completa (apagar un DIST entero con un equipo haciendo ping) en el paso 3.5, para medir el tiempo de recuperación.

### Paso 3.4: DHCPv4 y SLAAC

| Decisión | Motivo | Alternativas descartadas |
|---|---|---|
| DHCP y RA solo en las VLAN 10-60 (usuarios e invitados) | Las VLAN 70, 80 y 99 tienen direcciones fijas: un servidor DHCP allí sería un servicio innecesario que puede fallar o ser atacado | DHCP en todas las VLAN |
| DHCPv4 entrega como pasarela la `.1` (VRRP), no la `.2` o `.3` del DIST que responde | El equipo se beneficia de VRRP le haya dado la dirección quien se la haya dado | Entregar la dirección propia de cada DIST |
| Rangos sin solape: DIST1 `.100–.174` y DIST2 `.175–.250` (75 + 75 por VLAN) | Nunca dan la misma IP a dos equipos. Aunque caiga un DIST, quedan 75 direcciones por VLAN, más que los puestos del mayor departamento (Investigación, 60) | Un único servidor con todo el rango |
| `authoritative=no` en los servidores DHCP | Un servidor autoritario responde NAK a las peticiones de IP que no conoce; con dos servidores, al renovar una IP del otro DIST, el equipo la perdería | Autoritario (el valor por defecto) |
| Préstamo (*lease*) de 1 h | Si un equipo desaparece, su dirección vuelve pronto al rango | Préstamos muy cortos (más tráfico de renovación) o muy largos (las direcciones de equipos que ya no están tardan en liberarse) |
| Desactivar la entrada de RA por defecto (`interface=all`) y crear una por VLAN de usuarios | La entrada por defecto anunciaría el router por todas las interfaces, incluidos los enlaces y las interfaces VRRP | Dejar la entrada por defecto |
| RA cada 3-10 s y `ra-lifetime=30s` | Si un DIST cae, sus equipos lo descartan como pasarela en 30 s como máximo. Los valores de fábrica son RA cada 200-600 s y 30 min de vida | Valores por defecto |
| Prefijos GUA y ULA anunciados en las VLAN de usuarios | El equipo obtiene dos direcciones: GUA para Internet y ULA para lo interno | Solo GUA |
| DNS en el RA (`advertise-dns`, RDNSS), tomado de `/ip dns` | El equipo recibe el DNS sin servidor DHCPv6 | DHCPv6 sin estado |

**Ficheros:** `HQ-DIST1/07_dhcp_slaac.rsc` y `HQ-DIST2/07_dhcp_slaac.rsc` (con `push_config.py 07`).

**Pruebas del paso 3.4 (18/11/2026):** `push_config.py 07` sin errores (32 comandos por DIST). En HQ-DIST1: 6 servidores DHCP activos, pools de 75 direcciones `.100–.174`, entrada RA `interface=all` desactivada y 6 entradas por VLAN con `ra-interval=3s-10s` y `ra-lifetime=30s`, prefijos de las VLAN 10-50 con `advertise=yes` y `vlan255-TRANS` con `no`. La prueba real (equipos recibiendo dirección) se hace en el paso 3.5.

## Pruebas generales y pendientes

- **Persistencia comprobada (17/11/2026):** tras cerrar y reabrir GNS3, HQ-DIST1 conservaba sus direcciones y sus 6 vecinos OSPF. La configuración se guarda en el disco de cada nodo.
- **Pendiente:** HQ-MON (Prometheus) no arranca (en rojo) y provoca un aviso de uBridge al iniciar el proyecto. Se revisará en la fase 6 (falta `prometheus.yml` o la imagen Docker).
- **Pendiente (seguridad):** los puertos libres de los OVS (sin `tag` ni `trunks`) aceptan todas las VLAN. Aquí no tienen cable; en una red real se desactivarían.
- Añadido `*.gns3.backup` al `.gitignore` (copia que crea GNS3 al guardar).
