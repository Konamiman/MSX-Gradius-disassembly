#!/usr/bin/env python3
"""Counts, routine by routine, how many instructions carry a line comment.

The second commenting pass is not done by eye: first we measure where the gaps
are. A routine with a name but zero comments has been named, not explained.

Usage: density.py <asm> [min_instructions]
"""
import re
import sys


def main():
    lines = open(sys.argv[1], encoding="utf-8").read().splitlines()
    minimum = int(sys.argv[2]) if len(sys.argv) > 2 else 6
    blocks, name, start, n, c = [], "(header)", 0, 0, 0
    for ln in lines:
        m = re.match(r"^([A-Za-z_][A-Za-z_0-9]*):\s*(;.*)?$", ln)
        if m:
            if n:
                blocks.append((name, start, n, c))
            name, start, n, c = m.group(1), 0, 0, 0
            continue
        m = re.match(r"^\t.*;([0-9a-f]{4})(.*)$", ln)
        if not m:
            continue
        if not start:
            start = int(m.group(1), 16)
        n += 1
        if ";" in m.group(2):
            c += 1
    if n:
        blocks.append((name, start, n, c))
    tot_n = sum(b[2] for b in blocks)
    tot_c = sum(b[3] for b in blocks)
    weak = [b for b in blocks if b[2] >= minimum and b[3] * 100 // b[2] < 10]
    for nm, a, n, c in sorted(weak, key=lambda b: -b[2]):
        print("  %-32s 0x%04X  %3d instr  %2d comments  %2d %%"
              % (nm, a, n, c, c * 100 // n))
    if not tot_n:
        # Ten of the sixteen banks are data from end to end: they do not have
        # a single instruction to count, and that is not an error.
        print("  ---- this bank has no code: nothing to measure")
        return
    print("  ---- %d routines below 10 %%, out of %d" % (len(weak), len(blocks)))
    print("  ---- in total: %d instructions, %d comments, %.1f %%"
          % (tot_n, tot_c, 100.0 * tot_c / tot_n))


main()
