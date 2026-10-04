#!/usr/bin/env python3
"""Checks ALL the areas declared as data against what the tracer believes.

Why it is needed, and why check_trace.py is not enough: that one watches the
areas in the .nocode file, which are a handful. But the real data areas are
declared with `D` directives in the notes files, and there are dozens of them.
If a badly placed seed puts the tracer inside one of them, the listing
disassembles data as if it were instructions and the coverage goes up by
counting lies.

This is not hypothetical. In this series of disassemblies, a badly placed seed
once got 95 % of a soundtrack read as code, and it was the THIRD time a
project published a coverage figure inflated by the same kind of error.

What it does: for each `D` range in the notes file, it looks at how many of
its bytes fall in blocks that the trace marks as code, and warns. A small
overlap can be legitimate (a table that starts right where a routine ends, a
range declared with some slack), so the results are sorted by severity and the
percentage is given, which is what tells a border byte apart from a whole area
misread.

Usage:  check_data_as_code.py <work_dir> <src_dir> [--threshold N]
Exit code 1 if any area exceeds the threshold (16 bytes by default).
"""
import json
import os
import re
import sys

from banks import bank_name, N_BANKS

# One module per MegaROM bank: p00..p15, each with its own trace and notes.
# Addresses repeat across banks, so the check is done bank by bank, never
# mixing the notes of one with the trace of another.
MODULES = tuple(bank_name(p) for p in range(N_BANKS))


def declarations(notes):
    """The `D 0xAAAA 0xBBBB description` ranges in the notes file."""
    if not os.path.exists(notes):
        return []
    out = []
    for line in open(notes, encoding="utf-8"):
        m = re.match(r"D 0x([0-9A-Fa-f]{4}) 0x([0-9A-Fa-f]{4})\s*(.*)", line)
        if m:
            out.append((int(m.group(1), 16), int(m.group(2), 16),
                        m.group(3).strip()))
    return out


def code_ranges(trace):
    with open(trace, encoding="utf-8") as f:
        d = json.load(f)
    return [(a, b) for t, a, b in d["blocks"] if t == "c"]


def main(work, src, *rest):
    threshold = 16
    for a in rest:
        if a.startswith("--threshold"):
            threshold = int(a.split("=")[1])

    suspects = []
    total_zones = 0
    for m in MODULES:
        trace = os.path.join(work, m + ".trace.json")
        notes = os.path.join(src, m + ".notes")
        if not os.path.exists(trace):
            continue
        blocks = code_ranges(trace)
        for start, end, desc in declarations(notes):
            total_zones += 1
            overlap = sum(min(b, end) - max(a, start)
                          for a, b in blocks if min(b, end) > max(a, start))
            if overlap:
                suspects.append((overlap, 100.0 * overlap / max(1, end - start),
                                 m, start, end, desc))

    print("Checking %d declared data zones against the trace." % total_zones)
    if not suspects:
        print("  OK: no zone declared as data shows up as code")
        return 0

    serious = [s for s in suspects if s[0] >= threshold]
    print("  %d zones overlap with code; %d above the threshold (%d B)" % (
        len(suspects), len(serious), threshold))
    print()
    for overlap, pct, m, start, end, desc in sorted(suspects, reverse=True)[:20]:
        mark = "SERIOUS" if overlap >= threshold else "  graze"
        print("  %s %-7s 0x%04X-0x%04X  %5d B of %5d as code (%5.1f %%)  %s" % (
            mark, m, start, end - 1, overlap, end - start, pct, desc[:44]))
    if serious:
        print()
        print("  A whole zone read as code is FALSE coverage: there is a")
        print("  seed inside it. A graze of a few bytes is usually a range")
        print("  declared with some slack, and it is fixed by adjusting the range.")
    return 1 if serious else 0


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:]))
