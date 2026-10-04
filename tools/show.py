#!/usr/bin/env python3
"""Shows a piece of the listing of a bank.

    python3 tools/show.py <bank> 0x4629 0x4680     (a range)
    python3 tools/show.py <bank> 0x4629 [before] [after]

It is for looking at the code while commenting it, without dumping half a
file to the console. The bank is 00..15: here each one has its own listing and
its own org, so the same address shows up in several of them.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    bank = sys.argv[1].zfill(2)
    asm = os.path.join(ROOT, "src", "nemesis_p%s.asm" % bank)
    lines = open(asm, encoding="utf-8").read().splitlines()
    addrs = []
    for i, l in enumerate(lines):
        m = re.search(r"	;\s?([0-9a-f]{4})(?:\s|$)", l)
        addrs.append((int(m.group(1), 16), i) if m else (None, i))
    a = int(sys.argv[2], 0)
    if len(sys.argv) > 3 and sys.argv[3].startswith("0x"):
        b = int(sys.argv[3], 0)
        start = next((i for d, i in addrs if d is not None and d >= a), 0)
        end = next((i for d, i in addrs if d is not None and d >= b), len(lines))
    else:
        before = int(sys.argv[3]) if len(sys.argv) > 3 else 6
        after = int(sys.argv[4]) if len(sys.argv) > 4 else 30
        center = next((i for d, i in addrs if d is not None and d >= a), 0)
        start, end = max(0, center - before), min(len(lines), center + after)
    while start > 0 and re.match(r"^[A-Za-z_][\w]*:", lines[start - 1]):
        start -= 1
    print("\n".join(lines[start:end]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
