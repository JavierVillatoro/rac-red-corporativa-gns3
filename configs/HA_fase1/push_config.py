#!/usr/bin/env python3
"""push_config.py - envia los ficheros .rsc de una fase a los routers CHR de GNS3 por su consola telnet.

Hace lo mismo que hacer doble clic en el router, entrar con admin y pegar el fichero, pero para varios routers.
Solo usa la biblioteca estandar de Python. Los puertos de consola salen del propio proyecto .gns3.
La contrasena de admin se pide por teclado (o variable de entorno RAC_PASS) y NUNCA se guarda en disco.

Ejemplos (desde esta carpeta):
    python push_config.py 01 --dry-run                 # solo muestra que haria
    python push_config.py 01 --nodos HQ-CORE2          # un router
    python push_config.py 01 --saltar HQ-CORE1,HQ-DIST1  # todos menos los ya hechos a mano
    python push_config.py 02                           # OSPF en los routers de HQ (una sola vez por router)
"""
import argparse
import datetime
import getpass
import json
import os
import re
import socket
import sys
import time

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
HERE = os.path.dirname(os.path.abspath(__file__))
PROYECTO = os.path.normpath(os.path.join(HERE, "..", "..", "RAC_Red_HA", "RAC_Red_HA.gns3"))

IAC = re.compile(rb"\xff[\xfb-\xfe][\x00-\xff]|\xff[\xf0-\xfa]|\xff\xff?")
ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]|\x1b[=>()][0-9A-Za-z]?")
PROMPT = re.compile(r"\] > ?$")
PATS = [("prompt", PROMPT), ("license", re.compile(r"\[Y/n\]: ?$")), ("login", re.compile(r"[Ll]ogin: ?$")),
        ("password", re.compile(r"[Pp]assword: ?$")), ("new", re.compile(r"new password> ?$")),
        ("repeat", re.compile(r"repeat new password> ?$"))]
ERR = re.compile(r"failure:|bad command name|syntax error|expected end of command|invalid value|no such item|"
                 r"input does not match|not enough|ambiguous|unknown parameter", re.I)
YA = re.compile(r"already have|already exists|such item already", re.I)


def clean(raw):
    t = IAC.sub(b"", raw).decode("utf-8", "replace")
    return ANSI.sub("", t).replace("\r", "")


class Con:
    debug = False

    def __init__(self, host, port):
        self.s = socket.create_connection((host, port), timeout=8)
        self.s.settimeout(0.5)
        self.buf = b""

    def send(self, txt, secret=False):
        if Con.debug:
            print("   TX:", "<clave oculta>" if secret else repr(txt))
        self.s.sendall(txt.encode())

    def reset(self):
        self.buf = b""

    def read_until(self, pats, timeout):
        end = time.time() + timeout
        while time.time() < end:
            try:
                chunk = self.s.recv(4096)
            except socket.timeout:
                chunk = None
            if chunk == b"":
                raise ConnectionError("la consola se ha cerrado")
            if chunk:
                if Con.debug:
                    print("   RX:", repr(chunk[-200:]))
                if b"\x1b[6n" in chunk:               # RouterOS pregunta el tamano del terminal
                    self.s.sendall(b"\x1b[1;200R")
                self.buf += chunk
            text = clean(self.buf)
            tail = text.rstrip("\n")[-300:]
            for name, rx in pats:
                if rx.search(tail):
                    return name, text
        return None, clean(self.buf)

    def close(self):
        try:
            self.s.close()
        except OSError:
            pass


def login(con, user, pw, timeout=150):
    """Entra en el router. Si es un arranque nuevo (clave vacia) pone la contrasena pw."""
    pw_try, fallos, end = pw, 0, time.time() + timeout
    user_sent = real_try = False            # user_sent: ya hemos enviado el usuario en este intento
    despertado = False
    while time.time() < end:
        name, text = con.read_until(PATS, 4 if not despertado else 8)
        if name is None:                    # la consola no dice nada: pulsamos Enter una vez para provocar el prompt
            con.send("\r")
            despertado = True
            continue
        if name == "prompt":
            return
        con.reset()
        if name == "license":
            con.send("n\r")
        elif name == "login":
            if real_try and re.search(r"nvalid user|ogin failed|incorrect", text):
                fallos += 1
                if fallos > 4:
                    raise PermissionError("contrasena incorrecta o usuario no valido")
                pw_try = "" if pw_try != "" else pw
            real_try = False
            con.send(user + "\r")
            user_sent = True
        elif name == "password":
            if user_sent:
                con.send(pw_try + "\r", secret=True)
                real_try, user_sent = True, False
            else:                           # clave pedida sin que enviemos usuario (Enter de despertar): se descarta
                con.send("\r")
        elif name in ("new", "repeat"):
            con.send(pw + "\r", secret=True)
    raise TimeoutError("no he conseguido llegar al prompt del router")


