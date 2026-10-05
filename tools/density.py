#!/usr/bin/env python3
"""Counts, routine by routine, how many instructions carry a line comment.

The second commenting pass is not done by eye: first we measure where the gaps
are. A routine with a name but zero comments has been named, not explained.

A routine runs from one label to the next. Only instructions count: data
lines, directives and comment lines do not.

Usage: density.py <src dir> [min_instructions]
       density.py <file.asm> [min_instructions]
"""
import os
import re
import sys

NOT_INSTRUCTIONS = {"defb", "defw", "defs", "db", "dw", "ds", "defm",
                    "public", "extrn", "include", "end", "equ", "org"}


def link_order(src):
    """image -> [module files], in the order the Makefile links them."""
    text = open(os.path.join(src, "..", "Makefile"), encoding="utf-8").read()
    text = text.replace("\\\n", " ")
    out = {}
    for image in ("main", "scenery", "sound", "screens", "map"):
        m = re.search(r"(?m)^%s\s*=\s*(.*)$" % image.upper(), text)
        out[image] = [os.path.join(src, image, w + ".asm") for w in m.group(1).split()
                      if not w.startswith("@")]
    return out


def routines(paths):
    """[(name, instructions, commented)] for files linked one after another.

    A module that starts without a label carries on the last routine of the
    previous one (the code falls through from one file into the next)."""
    out, name, n, c = [], "(start of %s)" % os.path.basename(paths[0]), 0, 0
    for ln in (ln for p in paths for ln in open(p, encoding="utf-8")):
        m = re.match(r"^([A-Za-z_]\w*):", ln)
        if m and not re.search(r"\bequ\b", ln.split(";", 1)[0].lower()):
            if n:
                out.append((name, n, c))
            name, n, c = m.group(1), 0, 0
            continue
        if not ln.startswith("\t"):
            continue
        code, _, comment = ln.partition(";")
        op = code.split()[0].lower() if code.split() else ""
        if not op or op in NOT_INSTRUCTIONS:
            continue
        n += 1
        if comment.strip():
            c += 1
    if n:
        out.append((name, n, c))
    return out


def main():
    target = sys.argv[1]
    minimum = int(sys.argv[2]) if len(sys.argv) > 2 else 6
    if os.path.isdir(target):
        groups = link_order(target)
    else:
        groups = {os.path.basename(target): [target]}

    all_n = all_c = all_r = all_weak = 0
    for image, files in groups.items():
        blocks = routines(files)
        tot_n = sum(b[1] for b in blocks)
        tot_c = sum(b[2] for b in blocks)
        weak = [b for b in blocks if b[1] >= minimum and b[2] * 100 // b[1] < 10]
        print("-- %s" % image)
        for name, n, c in sorted(weak, key=lambda b: -b[1]):
            print("  %-32s %3d instr  %2d comments  %2d %%" % (name, n, c, c * 100 // n))
        if not tot_n:
            print("  ---- no code in this image: nothing to measure")
            continue
        print("  ---- %d routines below 10 %%, of %d" % (len(weak), len(blocks)))
        print("  ---- %d instructions, %d comments, %.1f %%"
              % (tot_n, tot_c, 100.0 * tot_c / tot_n))
        all_n += tot_n
        all_c += tot_c
        all_r += len(blocks)
        all_weak += len(weak)
    if len(groups) > 1 and all_n:
        print("== in total: %d instructions, %d comments, %.1f %%; %d routines,"
              " %d below 10 %%" % (all_n, all_c, 100.0 * all_c / all_n, all_r, all_weak))


if __name__ == "__main__":
    main()
