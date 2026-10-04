#!/usr/bin/env python3
"""Each unexplained gap, and WHO points at it from the code already traced.

A data range is not declared because it is left over: it is declared because
there is an identified instruction that reads it. This tool looks for that
instruction.

It walks the instruction starts of the trace (never the raw bytes, which is
how pointers get invented where there are none), keeps the 16-bit operands
(`ld hl,nn`, `ld de,nn`, `ld bc,nn`, `ld ix,nn`, `ld a,(nn)`,
`ld hl,(nn)`...) and says which ones fall inside each gap.

In a MegaROM there is one more step: an instruction in another bank pointing
at 0x8123 is only valid as evidence if at that moment the bank being looked at
was at 0x8000. That is why, besides the pointer, it says FROM WHICH BANK it is
pointed at, and those pointing from a bank whose slot is the same are marked
separately: they are pointers inside the bank itself.

The gaps that come out with NOBODY pointing at them are the interesting ones:
either they are chained data consumed one after another, or they are code the
trace does not reach.

Usage: gaps.py <rom> <work_dir> <src_dir> [pNN ...]
"""
import json
import os
import re
import sys

from bank_tracer import BASE_LEN, ED_LEN4, IDX_DISP
from banks import ORG, BANK_SIZE, N_BANKS, bank_name

# Instructions with a 16-bit immediate that can be an address.
IMMEDIATE = {
    0x01: "ld bc,", 0x11: "ld de,", 0x21: "ld hl,", 0x31: "ld sp,",
    0x22: "ld (nn),hl", 0x2A: "ld hl,(nn)", 0x32: "ld (nn),a", 0x3A: "ld a,(nn)",
    0xC3: "jp ", 0xCD: "call ",
    0xC2: "jp nz,", 0xCA: "jp z,", 0xD2: "jp nc,", 0xDA: "jp c,",
    0xE2: "jp po,", 0xEA: "jp pe,", 0xF2: "jp p,", 0xFA: "jp m,",
    0xC4: "call nz,", 0xCC: "call z,", 0xD4: "call nc,", 0xDC: "call c,",
    0xE4: "call po,", 0xEC: "call pe,", 0xF4: "call p,", 0xFC: "call m,",
}
IDX = {0x21: "ld i%s,", 0x22: "ld (nn),i%s", 0x2A: "ld i%s,(nn)"}


def ilen(d, o):
    op = d[o]
    if op == 0xCB:
        return 2
    if op == 0xED:
        return 4 if d[o + 1] in ED_LEN4 else 2
    if op in (0xDD, 0xFD):
        o2 = d[o + 1]
        if o2 == 0xCB:
            return 4
        if o2 in (0xDD, 0xFD, 0xED):
            return 1
        return 1 + BASE_LEN[o2] + (1 if o2 in IDX_DISP else 0)
    return BASE_LEN[op]


def instructions(rom, work, p):
    """(address, mnemonic, 16-bit operand) of the traced code of p."""
    path = os.path.join(work, bank_name(p) + ".trace.json")
    if not os.path.exists(path):
        return
    base = p * BANK_SIZE
    for k, a, b in json.load(open(path))["blocks"]:
        if k != "c":
            continue
        pc = a
        while pc < b:
            o = base + (pc & 0x1FFF)
            n = ilen(rom, o)
            if n == 0 or pc + n > b:
                break
            op = rom[o]
            if op in IMMEDIATE and n == 3:
                yield pc, IMMEDIATE[op], rom[o + 1] | (rom[o + 2] << 8)
            elif op in (0xDD, 0xFD) and rom[o + 1] in IDX and n == 4:
                yield (pc, IDX[rom[o + 1]] % ("x" if op == 0xDD else "y"),
                       rom[o + 2] | (rom[o + 3] << 8))
            pc += n


def note_ranges(path):
    out = []
    if not os.path.exists(path):
        return out
    for ln in open(path, encoding="utf-8"):
        if ln.startswith("D "):
            q = ln.split(None, 3)
            out.append((int(q[1], 0), int(q[2], 0)))
    return out


def main(rom_path, work, src, *which):
    rom = open(rom_path, "rb").read()
    selected = [int(c[1:], 10) for c in which] if which else list(range(N_BANKS))

    # All the pointers in the cartridge, grouped by value.
    pointers = {}
    for p in range(N_BANKS):
        for pc, mn, w in instructions(rom, work, p):
            pointers.setdefault(w, []).append((p, pc, mn))

    for p in selected:
        o = ORG[p]
        marks = bytearray(BANK_SIZE)
        path = os.path.join(work, bank_name(p) + ".trace.json")
        if os.path.exists(path):
            for k, a, b in json.load(open(path))["blocks"]:
                if k == "c":
                    for i in range(a - o, b - o):
                        marks[i] = 1
        for a, b in note_ranges(os.path.join(src, bank_name(p) + ".notes")):
            for i in range(max(0, a - o), min(BANK_SIZE, b - o)):
                marks[i] = 2
        rows, start = [], None
        for i in range(BANK_SIZE + 1):
            v = marks[i] if i < BANK_SIZE else 1
            if not v and start is None:
                start = i
            elif v and start is not None:
                rows.append((start, i))
                start = None
        if not rows:
            continue
        print("# ---- %s (org %#06x): %d gaps, %d bytes unexplained ----" % (
            bank_name(p), o, len(rows), sum(b - a for a, b in rows)))
        for a, b in rows:
            chunk = rom[p * BANK_SIZE + a:p * BANK_SIZE + b]
            ff = sum(1 for c in chunk if c == 0xFF)
            print("  %04X..%04X  %5d B  (0xFF: %d)  %s" % (
                o + a, o + b - 1, b - a, ff,
                " ".join("%02x" % c for c in chunk[:10])))
            who = []
            for w in range(o + a, o + b):
                for pp, pc, mn in pointers.get(w, []):
                    who.append((w, pp, pc, mn))
            if not who:
                print("      nobody points at it with a 16-bit immediate")
            for w, pp, pc, mn in who[:14]:
                same = "same slot" if ORG[pp] == (w & 0xE000) or (
                    pp == p) else "other slot"
                print("      %04X  <- %s:%04X  %s%04X   (%s)" % (
                    w, bank_name(pp), pc, mn, w, same))
            if len(who) > 14:
                print("      ... and %d more pointers" % (len(who) - 14))
    return 0


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:]))
