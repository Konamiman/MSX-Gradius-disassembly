#!/usr/bin/env python3
"""Checks what the sources say against what the code really does.

The reassembly cannot tell code from data: the bytes come out the same either
way. This checks it from the other side. The whole-cartridge tracer
(bank_tracer.py) follows the code from the two entry points the hardware
guarantees (INIT and the interrupt hook), plus the few in seeds.txt, keeping
track of which bank is in each slot; and the instructions written in the
sources have to be EXACTLY the ones it reaches:

  - an instruction in the sources that the tracer does not reach is either
    dead code or data written as code;
  - a traced instruction that the sources write as data (or that starts
    halfway through an instruction of the sources) is code being hidden.

It also checks that no data is left unexplained: every `defb`/`defw` line has
to be under a `; DATA name: ...` header.

Where everything is comes from the build: the N80 listing of each module
(build/<image>/<module>.lst, with addresses relative to the module) and the
LK80 link map of each image (build/<image>.map, with where each module was
placed).

Usage: check_code.py <rom> <build dir> <src dir> [--show]
       --show also prints the code/data figures, for figures.py
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from bank_tracer import full_trace                     # noqa: E402
from banks import BANK_SIZE, N_BANKS                   # noqa: E402

# image -> (first bank, address of its first bank). Same as the Makefile.
IMAGES = {"main": (0, 0x4000), "scenery": (4, 0x6000), "sound": (7, 0x8000),
          "screens": (9, 0x8000), "map": (11, 0x8000)}
# Places where the game jumps into the middle of one of its own instructions,
# so that its last byte runs as an instruction of its own. No source line can
# start there; each one is explained where it happens.
OVERLAPPING = {
    (0, 0x55F4),    # cheats.asm: `jr c,$+5` into the E0h (`ret po`) that ends
                    # `ld (0e067h),de`
}
DATA_OPS = {"defb", "defw", "defs", "db", "dw", "ds", "defm"}
NO_BYTES = {"public", "extrn", "include", "end", "equ", "org"}

# address' (relative to the module), bytes, a C for lines coming from an
# include file, and the source line.
LST = re.compile(r"^  ([0-9A-F]{4})'   (.{16})(.)     (.*)$")


def link_map(path):
    """module name (lower case) -> start address, from LK80's verbose output."""
    out, prog = {}, None
    with open(path, encoding="utf-8-sig") as f:
        lines = f.readlines()
    for ln in lines:
        m = re.match(r"^Program: (\S+)", ln)
        if m:
            prog = m.group(1).lower()
        m = re.match(r"^\s+Code segment: ([0-9A-F]+)h to", ln)
        if m and prog:
            out[prog] = int(m.group(1), 16)
    return out


def nbytes(field):
    """Bytes shown in the listing's byte column (XX, XXXX', XXXX*, ...)."""
    n = 0
    for tok in field.split():
        n += 2 if re.fullmatch(r"[0-9A-F]{4}[\"'*]?", tok) else 1
    return n


def source_items(listing):
    """(relative address, kind, size) for each line that emits bytes."""
    items = []
    with open(listing, encoding="utf-8-sig") as f:
        lines = f.readlines()
    for ln in lines:
        m = LST.match(ln.rstrip("\n"))
        if not m or not m.group(2).strip() or m.group(3) == "C":
            continue
        src = re.sub(r"^[A-Za-z_]\w*:", "", m.group(4)).strip()
        if not src:
            # the rest of the bytes of a long line: same item as the line above
            if items:
                a, kind, size = items[-1]
                items[-1] = (a, kind, size + nbytes(m.group(2)))
            continue
        op = src.split()[0].lower()
        if op in NO_BYTES:
            continue
        items.append((int(m.group(1), 16), "data" if op in DATA_OPS else "code",
                      nbytes(m.group(2))))
    return items


def unexplained_data(src_dir):
    """Data lines not covered by a `; DATA` header, per module."""
    out = {}
    for image in IMAGES:
        d = os.path.join(src_dir, image)
        for fn in sorted(os.listdir(d)):
            covered, n = False, 0
            with open(os.path.join(d, fn), encoding="utf-8") as f:
                lines = f.readlines()
            for ln in lines:
                if ln.startswith("; DATA "):
                    covered = True
                    continue
                code = ln.split(";", 1)[0].strip()
                code = re.sub(r"^[A-Za-z_]\w*:", "", code).strip()
                if not code:
                    continue
                op = code.split()[0].lower()
                if op in DATA_OPS:
                    if not covered:
                        n += 1
                elif op not in NO_BYTES:
                    covered = False
            if n:
                out["%s/%s" % (image, fn)] = n
    return out


def main():
    rom_path, build, src = sys.argv[1:4]
    rom = open(rom_path, "rb").read()
    t, _sizes = full_trace(rom, src)
    # An instruction that straddles two banks (the one at the end of bank 1)
    # is kept apart by the tracer; in the main image it is one more instruction.
    traced = set(t.starts) | {(b, pc) for b, pc, _n in t.split}

    written, code_bytes = set(), 0
    for image, (first, org) in IMAGES.items():
        bases = link_map(os.path.join(build, image + ".map"))
        for mod, base in bases.items():
            for rel, kind, size in source_items(os.path.join(build, image, mod + ".lst")):
                if kind == "code":
                    a = base + rel
                    written.add((first + (a - org) // BANK_SIZE, a))
                    code_bytes += size

    not_traced = sorted(written - traced)
    hidden = sorted(traced - written - OVERLAPPING)
    unexplained = unexplained_data(src)

    total = BANK_SIZE * N_BANKS
    if "--show" in sys.argv:
        print(json.dumps({"code": code_bytes, "data": total - code_bytes,
                          "unexplained": sum(unexplained.values())}))
        return 0
    print("  %d instructions written in the sources, %d reached by the tracer"
          " (plus %d jump%s into the middle of an instruction)"
          % (len(written), len(traced - OVERLAPPING), len(traced & OVERLAPPING),
             "" if len(traced & OVERLAPPING) == 1 else "s"))
    for b, a in not_traced[:12]:
        print("  written as code, never reached: bank %d, 0x%04X" % (b, a))
    for b, a in hidden[:12]:
        print("  traced, but not an instruction in the sources: bank %d, 0x%04X" % (b, a))
    for mod, n in sorted(unexplained.items()):
        print("  %s: %d data lines without a DATA header" % (mod, n))
    print("  %d bytes of code, %d of data (filler included), %d of %d in all"
          % (code_bytes, total - code_bytes, total, total))
    if not_traced or hidden or unexplained:
        print("  FAIL")
        return 1
    print("  OK: the code in the sources is exactly the traced code, and no data is"
          " left unexplained")
    return 0


if __name__ == "__main__":
    sys.exit(main())
