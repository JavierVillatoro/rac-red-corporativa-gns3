# RAC - Red corporativa (HQ + B1 + B2) en GNS3

Trabajo final de *Redes de Acceso y Corporativas* (grupo Javi / Pepe / Manu): diseño de una red corporativa de tres sedes, simulada en GNS3 con routers MikroTik CHR, y configurada **mediante scripts** (infraestructura como código).

![Topología](topologia_HA.png)

## Estado del trabajo

| Fase | Contenido | Estado |
|---|---|---|
| 1 | Direcciones IPv4/IPv6 de los enlaces, loopbacks, WAN con dos ISP | **Hecha y probada**: 49/49 pruebas de ping OK (08/11/2026) |
| 2 | OSPFv2/OSPFv3 en HQ (+ BFD opcional) | Scripts generados (`02_ospf.rsc`, `03_bfd_opcional.rsc`), **sin probar** |
| 3 | VLAN, RSTP, VRRP, DHCP, gateways de cada departamento | Pendiente |
| 4 | NAT, firewall, DMZ, política Zero Trust entre zonas | Pendiente |
| 5 | Túneles WireGuard B1/B2 y teletrabajo; OSPF en B1/B2 | Pendiente |
| 6 | Observabilidad (Prometheus, Grafana) y autenticación (FreeRADIUS) | Pendiente (nodos creados, sin configurar) |
| 7 | Pruebas de fallo y cálculo de disponibilidad; informe final | Pendiente |

Lo marcado como pendiente es el **plan**, no algo ya hecho.

## Qué es la red

- **HQ** (200 puestos): 2 routers de borde, 2 firewalls (CHR), 2 core, 2 distribución multicapa, 3 switches de acceso y 2 de servidores (Open vSwitch), DMZ.
- **B1** (50 puestos) y **B2** (10 puestos): 2 routers cada una (borde + L3) y 2 switches de acceso.
- **Internet simulado**: ISP1 e ISP2 interconectados; cada sede tiene un enlace por proveedor. ISP1 da salida real por el NAT de GNS3.
- 51 nodos (14 CHR, 9 Open vSwitch, 23 hosts Alpine, servicios Docker) y 71 enlaces. **Todo duplicado** salvo los equipos finales.
- **Objetivo de disponibilidad 0,999** (≈ 8,76 h/año de caída). Es un objetivo **nuestro**: el enunciado solo pide «disponibilidad» sin cifra. Se estimará con un modelo y se contrastará con pruebas de fallo (fase 7); **aún no está demostrado**.

### Direccionamiento (fase 1, ya aplicado)

| Elemento | Plan |
|---|---|
| Loopbacks HQ | `10.1.254.N/32` y `fdce:f6ae:a8d8:10fe::N/128` (BORDER1=1, BORDER2=2, FW1=3, FW2=4, CORE1=11, CORE2=12, DIST1=21, DIST2=22) |
| Enlaces HQ | 16 enlaces `/30` en `10.1.255.0/24` y `/127` en `fdce:f6ae:a8d8:10ff::/64` (tabla completa en `configs/HA_fase1/LEEME_fase1_HA.md`) |
| WAN | `203.0.113.0/24` y `2001:db8:ffff::/48` (documentación, RFC 5737/3849) |
| B1 / B2 | `10.2.0.0/16` / `10.3.0.0/16`; B2 solo IPv4 |
| Internas IPv6 | ULA `fdce:f6ae:a8d8::/48` |

Los rangos de VLAN y direcciones de usuarios (fases 3 en adelante) están en el informe técnico y **pendientes de confirmar** en grupo.

## Requisitos

