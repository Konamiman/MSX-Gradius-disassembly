#!/usr/bin/env python3
"""Merges the lines of another file into the notes file of a bank.

    python3 tools/add_notes.py <bank> <file with L/C/B/D/F lines>

    bank: 00..15, or the file name (src/p03.notes)

Commenting is a long session, and the annotations are written separately so
as not to touch the good file until the whole batch is ready. This merges
them:

  - a C at an address that already has a C REPLACES it (it is a correction);
  - an L at an address that already has an L replaces it too;
  - B lines are added, since a block can have several lines;
  - and everything ends up sorted by address, with the order B, L, D, F, C
    within each one, which is what mkasm expects.

There are SIXTEEN notes files here, one per bank, because each bank is
assembled at its own org. The address of a line has to fall inside the bank
it is merged into, and this checks it: a comment in the wrong bank would never
reach the listing.

When done it says how many lines there were and how many there are, so the
effect can be seen.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ORDER = {"B": 0, "L": 1, "D": 2, "F": 3, "C": 4}

# Where each bank executes; the same table as tools/banks.py.
ORG = {"00": 0x4000, "01": 0x6000, "02": 0x8000, "03": 0xA000,
       "04": 0x6000, "05": 0x8000, "06": 0xA000, "07": 0x8000,
       "08": 0xA000, "09": 0x8000, "10": 0xA000, "11": 0x8000,
       "12": 0xA000, "13": 0x8000, "14": 0x8000, "15": 0x8000}


def sort_key(l):
    p = l.split()
    return (int(p[1], 0), ORDER.get(p[0], 9))


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    bank = sys.argv[1]
    if bank.endswith(".notes"):
        notes = bank if os.path.exists(bank) else os.path.join(ROOT, bank)
        bank = os.path.basename(notes)[1:3]
    else:
        notes = os.path.join(ROOT, "src", "p%s.notes" % bank)
    if bank not in ORG:
        raise SystemExit("unknown bank: %s" % bank)
    start = ORG[bank]
    end = start + 0x2000

    new_lines = [l.rstrip("\n") for l in open(sys.argv[2], encoding="utf-8")
                 if l.strip() and not l.lstrip().startswith("#")]
    for l in new_lines:
        if not re.match(r"^[BLDFC] 0x[0-9A-Fa-f]+", l):
            raise SystemExit("line that is not a directive: %s" % l[:70])
        a = int(l.split()[1], 0)
        if not start <= a < end:
            raise SystemExit("0x%04X does not fall in bank %s (0x%04X..0x%04X): %s"
                             % (a, bank, start, end, l[:70]))

    old_lines = open(notes, encoding="utf-8").read().splitlines()
    header = [l for l in old_lines if l.startswith("#")]
    body = [l for l in old_lines if l.strip() and not l.startswith("#")]

    replaced = {(l.split()[0], l.split()[1].lower()) for l in new_lines
                if l.split()[0] in ("C", "L")}
    before = len(body)
    body = [l for l in body
            if (l.split()[0], l.split()[1].lower()) not in replaced]
    body += new_lines
    body.sort(key=sort_key)
    open(notes, "w", encoding="utf-8").write("\n".join(header + body) + "\n")
    print("  p%s: %d lines -> %d (%d new, %d replaced)"
          % (bank, before, len(body), len(new_lines),
             before + len(new_lines) - len(body)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
