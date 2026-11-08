#!/usr/bin/env python3
"""test_fase1.py - ejecuta automaticamente las pruebas de ping de la fase 1 en los routers de GNS3 y genera un informe.

Lee tests_fase1.json (lo genera el generador a partir del plan de direcciones), entra en cada router por su consola telnet
(igual que push_config.py), lanza `/ping <destino> count=3` y comprueba que respondan los 3 paquetes.
Escribe un informe en logs/test_fase1_<fecha>.md que sirve de evidencia para el apartado de pruebas del informe.

Uso (desde esta carpeta):
    python test_fase1.py                      # todas las pruebas
    python test_fase1.py --grupo "enlaces HQ" # solo un grupo (enlaces HQ, WAN, sedes, Internet)
    python test_fase1.py --nodos HQ-CORE1     # solo las pruebas que parten de ese router
"""
import argparse
import datetime
import getpass
import json
import os
import re
import sys

import push_config as pc

HERE = pc.HERE
RES = re.compile(r"sent=(\d+)\s+received=(\d+)\s+packet-loss=(\d+)%(?:\s+min-rtt=\S+\s+avg-rtt=(\S+))?")


def evaluar(texto):
    m = RES.search(texto)
    if not m:
        return "SIN RESPUESTA", "", 0, 0
    sent, rec, loss, rtt = int(m.group(1)), int(m.group(2)), int(m.group(3)), m.group(4) or ""
    return ("OK" if rec == sent and sent > 0 else ("PARCIAL" if rec > 0 else "FALLA")), rtt, sent, rec


def main():
    ap = argparse.ArgumentParser(description="Pruebas de ping automaticas de la fase 1")
    ap.add_argument("--grupo", help="enlaces HQ, WAN, sedes o Internet")
    ap.add_argument("--nodos", help="routers origen, separados por comas")
    ap.add_argument("--host", default=os.environ.get("GNS3_HOST", "192.168.196.128"),
                    help="IP del GNS3 VM (o variable de entorno GNS3_HOST)")
    ap.add_argument("--debug", action="store_true")
    a = ap.parse_args()
    pc.Con.debug = a.debug

    tests = json.load(open(os.path.join(HERE, "tests_fase1.json"), encoding="utf-8"))
    if a.grupo:
        tests = [t for t in tests if t["grupo"] == a.grupo]
    if a.nodos:
        sel = [n.strip() for n in a.nodos.split(",")]
        tests = [t for t in tests if t["from"] in sel]
    ports = pc.consolas()
    por_router = {}
    for t in tests:
        por_router.setdefault(t["from"], []).append(t)
    print("%d pruebas desde %d routers" % (len(tests), len(por_router)))
    pw = os.environ.get("RAC_PASS") or getpass.getpass("Contrasena de admin de los routers (no se guarda): ")

    filas = []
    for dev, lst in por_router.items():
        try:
            con = pc.Con(a.host, ports[dev])
        except (OSError, KeyError) as e:
            for t in lst:
                filas.append((t, "NO CONECTA", ""))
            print("%-11s NO CONECTA (%s)" % (dev, e))
            continue
        try:
            pc.login(con, "admin", pw)
            for t in lst:
                r = pc.run_lines(con, ["/ping %s count=3" % t["to"]])[0]
                est, rtt, sent, rec = evaluar(r[2])
                filas.append((t, est, rtt))
                print("%-11s %-6s %-30s %-24s %s %s" % (dev, t["fam"], t["desc"][:30], t["to"][:24], est, rtt))
        except (PermissionError, TimeoutError, ConnectionError) as e:
            for t in lst:
                filas.append((t, "FALLO: %s" % e, ""))
            print("%-11s FALLO: %s" % (dev, e))
        finally:
            con.close()

    ok = sum(1 for _, e, _ in filas if e == "OK")
    print("\nRESULTADO: %d/%d pruebas OK" % (ok, len(filas)))
    for t, e, _ in filas:
        if e != "OK":
            print("  NO OK:", t["grupo"], "|", t["desc"], "|", t["to"], "|", e)
    os.makedirs(os.path.join(HERE, "logs"), exist_ok=True)
    nombre = os.path.join(HERE, "logs", "test_fase1_%s.md" % datetime.datetime.now().strftime("%Y%m%d_%H%M%S"))
    with open(nombre, "w", encoding="utf-8") as f:
        f.write("# Pruebas de ping - fase 1 (%s)\n\nResultado: **%d/%d OK**. Cada prueba = `/ping <destino> count=3` desde el router origen; "
                "OK = 3 de 3 respuestas.\n\n| Grupo | Prueba | Origen | Destino | Familia | Resultado | RTT medio |\n|---|---|---|---|---|---|---|\n"
                % (datetime.datetime.now().strftime("%Y-%m-%d %H:%M"), ok, len(filas)))
        for t, e, rtt in filas:
            f.write("| %s | %s | %s | `%s` | %s | %s | %s |\n" % (t["grupo"], t["desc"], t["from"], t["to"], t["fam"], e, rtt))
    print("Informe:", nombre)
    sys.exit(0 if ok == len(filas) else 1)


if __name__ == "__main__":
    main()
