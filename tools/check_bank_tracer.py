#!/usr/bin/env python3
"""The two traces have to say the same thing.

This project has two tracers, on purpose:

  - tools/bank_tracer.py walks the WHOLE CARTRIDGE, keeping track of which bank
    is in each slot. It is the one that really knows where the flow goes, but
    its output is not published: what gets published is hand-written files.
  - tools/z80trace.py traces EACH BANK separately, starting from the entries
    already written in src/pNN.entries. It is the one that generates the
    listing.

If the .entries files are complete, both have to mark EXACTLY the same bytes
as code. When they do not match, it is one of two things:

  - there are bytes only the whole-cartridge tracer sees: an entry is missing
    from the .entries, and the listing publishes as data something that is
    code;
  - there are bytes only the bank tracer sees: an entry in the .entries leads
    where it should not, or a dispatcher table has been cut short, and the
    listing publishes as code something nobody executes.

Both are errors, and the byte-for-byte reassembly catches neither.

Usage: check_bank_tracer.py <rom> <work_dir> <src_dir>
"""
import json
import os
import sys

from bank_tracer import full_trace
from banks import ORG, BANK_SIZE, N_BANKS, bank_name


def ranges(marks, org):
    """Groups a bytearray of marks into [ini, fin) ranges."""
    out, start = [], None
    for i in range(BANK_SIZE + 1):
        v = marks[i] if i < BANK_SIZE else 0
        if v and start is None:
            start = i
        elif not v and start is not None:
            out.append((org + start, org + i))
            start = None
    return out


def main(rom_path, work, src):
    rom = open(rom_path, "rb").read()
    t, _sizes = full_trace(rom, src)
    failures = 0
    print("  %-5s %9s %9s %9s %9s" % ("bank", "bank_tracer.py", "z80trace",
                                      "only B", "only Z"))
    print("  " + "-" * 48)
    details = []
    for p in range(N_BANKS):
        path = os.path.join(work, bank_name(p) + ".trace.json")
        z = bytearray(BANK_SIZE)
        if os.path.exists(path):
            for k, a, b in json.load(open(path))["blocks"]:
                if k == "c":
                    for i in range(max(0, a - ORG[p]),
                                   min(BANK_SIZE, b - ORG[p])):
                        z[i] = 1
        b_ = t.marked[p]
        only_b = bytearray((x and not y) for x, y in zip(b_, z))
        only_z = bytearray((y and not x) for x, y in zip(b_, z))
        nb, nz = sum(only_b), sum(only_z)
        print("  %-5s %9d %9d %9d %9d" % (bank_name(p), sum(b_), sum(z), nb, nz))
        if nb or nz:
            failures += 1
            details.append((p, ranges(only_b, ORG[p]), ranges(only_z, ORG[p])))

    if not failures:
        print("\n  OK: both traces mark the same bytes as code")
        return 0

    print()
    for p, rb, rz in details:
        if rb:
            print("  %s: ONLY the whole-cartridge trace (missing entry):" % bank_name(p))
            for a, b in rb[:12]:
                print("      %04X..%04X  (%d bytes)" % (a, b - 1, b - a))
            if len(rb) > 12:
                print("      ... and %d more ranges" % (len(rb) - 12))
        if rz:
            print("  %s: ONLY the bank trace (extra entry or short table):"
                  % bank_name(p))
            for a, b in rz[:12]:
                print("      %04X..%04X  (%d bytes)" % (a, b - 1, b - a))
            if len(rz) > 12:
                print("      ... and %d more ranges" % (len(rz) - 12))
    print("\n  FAIL: %d banks in which the two traces do not match" % failures)
    return 1


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:4]))
