#!/usr/bin/env python3
"""The sources with the address of every line, after the build.

The sources carry no addresses: they would go stale as soon as anything
moves. This puts them back, from what the build produced: the N80 listing of
each module (addresses relative to the module) and the LK80 link map of each
image (where each module was placed).

As a module: line_map(build, src) gives, for every source line that emits
bytes, its absolute address, its bank, whether it is code or data and its
size; and the reverse lookups that go with it.

As a program: writes build/listing/<image>.lst, every module of the image in
link order, each line with its address and its bank (`make listing`).

Usage: listing.py [build dir] [src dir]
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from banks import BANK_SIZE                                  # noqa: E402

# image -> (first bank, address of its first bank). Same as the Makefile.
IMAGES = {"main": (0, 0x4000), "scenery": (4, 0x6000), "sound": (7, 0x8000),
          "screens": (9, 0x8000), "map": (11, 0x8000)}
DATA_OPS = {"defb", "defw", "defs", "db", "dw", "ds", "defm"}
NO_BYTES = {"public", "extrn", "include", "end", "equ", "org"}


def link_map(path):
    """module name (lower case) -> start address, from LK80's verbose output."""
    out, prog = {}, None
    with open(path, encoding="utf-8-sig") as f:
        for ln in f:
            m = re.match(r"^Program: (\S+)", ln)
            if m:
                prog = m.group(1).lower()
            m = re.match(r"^\s+Code segment: ([0-9A-F]+)h to", ln)
            if m and prog:
                out[prog] = int(m.group(1), 16)
    return out


def module_order(src):
    """image -> [module names], in the order the Makefile links them."""
    with open(os.path.join(src, "..", "Makefile"), encoding="utf-8") as f:
        text = f.read().replace("\\\n", " ")
    out = {}
    for image in IMAGES:
        m = re.search(r"(?m)^%s\s*=\s*(.*)$" % image.upper(), text)
        out[image] = [w for w in m.group(1).split() if not w.startswith("@")]
    return out


def nbytes(field):
    n = 0
    for tok in field.split():
        n += 2 if re.fullmatch(r"[0-9A-F]{4}[\"'*]?", tok) else 1
    return n


class Line:
    __slots__ = ("file", "lineno", "text", "addr", "bank", "kind", "size")

    def __init__(self, file, lineno, text):
        self.file, self.lineno, self.text = file, lineno, text
        self.addr = self.bank = self.kind = None
        self.size = 0

    def __repr__(self):
        return "%s:%d %s %s" % (self.file, self.lineno,
                                "%04X" % self.addr if self.addr is not None else "----",
                                self.text.strip()[:50])


def module_lines(build, src, image, module, base, first_bank, org):
    """[Line] for every line of src/<image>/<module>.asm, with addresses."""
    path = os.path.join(src, image, module + ".asm")
    with open(path, encoding="utf-8") as f:
        source = f.read().split("\n")
    with open(os.path.join(build, image, module + ".lst"), encoding="utf-8-sig") as f:
        listing = f.read().split("\n")
    lines = [Line("%s/%s.asm" % (image, module), i + 1, t) for i, t in enumerate(source)]
    k = 0
    current = None
    for ln in listing:
        if k >= len(lines):
            break
        is_include = ln[26:27] == "C" and ln[32:].strip().lower().startswith("include") \
            and ln[32:].rstrip() == lines[k].text.rstrip()
        if len(ln) < 32 or ln.startswith("\f") or (ln[26:27] == "C" and not is_include):
            if len(ln) >= 32 and ln[26:27] != "C" and not ln[32:].strip() and \
                    ln[2:6].strip() and current is not None:
                current.size += nbytes(ln[10:26])        # rest of a long line
            continue
        text = ln[32:]
        addr = ln[2:6]
        if not text.strip() and addr.strip() and ln[10:26].strip() and current is not None:
            current.size += nbytes(ln[10:26])            # rest of a long line
            continue
        if text.rstrip() != lines[k].text.rstrip():
            continue
        line = lines[k]
        k += 1
        current = None
        code = re.sub(r"^[A-Za-z_]\w*:", "", text.split(";", 1)[0]).strip()
        op = code.split()[0].lower() if code else ""
        if re.fullmatch(r"[0-9A-F]{4}", addr) and ln[6:7] == "'" and op and op not in NO_BYTES:
            a = base + int(addr, 16)
            line.addr = a
            line.bank = first_bank + (a - org) // BANK_SIZE
            line.kind = "data" if op in DATA_OPS else "code"
            line.size = nbytes(ln[10:26])
            current = line
        elif re.fullmatch(r"[0-9A-F]{4}", addr) and ln[6:7] == "'":
            line.addr = base + int(addr, 16)       # a label line: where it points
            line.bank = first_bank + (line.addr - org) // BANK_SIZE
    if any(l.text.strip() for l in lines[k:]):
        raise SystemExit("%s: listing and source do not match after line %d" % (path, k))
    return lines


def line_map(build, src):
    """image -> [Line] in link order (every line of every module)."""
    order = module_order(src)
    out = {}
    for image, (first, org) in IMAGES.items():
        bases = link_map(os.path.join(build, image + ".map"))
        out[image] = []
        for module in order[image]:
            out[image] += module_lines(build, src, image, module, bases[module], first, org)
    return out


def main():
    build = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "..", "build")
    src = sys.argv[2] if len(sys.argv) > 2 else os.path.join(HERE, "..", "src")
    outdir = os.path.join(build, "listing")
    os.makedirs(outdir, exist_ok=True)
    for image, lines in line_map(build, src).items():
        path = os.path.join(outdir, image + ".lst")
        with open(path, "w", encoding="utf-8") as f:
            current = None
            for ln in lines:
                if ln.file != current:
                    f.write("\n%s %s\n" % ("=" * 20, ln.file))
                    current = ln.file
                where = ("b%02d:%04X" % (ln.bank, ln.addr)) if ln.kind else " " * 8
                f.write("%s  %s\n" % (where, ln.text))
        print("  %s" % path)


if __name__ == "__main__":
    main()
