#!/usr/bin/env python3
"""Puts in both READMEs, and in the website, the figures that are really in the tree.

It exists because in this series of disassemblies it has already happened
twice that the front page published one count and the sources had another:
comments get written, labels get added, and nobody remembers to touch the
README table. The tests catch it (they compare both figures) but then they
have to be reconciled by hand. This reconciles them on its own.

What it updates:
  - in README.md and README.es.md, the rows of the "where it stands" table:
    code, data, modules, source lines, named routines, line comments and
    explained data ranges;
  - in tools/make_web.py, the constants the website is built with.

The code and data bytes come from tools/check_code.py, so the ROM has to be
built first (`make figures` does it).

Usage: figures.py            writes the figures
       figures.py --show     only prints them
"""
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
ROOT = os.path.dirname(HERE)
SRC = os.path.join(ROOT, "src")
BUILD = os.path.join(ROOT, "build")

ROWS = {
    "README.md": (",", (("traced code", "code"),
                        ("identified data", "data"),
                        ("modules", "modules"),
                        ("source lines", "lines"),
                        ("named routines", "routines"),
                        ("line comments", "comments"),
                        ("explained data ranges", "ranges"))),
    "README.es.md": (".", (("código trazado", "code"),
                           ("datos identificados", "data"),
                           ("módulos", "modules"),
                           ("líneas de fuente", "lines"),
                           ("rutinas con nombre", "routines"),
                           ("comentarios de línea", "comments"),
                           ("rangos de datos con explicación", "ranges"))),
}

DATA_OPS = {"defb", "defw", "defs", "db", "dw", "ds", "defm"}
DIRECTIVES = {"public", "extrn", "include", "end", "equ", "org"}
# Labels that only give an address a name of convenience: not "named".
UNNAMED = re.compile(r"^(L|DATA)_[0-9A-F]{4}(_[0-9A-F]{4})?$")


def source_files():
    for image in sorted(os.listdir(SRC)):
        d = os.path.join(SRC, image)
        if os.path.isdir(d) and image != "inc":
            for fn in sorted(os.listdir(d)):
                if fn.endswith(".asm"):
                    yield os.path.join(d, fn)


def is_real_comment(text):
    """Line comments written by a person, not generated annotations: a table
    index, an ASCII rendering of the bytes, or a "-> label" pointer note."""
    text = text.strip()
    return bool(text) and not re.fullmatch(r"\d+|\".*\"|-> [\w ]+", text)


def count():
    c = {"modules": 0, "lines": 0, "routines": 0, "comments": 0, "ranges": 0}
    for path in source_files():
        c["modules"] += 1
        pending = []
        for ln in open(path, encoding="utf-8"):
            c["lines"] += 1
            if ln.startswith("; DATA "):
                c["ranges"] += 1
                continue
            m = re.match(r"^([A-Za-z_]\w*):", ln)
            if m and not re.search(r"\bequ\b", ln.split(";", 1)[0].lower()):
                pending.append(m.group(1))
                continue
            if not ln.startswith("\t"):
                continue
            code, _, comment = ln.partition(";")
            op = code.split()[0].lower() if code.split() else ""
            if not op or op in DIRECTIVES:
                continue
            if op not in DATA_OPS:
                c["routines"] += sum(1 for n in pending if not UNNAMED.match(n))
            pending = []
            if is_real_comment(comment):
                c["comments"] += 1
    rom = os.path.join(BUILD, "nemesis.rom")
    out = subprocess.run([sys.executable, os.path.join(HERE, "check_code.py"), rom,
                          BUILD, SRC, "--show"], capture_output=True, text=True, check=True)
    c.update(json.loads(out.stdout))
    import density                                      # noqa: E402
    groups = density.link_order(SRC)
    blocks = [b for files in groups.values() for b in density.routines(files)]
    c["instructions"] = sum(b[1] for b in blocks)
    c["commented"] = sum(b[2] for b in blocks)
    return c


def main():
    c = count()
    print("  " + "  ".join("%s %s" % (k, v) for k, v in c.items()))
    if "--show" in sys.argv:
        return 0
    for fname, (sep, rows) in ROWS.items():
        path = os.path.join(ROOT, fname)
        with open(path, encoding="utf-8") as f:
            text = f.read()
        for label, key in rows:
            value = format(c[key], ",").replace(",", sep)
            text = re.sub(r"(\|\s*%s\s*\|\s*)[0-9.,]+" % re.escape(label),
                          lambda m, v=value: m.group(1) + v, text)
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        print("  %s updated" % fname)
    path = os.path.join(HERE, "make_web.py")
    with open(path, encoding="utf-8") as f:
        text = f.read()
    density_pct = ("%.1f" % (100.0 * c["commented"] / c["instructions"])).replace(".", ",")
    for name, value in (("CODE_BYTES", str(c["code"])), ("DATA_BYTES", str(c["data"])),
                        ("ROUTINES", str(c["routines"])), ("DENSITY", '"%s"' % density_pct)):
        text = re.sub(r"(?m)^%s = .*$" % name, "%s = %s" % (name, value), text)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    print("  tools/make_web.py updated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
