#!/usr/bin/env python3
"""Cartridge budget: not one byte unexplained, summed over the 16 banks.

Why this check and not the percentage of traced code: a good part of these
128 KB is data (stage maps, graphics, music), so a low code percentage sounds
like half-done work when it may be complete. What really measures progress is
that every byte is one of these two things:

  - code that the tracer really reaches by following the flow from the entry
    points, or
  - a byte inside a data range IDENTIFIED with a D directive in the notes file
    of its bank, that is, with a name and an explanation.

And IT IS A DIFFERENT CHECK FROM THE REPRODUCIBILITY ONE. A byte can reassemble
perfectly and be unexplained; or worse, be wrongly explained: if some graphics
are marked as code, the reassembled binary still comes out identical (the bytes
do not change, only how they are read) and the listing lies all the same.

WHAT CHANGES COMPARED TO A 16 KB CARTRIDGE: here there are 16 banks of 8 KB
and each one has its own org (tools/banks.py), its own trace and its own
notes. The budget is done bank by bank and summed. Addresses repeat across
banks (0x6000 is the start of 1, of 4, of 7...), so a D range is only valid
for the bank in whose notes it is.

Usage: budget.py <work_dir> <src_dir> [--per-bank]
"""
import json
import os
import sys

from banks import org, bank_name, BANK_SIZE, N_BANKS

UNEXPLAINED, CODE, DATA = 0, 1, 2


def notes_ranges(path):
    """The data ranges declared with the D directive in the .notes file."""
    out = []
    if not os.path.exists(path):
        return out
    for ln in open(path, encoding="utf-8"):
        ln = ln.strip()
        if not ln.startswith("D "):
            continue
        p = ln.split(None, 3)
        out.append((int(p[1], 0), int(p[2], 0)))
    return out


def classify(work, src, p):
    """Marks each byte of bank p as code, named data, or nothing."""
    state = bytearray(BANK_SIZE)
    ORG = org(p)
    trace = os.path.join(work, bank_name(p) + ".trace.json")
    if os.path.exists(trace):
        for kind, a, b in json.load(open(trace))["blocks"]:
            if kind != "c":
                continue
            for i in range(max(0, a - ORG), min(BANK_SIZE, b - ORG)):
                state[i] = CODE
    for a, b in notes_ranges(os.path.join(src, bank_name(p) + ".notes")):
        for i in range(max(0, a - ORG), min(BANK_SIZE, b - ORG)):
            if state[i] == UNEXPLAINED:
                state[i] = DATA
    return state


def gaps(state, ORG):
    """Groups the unexplained bytes into ranges, so they can be looked at."""
    out, start = [], None
    for i, v in enumerate(state):
        if v == UNEXPLAINED and start is None:
            start = i
        elif v != UNEXPLAINED and start is not None:
            out.append((ORG + start, ORG + i))
            start = None
    if start is not None:
        out.append((ORG + start, ORG + BANK_SIZE))
    return out


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    work, src = sys.argv[1], sys.argv[2]
    detail = "--per-bank" in sys.argv
    TOTAL = BANK_SIZE * N_BANKS

    tc = td = ts = 0
    pending = []
    print("  %-7s %-6s %8s %8s %8s" % ("bank", "org", "code", "data", "unexpl"))
    print("  " + "-" * 42)
    for p in range(N_BANKS):
        state = classify(work, src, p)
        c, d, s = state.count(CODE), state.count(DATA), state.count(UNEXPLAINED)
        tc += c
        td += d
        ts += s
        print("  %-7s %#06x %8d %8d %8d" % (bank_name(p), org(p), c, d, s))
        for a, b in gaps(state, org(p)):
            pending.append((p, a, b))
    print("  " + "=" * 42)
    print()
    print("  %-24s %7s %8s" % ("", "bytes", "of total"))
    print("  " + "-" * 42)
    for label, n in (("traced code", tc),
                     ("identified data", td),
                     ("unexplained", ts)):
        print("  %-24s %7d %7.2f %%" % (label, n, 100.0 * n / TOTAL))
    print("  " + "=" * 42)
    print("  %-24s %7d %7.2f %%" % ("explained", tc + td, 100.0 * (tc + td) / TOTAL))

    if pending:
        print()
        print("  Unexplained, by range:")
        for p, a, b in pending:
            print("    %s 0x%04X..0x%04X  (%d bytes)" % (bank_name(p), a, b - 1, b - a))
        print()
        print("  Each of these ranges has to end up inside a D directive")
        print("  in the notes file of ITS bank, with an explanation of")
        print("  what it is and how that is known.")
        return 1

    print()
    print("  OK: not one byte of the cartridge unassigned")
    return 0


if __name__ == "__main__":
    sys.exit(main())