- **GNS3 2.2.x** (GUI) y **GNS3 VM** en VMware, con virtualización anidada/KVM. Recomendado: **8 GB de RAM y 4 vCPU** (`Edit → Preferences → GNS3 VM`). Con 2 GB los 14 routers no arrancan.
- **Imagen de MikroTik CHR 7.22.1** (`chr-7.22.1.img`): **no está en el repositorio**. Se descarga de <https://mikrotik.com/download> y se importa con `File → Import appliance → mikrotik-chr.gns3a` (viene con GNS3) eligiendo la versión 7.22.1 y el servidor GNS3 VM. Sin esa imagen el proyecto **no abre** (GNS3 aborta si falta una).
- Las imágenes Docker (`alpine`, `gns3/openvswitch`, `nginx:alpine`, `prom/prometheus`, `grafana/grafana`, `freeradius/freeradius-server`) las usa el GNS3 VM; si no las tiene, GNS3 intenta descargarlas al arrancar el nodo.
- **Python 3.8+** (solo biblioteca estándar) y **git**.
- Licencia gratuita del CHR: **1 Mbps por interfaz**. Sirve para conectividad y recuperación, **no** para medir rendimiento ([manual MikroTik](https://manual.mikrotik.com/docs/getting-started/routeros-licensing/chr/chr-licensing/)).

## Puesta en marcha

1. Clona el repositorio (o `Code → Download ZIP`) y abre GNS3.
2. Importa el CHR (ver Requisitos) y comprueba el GNS3 VM (8 GB / 4 vCPU).
3. `File → Open project` → `RAC_Red_HA/RAC_Red_HA.gns3`.
4. Arranca los routers (▶ Start all). Espera 2-3 minutos. En el primer arranque cada CHR pide cambiar la contraseña (usuario `admin`, clave vacía).
5. Anota la **IP del GNS3 VM** (columna *Console* de *Topology Summary*, p. ej. `192.168.196.128`). Si es distinta, usa `--host IP` o la variable de entorno `GNS3_HOST`.
6. En la carpeta `configs/HA_fase1`:
   ```
   python push_config.py 01 --dry-run     # solo muestra qué haría
   python push_config.py 01               # aplica las direcciones a los 14 routers
   python test_fase1.py                   # lanza las 49 pruebas de ping y guarda un informe en logs/
   ```
   La contraseña de `admin` se pide por teclado (o `RAC_PASS`) y **no se guarda**. Cierra antes las ventanas de consola de los routers: solo admiten un cliente.
7. Para apagar: `Control → Stop all nodes`, esperar a que todos estén en rojo, `File → Save project` y entonces salir.

## Estructura

```
RAC_Red_HA/RAC_Red_HA.gns3      proyecto de GNS3 (topología)
configs/HA_fase1/
  <router>/01_direcciones.rsc   direcciones, loopback, WAN
  <router>/02_ospf.rsc          OSPFv2/v3 (solo HQ)
  <router>/03_bfd_opcional.rsc  BFD (tras comprobar OSPF)
  push_config.py                envía un .rsc a los routers por su consola telnet
  test_fase1.py                 pruebas de ping automáticas + informe
  tests_fase1.json              lista de pruebas
  LEEME_fase1_HA.md             pruebas manuales y tabla de enlaces
topologia_HA.png                esquema
Informe_final_RAC.pdf           memoria técnica (versión 4: diseño, estado y pasos pendientes)
informe/                        fuentes LaTeX del informe (compilar con XeLaTeX) y tablas generadas
```

## Reglas para trabajar en equipo

- `git pull` antes de empezar y `git push` al terminar. Mensajes de commit que digan **qué** se hizo.
- **Una sola persona edita el `.gns3`** a la vez: GNS3 lo reescribe entero (puertos de consola, posiciones) y dos cambios simultáneos dan conflictos. Quien lo cambie, lo avisa por el grupo.
- Los cambios de configuración van en los `.rsc` (o en el generador), **no** solo dentro del router: los discos de los routers viven en el GNS3 VM de cada uno y **no** están en el repositorio.
- **Nunca** subir contraseñas, ni ficheros `.env`, ni el enunciado, ni trabajos de otros grupos (el `.gitignore` ya excluye lo conocido).
- Los `.rsc` y el proyecto se generan con un script que **no** está aún en el repositorio; si se necesita regenerar, pedirlo a Javi. No regenerar el `.gns3` con el proyecto abierto en GNS3 (lo pisa).

## Limitaciones conocidas

- Los scripts de la fase 2 en adelante **no están probados** en el router real. Cualquier error de sintaxis de RouterOS: copiad el mensaje exacto.
- Que un comando se acepte no prueba que funcione: se valida siempre con ping/traceroute (`test_fase1.py`).
- La persistencia de la configuración al cerrar y reabrir GNS3 está **por comprobar**.
- OPNsense (IPS/IDS) no está integrado: los firewalls son CHR. Pendiente de decidir (necesita imagen de ~3 GB).

## Reparto propuesto (pendiente de confirmar)

| Persona | Bloques |
|---|---|
| Javi | Interior de HQ, direccionamiento, base de automatización |
| Pepe | Perímetro, firewall, WireGuard, DMZ |
| Manu | Observabilidad, RADIUS, B1/B2, pruebas |

## Referencias

- Gill, Jain, Nagappan. *Understanding Network Failures in Data Centers*. SIGCOMM 2011: <https://people.cs.umass.edu/~phillipa/papers/comm235-gill.pdf>
- Turner, Levchenko, Snoeren, Savage. *California Fault Lines*. SIGCOMM 2010: <https://people.cs.umass.edu/~phillipa/CSE390/calfault.pdf>
- Temario *Diseño de Redes* (DDR), Tema 2: topología, redundancia, disponibilidad.
