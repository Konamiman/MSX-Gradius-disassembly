#!/usr/bin/env python3
"""Puts in both READMEs the figures that are really in the tree.

It exists because in this series of disassemblies it has already happened
twice that the front page published one count and the listing had another:
comments get written, labels get added, and nobody remembers to touch the
README table. The tests catch it (they compare both figures) but then they
have to be reconciled by hand. This reconciles them on its own.

What it updates, in README.md and README.es.md, are the rows of the "where it
stands" table: traced code, identified data, listing lines, entry points,
labels, comments and data ranges.

Usage: figures.py            writes the figures into both READMEs
       figures.py --show     only prints them
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from banks import N_BANKS, BANK_SIZE, bank_name                # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOTAL = BANK_SIZE * N_BANKS

ROWS = {
    "README.md": (",", (("traced code", "code"),
                        ("identified data", "data"),
                        ("listing", "lines"),
                        ("entry points, each with its justification", "entries"),
                        ("named labels", "L"),
                        ("anchored comments", "C"),
                        ("explained data ranges", "D"))),
    "README.es.md": (".", (("código trazado", "code"),
                           ("datos identificados", "data"),
                           ("listado", "lines"),
                           ("puntos de entrada, cada uno con su justificación",
                            "entries"),
                           ("etiquetas con nombre", "L"),
                           ("comentarios anclados", "C"),
                           ("rangos de datos con explicación", "D"))),
}


def count():
    c = {"L": 0, "C": 0, "D": 0, "code": 0, "lines": 0, "entries": 0}
    for p in range(N_BANKS):
        with open(os.path.join(ROOT, "src", bank_name(p) + ".notes"),
                  encoding="utf-8") as f:
            for ln in f:
                if ln[:2] in ("L ", "C ", "D "):
                    c[ln[0]] += 1
        trace = os.path.join(ROOT, "work", bank_name(p) + ".trace.json")
        if os.path.exists(trace):
            with open(trace, encoding="utf-8") as f:
                c["code"] += json.load(f)["report"]["code_bytes"]
        asm = os.path.join(ROOT, "src", "nemesis_%s.asm" % bank_name(p))
        if os.path.exists(asm):
            with open(asm, encoding="utf-8") as f:
                c["lines"] += len(f.read().splitlines())
        with open(os.path.join(ROOT, "src", bank_name(p) + ".entries"),
                  encoding="utf-8") as f:
            c["entries"] += sum(1 for ln in f
                                if ln.strip() and not ln.lstrip().startswith("#"))
    c["data"] = TOTAL - c["code"]
    return c


def main():
    c = count()
    print("  code %d  data %d  lines %d  entries %d  L %d  C %d  D %d"
          % (c["code"], c["data"], c["lines"], c["entries"],
             c["L"], c["C"], c["D"]))
    if "--show" in sys.argv:
        return 0
    for fname, (sep, rows) in ROWS.items():
        path = os.path.join(ROOT, fname)
        if not os.path.exists(path):
            continue
        with open(path, encoding="utf-8") as f:
            text = f.read()
        for label, key in rows:
            value = format(c[key], ",").replace(",", sep)
            text = re.sub(r"(\|\s*%s\s*\|\s*)[0-9.,]+" % re.escape(label),
                          lambda m, v=value: m.group(1) + v, text)
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        print("  %s updated" % fname)
    return 0


if __name__ == "__main__":
    sys.exit(main())