def run_lines(con, lines):
    res = []
    for ln in lines:
        con.reset()
        con.send(ln + "\r")
        name, text = con.read_until([("prompt", PROMPT)], 25)
        if name is None:
            res.append((ln, "TIMEOUT", text))
        elif YA.search(text):
            res.append((ln, "ya existia", text))
        elif ERR.search(text):
            res.append((ln, "ERROR", text))
        else:
            res.append((ln, "ok", text))
    return res


def consolas():
    p = json.load(open(PROYECTO, encoding="utf-8"))
    return {n["name"]: n["console"] for n in p["topology"]["nodes"] if n["node_type"] == "qemu" and n.get("console")}


def main():
    ap = argparse.ArgumentParser(description="Envia los .rsc de una fase a los routers por su consola telnet")
    ap.add_argument("fase", help="01 (direcciones), 02 (ospf) o 03 (bfd)")
    ap.add_argument("--nodos", help="lista separada por comas (por defecto: todos los que tengan ese fichero)")
    ap.add_argument("--saltar", default="", help="routers a omitir, separados por comas")
    ap.add_argument("--host", default=os.environ.get("GNS3_HOST", "192.168.196.128"),
                    help="IP del GNS3 VM (columna Console de Topology Summary). Tambien: variable de entorno GNS3_HOST")
    ap.add_argument("--dry-run", action="store_true", help="no conecta; solo muestra que enviaria")
    ap.add_argument("--si", action="store_true", help="no pedir confirmacion en fases no repetibles")
    ap.add_argument("--debug", action="store_true", help="muestra lo que se envia (TX) y lo que se recibe (RX)")
    a = ap.parse_args()
    Con.debug = a.debug

    ports = consolas()
    ficheros = {}
    for d in sorted(os.listdir(HERE)):
        dd = os.path.join(HERE, d)
        if os.path.isdir(dd):
            for f in os.listdir(dd):
                if f.startswith(a.fase + "_") and f.endswith(".rsc"):
                    ficheros[d] = os.path.join(dd, f)
    nodos = [n.strip() for n in a.nodos.split(",")] if a.nodos else list(ficheros)
    nodos = [n for n in nodos if n in ficheros and n not in [s.strip() for s in a.saltar.split(",") if s.strip()]]
    faltan = [n for n in nodos if n not in ports]
    if faltan:
        print("Sin puerto de consola en el proyecto (arrancad el nodo y guardad):", faltan)
        nodos = [n for n in nodos if n in ports]
    print("Fase %s -> %d routers: %s" % (a.fase, len(nodos), ", ".join(nodos)))
    if a.dry_run:
        for n in nodos:
            ls = [l for l in open(ficheros[n], encoding="utf-8").read().splitlines() if l.strip()]
            print("  %-11s %s:%d  %d comandos  (%s)" % (n, a.host, ports[n], len(ls), os.path.basename(ficheros[n])))
        return
    if a.fase != "01" and not a.si:
        if input("Esta fase NO es repetible en el mismo router. Continuar? (s/n) ").strip().lower() != "s":
            return
    pw = os.environ.get("RAC_PASS") or getpass.getpass("Contrasena de admin de los routers (no se guarda): ")
    os.makedirs(os.path.join(HERE, "logs"), exist_ok=True)
    logf = os.path.join(HERE, "logs", "push_%s_%s.txt" % (a.fase, datetime.datetime.now().strftime("%Y%m%d_%H%M%S")))
    resumen = []
    with open(logf, "w", encoding="utf-8") as lg:
        for n in nodos:
            lines = [l for l in open(ficheros[n], encoding="utf-8").read().splitlines() if l.strip() and not l.startswith("#")]
            try:
                con = Con(a.host, ports[n])
            except OSError as e:
                resumen.append((n, "NO CONECTA (nodo arrancado?)", 0, 0))
                print("%-11s NO CONECTA: %s" % (n, e))
                continue
            try:
                login(con, "admin", pw)
                res = run_lines(con, lines)
                bad = [r for r in res if r[1] in ("ERROR", "TIMEOUT")]
                ya = [r for r in res if r[1] == "ya existia"]
                lg.write("===== %s (%s)\n" % (n, ficheros[n]))
                for ln, st, out in res:
                    lg.write("--- [%s] %s\n%s\n" % (st, ln, out.strip()))
                resumen.append((n, "OK" if not bad else "CON ERRORES", len(bad), len(ya)))
                print("%-11s %-12s comandos=%d errores=%d ya_existian=%d" % (n, "OK" if not bad else "ERRORES", len(res), len(bad), len(ya)))
                for ln, st, out in bad:
                    print("     ", st, ln, "->", out.strip().splitlines()[-2:] if out.strip() else "")
            except (PermissionError, TimeoutError, ConnectionError) as e:
                resumen.append((n, "FALLO: %s" % e, 0, 0))
                print("%-11s FALLO: %s" % (n, e))
            finally:
                con.close()
    print("\nLog completo:", logf)
    if any(r[1] != "OK" for r in resumen):
        sys.exit(1)


if __name__ == "__main__":
    main()
