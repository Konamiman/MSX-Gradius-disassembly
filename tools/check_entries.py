#!/usr/bin/env python3
"""No entry point may fall inside a range declared as data.

Why this exists. The costliest contamination in this project was not caught by
any of the checks that existed at the time: 41 of the 114 entry points of the
game block fell inside the tiles and the sprites. The tracer went in to
disassemble drawings, the coverage went up from 24.6% to 61.6%, and everything
else stayed green:

  - the reassembly, because the bytes do not change: only how they are read;
  - the budget, because a byte misread as code also has an owner;
  - check_trace.py, because it only watches the ranges in the .nocode file,
    and the graphics were not declared there.

In other words: the project contradicted itself (the same binary declared as
graphics in one file and as code in another) and no tool was looking at it.
This one does.

Usage: check_entries.py <src/X.entries> <src/X.notes> [src/X.nocode]
"""
import re
import sys

RANGE = re.compile(r"^D\s+0x([0-9A-Fa-f]+)\s+0x([0-9A-Fa-f]+)\s+(.*)$")
NOCODE = re.compile(r"^0x([0-9A-Fa-f]+)\s+0x([0-9A-Fa-f]+)\s+(.*)$")
ENTRY = re.compile(r"^0x([0-9A-Fa-f]{4})\s+(\S+)")


def ranges(path, rx):
    out = []
    try:
        f = open(path, encoding="utf-8")
    except OSError:
        return out
    for ln in f:
        if ln.lstrip().startswith("#"):
            continue
        m = rx.match(ln.strip())
        if m:
            out.append((int(m.group(1), 16), int(m.group(2), 16), m.group(3).strip()))
    return out


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 2
    entries_path, notes_path = argv[1], argv[2]
    zones = ranges(notes_path, RANGE)
    if len(argv) > 3:
        zones += ranges(argv[3], NOCODE)

    entries = []
    for ln in open(entries_path, encoding="utf-8"):
        if ln.lstrip().startswith("#"):
            continue
        m = ENTRY.match(ln.strip())
        if m:
            entries.append((int(m.group(1), 16), m.group(2)))

    bad = []
    for a, name in entries:
        for start, end, text in zones:
            if start <= a < end:
                bad.append((a, name, start, end, text))
                break

    print("  %d entry points against %d declared data ranges"
          % (len(entries), len(zones)))
    if not bad:
        print("  OK: no entry point falls inside a data zone")
        return 0

    print()
    print("  CONTRADICTION: %d entry points fall inside declared data."
          % len(bad))
    print("  Either the entry point is wrong, or the range is. Both cannot be")
    print("  true, and as long as they are, the published listing lies.")
    print()
    for a, name, start, end, text in bad:
        print("    0x%04X %-24s inside 0x%04X-0x%04X  %s"
              % (a, name, start, end, text[:44]))
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
