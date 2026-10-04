#!/usr/bin/env python3
"""Proposes the D directives of a bank, splitting where the code points.

It decides nothing: it PROPOSES, and the proposal has to be reviewed and
given a name. What it does is the mechanical work of closing the budget:

  - it takes the gaps that remain (neither traced code nor an already
    declared D range);
  - it splits them at every address pointed at by an instruction of the
    traced code, counting only the instructions that execute WITH THAT BANK
    MAPPED (at 0x8000 there are five different banks depending on the moment,
    and a pointer from another bank arrangement proves nothing);
  - it also splits at the boundaries of the compressed blocks, when the piece
    is an RLE chain that fits with no slack (tools/rle.py);
  - and it separates the 0xFF tail, which is filler up to the 8 KB.

Each line comes out with the pointer that justifies it written next to it. A
range with no pointer is not a failure: it can be the continuation of a table
that is walked sequentially. But it has to be said, not kept quiet.

Usage: propose_data.py <rom> <work_dir> <src_dir> pNN [pNN ...]
"""
import json
import os
import sys

from bank_tracer import full_trace
from banks import ORG, BANK_SIZE, N_BANKS, bank_name
from rle import chain

SLOT = {0x4000: 0, 0x6000: 0, 0x8000: 1, 0xA000: 2}   # 0x4000 has no register


def marks(rom, work, src, p):
    """0 = unexplained, 1 = traced code, 2 = already declared as data."""
    o = ORG[p]
    m = bytearray(BANK_SIZE)
    path = os.path.join(work, bank_name(p) + ".trace.json")
    if os.path.exists(path):
        for k, a, b in json.load(open(path))["blocks"]:
            if k == "c":
                for i in range(a - o, b - o):
                    m[i] = 1
    notes = os.path.join(src, bank_name(p) + ".notes")
    if os.path.exists(notes):
        for ln in open(notes, encoding="utf-8"):
            if ln.startswith("D "):
                q = ln.split(None, 3)
                for i in range(max(0, int(q[1], 0) - o),
                               min(BANK_SIZE, int(q[2], 0) - o)):
                    m[i] = 2
    return m


def pointers(rom, t, p):
    """{address: [pointer text]} with bank p really mapped."""
    o = ORG[p]
    slot = SLOT[o]
    out = {}
    for b, pc in sorted(t.starts):
        off = b * BANK_SIZE + (pc & 0x1FFF)
        op = rom[off]
        w = None
        if op in (0x01, 0x11, 0x21, 0x31, 0x22, 0x2A, 0x32, 0x3A) \
                and (pc & 0x1FFF) + 3 <= BANK_SIZE:
            w = rom[off + 1] | (rom[off + 2] << 8)
        elif op in (0xDD, 0xFD) and (pc & 0x1FFF) + 4 <= BANK_SIZE \
                and rom[off + 1] in (0x21, 0x22, 0x2A):
            w = rom[off + 2] | (rom[off + 3] << 8)
        if op == 0x32 and w in (0x6000, 0x8000, 0xA000):
            continue          # it is a write to the mapper, not a pointer
        if w is None or not (o <= w < o + BANK_SIZE):
            continue
        # Bank 0 is ALWAYS at 0x4000: there is no arrangement to check.
        if p and p not in {c[slot] for c in t.layouts_of[(b, pc)]}:
            continue
        out.setdefault(w, []).append("%s:%04X" % (bank_name(b), pc))
    return out


def ff_tail(rom, p):
    """Where the 0xFF tail of the bank starts (or None if there is none)."""
    base = p * BANK_SIZE
    i = BANK_SIZE - 1
    while i >= 0 and rom[base + i] == 0xFF:
        i -= 1
    return ORG[p] + i + 1 if i < BANK_SIZE - 1 else None


def main(rom_path, work, src, *which):
    rom = open(rom_path, "rb").read()
    t, _ = full_trace(rom, src)
    banks = [int(c[1:], 10) for c in which] if which else list(range(N_BANKS))
    for p in banks:
        o = ORG[p]
        m = marks(rom, work, src, p)
        ap = pointers(rom, t, p)
        ff = ff_tail(rom, p)
        cuts = {a - o for a in ap if 0 <= a - o < BANK_SIZE}
        if ff is not None:
            cuts.add(ff - o)
        gaps, start = [], None
        for i in range(BANK_SIZE + 1):
            v = m[i] if i < BANK_SIZE else 1
            if not v and start is None:
                start = i
            elif v and start is not None:
                gaps.append((start, i))
                start = None
        print("# ---- %s (org %#06x): %d unexplained bytes ----"
              % (bank_name(p), o, sum(b - a for a, b in gaps)))
        for a, b in gaps:
            points = sorted({a, b} | {c for c in cuts if a < c < b})
            for x, y in zip(points, points[1:]):
                who = ap.get(o + x)
                chunk = rom[p * BANK_SIZE + x:p * BANK_SIZE + y]
                if set(chunk) == {0xFF}:
                    what = "0xFF filler up to the 8 KB of the bank"
                    name = "filler"
                elif who:
                    what = "pointed at by " + " ".join(who[:4])
                    name = "data_%04X" % (o + x)
                else:
                    what = "NOBODY points at it directly"
                    name = "data_%04X" % (o + x)
                print("D 0x%04X 0x%04X %s   %s   (%d bytes)"
                      % (o + x, o + y, name, what, y - x))
                blocks, end = chain(rom, p, o + x, o + y)
                if end == o + y and len(blocks) > 1 and (y - x) > 32:
                    print("#   RLE chain that fits: %d blocks -> %s"
                          % (len(blocks),
                             " ".join("%04X" % q[0] for q in blocks[:12])))
    return 0


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:]))
