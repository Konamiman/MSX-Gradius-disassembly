#!/usr/bin/env python3
"""Checks the line comments in the notes before reassembling.

Two things: that each C falls on the first byte of an instruction, and that
there are no two C lines for the same address (the second one would silently
overwrite the first).

The test catches it anyway, but here it shows up immediately and with the
line of the file.

Usage: validate_c.py <asm> <notes> [--fix]

With --fix it removes the duplicates keeping the LAST one, and says which
one it removed.
"""
import re
import sys

valid = set()
for ln in open(sys.argv[1], encoding="utf-8"):
    m = re.match(r"^\t.*;([0-9a-f]{4})", ln)
    if m:
        valid.add(int(m.group(1), 16))
lines = open(sys.argv[2], encoding="utf-8").readlines()
fix = "--fix" in sys.argv
misplaced, seen, dups = [], {}, []
for i, ln in enumerate(lines):
    m = re.match(r"^C 0x([0-9A-Fa-f]{4})\s", ln)
    if not m:
        continue
    d = int(m.group(1), 16)
    if d not in valid:
        misplaced.append((i + 1, ln.rstrip()))
    if d in seen:
        dups.append(seen[d])
    seen[d] = i
for i, ln in misplaced:
    print("  out of place, line %d: %s" % (i, ln))
for i in dups:
    print("  duplicate%s: %s" % (" (removed)" if fix else "", lines[i].rstrip()))
if fix and dups:
    for i in sorted(dups, reverse=True):
        del lines[i]
    open(sys.argv[2], "w", encoding="utf-8").writelines(lines)
    dups = []
print("  ---- %d out of place, %d duplicates" % (len(misplaced), len(dups)))
sys.exit(1 if misplaced or dups else 0)
